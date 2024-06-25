import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/constants/api_constants.dart';

class AuthService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.authEndpoint),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Salvar tokens em armazenamento seguro
      await secureStorage.write(
          key: 'accessToken', value: jsonData['accessToken']);
      await secureStorage.write(
          key: 'refreshToken', value: jsonData['refreshToken']);

      // Salvar dados do usuário em armazenamento seguro
      final decodedToken = _decodeJwt(jsonData['accessToken']);
      await secureStorage.write(
        key: 'user',
        value: json.encode(decodedToken),
      );

      return true;
    } else {
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    final response = await http.post(
      Uri.parse(ApiConstants.googleAuthEndpoint),
      // Adicione parâmetros necessários para o login com Google
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Salvar tokens em armazenamento seguro
      await secureStorage.write(
          key: 'accessToken', value: jsonData['accessToken']);
      await secureStorage.write(
          key: 'refreshToken', value: jsonData['refreshToken']);

      // Salvar dados do usuário em armazenamento seguro
      final decodedToken = _decodeJwt(jsonData['accessToken']);
      await secureStorage.write(
        key: 'user',
        value: json.encode(decodedToken),
      );
    } else {
      // Login com Google falhou
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userJson = await secureStorage.read(key: 'user');
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refreshToken');
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
    await secureStorage.delete(key: 'user');
  }

  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = _base64UrlDecode(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  String _base64UrlDecode(String input) {
    var output = input.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
