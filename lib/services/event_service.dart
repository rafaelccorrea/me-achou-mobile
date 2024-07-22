import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'package:http/http.dart' as http;

class EventService {
  final ApiClient apiClient = ApiClient();

  Future<http.Response> getEvents({
    required int page,
    required int limit,
    required String city,
    String? eventName,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
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

    return await apiClient.get(uri.toString());
  }
}
