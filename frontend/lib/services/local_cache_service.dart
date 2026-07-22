import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_stats_model.dart';
import '../models/prediction_model.dart';
import '../models/user_model.dart';

class LocalCacheService {
  static const _statsKey = 'cachedStats';
  static const _usersKey = 'cachedUsers';
  static const _predictionsKey = 'cachedPredictions';

  static Future<void> saveStats(DashboardStatsModel stats) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_statsKey, jsonEncode({
      'totalPredictions': stats.totalPredictions,
      'approved': stats.approved,
      'completed': stats.completed,
      'pending': stats.pending,
      'totalUsers': stats.totalUsers,
      'clients': stats.clients,
      'admins': stats.admins,
      'trends': stats.trends.map((t) => {'_id': t.trend, 'count': t.count}).toList(),
      'probabilities': stats.probabilities.map((p) => {'_id': p.range, 'count': p.count}).toList(),
    }));
  }

  static Future<DashboardStatsModel?> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statsKey);
    if (raw == null) return null;
    return DashboardStatsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_usersKey, jsonEncode(users.map((u) => {
          'id': u.id,
          '_id': u.id,
          'name': u.name,
          'email': u.email,
          'role': u.role,
          'active': u.active,
        }).toList()));
  }

  static Future<List<UserModel>?> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
  }

  static Future<void> savePredictions(List<PredictionModel> predictions) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_predictionsKey, jsonEncode(predictions.map((p) => {
          'id': p.id,
          '_id': p.id,
          'title': p.title,
          'description': p.description,
          'amount': p.amount,
          'probability': p.probability,
          'trend': p.trend,
          'status': p.status,
          'createdBy': p.createdBy,
        }).toList()));
  }

  static Future<List<PredictionModel>?> getPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_predictionsKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((p) => PredictionModel.fromJson(p as Map<String, dynamic>)).toList();
  }
}
