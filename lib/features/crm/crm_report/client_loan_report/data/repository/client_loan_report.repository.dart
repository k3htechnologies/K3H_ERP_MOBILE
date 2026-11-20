import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_report/client_loan_report/data/datasource/client_loan_report.datasource.dart';

abstract interface class ClientLoanReportRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectWiseClientLoanReportList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportClientLoanReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ClientLoanReportRepositoryImpl extends ClientLoanReportRepository {
  final ClientLoanReportDatasource clientLoanReportDatasource;

  ClientLoanReportRepositoryImpl({required this.clientLoanReportDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectWiseClientLoanReportList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await clientLoanReportDatasource
          .apiCallPullProjectWiseClientLoanReport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportClientLoanReport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await clientLoanReportDatasource
          .apiCallPullClientLoanReportForExport(
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
