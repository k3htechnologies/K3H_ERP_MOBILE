import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/payroll_dashboard/data/datasource/payroll_dashboard.datasource.dart';

abstract interface class PayrollDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPayrollDashboardList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
}

class PayrollDashboardRepositoryImpl extends PayrollDashboardRepository {
  final PayrollDashboardDatasource payrollDashboardDatasource;

  PayrollDashboardRepositoryImpl({required this.payrollDashboardDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPayrollDashboardList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await payrollDashboardDatasource.apiCallPullPayrollDashboard(
        pageSize: pageSize,
        pageNumber: pageNumber,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
