import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meachou/services/user_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String token = '';
  String newPassword = '';
  bool isLoading = false;
  bool _passwordVisible = false;
  int timeRemaining = 300;
  late Timer _timer;
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeRemaining > 0) {
          timeRemaining--;
        } else {
          timer.cancel();
          Navigator.pushReplacementNamed(context, '/forgot_password');
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
    });

    _userService
        .resetPasswordEndpoint(widget.email, token, newPassword)
        .then((response) {
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Senha redefinida com sucesso',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        String errorMsg = responseBody['message'] ?? 'Erro ao redefinir senha';
        if (responseBody.containsKey('errors')) {
          errorMsg = responseBody['errors'].join(', ');
        }
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Erro ao redefinir senha: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    });
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'A senha não pode estar vazia';
    } else if (password.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  String? _validateToken(String? token) {
    final tokenRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (token == null || token.isEmpty) {
      return 'O token não pode estar vazio';
    } else if (!tokenRegExp.hasMatch(token)) {
      return 'Token inválido';
    }
    return null;
  }

  bool get _isFormValid {
    return _validatePassword(newPassword) == null &&
        _validateToken(token) == null;
  }

  @override
  Widget build(BuildContext context) {
    int minutes = timeRemaining ~/ 60;
    int seconds = timeRemaining % 60;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Container(
                constraints: BoxConstraints.expand(),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 160),
                        const Text(
                          'Me Achou',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Tempo restante para redefinição: $minutes:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              token = value;
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.vpn_key, color: Colors.white),
                            hintText: 'Token',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              newPassword = value;
                            });
                          },
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            hintText: 'Nova Senha',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isFormValid ? _resetPassword : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Redefinir Senha',
                            style: TextStyle(
                                fontSize: 18, color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
