import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/user_service.dart';
import 'package:meachou/components/delete-confirmation/delete-confirmation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  String _loadingOperation = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FontAwesomeIcons.cog,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Configurações',
                          style: GoogleFonts.lato(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildOption(
                        context,
                        icon: FontAwesomeIcons.userSlash,
                        title: 'Deletar Conta',
                        onTap: () {
                          if (!_isLoading) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Text(
                                    'Confirmar Deleção',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                      'Tem certeza que deseja deletar sua conta?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                    ConfirmActionComponent(
                                      actionTitle: 'Deletar Conta',
                                      confirmButtonText: 'Confirmar',
                                      onConfirm: () async {
                                        Navigator.of(context)
                                            .pop(); // Fechar o diálogo
                                        await _deleteAccount(context);
                                      },
                                      buttonColor:
                                          Colors.redAccent.withOpacity(0.7),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        color: Colors.redAccent.withOpacity(0.7),
                        enabled: _loadingOperation != 'delete',
                      ),
                      const SizedBox(height: 10),
                      _buildOption(
                        context,
                        icon: FontAwesomeIcons.signOutAlt,
                        title: 'Sair da Conta',
                        onTap: () async {
                          if (!_isLoading) {
                            setState(() {
                              _isLoading = true;
                              _loadingOperation = 'logout';
                            });
                            AuthService authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            await authService.logout();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                            setState(() {
                              _isLoading = false;
                              _loadingOperation = '';
                            });
                          }
                        },
                        color: Colors.blueAccent.withOpacity(0.7),
                        enabled: _loadingOperation != 'logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Center(
                child: Container(
                  child: const LoadingDots(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool enabled = true,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _loadingOperation = 'delete';
    });

    try {
      UserService userService = UserService();
      final response = await userService.deleteUser();
      if (response['statusCode'] == 200) {
        AuthService authService =
            Provider.of<AuthService>(context, listen: false);
        await authService.logout();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        final errorMessage =
            response['body']['message'] ?? 'Failed to delete user';
        _showErrorToast(context, errorMessage);
      }
    } catch (error) {
      _showErrorToast(context, error.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _loadingOperation = '';
      });
    }
  }

  void _showErrorToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
