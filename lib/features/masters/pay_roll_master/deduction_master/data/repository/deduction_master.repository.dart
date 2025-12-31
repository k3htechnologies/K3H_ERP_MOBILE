import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/deduction_master/data/datasource/deduction_master.datasource.dart';

abstract interface class DeductionMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDeductionList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateDeduction({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteDeduction({
    required int deductionMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportDeductions({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class DeductionMasterRepositoryImpl extends DeductionMasterRepository {
  final DeductionMasterDatasource deductionMasterDatasource;

  DeductionMasterRepositoryImpl({required this.deductionMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeductionList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await deductionMasterDatasource.apicallPullDeductionMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateDeduction({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await deductionMasterDatasource
          .apicallAddUpdateDeductionMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDeduction({
    required int deductionMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await deductionMasterDatasource.apicallDeleteDeductionMaster(
        deductionMasterId: deductionMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportDeductions({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await deductionMasterDatasource
          .apicallPullDeductionMasterForExport(
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
