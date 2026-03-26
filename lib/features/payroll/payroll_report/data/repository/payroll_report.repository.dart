import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/payroll_report/data/datasource/payroll_report.datasource.dart';

abstract interface class PayrollReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> getApprovalStatus({
    int? id,
    String? moduleName,
    String? requestId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addApproval({
    required Map<String, dynamic> body,
  });
}

class PayrollReportRepositoryImpl implements PayrollReportRepository {
  final PayrollReportDatasource payrollReportDatasource;

  PayrollReportRepositoryImpl({required this.payrollReportDatasource});

  /// -------------------- GET: Pull Approval Status --------------------
  @override
  Future<Either<Failure, Map<String, dynamic>>> getApprovalStatus({
    int? id,
    String? moduleName,
    String? requestId,
  }) async {
    try {
      final result = await payrollReportDatasource.apicallPullApprovalStatus(
        id: id,
        moduleName: moduleName,
        requestId: requestId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// -------------------- POST: Add Approval --------------------
  @override
  Future<Either<Failure, Map<String, dynamic>>> addApproval({
    required Map<String, dynamic> body,
  }) async {
    try {
      final result = await payrollReportDatasource.apicallAddApproval(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
