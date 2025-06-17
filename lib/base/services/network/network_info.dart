import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../helpers/utilities.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImplementation implements NetworkInfo {
  final Connectivity connectivity;
  final Duration timeout;

  NetworkInfoImplementation({
    Connectivity? connectivity,
    this.timeout = const Duration(seconds: 5),
  }) : connectivity = connectivity ?? Connectivity() {
    connectivity!.onConnectivityChanged.listen((status) {
      // Map ConnectivityResult to a boolean or custom status for snackbar
      final hasConnection = status != ConnectivityResult.none;
      Utilities.showInternetConnectionSnackBar(
        hasConnection ? InternetStatus.connected : InternetStatus.disconnected,
      );
    });
  }


  @override
  Future<bool> get isConnected async {
    // Step 1: Check network connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    // Step 2: Optional HTTP check to verify internet access
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}