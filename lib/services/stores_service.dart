import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'dart:convert';
import 'dart:io';
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

  Future<http.Response> createStore(Map<String, dynamic> storeData) async {
    final uri = Uri.parse(ApiConstants.createStoreEndpoint);
    final request = http.MultipartRequest('POST', uri);

    request.fields['company_name'] = storeData['company_name'];
    request.fields['business_sector'] = storeData['business_sector'];
    request.fields['whatsapp_phone'] = storeData['whatsapp_phone'];
    request.fields['service_values'] = storeData['service_values'].toString();
    request.fields['email'] = storeData['email'];

    if (storeData.containsKey('about')) {
      request.fields['about'] = storeData['about'] ?? '';
    }
    if (storeData.containsKey('contact_phone')) {
      request.fields['contact_phone'] = storeData['contact_phone'] ?? '';
    }
    if (storeData.containsKey('delivery')) {
      request.fields['delivery'] = storeData['delivery'].toString();
    }
    if (storeData.containsKey('in_home_service')) {
      request.fields['in_home_service'] =
          storeData['in_home_service'].toString();
    }
    if (storeData.containsKey('working_hours')) {
      request.fields['working_hours'] = storeData['working_hours'] ?? '';
    }
    if (storeData.containsKey('website')) {
      request.fields['website'] = storeData['website'] ?? '';
    }
    if (storeData.containsKey('social_networks')) {
      request.fields['social_networks'] =
          json.encode(storeData['social_networks'] ?? {});
    }
    if (storeData.containsKey('photos')) {
      List<File> photos = List<File>.from(storeData['photos']);
      for (var photo in photos) {
        request.files
            .add(await http.MultipartFile.fromPath('photos', photo.path));
      }
    }
    if (storeData.containsKey('address')) {
      request.fields['address'] = json.encode(storeData['address']);
    }

    return await apiClient.sendMultipartRequest(request);
  }

  Future<http.StreamedResponse> uploadProfileImage(File image) async {
    final uri = Uri.parse(ApiConstants.uploadProfileImageEndpoint);
    return await apiClient.uploadFile(uri.toString(), image);
  }
}
