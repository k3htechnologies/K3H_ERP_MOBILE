import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/datasource/asset_master_mapping.datasource.dart';

abstract interface class AssetMasterMappingRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAssetMasterMappedList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateAssetMapping({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteAssetMapping({
    required int branchMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getAssetMasterMappedListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class AssetMasterMappingRepositoryImpl extends AssetMasterMappingRepository {
  final AssetMasterMappingDatasource assetMasterMappingDatasource;

  AssetMasterMappingRepositoryImpl({
    required this.assetMasterMappingDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAssetMasterMappedList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await assetMasterMappingDatasource.apiCallPullMappedAssets(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateAssetMapping({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await assetMasterMappingDatasource
          .apiCallAddUpdateMappedAsset(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteAssetMapping({
    required int branchMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await assetMasterMappingDatasource.apiCallDeleteMappedAsset(
        assetMasterMappingId: branchMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getAssetMasterMappedListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await assetMasterMappingDatasource
          .apiCallPullMappedAssetsForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportBranch({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await assetMasterMappingDatasource
          .apiCallPullMappedAssetsForExport(
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
