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

  Future<http.Response> forgotPasswordEndpoint(String email) async {
    return await http.post(
      Uri.parse(ApiConstants.forgotPasswordEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
  }

  Future<http.Response> resetPasswordEndpoint(
      String email, String token, String newPassword) async {
    return await http.post(
      Uri.parse(ApiConstants.resetPasswordEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
    );
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final token = await secureStorage.read(key: 'accessToken');
    final response = await http.get(
      Uri.parse(ApiConstants.userDetailsEndpoint),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<Map<String, dynamic>> deleteUser() async {
    final token = await secureStorage.read(key: 'accessToken');

    final response = await http.delete(
      Uri.parse(ApiConstants.userDeleteEndpoint),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body)
    };
  }
}
