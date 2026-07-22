import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../services/api_service.dart';
import '../services/local_cache_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStatsModel? _stats;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats({String? token, bool useCache = true, Duration cacheExpiry = const Duration(minutes: 5)}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (useCache) {
        final cached = await LocalCacheService.getStats();
        if (cached != null) {
          _stats = cached;
          _lastFetch = DateTime.now();
          notifyListeners();
        }
      }

      final response = await ApiService.get('/dashboard/stats', token: token);
      if (response.statusCode == 200) {
        _stats = DashboardStatsModel.fromJson(jsonDecode(response.body));
        _lastFetch = DateTime.now();
        await LocalCacheService.saveStats(_stats!);
      } else {
        _error = 'Error cargando estadísticas (${response.statusCode})';
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool shouldRefetch() {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!).inMinutes > 5;
  }
}
