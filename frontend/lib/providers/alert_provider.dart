import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  List<AlertModel> _alerts = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AlertModel> get alerts => _alerts;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAlerts({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/alerts', token: token);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        _alerts = json.map((e) => AlertModel.fromJson(e)).toList();
        _unreadCount = _alerts.where((a) => !a.read).length;
      } else {
        _error = 'Error cargando alertas';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String alertId, {String? token}) async {
    try {
      final response = await ApiService.put('/alerts/$alertId/read', {}, token: token);
      if (response.statusCode == 200) {
        final index = _alerts.indexWhere((a) => a.id == alertId);
        if (index != -1) {
          _alerts[index] = AlertModel.fromJson(jsonDecode(response.body));
          _unreadCount = _alerts.where((a) => !a.read).length;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getUnreadCount({String? token}) async {
    try {
      final response = await ApiService.get('/alerts/unread/count', token: token);
      if (response.statusCode == 200) {
        _unreadCount = jsonDecode(response.body)['unreadCount'] ?? 0;
        notifyListeners();
        return _unreadCount;
      }
    } catch (e) {
      _error = e.toString();
    }
    return 0;
  }
}
