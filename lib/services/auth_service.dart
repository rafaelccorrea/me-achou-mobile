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
      await secureStorage.write(key: 'user', value: json.encode(decodedToken));

      bool hasStore = await _checkUserStore();
      await secureStorage.write(key: 'hasStore', value: hasStore.toString());

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
      await secureStorage.write(key: 'user', value: json.encode(decodedToken));

      bool hasStore = await _checkUserStore();
      await secureStorage.write(key: 'hasStore', value: hasStore.toString());
    } else {
      // Login com Google falhou
    }
  }

  Future<bool> _checkUserStore() async {
    final String? token = await getAccessToken();
    final uri = Uri.parse(ApiConstants.storeDetailsEndpoint);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Failed to check store details');
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

  Future<bool> hasStore() async {
    final hasStoreString = await secureStorage.read(key: 'hasStore');
    return hasStoreString == 'true';
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
    await secureStorage.delete(key: 'user');
    await secureStorage.delete(key: 'hasStore');
  }

  Future<void> refreshToken() async {
    final refreshToken = await getRefreshToken();
    final userId = (await getUser())?['id'];

    print('Response refreshToken: ${refreshToken}');
    print('Response userId: ${userId}');

    if (refreshToken != null && userId != null) {
      final response = await http.post(
        Uri.parse(ApiConstants.refreshTokenEndpoint),
        body: json.encode({
          'userId': userId,
          'refreshToken': refreshToken,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        // Atualizar tokens em armazenamento seguro
        await secureStorage.write(
            key: 'accessToken', value: jsonData['accessToken']);
        await secureStorage.write(
            key: 'refreshToken', value: jsonData['refreshToken']);
      } else if (response.statusCode == 401) {
        throw Exception('Refresh token inválido');
      } else {
        throw Exception('Falha ao atualizar token');
      }
    } else {
      throw Exception('Refresh token ou userId ausente');
    }
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
