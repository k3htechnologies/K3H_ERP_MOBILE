import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/datasource/budget.datasource.dart';

abstract interface class BudgetRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullBudget({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullBudgetForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class BudgetRepositoryImpl extends BudgetRepository {
  final BudgetDatasource budgetDatasource;
  BudgetRepositoryImpl({required this.budgetDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBudget({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await budgetDatasource.apiCallPullBudget(
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
  Future<Either<Failure, Map<String, dynamic>>> pullBudgetForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await budgetDatasource.apiCallPullBudgetForExport(
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
