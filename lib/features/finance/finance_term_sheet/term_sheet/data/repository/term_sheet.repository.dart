import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/datasource/term_sheet.datasource.dart';

abstract interface class TermSheetRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTermSheet({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheet({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> getTermSheetView({
    required int projectId,
    required int termSheetId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteTermSheet({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
  });
  Future<Either<Failure, Map<String, dynamic>>> finalizeApproval({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportTermSheet({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class TermSheetRepositoryImpl extends TermSheetRepository {
  final TermSheetDatasource termSheetDatasource;
  TermSheetRepositoryImpl({required this.termSheetDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getTermSheet({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termSheetDatasource.apiCallPullTermSheet(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheet({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await termSheetDatasource.addUpdateTermSheet(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTermSheetView({
    required int projectId,
    required int termSheetId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termSheetDatasource.apiCallPullTermSheetView(
        projectId: projectId,
        termSheetId: termSheetId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTermSheet({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
  }) async {
    try {
      final result = await termSheetDatasource.apiCallDeleteTermSheet(
        projectId: projectId,
        termSheetId: termSheetId,
        termSheetDetailsId: termSheetDetailsId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> finalizeApproval({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await termSheetDatasource.apicallFinalizeTermSheetDetails(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportTermSheet({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termSheetDatasource.apiCallPullTermSheetForExport(
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
