import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/datasource/branch_master.datasource.dart';

abstract interface class BranchMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBranchList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBranch({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteBranch({
    required int branchMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class BranchMasterRepositoryImpl extends BranchMasterRepository {
  final BranchMasterDatasource branchMasterDatasource;

  BranchMasterRepositoryImpl({required this.branchMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBranchList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await branchMasterDatasource.apicallPullBranchMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBranch({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await branchMasterDatasource.apicallAddUpdateBranchMaster(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBranch({
    required int branchMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await branchMasterDatasource.apicallDeleteBranchMaster(
        branchMasterId: branchMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await branchMasterDatasource
          .apicallPullBranchMasterForExport(
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
