import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';
import '../services/local_cache_service.dart';

class PredictionProvider extends ChangeNotifier {
  List<PredictionModel> _predictions = [];
  bool _isLoading = false;
  String? _error;

  List<PredictionModel> get predictions => _predictions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPredictions({String? token, bool useCache = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (useCache) {
        final cached = await LocalCacheService.getPredictions();
        if (cached != null && cached.isNotEmpty) {
          _predictions = cached;
          notifyListeners();
        }
      }

      final response = await ApiService.get('/predictions', token: token);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        _predictions = json.map((e) => PredictionModel.fromJson(e)).toList();
        await LocalCacheService.savePredictions(_predictions);
      } else {
        _error = 'Error cargando predicciones';
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPrediction(
    String title,
    String description,
    double amount,
    double probability,
    String trend, {
    String category = 'Acciones',
    double targetReturn = 0,
    String riskLevel = 'Medio',
    String? token,
  }) async {
    try {
      final response = await ApiService.post(
        '/predictions',
        {
          'title': title,
          'description': description,
          'amount': amount,
          'probability': probability,
          'trend': trend,
          'category': category,
          'targetReturn': targetReturn,
          'riskLevel': riskLevel,
        },
        token: token,
      );

      if (response.statusCode == 201) {
        final prediction = PredictionModel.fromJson(jsonDecode(response.body));
        _predictions.add(prediction);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePrediction(String id, Map<String, dynamic> updates, {String? token}) async {
    try {
      final response = await ApiService.put('/predictions/$id', updates, token: token);
      if (response.statusCode == 200) {
        final updated = PredictionModel.fromJson(jsonDecode(response.body));
        final index = _predictions.indexWhere((p) => p.id == id);
        if (index != -1) {
          _predictions[index] = updated;
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

  Future<bool> deletePrediction(String id, {String? token}) async {
    try {
      final response = await ApiService.delete('/predictions/$id', token: token);
      if (response.statusCode == 200) {
        _predictions.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
