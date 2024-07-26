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
    startSubscriptionCheck(Duration(minutes: 1));
  }

  Future<String> checkSubscription() async {
    try {
      final uri = Uri.parse(ApiConstants.getDetailsSubscriptionEndpoint);
      print('Checking subscription status...');
      final response = await apiClient.get(uri.toString());
      print('Subscription response ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        String status = jsonData['data']['status'];
        _subscriptionStatusController.add(status);
        print('Subscription status retrieved: $status');
        return status;
      } else {
        String cachedStatus = await _getCachedSubscriptionStatus();
        print(
            'Failed to fetch subscription status. Using cached status: $cachedStatus');
        _subscriptionStatusController.add(cachedStatus);
        return cachedStatus;
      }
    } on PlatformException catch (e) {
      print('PlatformException: ${e.message}');
      String cachedStatus = await _getCachedSubscriptionStatus();
      print('Using cached status due to PlatformException: $cachedStatus');
      _subscriptionStatusController.add(cachedStatus);
      return cachedStatus;
    } catch (e) {
      print('Unexpected error: $e');
      String cachedStatus = await _getCachedSubscriptionStatus();
      print('Using cached status due to unexpected error: $cachedStatus');
      _subscriptionStatusController.add(cachedStatus);
      return cachedStatus;
    }
  }

  Future<String> _getCachedSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(subscriptionStatusKey) ?? 'NONE';
  }

  void startSubscriptionCheck(Duration interval) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) async {
      await checkSubscription();
    });
    print('Started subscription check every ${interval.inMinutes} minutes');
  }

  void dispose() {
    _timer?.cancel();
    _subscriptionStatusController.close();
  }
}
