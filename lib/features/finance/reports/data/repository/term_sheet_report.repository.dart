import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/reports/data/datasource/term_sheet_report.datasource.dart';

abstract interface class TermSheetReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullTermSheetReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullTermSheetReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class TermSheetReportRepositoryImpl extends TermSheetReportRepository {
  final TermSheetReportDatasource termSheetReportDatasource;
  TermSheetReportRepositoryImpl({required this.termSheetReportDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullTermSheetReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await termSheetReportDatasource.apiCallPullTermSheetReport(
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
  Future<Either<Failure, Map<String, dynamic>>> pullTermSheetReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await termSheetReportDatasource
          .apiCallPullTermSheetReportForExport(
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
