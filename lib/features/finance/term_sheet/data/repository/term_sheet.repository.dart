import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/datasource/term_sheet.datasource.dart';

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
}
