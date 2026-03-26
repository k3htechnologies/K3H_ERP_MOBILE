import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/data/datasource/sales.dashboard.datasource.dart';

abstract interface class SalesDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSalesDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> markTimeOutEnquiry({
    required Map<String, dynamic> body,
  });
}

class SalesDashboardRepositoryImpl extends SalesDashboardRepository {
  final SalesDashboardDatasource salesDashboardDatasource;
  SalesDashboardRepositoryImpl({required this.salesDashboardDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSalesDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await salesDashboardDatasource.apiCallPullSalesDashboard(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> markTimeOutEnquiry({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await salesDashboardDatasource.apicallMarkTimeOutEnquiry(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
