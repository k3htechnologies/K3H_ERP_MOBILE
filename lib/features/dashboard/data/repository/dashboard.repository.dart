import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/dashboard/data/datasource/dashboard.datasource.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addAttendace({
    required Map<String, dynamic> requestBody,
  });
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDatasource dashboardDatasource;

  DashboardRepositoryImpl({required this.dashboardDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await dashboardDatasource.apicallPullAttendance(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addAttendace({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await dashboardDatasource.apicallAddAttendance(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
