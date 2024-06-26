import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/screens/forgot_password_screen.dart';
import 'package:meachou/screens/home/home_screen.dart';
import 'package:meachou/screens/login_screen.dart';
import 'package:meachou/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:meachou/providers/app_drawer_provider.dart';
import 'package:meachou/services/auth_service.dart'; // Importe o serviço AuthService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                AppDrawerProvider()), // Exemplo de outro provider necessário
        Provider<AuthService>(
            create: (_) =>
                AuthService()), // Adicione o Provider do AuthService aqui
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/signup': (context) => const SignUpScreen()
      },
    );
  }
}
