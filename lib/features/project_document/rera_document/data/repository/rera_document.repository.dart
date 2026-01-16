import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/datasource/rera_document.datasource.dart';

abstract interface class RERADocumentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullProjectRERADocument({
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
    required int projectRERADocumentId,
    required int projectId,
    required int projectRERADocumentCategoryId,
    required String uniqueKey,
  });
}

class RERADocumentRepositoryImpl implements RERADocumentRepository {
  final RERADocumentDatasource reraDocumentDatasource;

  RERADocumentRepositoryImpl({required this.reraDocumentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullProjectRERADocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await reraDocumentDatasource.apicallPullProjectRERADocument(
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
      var result = await reraDocumentDatasource.apiCallAddUpdateDocument(
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
    required int projectRERADocumentId,
    required int projectId,
    required int projectRERADocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await reraDocumentDatasource.apicallDeleteDocument(
        projectRERADocumentId: projectRERADocumentId,
        projectId: projectId,
        projectRERADocumentCategoryId: projectRERADocumentCategoryId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
