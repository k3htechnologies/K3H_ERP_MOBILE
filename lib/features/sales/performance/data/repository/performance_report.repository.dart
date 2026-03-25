import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/performance/data/datasource/performance_report.datatsource.dart';

abstract interface class PerformanceReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceSourcingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceClosingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
  });
}

class PerformanceReportRepositoryImpl extends PerformanceReportRepository {
  final PerformanceReportDatasource performanceReportDatasource;

  PerformanceReportRepositoryImpl({required this.performanceReportDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceSourcingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await performanceReportDatasource
          .apiCallPullPerformanceSourcingReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
            reportType: reportType,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPerformanceClosingReport({
    required int projectId,
    required int pageSize,
    required int pageNumber,
    required String reportType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await performanceReportDatasource
          .apiCallPullPerformanceClosingReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            queryParams: queryParams,
            reportType: reportType,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
