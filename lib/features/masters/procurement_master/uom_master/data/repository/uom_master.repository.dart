import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/datasource/uom_master.datasource.dart';

abstract interface class UOMMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getUOMList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportUMO({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class UOMMasterRepositoryImpl implements UOMMasterRepository {
  final UOMMasterDatasource uomMasterDatasource;

  UOMMasterRepositoryImpl({required this.uomMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUOMList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await uomMasterDatasource.apicallPullUOMMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> exportUMO({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await uomMasterDatasource.apicallPullUOMMasterExport(
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
