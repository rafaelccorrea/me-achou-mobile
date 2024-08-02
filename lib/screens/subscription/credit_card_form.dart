import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meachou/screens/home/home_screen.dart';
import 'package:meachou/services/subscription_client.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:ui'; // Necessário para o ImageFilter

class CreditCardForm extends StatefulWidget {
  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final MaskedTextController _cpfCnpjController =
      MaskedTextController(mask: '000.000.000-00');
  final TextEditingController _holderNameController = TextEditingController();
  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final MaskedTextController _expiryMonthController =
      MaskedTextController(mask: '00');
  final MaskedTextController _expiryYearController =
      MaskedTextController(mask: '0000');
  final MaskedTextController _ccvController = MaskedTextController(mask: '000');
  bool _isLoading = false;

  final CreditCardValidator _ccValidator = CreditCardValidator();
  final SubscriptionClient _subscriptionClient = SubscriptionClient();
  final AuthService _authService = AuthService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String cpfCnpj = _cpfCnpjController.text.replaceAll(RegExp(r'\D'), '');
      String cardNumber =
          _cardNumberController.text.replaceAll(RegExp(r'\D'), '');

      try {
        await _subscriptionClient.createSubscription(
          cpfCnpj,
          _holderNameController.text,
          cardNumber,
          _expiryMonthController.text,
          _expiryYearController.text,
          _ccvController.text,
        );

        await _authService.refreshToken();

        setState(() {
          _isLoading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    './assets/animation/payment.json',
                    height: 150,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Assinatura realizada com sucesso!'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  String? _validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF';
    } else if (!CPFValidator.isValid(value)) {
      return 'CPF inválido';
    }
    return null;
  }

  String? _validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o número do cartão de crédito';
    } else if (!_ccValidator.validateCCNum(value.replaceAll(' ', '')).isValid) {
      return 'Número do cartão inválido';
    }
    return null;
  }

  String? _validateExpiryMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o mês de expiração';
    }
    int? month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Mês de expiração inválido';
    }
    return null;
  }

  String? _validateExpiryYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o ano de expiração';
    }
    int? year = int.tryParse(value);
    if (year == null || year < DateTime.now().year) {
      return 'Ano de expiração inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adicionar detalhes do cartão',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cpfCnpjController,
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateCpf,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _holderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Titular',
                      prefixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do titular';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Número do Cartão',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateCreditCard,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryMonthController,
                          decoration: const InputDecoration(
                            labelText: 'Mês de Expiração',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateExpiryMonth,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _expiryYearController,
                          decoration: const InputDecoration(
                            labelText: 'Ano de Expiração',
                            prefixIcon: Icon(Icons.date_range),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _validateExpiryYear,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ccvController,
                    decoration: const InputDecoration(
                      labelText: 'CCV',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o CCV';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Assinar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const Center(
              child: LoadingDots(),
            ),
          ),
      ],
    );
  }
}
