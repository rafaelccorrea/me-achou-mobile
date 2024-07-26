import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/api_client.dart';
import 'dart:convert';
import 'dart:async';

class SubscriptionClient {
  final ApiClient apiClient = ApiClient();
  static const String subscriptionStatusKey = 'subscription_status';
  final StreamController<String> _subscriptionStatusController =
      StreamController<String>.broadcast();
  Timer? _timer;

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
        _subscriptionStatusController.add(status);
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(subscriptionStatusKey, status);
    print('Cached subscription status: $status');
  }

  Future<String> _getCachedSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedStatus = prefs.getString(subscriptionStatusKey) ?? 'NONE';
    print('Retrieved cached subscription status: $cachedStatus');
    return cachedStatus;
  }

  Future<String> _handleError() async {
    String cachedStatus = await _getCachedSubscriptionStatus();
    _subscriptionStatusController.add(cachedStatus);
    return cachedStatus;
  }

  void startSubscriptionCheck(Duration interval) {
    print('Starting subscription check every ${interval.inMinutes} minutes');
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) async {
      print('Running periodic subscription check...');
      await checkSubscription();
    });
  }

  void dispose() {
    _timer?.cancel();
    _subscriptionStatusController.close();
    print('Disposed SubscriptionClient');
  }
}
