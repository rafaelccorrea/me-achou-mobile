import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';

class StoreService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AuthService authService = AuthService();

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
    final String? token = await authService.getAccessToken();

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

    return await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
