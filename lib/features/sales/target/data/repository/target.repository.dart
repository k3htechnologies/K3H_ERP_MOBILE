import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/target/data/datasource/target.datasource.dart';

abstract interface class TargetRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSalesTargets({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required DateTime targetMonth,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateSalesTarget({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteSalesTarget({
    required int saleTargetId,
    required String uniqueKey,
    required int projectId,
  });
}

class TargetRepositoryImpl extends TargetRepository {
  final TargetDatasource salesTargetDatasource;

  TargetRepositoryImpl({required this.salesTargetDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSalesTargets({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required DateTime targetMonth,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await salesTargetDatasource.apicallPullTarget(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        targetMonth: targetMonth,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateSalesTarget({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await salesTargetDatasource.apicallAddUpdateTarget(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteSalesTarget({
    required int saleTargetId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await salesTargetDatasource.apicallDeleteTarget(
        saleTargetId: saleTargetId,
        uniqueKey: uniqueKey,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
