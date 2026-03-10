import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/legal/dashboard/data/datasource/litigation_dashboard.datatsource.dart';

abstract interface class LitigationDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLitigationDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class LitigationDashboardRepositoryImpl extends LitigationDashboardRepository {
  final LitigationDashboardDatasource litigationDashboardDatasource;
  LitigationDashboardRepositoryImpl({
    required this.litigationDashboardDatasource,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLitigationDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await litigationDashboardDatasource
          .apiCallPullLitigationDashboard(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
