import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/dashboard/data/datasource/crm_dashboard.datasource.dart';

abstract interface class CrmDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardList({
    required int projectId,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
}

class CrmDashboardRepositoryImpl implements CrmDashboardRepository {
  final CrmDashboardDatasource crmDashboardDatasource;

  CrmDashboardRepositoryImpl({required this.crmDashboardDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardList({
    required int projectId,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await crmDashboardDatasource.apiCallPullDashboard(
        queryParams: {"ProjectId": projectId, "FilterType": filterType},
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
