import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final IconData icon;
  final Color? iconColor;
  final bool isNumeric;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const CustomTextFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.icon,
    this.iconColor,
    this.isNumeric = false,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: maxLength != null
            ? [LengthLimitingTextInputFormatter(maxLength)]
            : null,
        validator: validator,
        onChanged: onChanged,
        enabled: enabled,
      ),
    );
  }
}

class CustomDropdownFormField extends StatelessWidget {
  final String labelText;
  final String initialValue;
  final ValueChanged<String?> onChanged;
  final IconData icon;
  final Color? iconColor;
  final List<String> items;
  final bool enabled;

  const CustomDropdownFormField({
    Key? key,
    required this.labelText,
    required this.initialValue,
    required this.onChanged,
    required this.icon,
    this.iconColor,
    required this.items,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: initialValue,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: enabled ? onChanged : null,
        disabledHint: Text(initialValue),
      ),
    );
  }
}

class CustomPhoneFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final IconData icon;
  final Color? iconColor;
  final String? Function(String?)? validator;

  const CustomPhoneFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.icon,
    this.iconColor,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) {
              return newValue.copyWith(text: '');
            }
            final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
            final length = digitsOnly.length;

            String newText;
            if (length <= 2) {
              newText = '($digitsOnly';
            } else if (length <= 6) {
              newText =
                  '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
            } else if (length <= 10) {
              newText =
                  '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
            } else {
              newText =
                  '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
            }

            return newValue.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: newText.length),
            );
          }),
        ],
        validator: validator,
      ),
    );
  }
}

class CustomEmailFormField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final IconData icon;
  final Color? iconColor;
  final String? Function(String?)? validator;

  const CustomEmailFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.icon,
    this.iconColor,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: iconColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: validator,
      ),
    );
  }
}

class CustomSocialNetworksFormField extends StatefulWidget {
  final String labelText;
  final List<String> socialNetworks;
  final IconData icon;
  final Color iconColor;
  final String? Function(String?)? validator;

  const CustomSocialNetworksFormField({
    Key? key,
    required this.labelText,
    required this.socialNetworks,
    required this.icon,
    required this.iconColor,
    this.validator,
  }) : super(key: key);

  @override
  _CustomSocialNetworksFormFieldState createState() =>
      _CustomSocialNetworksFormFieldState();
}

class _CustomSocialNetworksFormFieldState
    extends State<CustomSocialNetworksFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.labelText,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Adicione um link de rede social',
                    prefixIcon: Icon(widget.icon, color: widget.iconColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_controller.text.isNotEmpty &&
                      (widget.validator == null ||
                          widget.validator!(_controller.text) == null)) {
                    setState(() {
                      widget.socialNetworks.add(_controller.text);
                      _controller.clear();
                    });
                  }
                },
              ),
            ],
          ),
          Wrap(
            children: widget.socialNetworks
                .map((social) => Chip(
                      label: Text(social),
                      onDeleted: () {
                        setState(() {
                          widget.socialNetworks.remove(social);
                        });
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class CustomPhotoPickerField extends StatefulWidget {
  final String labelText;
  final List<String> photos;
  final Function onTap;
  final IconData icon;
  final Color iconColor;

  const CustomPhotoPickerField({
    Key? key,
    required this.labelText,
    required this.photos,
    required this.onTap,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  _CustomPhotoPickerFieldState createState() => _CustomPhotoPickerFieldState();
}

class _CustomPhotoPickerFieldState extends State<CustomPhotoPickerField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.labelText,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: widget.photos.length < 5 ? () => widget.onTap() : null,
            icon: Icon(widget.icon, color: widget.iconColor),
            label: const Text('Selecionar fotos'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
            ),
          ),
          Wrap(
            children: widget.photos
                .map(
                  (photo) => Stack(
                    children: [
                      Image.file(File(photo), width: 100, height: 100),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.photos.remove(photo);
                            });
                          },
                          child: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckboxListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CheckboxListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
