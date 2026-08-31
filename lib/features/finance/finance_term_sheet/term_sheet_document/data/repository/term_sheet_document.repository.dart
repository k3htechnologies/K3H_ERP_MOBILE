import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/data/datasource/term_sheet_document.datasource.dart';

abstract interface class TermSheetDocumentsRepository {
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

class TermSheetDocumentsRepositoryImpl extends TermSheetDocumentsRepository {
  final TermSheetDocumentsDatasource termSheetDocumentsDatasource;
  TermSheetDocumentsRepositoryImpl({
    required this.termSheetDocumentsDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTermSheetDocumentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termSheetDocumentsDatasource
          .apiCallPullTermSheetDocument(
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
      var result = await termSheetDocumentsDatasource
          .apiCallAddUpdateTermSheetDocument(body: body, fileList: fileList);
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
      final result = await termSheetDocumentsDatasource
          .apiCallDeleteTermSheetDocument(
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
