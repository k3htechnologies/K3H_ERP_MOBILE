import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/datasource/tax_tracker.datasource.dart';

abstract interface class TaxTrackerRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTaxTrackerList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTaxTrackerDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTaxTracker({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class TaxTrackerRepositoryImpl implements TaxTrackerRepository {
  final TaxTrackerDatasource taxTrackerDatasource;
  TaxTrackerRepositoryImpl({required this.taxTrackerDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaxTrackerList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await taxTrackerDatasource.apiCallPullTaxTracker(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTaxTrackerDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await taxTrackerDatasource
          .apicallAddUpdateTaxTrackerDocument(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTaxTracker({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await taxTrackerDatasource.apicallAddUpdateTaxTracker(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
