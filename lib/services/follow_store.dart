import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:convert';

class FollowsService {
  final ApiClient apiClient = ApiClient();
  final AuthService authService = AuthService();

  Future<Map<String, dynamic>> getFollowingStores({
    String? companyName,
    int? rankingMin,
    int? rankingMax,
    required int page,
    required int limit,
  }) async {
    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (companyName != null) 'company_name': companyName,
      if (rankingMin != null) 'ranking_min': rankingMin.toString(),
      if (rankingMax != null) 'ranking_max': rankingMax.toString(),
    };

    final uri = Uri.parse(ApiConstants.getFollowsEndpoint)
        .replace(queryParameters: queryParameters);

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

  Future<Map<String, dynamic>> getFollowersStores({
    required int page,
    required int limit,
    String? name,
  }) async {
    final uri =
        Uri.parse(ApiConstants.getFollowersEndpoint).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
      if (name != null) 'user_name': name,
    });

    final response = await apiClient.get(uri.toString());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'total': data['total'],
        'data': List<Map<String, dynamic>>.from(data['data']),
      };
    } else {
      throw Exception('Failed to load followers stores');
    }
  }

  Future<void> followStore(String storeId) async {
    final endpoint =
        ApiConstants.followStoreEndpoint.replaceFirst(':storeId', storeId);

    final response = await apiClient.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to follow store');
    }
  }

  Future<void> unfollowStore(String storeId) async {
    final endpoint =
        ApiConstants.unfollowStoreEndpoint.replaceFirst(':storeId', storeId);

    final response = await apiClient.delete(endpoint);

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow store');
    }
  }
}
