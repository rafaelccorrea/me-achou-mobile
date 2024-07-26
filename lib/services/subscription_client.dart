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
    startSubscriptionCheck(Duration(minutes: 60));
  }

  Future<String> checkSubscription() async {
    try {
      final uri = Uri.parse(ApiConstants.getDetailsSubscriptionEndpoint);

      final response = await apiClient.get(uri.toString());
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        String status = jsonData['data']['status'];
        await _cacheSubscriptionStatus(status);
        _subscriptionStatusController.add(status);
        return status;
      } else {
        String cachedStatus = await _getCachedSubscriptionStatus();
        _subscriptionStatusController.add(cachedStatus);
        return cachedStatus;
      }
    } on PlatformException catch (e) {
      String cachedStatus = await _getCachedSubscriptionStatus();
      _subscriptionStatusController.add(cachedStatus);
      return cachedStatus;
    } catch (e) {
      String cachedStatus = await _getCachedSubscriptionStatus();
      _subscriptionStatusController.add(cachedStatus);
      return cachedStatus;
    }
  }

  Future<void> _cacheSubscriptionStatus(String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(subscriptionStatusKey, status);
  }

  Future<String> _getCachedSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cachedStatus = prefs.getString(subscriptionStatusKey) ?? 'NONE';

    return cachedStatus;
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
