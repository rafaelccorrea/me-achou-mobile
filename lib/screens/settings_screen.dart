import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/user_service.dart';
import 'package:meachou/screens/login_screen.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/components/delete-confirmation/delete-confirmation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _loadingOperation = '';
  late AnimationController _animationController;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Garantir que o AuthService seja inicializado aqui
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildOption(
                        context,
                        icon: FontAwesomeIcons.userSlash,
                        title: 'Deletar Conta',
                        onTap: _isLoading
                            ? null
                            : () => _showDeleteConfirmation(context),
                        color: Colors.redAccent.withOpacity(0.7),
                        enabled: _loadingOperation != 'delete',
                      ),
                      const SizedBox(height: 20),
                      _buildOption(
                        context,
                        icon: FontAwesomeIcons.signOutAlt,
                        title: 'Sair da Conta',
                        onTap: _isLoading ? null : _logout,
                        color: Colors.blueAccent.withOpacity(0.7),
                        enabled: _loadingOperation != 'logout',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
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
            ScaleTransition(
              scale: _animationController,
              child: const Icon(
                FontAwesomeIcons.cog,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              'Configurações',
              style: GoogleFonts.lato(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    required Color color,
    bool enabled = true,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: GoogleFonts.lato(fontSize: 20, color: Colors.black87),
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingDots(),
            const SizedBox(height: 10),
            Text(
              _loadingOperation == 'delete'
                  ? 'Deletando conta...'
                  : 'Saindo...',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmar Deleção',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: const Text('Tem certeza que deseja deletar sua conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            ConfirmActionComponent(
              actionTitle: 'Deletar Conta',
              confirmButtonText: 'Confirmar',
              onConfirm: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              buttonColor: Colors.redAccent.withOpacity(0.7),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingOperation = 'delete';
    });

    try {
      UserService userService = UserService();
      final response = await userService.deleteUser();
      if (response.statusCode == 200) {
        await _authService.logout();

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? 'Falha ao deletar usuário';
        _showErrorToast(errorMessage);
      }
    } catch (error) {
      _showErrorToast(error.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingOperation = '';
      });
    }
  }

  Future<void> _logout() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingOperation = 'logout';
    });
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      _showErrorToast(error.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingOperation = '';
      });
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
