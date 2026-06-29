import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';

import '../datasource/ibm_obm_report.datasource.dart';

abstract interface class IbmObmReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> getIbmObmReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getIbmObmReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class IbmObmReportRepositoryImpl implements IbmObmReportRepository {
  final IbmObmReportDatasource ibmObmReportDatasource;

  IbmObmReportRepositoryImpl({required this.ibmObmReportDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getIbmObmReport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await ibmObmReportDatasource.apiCallPullIbmObmReport(
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
  Future<Either<Failure, Map<String, dynamic>>> getIbmObmReportForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await ibmObmReportDatasource
          .apiCallPullIbmObmReportForExport(
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
