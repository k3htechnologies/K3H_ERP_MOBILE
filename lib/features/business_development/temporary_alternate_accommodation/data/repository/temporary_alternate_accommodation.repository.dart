import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/datasource/temporary_alternate_accommodation.datasource.dart';

abstract interface class TemporaryAlternateAccommodationRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdatePayTrackRent({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> getPayTrackRentLedgerList({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> deletePayTrackRent({
    required int payTrackRentId,
    required String uniqueKey,
    required int projectId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  pullTenantApplicantChargesForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackRentLedgerListForExport({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class RentRepositoryImpl implements TemporaryAlternateAccommodationRepository {
  final TemporaryAlternateAccommodationDatasource rentDatasource;

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

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePayTrackRent({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await rentDatasource.apicallAddUpdatePayTrackRent(
        requestBody: requestBody,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPayTrackRentLedgerList({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await rentDatasource.apicallPullPayTrackRentLedger(
        pageNumber: pageNumber,
        pageSize: pageSize,
        tenantId: tenantId,
        tenantApplicantId: tenantApplicantId,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePayTrackRent({
    required int payTrackRentId,
    required String uniqueKey,
    required int projectId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
  }) async {
    try {
      var result = await rentDatasource.apicallDeletePayTrackRent(
        payTrackRentId: payTrackRentId,
        uniqueKey: uniqueKey,
        projectId: projectId,
        tenantId: tenantId,
        tenantApplicantId: tenantApplicantId,
        buildingId: buildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  pullTenantApplicantChargesForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await rentDatasource
          .apicallPullTenantApplicantChargesForExport(
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

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getPayTrackRentLedgerListForExport({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await rentDatasource.apicallPullPayTrackRentLedgerForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        tenantId: tenantId,
        tenantApplicantId: tenantApplicantId,
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
