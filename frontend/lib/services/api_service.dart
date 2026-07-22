import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_base.dart';

class ApiService {
  static const Duration _defaultTimeout = Duration(seconds: 8);
  static const Duration _candidateTimeout = Duration(seconds: 2);
  static String? _workingBaseUrl;

  static List<String> get _candidateBaseUrls {
    final urls = <String>[];
    if (_workingBaseUrl != null) {
      urls.add(_workingBaseUrl!);
    }
    final primary = getApiBaseUrl();
    if (!urls.contains(primary)) {
      urls.add(primary);
    }
    const defaults = [
      'http://172.30.115.72:4000/api',
      'http://127.0.0.1:4000/api',
      'http://localhost:4000/api',
      'http://10.0.2.2:4000/api',
    ];
    for (final url in defaults) {
      if (!urls.contains(url)) {
        urls.add(url);
      }
    }
    return urls;
  }

  static Map<String, String> defaultHeaders([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body, {String? token}) async {
    return _sendWithFallback((baseUrl, timeout) async {
      return http
          .post(Uri.parse('$baseUrl$path'), headers: defaultHeaders(token), body: jsonEncode(body))
          .timeout(timeout);
    });
  }

  static Future<http.Response> get(String path, {String? token}) async {
    return _sendWithFallback((baseUrl, timeout) async {
      return http
          .get(Uri.parse('$baseUrl$path'), headers: defaultHeaders(token))
          .timeout(timeout);
    });
  }

  static Future<http.Response> put(String path, Map<String, dynamic> body, {String? token}) async {
    return _sendWithFallback((baseUrl, timeout) async {
      return http
          .put(Uri.parse('$baseUrl$path'), headers: defaultHeaders(token), body: jsonEncode(body))
          .timeout(timeout);
    });
  }

  static Future<http.Response> delete(String path, {String? token}) async {
    return _sendWithFallback((baseUrl, timeout) async {
      return http
          .delete(Uri.parse('$baseUrl$path'), headers: defaultHeaders(token))
          .timeout(timeout);
    });
  }

  static Future<http.Response> _sendWithFallback(
      Future<http.Response> Function(String baseUrl, Duration timeout) request) async {
    String? lastErrorMessage;
    final candidates = _candidateBaseUrls;

    for (int i = 0; i < candidates.length; i++) {
      final baseUrl = candidates[i];
      final isKnownWorking = (baseUrl == _workingBaseUrl);
      final timeout = isKnownWorking ? _defaultTimeout : _candidateTimeout;

      try {
        final response = await request(baseUrl, timeout);
        if (response.statusCode < 500) {
          _workingBaseUrl = baseUrl;
          return response;
        }
        if (isKnownWorking) _workingBaseUrl = null;
        lastErrorMessage = 'El servidor respondió con código ${response.statusCode}';
      } on TimeoutException {
        if (isKnownWorking) _workingBaseUrl = null;
        lastErrorMessage = 'Tiempo de espera agotado al conectar con el servidor. Confirma que Node.js esté activo en el puerto 4000.';
      } on SocketException catch (se) {
        if (isKnownWorking) _workingBaseUrl = null;
        if (se.message.contains('refused') || se.osError?.errorCode == 10061 || se.osError?.errorCode == 111) {
          lastErrorMessage = 'Conexión rehusada en el servidor backend. Confirma que Node.js esté ejecutándose en el puerto 4000.';
        } else {
          lastErrorMessage = 'Error de conexión de red: ${se.message}';
        }
      } catch (e) {
        if (isKnownWorking) _workingBaseUrl = null;
        final errStr = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
        if (errStr.contains('Connection refused') || errStr.contains('XMLHttpRequest error')) {
          lastErrorMessage = 'No se pudo establecer conexión con el servidor backend. Confirma que Node.js esté activo en el puerto 4000.';
        } else {
          lastErrorMessage = errStr;
        }
      }
    }

    throw Exception(
        lastErrorMessage ?? 'No se pudo conectar con el servidor backend. Verifica tu conexión e inicia el backend Node.js en el puerto 4000.');
  }
}

