import 'dart:io';

String getApiBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://172.30.115.72:4000/api';
  }
  return 'http://127.0.0.1:4000/api';
}
