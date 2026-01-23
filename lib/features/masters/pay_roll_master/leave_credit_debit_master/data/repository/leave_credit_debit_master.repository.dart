import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_debit_master/data/datasource/leave_credit_debit_master.datasource.dart';

abstract interface class LeaveCreditDebitMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLeaveCreditDebitList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateLeaveCreditDebitMaster({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveCreditDebit({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportLeaveCreditDebit({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveCreditDebitMasterRepositoryImpl
    extends LeaveCreditDebitMasterRepository {
  final LeaveCreditDebitMasterDatasource leaveCreditDebitMasterDatasource;

  LeaveCreditDebitMasterRepositoryImpl({
    required this.leaveCreditDebitMasterDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveCreditDebitList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveCreditDebitMasterDatasource
          .apicallPullLeaveCreditDebitMaster(
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
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateLeaveCreditDebitMaster({required Map<String, dynamic> body}) async {
    try {
      var result = await leaveCreditDebitMasterDatasource
          .apicallAddUpdateLeaveCreditDebitMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveCreditDebit({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  }) async {
    try {
      var result = await leaveCreditDebitMasterDatasource
          .apicallDeleteLeaveCreditDebitMaster(
            leaveCreditConfigurationId: leaveCreditConfigurationId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportLeaveCreditDebit({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveCreditDebitMasterDatasource
          .apicallPullLeaveCreditDebitMasterExport(
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
