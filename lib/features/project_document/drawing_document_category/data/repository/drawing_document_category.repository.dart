import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/datasource/drawing_document_category.datasource.dart';

abstract interface class DrawingDocumentCategoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateDrawingDocumentCategory({required Map<String, dynamic> body});
  Future<Either<Failure, Map<String, dynamic>>> deleteDrawingDocumentCategory({
    required int drawingDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DrawingDocumentCategoryRepositoryImpl
    extends DrawingDocumentCategoryRepository {
  final DrawingDocumentCategoryDatasource drawingDocumentCategoryDatasource;

  DrawingDocumentCategoryRepositoryImpl({
    required this.drawingDocumentCategoryDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await drawingDocumentCategoryDatasource
          .apicallPullDrawingDocumentCategory(
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
  addUpdateDrawingDocumentCategory({required Map<String, dynamic> body}) async {
    try {
      var result = await drawingDocumentCategoryDatasource
          .apicallAddUpdateDrawingDocumentCategory(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDrawingDocumentCategory({
    required int drawingDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await drawingDocumentCategoryDatasource
          .apicallDeleteDrawingDocumentCategory(
            drawingDocumentCategoryId: drawingDocumentCategoryId,
            projectId: projectId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await drawingDocumentCategoryDatasource
          .apicallPulDrawingDocumentCategoryForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
