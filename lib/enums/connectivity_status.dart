enum ConnectivityStatus { WiFi, Cellular, Offline }

String connectivityToString(ConnectivityStatus connectivityStatus) {
  return '$connectivityStatus'.split('.').last;
}
