import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/forgot_password_screen.dart';
import 'package:meachou/screens/home/home_screen.dart';
import 'package:meachou/screens/signup_screen.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _loading = false;
  bool _obscureText = true;
  bool _canCheckBiometrics = false;
  bool _isBiometricEnabled = false;
  bool _biometricLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
    _checkBiometrics();
    _attemptBiometricLogin();
  }

  Future<void> _loadBiometricPreference() async {
    String? isBiometricEnabled =
        await _secureStorage.read(key: 'isBiometricEnabled');
    setState(() {
      _isBiometricEnabled = isBiometricEnabled == 'true';
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _requestBiometricPermission() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.blueAccent),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Permissão de Biometria',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
        content: Text(
          'Deseja usar a biometria para login?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Não', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sim', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final availableBiometrics = await auth.getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          bool authenticated = await auth.authenticate(
            localizedReason: 'Autentique-se para habilitar a biometria',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );
          if (authenticated) {
            await _secureStorage.write(
                key: 'isBiometricEnabled', value: 'true');
            setState(() {
              _isBiometricEnabled = true;
            });
          }
        }
      } catch (e) {
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _biometricLoading = true;
    });

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Finder precisa confirmar a sua identidade.',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticação biométrica necessária!',
            cancelButton: 'Cancelar',
            goToSettingsButton: AutofillHints.addressCity,
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            localizedFallbackTitle: 'Use o código',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      authenticated = false;
    }
    if (!mounted) return;

    if (authenticated) {
      final email = await _secureStorage.read(key: 'email');
      final password = await _secureStorage.read(key: 'password');

      if (email != null && password != null) {
        final success = await _authService.login(email, password);

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          Fluttertoast.showToast(
            msg:
                'Falha ao fazer login com biometria. Verifique suas credenciais.',
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg:
              'Credenciais não encontradas. Faça login com email e senha primeiro.',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      setState(() {
        _isBiometricEnabled = false;
      });
      await _secureStorage.write(key: 'isBiometricEnabled', value: 'false');

      Fluttertoast.showToast(
        msg: 'Falha na autenticação biométrica. Faça login com email e senha.',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() {
      _biometricLoading = false;
    });
  }

  Future<void> _attemptBiometricLogin() async {
    if (_isBiometricEnabled) {
      await _authenticateWithBiometrics();
    }
  }

  void _showLoading() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _loading = false;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      _showLoading();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await _authService.login(email, password);

      _hideLoading();

      if (success) {
        await _checkBiometrics();

        if (_canCheckBiometrics) {
          await _requestBiometricPermission();
        }

        await _secureStorage.write(key: 'email', value: email);
        await _secureStorage.write(key: 'password', value: password);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Falha ao fazer login. Verifique suas credenciais.',
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/finder-logo.png',
                          height: 200,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.email, color: Colors.white),
                        hintText: 'Email',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        hintText: 'Senha',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_canCheckBiometrics &&
                        _isBiometricEnabled &&
                        !_biometricLoading) ...[
                      ElevatedButton.icon(
                        onPressed: _authenticateWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Login com Biometria'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextButton.icon(
                      onPressed: _loading ? null : _authService.loginWithGoogle,
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color.fromRGBO(66, 133, 244, 1),
                              Color.fromRGBO(234, 67, 53, 1),
                              Color.fromRGBO(251, 188, 5, 1),
                              Color.fromRGBO(52, 168, 83, 1),
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            tileMode: TileMode.clamp,
                          ).createShader(bounds);
                        },
                        child: const FaIcon(
                          FontAwesomeIcons.google,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      label: const Text(
                        'Login com Google',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Não tem uma conta? Cadastre-se',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          if (_loading || _biometricLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: LoadingDots(),
              ),
            ),
        ],
      ),
    );
  }
}
