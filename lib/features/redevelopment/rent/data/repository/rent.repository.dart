import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/datasource/rent.datasource.dart';

abstract interface class RentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class RentRepositoryImpl implements RentRepository {
  final RentDatasource rentDatasource;

  RentRepositoryImpl({required this.rentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await rentDatasource.apicallPullTenantApplicantCharges(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
