import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class UserService {
  final ApiClient apiClient = ApiClient();
  final AuthService authService = AuthService();

  Future<http.Response> createUserEndpoint(
      String name, String email, String password) async {
    return await apiClient.post(
      ApiConstants.createUserEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  Future<http.Response> forgotPasswordEndpoint(String email) async {
    return await apiClient.post(
      ApiConstants.forgotPasswordEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<http.Response> resetPasswordEndpoint(
      String email, String token, String newPassword) async {
    return await apiClient.post(
      ApiConstants.resetPasswordEndpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
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

  Future<http.Response> deleteUser() async {
    final response = await apiClient.delete(ApiConstants.userDeleteEndpoint);
    return response;
  }

  Future<http.Response> updateUserName(String name) async {
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(ApiConstants.updateUserEndpoint),
    );
    request.fields['name'] = name;
    final response = await apiClient.sendMultipartRequest(request);

    if (response.statusCode == 200) {
      print("#############################################################");

      await authService.refreshToken();
    }

    return response;
  }

  Future<http.Response> updateUserAvatar(String filePath) async {
    final file = File(filePath);
    int fileSize = await file.length();
    const int maxSize = 2 * 1024 * 1024; // 2 MB

    if (fileSize > maxSize) {
      final compressedFile = await apiClient.compressImage(file, maxSize);
      if (compressedFile == null) {
        throw Exception('A imagem deve ter menos de 2 MB.');
      }
      filePath = compressedFile.path;
    }

    final mimeTypeData = lookupMimeType(filePath)!.split('/');
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse(ApiConstants.updateUserEndpoint),
    );
    request.files.add(multipartFile);
    final response = await apiClient.sendMultipartRequest(request);

    if (response.statusCode == 200) {
      await authService.refreshToken();
    }

    return response;
  }
}
