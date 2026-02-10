import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/datasource/leave_credit_configuration_master.datasource.dart';

abstract interface class LeaveCreditConfigurationMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getLeaveCreditConfigurationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateLeaveCreditConfigurationMaster({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveCreditConfiguration({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportLeaveCreditConfiguration({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class LeaveCreditConfigurationMasterRepositoryImpl
    extends LeaveCreditConfigurationMasterRepository {
  final LeaveCreditConfigurationMasterDatasource leaveCreditConfigurationMasterDatasource;

  LeaveCreditConfigurationMasterRepositoryImpl({
    required this.leaveCreditConfigurationMasterDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLeaveCreditConfigurationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveCreditConfigurationMasterDatasource
          .apicallPullLeaveCreditConfigurationMaster(
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
  addUpdateLeaveCreditConfigurationMaster({required Map<String, dynamic> body}) async {
    try {
      var result = await leaveCreditConfigurationMasterDatasource
          .apicallAddUpdateLeaveCreditConfigurationMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLeaveCreditConfiguration({
    required int leaveCreditConfigurationId,
    required String uniqueKey,
  }) async {
    try {
      var result = await leaveCreditConfigurationMasterDatasource
          .apicallDeleteLeaveCreditConfigurationMaster(
            leaveCreditConfigurationId: leaveCreditConfigurationId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportLeaveCreditConfiguration({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await leaveCreditConfigurationMasterDatasource
          .apicallPullLeaveCreditConfigurationMasterExport(
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
