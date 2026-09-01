import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/vendor_management/data/datasource/vendor.datasource.dart';

abstract interface class VendorRepository {
  Future<Either<Failure, Map<String, dynamic>>> getVendorsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateVendor({
    required Map<String, String> payload,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteVendor({
    required int vendorId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportVendor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class VendorRepositoryImpl implements VendorRepository {
  final VendorDatasource vendorDatasource;
  VendorRepositoryImpl({required this.vendorDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getVendorsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await vendorDatasource.apiCallPullVendor(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateVendor({
    required Map<String, String> payload,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await vendorDatasource.apiCallAddUpdateVendor(
        payload: payload,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteVendor({
    required int vendorId,
    required String uniqueKey,
  }) async {
    try {
      var result = await vendorDatasource.apiCallDeleteVendor(
        vendorId: vendorId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: ErrorHandler.getErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportVendor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await vendorDatasource.apicallPullVendorForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
