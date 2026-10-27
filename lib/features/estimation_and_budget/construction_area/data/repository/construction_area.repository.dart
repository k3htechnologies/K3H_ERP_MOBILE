import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/datasource/construction_area.datasource.dart';

abstract interface class ConstructionAreaRepository {
  Future<Either<Failure, Map<String, dynamic>>> getConstructionArea({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getConstructionAreaComparative({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateConstructionAreaComparative({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateConstructionArea({
    required Map<String, dynamic> requestBody,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportConstructionArea({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  exportConstructionAreaComparative({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ConstructionAreaRepositoryImpl extends ConstructionAreaRepository {
  final ConstructionAreaDatasource constructionAreaDatasource;
  ConstructionAreaRepositoryImpl({required this.constructionAreaDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getConstructionArea({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await constructionAreaDatasource.apicallPullConstructionArea(
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
  Future<Either<Failure, Map<String, dynamic>>> getConstructionAreaComparative({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await constructionAreaDatasource
          .apicallPullConstructionAreaComparative(
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
  addUpdateConstructionAreaComparative({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await constructionAreaDatasource
          .apiCallAddUpdateConstructionAreaComparative(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateConstructionArea({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await constructionAreaDatasource
          .apicallAddUpdateConstructionArea(body: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportConstructionArea({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await constructionAreaDatasource
          .apiCallPullConstructionAreaForExport(
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
  exportConstructionAreaComparative({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await constructionAreaDatasource
          .apiCallPullConstructionAreaComparativeForExport(
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
