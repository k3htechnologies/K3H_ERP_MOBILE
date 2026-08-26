import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/document/data/datasource/document.datasource.dart';

abstract interface class DocumentsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTermSheetDocumentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheetDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteTermSheetDocument({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDocumentId,
    required String uniquekey,
  });
}

class DocumentsRepositoryImpl extends DocumentsRepository {
  final DocumentsDatasource documentsDatasource;
  DocumentsRepositoryImpl({required this.documentsDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTermSheetDocumentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentsDatasource.apiCallPullTermSheetDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheetDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await documentsDatasource.apiCallAddUpdateTermSheetDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTermSheetDocument({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDocumentId,
    required String uniquekey,
  }) async {
    try {
      final result = await documentsDatasource.apiCallDeleteTermSheetDocument(
        projectId: projectId,
        termSheetId: termSheetId,
        termSheetDetailsId: termSheetDetailsId,
        termSheetDocumentId: termSheetDocumentId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
