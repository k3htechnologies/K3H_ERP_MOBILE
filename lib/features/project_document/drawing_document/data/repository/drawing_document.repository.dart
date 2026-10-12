import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/datasource/drawing_document.datasource.dart';

abstract interface class DrawingDocumentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateDrawingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteDrawingDocument({
    required int drawingDocumentId,
    required int projectId,
    required int drawingDocumentCategoryId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullInventoryDrawingDocument({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DrawingDocumentRepositoryImpl extends DrawingDocumentRepository {
  final DrawingDocumentDatasource drawingDocumentDatasource;

  DrawingDocumentRepositoryImpl({required this.drawingDocumentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await drawingDocumentDatasource.apicallPullDrawingDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDrawingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await drawingDocumentDatasource
          .apiCallAddUpdateDrawingDocument(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDrawingDocument({
    required int drawingDocumentId,
    required int projectId,
    required int drawingDocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await drawingDocumentDatasource.apicallDeleteDrawingDocument(
        drawingDocumentId: drawingDocumentId,
        projectId: projectId,
        drawingDocumentCategoryId: drawingDocumentCategoryId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullInventoryDrawingDocument({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await drawingDocumentDatasource
          .apicallPullInventoryDrawingDocument(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
