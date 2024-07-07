import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';

class EventService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthService authService = AuthService();

  Future<http.Response> getEvents({
    required int page,
    required int limit,
    required String city,
    String? eventName,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final String? token = await authService.getAccessToken();

    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'city': city,
      if (eventName != null) 'event_name': eventName,
      if (category != null) 'category': category,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final uri = Uri.parse(
        '${ApiConstants.eventsEndpoint}?${Uri(queryParameters: queryParams).query}');

    return await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
