import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/datasource/branch_association_master.datasource.dart';

abstract interface class BranchAssociationMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBranchAssociationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBranchAssociation({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportBranchAssociation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class BranchAssociationMasterRepositoryImpl
    extends BranchAssociationMasterRepository {
  final BranchAssociationMasterDatasource branchAssociationMasterDataSource;

  BranchAssociationMasterRepositoryImpl({
    required this.branchAssociationMasterDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBranchAssociationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await branchAssociationMasterDataSource
          .apicallPullBranchAssociation(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBranchAssociation({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await branchAssociationMasterDataSource
          .apicallAddUpdateBranchAssociation(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportBranchAssociation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await branchAssociationMasterDataSource
          .apicallPullBranchAssociation(
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
