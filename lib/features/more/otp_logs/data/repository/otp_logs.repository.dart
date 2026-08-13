import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/more/otp_logs/data/datasource/otp_logs.datasource.dart';

abstract interface class OtpLogsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getOTPLogsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportOTPLogsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class OtpLogsRepositoryImpl implements OtpLogsRepository {
  final OtpLogsDatasource otpLogsDatasource;

  OtpLogsRepositoryImpl({required this.otpLogsDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOTPLogsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await otpLogsDatasource.apicallPullOTPLogs(
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
  Future<Either<Failure, Map<String, dynamic>>> exportOTPLogsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await otpLogsDatasource.apicallPullOTPLogsForExport(
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
