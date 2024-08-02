import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinatura'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text('Página de Assinatura'),
      ),
    );
  }
}
