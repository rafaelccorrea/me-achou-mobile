import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/constants/api_constants.dart';

class UserService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<http.Response> createUserEndpoint(
      String name, String email, String password) async {
    return await http.post(
      Uri.parse(ApiConstants.createUserEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  // Métodos adicionais conforme necessário para operações de usuário
}
