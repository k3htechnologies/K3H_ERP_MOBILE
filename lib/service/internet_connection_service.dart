import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final instance = ConnectivityService._();

  Stream<bool> get connectionStream => InternetConnection().onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );

  Future<bool> get isConnected => InternetConnection().hasInternetAccess;
}
