import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/datasource/visitor_management_dashboard.datasource.dart';

abstract interface class VisitorManagementDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getGatePassDashboard({
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addApproval({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateGatePassOut({
    required Map<String, dynamic> body,
  });
}

class VisitorManagementDashboardRepositoryImpl
    extends VisitorManagementDashboardRepository {
  final VisitorManagementDashboardDatasource
  visitorManagementDashboardDatasource;
  VisitorManagementDashboardRepositoryImpl({
    required this.visitorManagementDashboardDatasource,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> getGatePassDashboard({
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await visitorManagementDashboardDatasource
          .apiCallPullGatePassDashboard(
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addApproval({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await visitorManagementDashboardDatasource
          .apicallAddUpdateGatePassApproval(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateGatePassOut({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await visitorManagementDashboardDatasource
          .apicallUpdateGatePassOut(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
