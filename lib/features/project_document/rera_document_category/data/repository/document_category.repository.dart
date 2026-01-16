import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/datasource/rera_document_category.datasource.dart';

abstract interface class RERADocumentCategoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getReraDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateReraDocumentCategory({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteReraDocumentCategory({
    required int projectRERADocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportReraDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class RERADocumentCategoryRepositoryImpl
    implements RERADocumentCategoryRepository {
  final RERADocumentCategoryDatasource reraDocumentCategoryDatasource;

  RERADocumentCategoryRepositoryImpl({
    required this.reraDocumentCategoryDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReraDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await reraDocumentCategoryDatasource
          .apicallPullProjectRERADocumentCategory(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateReraDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await reraDocumentCategoryDatasource
          .apicallAddUpdateProjectRERADocumentCategory(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteReraDocumentCategory({
    required int projectRERADocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await reraDocumentCategoryDatasource
          .apicallDeleteProjectRERADocumentCategory(
            projectDocumentCategoryId: projectRERADocumentCategoryId,
            projectId: projectId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportReraDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await reraDocumentCategoryDatasource
          .apicallPullProjectRERADocumentCategoryForExport(
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
}
