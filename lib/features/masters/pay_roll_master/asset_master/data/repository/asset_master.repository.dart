import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/datasource/asset_master.datasource.dart';

abstract interface class AssetMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAssetList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateAsset({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteAsset({
    required int assetMasterId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportAsset({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class AssetMasterRepositoryImpl extends AssetMasterRepository {
  final AssetMasterDataSource assetMasterDatasource;

  AssetMasterRepositoryImpl({required this.assetMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAssetList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await assetMasterDatasource.apiCallPullAssets(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateAsset({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await assetMasterDatasource.apiCallAddUpdateAsset(
        body: body,
        fileList: fileList
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteAsset({
    required int assetMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await assetMasterDatasource.apiCallDeleteAsset(
        assetMasterId: assetMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportAsset({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await assetMasterDatasource.apiCallPullAssets(
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
