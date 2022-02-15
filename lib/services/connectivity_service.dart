import 'dart:async';

import 'package:chatsample/enums/connectivity_status.dart';
import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';

class ConnectivityService {
  // Create our public controller
  StreamController<ConnectivityStatus> connectionStatusController =
      StreamController<ConnectivityStatus>();

  final _connectivitySink = PublishSubject<ConnectivityStatus>();

  Observable<ConnectivityStatus> get connectivityObserver =>
      _connectivitySink.stream;

  static final ConnectivityService _instance = ConnectivityService.internal();

  factory ConnectivityService() => _instance;

  static ConnectivityService get instance => _instance;

  ConnectivityService.internal() {
    checkCurrentConnectivity();
    // Subscribe to the connectivity Chanaged Steam
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Use Connectivity() here to gather more info if you need t
      ConnectivityStatus status = _getStatusFromResult(result);
      connectionStatusController.add(status);
      _connectivitySink.add(status);
    });
  }

  // Convert from the third part enum to our own enum
  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.WiFi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }

  void checkCurrentConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    ConnectivityStatus status = _getStatusFromResult(result);
    connectionStatusController.add(status);
    _connectivitySink.add(status);
  }

  dispose() {
    _connectivitySink.close();
    connectionStatusController.close();
  }
}
