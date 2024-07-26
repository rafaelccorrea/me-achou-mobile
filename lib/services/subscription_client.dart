import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'dart:convert';
import 'dart:async';

class SubscriptionClient {
  final ApiClient apiClient = ApiClient();
  static const String subscriptionStatusKey = 'subscription_status';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final StreamController<String> _subscriptionStatusController =
      StreamController<String>.broadcast();
  Timer? _timer;
  bool _isClosed = false;

  Stream<String> get subscriptionStatusStream =>
      _subscriptionStatusController.stream;

  SubscriptionClient() {
    print('SubscriptionClient initialized');
  }

  Future<String> checkSubscription() async {
    try {
      print('Fetching subscription status from API...');
      final uri = Uri.parse(ApiConstants.getDetailsSubscriptionEndpoint);

      final response = await apiClient.get(uri.toString());
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        String status = jsonData['data']['status'];
        print('Received subscription status: $status');
        await _cacheSubscriptionStatus(status);
        _addStatusToController(status);
        return status;
      } else {
        print(
            'Failed to fetch subscription status, status code: ${response.statusCode}');
        return await _handleError();
      }
    } on PlatformException catch (e) {
      print('PlatformException occurred: $e');
      return await _handleError();
    } catch (e) {
      print('Exception occurred: $e');
      return await _handleError();
    }
  }

  Future<void> _cacheSubscriptionStatus(String status) async {
    await secureStorage.write(key: subscriptionStatusKey, value: status);
    print('Cached subscription status: $status');
  }

  Future<String> _getCachedSubscriptionStatus() async {
    String? cachedStatus = await secureStorage.read(key: subscriptionStatusKey);
    cachedStatus ??= 'NONE';
    print('Retrieved cached subscription status: $cachedStatus');
    return cachedStatus;
  }

  Future<String> _handleError() async {
    String cachedStatus = await _getCachedSubscriptionStatus();
    _addStatusToController(cachedStatus);
    return cachedStatus;
  }

  void _addStatusToController(String status) {
    if (!_isClosed && !_subscriptionStatusController.isClosed) {
      _subscriptionStatusController.add(status);
    }
  }

  void startSubscriptionCheck(Duration interval) {
    print('Starting subscription check every ${interval.inMinutes} minutes');
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) async {
      print('Running periodic subscription check...');
      await checkSubscription();
    });
  }

  void close() {
    _isClosed = true;
    _subscriptionStatusController.close();
    _timer?.cancel();
  }
}
