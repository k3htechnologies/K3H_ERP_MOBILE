import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/datasource/finalize_vendor.datasource.dart';

abstract interface class FinalizeVendorRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSelectedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });
  Future<Either<Failure, Map<String, dynamic>>> getFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getAllAvailableVendorForRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });

  Future<Either<Failure, Map<String, dynamic>>> addVendorForEnquiry({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> addFinalizedVendor({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addToUpdateMaterialRequisitionQuotation({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> getSelectedVendorForCompare({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
    Map<String, dynamic> queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> compareFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    Map<String, dynamic>? queryParams,
  });
}

class FinalizeVendorRepositoryImpl implements FinalizeVendorRepository {
  final FinalizeVendorDatasource finalizeVendorDatasource;

  FinalizeVendorRepositoryImpl({required this.finalizeVendorDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSelectedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      var result = await finalizeVendorDatasource.apicallPullVendorForEnquiry(
        projectId: projectId,
        materialRequisitionId: materialRequisitionId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      var result = await finalizeVendorDatasource.apiCallPullFinalizedVendor(
        projectId: projectId,
        materialRequisitionId: materialRequisitionId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getAllAvailableVendorForRequisition({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      var result = await finalizeVendorDatasource.apicallPullVendorForEnquiry(
        projectId: projectId,
        materialRequisitionId: materialRequisitionId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addVendorForEnquiry({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await finalizeVendorDatasource.apiCallAddVendorForEnquiry(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addFinalizedVendor({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await finalizeVendorDatasource.apiCallAddFinalizedVendor(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addToUpdateMaterialRequisitionQuotation({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await finalizeVendorDatasource
          .apiCallToUpdateMaterialRequisitionQuotation(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSelectedVendorForCompare({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await finalizeVendorDatasource
          .apiCallPullSelectedVendorForEnquiryForCompare(
            projectId: projectId,
            materialRequisitionId: materialRequisitionId,
            uniquekey: uniquekey,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> compareFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await finalizeVendorDatasource
          .apicallPullFinalizeVendorForExport(
            projectId: projectId,
            materialRequisitionId: materialRequisitionId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
