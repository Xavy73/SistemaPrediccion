import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {'email': email, 'password': password});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        final pref = await SharedPreferences.getInstance();
        await pref.setString('token', _token!);
        await pref.setString('user', jsonEncode(data['user']));
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          _error = data['message'] ?? 'Credenciales inválidas';
        } catch (_) {
          _error = 'Credenciales inválidas (${response.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        final pref = await SharedPreferences.getInstance();
        await pref.setString('token', _token!);
        await pref.setString('user', jsonEncode(data['user']));
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          _error = data['message'] ?? 'Error al registrar. Intenta de nuevo.';
        } catch (_) {
          _error = 'Error al registrar (${response.statusCode})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;
    final pref = await SharedPreferences.getInstance();
    await pref.remove('token');
    await pref.remove('user');
    notifyListeners();
  }

  Future<void> loadSession() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final savedToken = pref.getString('token');
      final savedUser = pref.getString('user');
      if (savedToken != null && savedUser != null) {
        _token = savedToken;
        _user = UserModel.fromJson(jsonDecode(savedUser));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error cargando sesión';
      notifyListeners();
    }
  }
}
