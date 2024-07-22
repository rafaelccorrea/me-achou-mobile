import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StoreService {
  final ApiClient apiClient = ApiClient();

  Future<http.Response> getStores({
    required int page,
    required int limit,
    String? companyName,
    bool? delivery,
    required String businessSector,
    String? workingHours,
    bool? inHomeService,
    required String city,
    String? region,
    int? serviceValuesMin,
    int? serviceValuesMax,
    int? rankingMin,
    int? rankingMax,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'business_sector': businessSector,
      'city': city,
      if (companyName != null) 'company_name': companyName,
      if (delivery != null) 'delivery': delivery.toString(),
      if (workingHours != null) 'working_hours': workingHours,
      if (inHomeService != null) 'in_home_service': inHomeService.toString(),
      if (region != null) 'region': region,
      if (serviceValuesMin != null)
        'service_values_min': serviceValuesMin.toString(),
      if (serviceValuesMax != null)
        'service_values_max': serviceValuesMax.toString(),
      if (rankingMin != null) 'ranking_min': rankingMin.toString(),
      if (rankingMax != null) 'ranking_max': rankingMax.toString(),
    };

    final uri = Uri.parse(
        '${ApiConstants.getStoresEndpoint}?${Uri(queryParameters: queryParams).query}');

    return await apiClient.get(uri.toString());
  }

  Future<Map<String, dynamic>?> getStoreDetails() async {
    final uri = Uri.parse(ApiConstants.storeDetailsEndpoint);
    final response = await apiClient.get(uri.toString());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load store details');
    }
  }
}
