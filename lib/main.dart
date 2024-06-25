import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

void main() {
  runApp(MeAchouApp());
}

class MeAchouApp extends StatelessWidget {
  const MeAchouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Me-Achou',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
