import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/specification_and_budget/specification_master/data/datasource/specification_master.datasource.dart';

abstract interface class SpecificationMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullSpecificationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  pullSpecificationMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class SpecificationMasterRepositoryImpl extends SpecificationMasterRepository {
  final SpecificationMasterDatasource specificationMasterDatasource;

  SpecificationMasterRepositoryImpl({
    required this.specificationMasterDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullSpecificationMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await specificationMasterDatasource
          .apiCallPullSpecificationMaster(
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
  Future<Either<Failure, Map<String, dynamic>>>
  pullSpecificationMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await specificationMasterDatasource
          .apiCallPullSpecificationMasterForExport(
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
