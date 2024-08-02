import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/store/subscription_screen.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/stores_service.dart';
import './widgets/custom_widgets.dart';

class CreateStoreScreen extends StatefulWidget {
  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  final StoreService _storeService = StoreService();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  int _currentStep = 0;
  bool _isLoading = false;
  File? _profileImage;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _whatsappPhoneController =
      TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _serviceValuesController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _addressNumberController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();

  final MaskedTextController _postalCodeController =
      MaskedTextController(mask: '00000-000');

  String? businessSector = 'Alimento';
  List<String> businessSectors = [
    'Alimento',
    'Tecnologia',
    'Vestuário',
    'Saúde',
    'Educação'
  ];
  List<String> socialNetworks = [];
  List<String> photos = [];
  bool delivery = false;
  bool inHomeService = false;

  Future<void> _fetchBusinessSectors() async {
    // Implementar chamada à API para buscar ramos de atuação, se disponível
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final storeData = {
        'company_name': _companyNameController.text,
        'about': _aboutController.text,
        'business_sector': businessSector!,
        'contact_phone': _contactPhoneController.text,
        'whatsapp_phone': _whatsappPhoneController.text,
        'website': _websiteController.text,
        'social_networks': socialNetworks,
        'service_values': double.parse(
          _serviceValuesController.text
              .replaceAll('R\$', '')
              .replaceAll(',', '.'),
        ),
        'email': _emailController.text,
        'photos': photos.map((filePath) {
          final file = File(filePath);
          return {
            'fieldname': 'photos',
            'originalname': file.path.split('/').last,
            'encoding': '7bit',
            'buffer': base64Encode(file.readAsBytesSync()),
            'size': file.lengthSync(),
          };
        }).toList(),
        'delivery': delivery,
        'in_home_service': inHomeService,
        'working_hours': _workingHoursController.text,
        'address': {
          'street': _streetController.text,
          'address_number': _addressNumberController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postal_code': _postalCodeController.text,
          'country': 'Brasil',
          'region': _regionController.text,
        }
      };

      final response = await _storeService.createStore(storeData);

      print('***************************** ${response.body}');

      if (response.statusCode == 201) {
        if (_profileImage != null) {
          try {
            final profileResponse =
                await _storeService.uploadProfileImage(_profileImage!);
            if (profileResponse.statusCode != 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Erro ao atualizar a foto de perfil!')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Erro ao atualizar a foto de perfil!')),
            );
          }
        }

        try {
          await _authService.refreshToken();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar o token!')),
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubscriptionScreen()),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar a loja!')),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeProfileImage() async {
    setState(() {
      _profileImage = null;
    });
  }

  Future<void> _pickImages() async {
    if (photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você só pode selecionar até 5 fotos.')),
      );
      return;
    }
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        final newPhotos = pickedFiles.map((file) => file.path).toList();
        if (photos.length + newPhotos.length <= 5) {
          photos.addAll(newPhotos);
        } else {
          final remainingSlots = 5 - photos.length;
          photos.addAll(newPhotos.take(remainingSlots));
        }
      });
    }
  }

  Future<void> _fetchAddressFromCep(String cep) async {
    final cleanedCep = cep.replaceAll('-', '');
    if (cleanedCep.isEmpty || cleanedCep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP inválido!')),
      );
      return;
    }

    final url = Uri.parse('https://viacep.com.br/ws/$cleanedCep/json/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['erro'] == null) {
        setState(() {
          _streetController.text = data['logradouro'] ?? '';
          _cityController.text = data['localidade'] ?? '';
          _stateController.text = data['uf'] ?? '';
          _regionController.text = data['bairro'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar o endereço!')),
      );
    }
  }

  bool _validateCurrentStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return true;
    }
    return false;
  }

  List<Widget> _buildStepContent(int step) {
    switch (step) {
      case 0:
        return [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color.fromARGB(24, 197, 208, 221),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informações da Empresa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _companyNameController,
                  labelText: 'Nome da empresa',
                  icon: FontAwesomeIcons.building,
                  iconColor: Colors.blue[800]!,
                  maxLength: 20,
                  validator: (value) {
                    if (value!.replaceAll(' ', '').length < 3 ||
                        value.replaceAll(' ', '').length > 20) {
                      return 'O nome deve ter entre 3 e 20 caracteres, sem espaços.';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _aboutController,
                  labelText: 'Descrição sobre a empresa',
                  icon: FontAwesomeIcons.infoCircle,
                  iconColor: Colors.grey,
                  maxLength: 150,
                  validator: (value) {
                    if (value!.length > 150) {
                      return 'A descrição não pode ter mais de 150 caracteres.';
                    }
                    return null;
                  },
                ),
                CustomDropdownFormField(
                  labelText: 'Ramo de atuação',
                  initialValue: businessSector!,
                  onChanged: (value) => setState(() => businessSector = value),
                  icon: FontAwesomeIcons.briefcase,
                  iconColor: Colors.brown,
                  items: businessSectors,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickProfileImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Imagem de Perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    if (_profileImage != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Stack(
                          children: [
                            Image.file(
                              _profileImage!,
                              width: 50,
                              height: 50,
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: _removeProfileImage,
                                child: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ];
      case 1:
        return [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color.fromARGB(24, 197, 208, 221),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contatos e Redes Sociais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomPhoneFormField(
                  controller: _contactPhoneController,
                  labelText: 'Telefone de contato',
                  icon: FontAwesomeIcons.phone,
                  iconColor: Colors.green[800]!,
                  validator: (value) {
                    return null; // Não obrigatório
                  },
                ),
                CustomPhoneFormField(
                  controller: _whatsappPhoneController,
                  labelText: 'Telefone WhatsApp',
                  icon: FontAwesomeIcons.whatsapp,
                  iconColor: Colors.green,
                  validator: (value) {
                    if (value!.isEmpty) return 'Campo obrigatório';
                    if (value.length < 14) return 'Número de telefone inválido';
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _websiteController,
                  labelText: 'Website',
                  icon: FontAwesomeIcons.globe,
                  iconColor: Colors.blue,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      const urlPattern =
                          r'^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$';
                      if (!RegExp(urlPattern).hasMatch(value)) {
                        return 'Por favor, insira um URL válido.';
                      }
                    }
                    return null;
                  },
                ),
                CustomSocialNetworksFormField(
                  labelText: 'Redes sociais',
                  socialNetworks: socialNetworks,
                  icon: FontAwesomeIcons.users,
                  iconColor: Colors.blue[800]!,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      const urlPattern =
                          r'^(https?:\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$';
                      if (!RegExp(urlPattern).hasMatch(value)) {
                        return 'Por favor, insira um URL válido.';
                      }
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _serviceValuesController,
                  labelText: 'Valores dos serviços',
                  icon: FontAwesomeIcons.dollarSign,
                  iconColor: Colors.green,
                  isNumeric: true,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        double.tryParse(value
                                .replaceAll('R\$', '')
                                .replaceAll(',', '.')) ==
                            null) {
                      return 'Por favor, insira um valor válido.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      _serviceValuesController.clear();
                      return;
                    }
                    final newValue = value.replaceAll(RegExp(r'[^\d]'), '');
                    final doubleValue = int.parse(newValue) / 100;
                    _serviceValuesController.value = TextEditingValue(
                      text:
                          'R\$${doubleValue.toStringAsFixed(2).replaceAll('.', ',')}',
                      selection: TextSelection.collapsed(
                          offset:
                              'R\$${doubleValue.toStringAsFixed(2).replaceAll('.', ',')}'
                                  .length),
                    );
                  },
                ),
                CustomEmailFormField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: FontAwesomeIcons.envelope,
                  iconColor: Colors.red,
                  validator: (value) {
                    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!regex.hasMatch(value!)) {
                      return 'Formato de email inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ];
      case 2:
        return [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color.fromARGB(24, 197, 208, 221),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endereço e Outros Detalhes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _postalCodeController,
                  labelText: 'CEP',
                  icon: FontAwesomeIcons.locationArrow,
                  iconColor: Colors.blue[300]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'CEP é obrigatório';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 9) {
                      _fetchAddressFromCep(value);
                    }
                  },
                ),
                CustomTextFormField(
                  controller: _streetController,
                  labelText: 'Rua',
                  icon: FontAwesomeIcons.road,
                  iconColor: Colors.grey[800]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rua é obrigatório';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _addressNumberController,
                  labelText: 'Número',
                  icon: FontAwesomeIcons.hashtag,
                  iconColor: Colors.grey[800]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Número é obrigatório';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _cityController,
                  labelText: 'Cidade',
                  icon: FontAwesomeIcons.city,
                  iconColor: Colors.blue[800]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cidade é obrigatório';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _stateController,
                  labelText: 'Estado',
                  icon: FontAwesomeIcons.map,
                  iconColor: Colors.green,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Estado é obrigatório';
                    }
                    return null;
                  },
                ),
                CustomTextFormField(
                  controller: _regionController,
                  labelText: 'Região',
                  icon: FontAwesomeIcons.mapMarkedAlt,
                  iconColor: Colors.brown,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Região é obrigatório';
                    }
                    return null;
                  },
                ),
                CustomPhotoPickerField(
                  labelText: 'Fotos do ambiente',
                  photos: photos,
                  onTap: _pickImages,
                  icon: FontAwesomeIcons.camera,
                  iconColor: Colors.purple,
                ),
                CustomCheckboxListTile(
                  title: 'Entrega',
                  value: delivery,
                  onChanged: (value) => setState(() => delivery = value!),
                ),
                CustomCheckboxListTile(
                  title: 'Serviço em domicílio',
                  value: inHomeService,
                  onChanged: (value) => setState(() => inHomeService = value!),
                ),
                CustomTextFormField(
                  controller: _workingHoursController,
                  labelText: 'Horário de funcionamento',
                  icon: FontAwesomeIcons.clock,
                  iconColor: Colors.orange,
                  validator: (value) {
                    return null; // Não obrigatório
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ];
      default:
        return [];
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Loja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.blueAccent,
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    color: Colors.white,
                    child: StepProgressIndicator(
                      totalSteps: 3,
                      currentStep: _currentStep + 1,
                      selectedColor: Colors.blueAccent,
                      unselectedColor: Colors.grey[200]!,
                      customStep: (index, color, _) => Container(
                        color: color,
                        height: 10.0,
                        width: 60.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ..._buildStepContent(_currentStep),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep -= 1;
                              _scrollToTop();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: Colors.white,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentStep < 2) {
                            if (_validateCurrentStep()) {
                              setState(() {
                                _currentStep += 1;
                                _scrollToTop();
                              });
                            }
                          } else {
                            _submitForm();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          backgroundColor: Colors.blueAccent,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          elevation: 5,
                        ),
                        child: Text(
                          _currentStep < 2 ? 'Próximo' : 'Enviar',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: LoadingDots()),
            ),
        ],
      ),
    );
  }
}
