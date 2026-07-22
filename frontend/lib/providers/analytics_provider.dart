import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../services/api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsModel? _userAnalytics;
  Map<String, dynamic>? _globalAnalytics;
  bool _isLoading = false;
  String? _error;

  AnalyticsModel? get userAnalytics => _userAnalytics;
  Map<String, dynamic>? get globalAnalytics => _globalAnalytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserAnalytics(String userId, {String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/analytics/user/$userId', token: token);
      if (response.statusCode == 200) {
        _userAnalytics = AnalyticsModel.fromJson(jsonDecode(response.body));
      } else {
        _error = 'Error cargando analytics del usuario';
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGlobalAnalytics({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/analytics/global', token: token);
      if (response.statusCode == 200) {
        _globalAnalytics = jsonDecode(response.body);
      } else {
        _error = 'Error cargando analytics global';
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
