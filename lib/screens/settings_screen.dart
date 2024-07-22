import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/user_service.dart';

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
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.white],
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
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Configurações',
                          style: GoogleFonts.lato(
                            fontSize: 28, // Aumentando o tamanho da fonte
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      _buildOption(
                        context,
                        icon: FontAwesomeIcons.trash,
                        title: 'Deletar Conta',
                        onTap: () async {
                          if (!_isLoading) {
                            setState(() {
                              _isLoading = true;
                              _loadingOperation = 'delete';
                            });
                            await _deleteAccount(context);
                            setState(() {
                              _isLoading = false;
                              _loadingOperation = '';
                            });
                          }
                        },
                        color: Colors.redAccent,
                        enabled: _loadingOperation != 'delete',
                      ),
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
                        color: Colors.blueAccent,
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
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: LoadingDots(),
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
