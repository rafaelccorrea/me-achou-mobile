import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FollowsService {
  final ApiClient apiClient = ApiClient();
  final AuthService authService = AuthService();

  Future<Map<String, dynamic>> getFollowedStores(int page, int limit) async {
    final uri =
        Uri.parse('${ApiConstants.getFollowsEndpoint}?page=$page&limit=$limit');
    final response = await apiClient.get(uri.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'total': data['total'],
        'data': List<Map<String, dynamic>>.from(data['data']),
      };
    } else {
      throw Exception('Failed to load followed stores');
    }
  }

  Future<void> followStore(String storeId) async {
    final token = await authService.getAccessToken();
    final endpoint =
        ApiConstants.followStoreEndpoint.replaceFirst(':storeId', storeId);

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to follow store');
    }
  }

  Future<void> unfollowStore(String storeId) async {
    final token = await authService.getAccessToken();
    final endpoint =
        ApiConstants.unfollowStoreEndpoint.replaceFirst(':storeId', storeId);

    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow store');
    }
  }
}
