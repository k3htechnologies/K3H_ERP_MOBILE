import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/datasource/dar_allocation.datasource.dart';

abstract interface class DarAllocationRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDarAllocationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteDarAllocation({
    required int darAllocationId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDarAllocation({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportDarAllocation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class DarAllocationRepositoryImpl extends DarAllocationRepository {
  final DarAllocationDatasource darAllocationDatasource;

  DarAllocationRepositoryImpl({required this.darAllocationDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDarAllocationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await darAllocationDatasource.apicallPullDarAllocation(
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
  Future<Either<Failure, Map<String, dynamic>>> deleteDarAllocation({
    required int darAllocationId,
    required String uniqueKey,
  }) async {
    try {
      var result = await darAllocationDatasource.apicallDeleteDarAllocation(
        darAllocationId: darAllocationId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDarAllocation({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await darAllocationDatasource.apicallAddUpdateDarAllocation(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDarAllocation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await darAllocationDatasource
          .apiCallPullDarAllocationForExport(
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
