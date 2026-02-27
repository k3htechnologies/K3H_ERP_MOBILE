import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/dashboard/data/datasource/redevelopment_dashborad.datasource.dart';

abstract interface class RedevelopmentDashboardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getRedevelopmentDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class RedevelopmentDashboardRepositoryImpl
    extends RedevelopmentDashboardRepository {
  final RedevelopmentDashboradDatasource redevelopmentDashboradDatasource;
  RedevelopmentDashboardRepositoryImpl({
    required this.redevelopmentDashboradDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRedevelopmentDashboardList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await redevelopmentDashboradDatasource
          .apiCallPullRedevelopmentDashboard(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
