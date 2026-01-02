import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/earning_master/data/datasource/earning_master.datasource.dart';

abstract interface class EarningMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEarningsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });


  Future<Either<Failure, Map<String, dynamic>>> addUpdateEarning({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteEarning({
    required int earningMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportEarnings({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class EarningMasterRepositoryImpl extends EarningMasterRepository {
  final EarningMasterDatasource earningMasterDatasource;

  EarningMasterRepositoryImpl({
    required this.earningMasterDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEarningsList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await earningMasterDatasource.apiCallPullEarningMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }



  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteEarning({
    required int earningMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await earningMasterDatasource.apicallDeleteEarningMaster(
        earningMasterId: earningMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportEarnings({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await earningMasterDatasource
          .apicallPullEarningMasterForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEarning({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await earningMasterDatasource.apicallAddUpdateEarningMaster(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
