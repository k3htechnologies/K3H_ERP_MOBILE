import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/services/paytrack_call_log_service.dart';

void registerPaytrackCallTrackerDependencies(GetIt serviceLocator) {
  if (!serviceLocator.isRegistered<PayTrackCallLogService>()) {
    serviceLocator.registerSingleton<PayTrackCallLogService>(
      PayTrackCallLogService(),
    );
  }
}
