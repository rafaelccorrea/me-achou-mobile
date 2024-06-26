import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meachou/screens/reset_password-screen.dart';
import 'package:meachou/services/user_service.dart'; // Importe o serviço UserService aqui

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = ''; // Variável para armazenar o e-mail digitado pelo usuário
  bool isLoading = false; // Variável para controlar o estado de carregamento

  void _resetPassword() async {
    setState(() {
      isLoading = true; // Ativa o indicador de carregamento
    });

    UserService userService = UserService();

    try {
      // Chame o serviço de recuperação de senha
      var response = await userService.forgotPasswordEndpoint(email);

      // Verifique a resposta da sua API e trate conforme necessário
      if (response.statusCode == 200) {
        // Sucesso na solicitação de recuperação de senha
        Fluttertoast.showToast(
          msg: 'Email de recuperação enviado com sucesso',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navegue para a tela de redefinição de senha
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: email),
          ),
        );
      } else {
        // Trate casos de erro, como 404 (not found), 500 (server error), etc.
        Fluttertoast.showToast(
          msg: 'Falha ao enviar email de recuperação',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      // Trate erros de conexão ou outros erros inesperados
      print('Erro ao enviar requisição: $e');
      Fluttertoast.showToast(
        msg: 'Erro ao enviar requisição de recuperação',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false; // Desativa o indicador de carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
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
            TextField(
              onChanged: (value) {
                email =
                    value; // Atualiza o valor do e-mail conforme o usuário digita
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email, color: Colors.white),
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : _resetPassword, // Desabilita o botão se isLoading for true
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                    )
                  : const Text(
                      'Redefinição de Senha',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
