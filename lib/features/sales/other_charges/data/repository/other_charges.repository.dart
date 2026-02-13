import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/datasource/other_charges.datasource.dart';

abstract interface class OtherChargesRepository {
  Future<Either<Failure, Map<String, dynamic>>> getOtherChargesList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateOtherCharges({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteOtherCharges({
    required int projectId,
    required int otherChargesId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportOtherCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class OtherChargesRepositoryImpl extends OtherChargesRepository {
  final OtherChargesDatasource otherChargesDatasource;

  OtherChargesRepositoryImpl({required this.otherChargesDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOtherChargesList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await otherChargesDatasource.apicallPullOtherCharges(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateOtherCharges({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await otherChargesDatasource.apicallAddUpdateOtherCharges(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteOtherCharges({
    required int projectId,
    required int otherChargesId,
    required String uniqueKey,
  }) async {
    try {
      var result = await otherChargesDatasource.apicallDeleteOtherCharges(
        projectId: projectId,
        otherChargesId: otherChargesId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportOtherCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await otherChargesDatasource
          .apicallPullOtherChargesForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
