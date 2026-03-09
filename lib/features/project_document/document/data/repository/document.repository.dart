import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/document/data/datasource/document.datasource.dart';

abstract interface class DocumentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteDocument({
    required int projectDocumentId,
    required int projectId,
    required int projectDocumentCategoryId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentDatasource documentDatasource;

  DocumentRepositoryImpl({required this.documentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentDatasource.apicallPullProjectDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await documentDatasource.apiCallAddUpdateDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDocument({
    required int projectDocumentId,
    required int projectId,
    required int projectDocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await documentDatasource.apicallDeleteDocument(
        projectDocumentId: projectDocumentId,
        projectId: projectId,
        projectDocumentCategoryId: projectDocumentCategoryId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportProjectDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentDatasource.apicallPullProjectDocumentForExport(
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
