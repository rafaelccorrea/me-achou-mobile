import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final ApiClient apiClient = ApiClient();

  Future<http.Response> createUserEndpoint(
      String name, String email, String password) async {
    return await apiClient.post(
      ApiConstants.createUserEndpoint,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<http.Response> forgotPasswordEndpoint(String email) async {
    return await apiClient.post(
      ApiConstants.forgotPasswordEndpoint,
      body: {'email': email},
    );
  }

  Future<http.Response> resetPasswordEndpoint(
      String email, String token, String newPassword) async {
    return await apiClient.post(
      ApiConstants.resetPasswordEndpoint,
      body: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final response = await apiClient.get(ApiConstants.userDetailsEndpoint);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<Map<String, dynamic>> deleteUser() async {
    final response = await apiClient.delete(ApiConstants.userDeleteEndpoint);

    return {
      'statusCode': response.statusCode,
      'body': jsonDecode(response.body)
    };
  }
}
