import 'dart:io';

// CONFIGURA TU IP AQUÍ: Reemplaza esta IP con la IPv4 de tu PC donde corre el backend
// Para encontrar tu IP: Ejecuta 'ipconfig' en Windows y busca tu IPv4 (ej: 192.168.1.10)
const String _customBackendIp = '172.30.115.81'; // IP Wi-Fi actual detectada

String getApiBaseUrl() {
  if (Platform.isAndroid) {
    // Usa tu IP personalizada o la IP por defecto
    return 'http://$_customBackendIp:4000/api';
  }
  return 'http://127.0.0.1:4000/api';
}
