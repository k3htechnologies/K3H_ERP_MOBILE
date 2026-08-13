import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/datasource/dcr.datasource.dart';

abstract interface class DCRRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDailyCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required int projectId,
    String? fromDate,
    String? toDate,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  exportDailyCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DCRRepositoryImp extends DCRRepository {
  final DCRDatasource dcrDatasource;

  DCRRepositoryImp({required this.dcrDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDailyCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required String filterType,
    String? fromDate,
    String? toDate,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final params = {
        ...?queryParams,
        "ProjectId": projectId,
        "FilterType": filterType,
      };

      if (fromDate != null && fromDate.isNotEmpty) {
        params["FromDate"] = fromDate;
      }

      if (toDate != null && toDate.isNotEmpty) {
        params["ToDate"] = toDate;
      }

      var result = await dcrDatasource.apiCallPullDailyCollectionReport(
        queryParams: queryParams,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  exportDailyCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await dcrDatasource
          .apiCallPullDailyCollectionReportForExport(
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
