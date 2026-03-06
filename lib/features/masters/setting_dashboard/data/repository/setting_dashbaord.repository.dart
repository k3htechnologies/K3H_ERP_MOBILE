import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/setting_dashboard/data/datasource/setting_dashbaord.datasource.dart';

abstract interface class SettingDashbaordRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSettingDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class SettingDashbaordRepositoryImpl implements SettingDashbaordRepository {
  final SettingDashbaordDatasource settingDashbaordDatasource;

  SettingDashbaordRepositoryImpl({required this.settingDashbaordDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSettingDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await settingDashbaordDatasource
          .apiCallPullSettingsDashboard(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
