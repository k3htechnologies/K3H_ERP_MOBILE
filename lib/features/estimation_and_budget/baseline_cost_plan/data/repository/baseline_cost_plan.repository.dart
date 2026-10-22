import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/datasource/baseline_cost_plan.datasource.dart';

abstract interface class BaselineCostPlanRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getBaselineCostPlanDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateBaselineCostPlanDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteBaseplanCostPlanDocument({
    required int baselineCostPlanDocumentId,
    required int projectId,
    required int baselineCostPlanDocumentCategoryId,
    required String uniqueKey,
  });
}

class BaselineCostPlanRepositoryImpl extends BaselineCostPlanRepository {
  final BaselineCostPlanDatasource baselineCostPlanDatasource;
  BaselineCostPlanRepositoryImpl({required this.baselineCostPlanDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getBaselineCostPlanDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await baselineCostPlanDatasource
          .apicallPullBaselineCostPlanDocumentCategory(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await baselineCostPlanDatasource
          .apicallPullBaselineCostPlanDocument(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateBaselineCostPlanDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await baselineCostPlanDatasource
          .apiCallAddUpdateBaselineCostPlanDocument(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBaseplanCostPlanDocument({
    required int baselineCostPlanDocumentId,
    required int projectId,
    required int baselineCostPlanDocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await baselineCostPlanDatasource
          .apicallDeleteBaselineCostPlanDocument(
            baselineCostPlanDocumentId: baselineCostPlanDocumentId,
            projectId: projectId,
            baselineCostPlanDocumentCategoryId:
                baselineCostPlanDocumentCategoryId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
