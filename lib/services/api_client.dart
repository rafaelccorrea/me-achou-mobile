import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/services/auth_service.dart';

class ApiClient {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthService authService = AuthService();
  int _failureCount = 0;

  Future<http.Response> sendRequest(
      Future<http.Response> Function() request) async {
    final response = await request();

    if (response.statusCode == 401) {
      _failureCount++;
      if (_failureCount >= 3) {
        await authService.logout();
        _failureCount = 0;
        throw Exception(
            'Usuário deslogado devido a falhas consecutivas de autenticação.');
      }

      await authService.refreshToken();
      final retryResponse = await request();

      if (retryResponse.statusCode != 401) {
        _failureCount = 0;
      }

      return retryResponse;
    } else {
      _failureCount = 0;
      return response;
    }
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final String? token = await authService.getAccessToken();
    final newHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
    return sendRequest(() => http.get(Uri.parse(url), headers: newHeaders));
  }

  Future<http.Response> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    final String? token = await authService.getAccessToken();
    final newHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
    return sendRequest(
        () => http.post(Uri.parse(url), headers: newHeaders, body: body));
  }

  Future<http.Response> put(String url,
      {Map<String, String>? headers, dynamic body}) async {
    final String? token = await authService.getAccessToken();
    final newHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
    return sendRequest(
        () => http.put(Uri.parse(url), headers: newHeaders, body: body));
  }

  Future<http.Response> delete(String url,
      {Map<String, String>? headers}) async {
    final String? token = await authService.getAccessToken();
    final newHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };
    return sendRequest(() => http.delete(Uri.parse(url), headers: newHeaders));
  }

  Future<http.StreamedResponse> uploadFile(String url, File file,
      {Map<String, String>? headers}) async {
    final String? token = await authService.getAccessToken();

    final newHeaders = {
      if (token != null) 'Authorization': 'Bearer $token',
      if (headers != null) ...headers,
    };

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.headers.addAll(newHeaders);
    return request.send();
  }

  Future<http.Response> sendMultipartRequest(
      http.MultipartRequest request) async {
    final String? token = await authService.getAccessToken();

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}
