import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/datasource/sourcing.datasource.dart';

abstract interface class SourcingRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSourcingList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
}

class SourcingRepositoryImpl extends SourcingRepository {
  final SourcingDatasource sourcingDatasource;

  SourcingRepositoryImpl({required this.sourcingDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSourcingList({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await sourcingDatasource.apicallPullSourcing(
        pageSize: pageSize,
        pageNumber: pageNumber,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
