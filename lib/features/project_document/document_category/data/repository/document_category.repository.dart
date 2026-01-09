import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/datasource/document_category.datasource.dart';

abstract interface class DocumentCategoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateDocumentCategory({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteDocumentCategory({
    required int projectDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DocumentCategoryRepositoryImpl implements DocumentCategoryRepository {
  final DocumentCategoryDatasource documentCategoryDatasource;

  DocumentCategoryRepositoryImpl({required this.documentCategoryDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentCategoryDatasource.apicallPullProjectDocumentCategory(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallAddUpdateProjectDocumentCategory(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDocumentCategory({
    required int projectDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallDeleteProjectDocumentCategory(
        projectDocumentCategoryId: projectDocumentCategoryId,
        projectId: projectId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallPullProjectDocumentCategoryForExport(
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
