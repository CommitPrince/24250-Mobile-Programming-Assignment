import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late Stream<ConnectivityResult> _connectivityStream;

  ConnectivityService() {
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_connectivityChanged);
  }

  void _connectivityChanged(ConnectivityResult result) {
    String message;
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      message = 'Internet Connected';
    } else {
      message = 'No Internet Connection';
    }
    Fluttertoast.showToast(msg: message);
  }
}
