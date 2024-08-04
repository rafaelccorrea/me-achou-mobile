import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:diacritic/diacritic.dart';

class StoreFilterForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilter;
  final Function onClearFilters;
  final Map<String, dynamic> initialFilters;

  const StoreFilterForm({
    Key? key,
    required this.onFilter,
    required this.onClearFilters,
    required this.initialFilters,
  }) : super(key: key);

  @override
  _StoreFilterFormState createState() => _StoreFilterFormState();
}

class _StoreFilterFormState extends State<StoreFilterForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBusinessSector;
  String? _selectedCity;
  String? _selectedRegion;
  int? _selectedRankingMin;
  int? _selectedRankingMax;
  bool _delivery = false;
  bool _inHomeService = false;
  List<String> _cities = [];
  final TextEditingController _cityController = TextEditingController();
  final List<String> _sectors = [
    'Alimentos',
    'Roupas',
    'Tecnologia',
    'Serviços',
    'Educação'
  ];
  final List<Map<String, String>> _regions = [
    {'display': 'Centro', 'value': 'CENTRO'},
    {'display': 'Zona Norte', 'value': 'ZONA_NORTE'},
    {'display': 'Zona Sul', 'value': 'ZONA_SUL'},
    {'display': 'Zona Leste', 'value': 'ZONA_LESTE'},
    {'display': 'Zona Oeste', 'value': 'ZONA_OESTE'},
  ];
  final List<String> _rankingOptions = ['1', '2', '3', '4', '5', '6', '7'];

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _loadInitialFilters();
  }

  void _loadInitialFilters() {
    setState(() {
      _selectedBusinessSector = widget.initialFilters['business_sector'];
      _selectedCity = widget.initialFilters['city'];
      _selectedRegion = widget.initialFilters['region'];
      _selectedRankingMin = widget.initialFilters['ranking_min'];
      _selectedRankingMax = widget.initialFilters['ranking_max'];
      _delivery = widget.initialFilters['delivery'] ?? false;
      _inHomeService = widget.initialFilters['in_home_service'] ?? false;
    });

    if (_selectedCity != null) {
      _cityController.text = _selectedCity!;
    }
  }

  Future<void> _fetchCities() async {
    final response = await http.get(
      Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/SP/municipios'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        _cities = data.map((city) => city['nome'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros de lojas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.close, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    _buildCategory(
                      'Categorias',
                      _sectors,
                      _selectedBusinessSector,
                      (value) {
                        setState(() {
                          _selectedBusinessSector =
                              _selectedBusinessSector == value ? null : value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildCategory(
                      'Região',
                      _regions.map((region) => region['display']!).toList(),
                      _selectedRegion != null
                          ? _regions.firstWhere((region) =>
                              region['value'] == _selectedRegion)['display']
                          : null,
                      (value) {
                        setState(() {
                          if (value != null) {
                            final selectedRegion = _regions.firstWhere(
                                (region) => region['display'] == value);
                            _selectedRegion =
                                _selectedRegion == selectedRegion['value']
                                    ? null
                                    : selectedRegion['value'];
                          } else {
                            _selectedRegion = null;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    _buildCityField(),
                    const SizedBox(height: 16.0),
                    _buildRankingCategory(
                        'Classificação mínima',
                        _getFilteredRankingOptions(
                            maxValue: _selectedRankingMax),
                        _selectedRankingMin?.toString(), (value) {
                      setState(() {
                        _selectedRankingMin =
                            _selectedRankingMin == int.tryParse(value!)
                                ? null
                                : int.tryParse(value);
                      });
                    }),
                    const SizedBox(height: 16.0),
                    _buildRankingCategory(
                        'Classificação máxima',
                        _getFilteredRankingOptions(
                            minValue: _selectedRankingMin),
                        _selectedRankingMax?.toString(), (value) {
                      setState(() {
                        _selectedRankingMax =
                            _selectedRankingMax == int.tryParse(value!)
                                ? null
                                : int.tryParse(value);
                        if (_selectedRankingMax != null &&
                            (_selectedRankingMin == null ||
                                _selectedRankingMin! > _selectedRankingMax!)) {
                          _selectedRankingMin = _selectedRankingMax;
                        }
                      });
                    }),
                    const SizedBox(height: 16.0),
                    _buildCheckbox('Faz entrega', _delivery, (value) {
                      setState(() {
                        _delivery = value!;
                      });
                    }),
                    _buildCheckbox('Serviço em domicílio', _inHomeService,
                        (value) {
                      setState(() {
                        _inHomeService = value!;
                      });
                    }),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _clearFilters();
                              widget.onClearFilters();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text(
                              'Limpar Filtros',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _applyFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 12.0),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: const Text(
                              'Aplicar Filtro',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyFilter() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> filters = {
        'business_sector': _selectedBusinessSector,
        'delivery': _delivery,
        'in_home_service': _inHomeService,
        'city': _selectedCity ?? 'Marília',
        'region': _selectedRegion,
        'ranking_min': _selectedRankingMin,
        'ranking_max': _selectedRankingMax,
      };

      widget.onFilter(filters);
      Navigator.of(context).pop();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedBusinessSector = null;
      _selectedCity = null;
      _cityController.clear();
      _selectedRegion = null;
      _selectedRankingMin = null;
      _selectedRankingMax = null;
      _delivery = false;
      _inHomeService = false;
    });
  }

  List<String> _getFilteredRankingOptions({int? minValue, int? maxValue}) {
    int min = minValue ?? 1;
    int max = maxValue ?? 7;
    return _rankingOptions.where((option) {
      int value = int.parse(option);
      return value >= min && value <= max;
    }).toList();
  }

  Widget _buildCategory(String title, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged,
      {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                },
                selectedColor: Colors.blueAccent.shade100,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRankingCategory(String title, List<String> options,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? option : null);
                },
                selectedColor: Colors.blueAccent.shade100,
                labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue,
      List<String> items, ValueChanged<String?> onChanged,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedValue,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          );
        }).toList(),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, selecione $label';
                }
                return null;
              }
            : null,
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildCityField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'Cidade',
            labelStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.lightBlueAccent),
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.lightBlueAccent),
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        suggestionsCallback: (pattern) {
          final normalizedPattern = removeDiacritics(pattern.toLowerCase());
          return _cities.where((city) =>
              removeDiacritics(city.toLowerCase()).contains(normalizedPattern));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            _selectedCity = suggestion;
            _cityController.text = suggestion;
          });
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor, selecione uma cidade';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
          Text(label, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}

void showStoreFilterForm(BuildContext context,
    {required Function(Map<String, dynamic>) onFilter,
    required Function onClearFilters,
    required Map<String, dynamic> initialFilters}) {
  showModalBottomSheet(
    context: context,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: StoreFilterForm(
              onFilter: onFilter,
              onClearFilters: onClearFilters,
              initialFilters: initialFilters,
            ),
          ),
        ),
      );
    },
  );
}
