import 'package:flutter/material.dart';

class ConfirmActionComponent extends StatefulWidget {
  final String actionTitle;
  final String confirmButtonText;
  final Future<void> Function() onConfirm;
  final Color buttonColor;

  const ConfirmActionComponent({
    Key? key,
    required this.actionTitle,
    required this.confirmButtonText,
    required this.onConfirm,
    required this.buttonColor,
  }) : super(key: key);

  @override
  _ConfirmActionComponentState createState() => _ConfirmActionComponentState();
}

class _ConfirmActionComponentState extends State<ConfirmActionComponent> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onConfirm();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(widget.buttonColor),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handleConfirm,
            child: Text(
              widget.confirmButtonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
