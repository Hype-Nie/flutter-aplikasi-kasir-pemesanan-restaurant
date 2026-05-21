import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectivityHelper {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } on MissingPluginException {
      return true;
    }
  }
}
