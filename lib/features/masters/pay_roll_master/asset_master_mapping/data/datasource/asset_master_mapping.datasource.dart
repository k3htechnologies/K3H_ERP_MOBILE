import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class AssetMasterMappingDatasource {
  Future<Map<String, dynamic>> apiCallPullMappedAssets({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateMappedAsset({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallDeleteMappedAsset({
    required int assetMasterMappingId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallPullMappedAssetsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class AssetMasterMappingDatasourceImpl extends AssetMasterMappingDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullMappedAssets({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAssetMasterMappingsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AssetMasterMappingMapping/PullAssetMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAssetMasterMappingsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<AssetMappingModel>.from(
          networkResponse['data'].map((e) => AssetMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullMappedAssets(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateMappedAsset({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateAssetMasterMappingUrl =
        "AssetMasterMappingMapping/AddUpdateAssetMasterMapping";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateAssetMasterMappingUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateMappedAsset(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteMappedAsset({
    required int assetMasterMappingId,
    required String uniqueKey,
  }) async {
    String deleteAssetMasterMappingUrl({
      required int assetMasterMappingId,
      required String uniqueKey,
    }) {
      return "AssetMasterMappingMapping/DeleteAssetMasterMapping?AssetMasterMappingId=$assetMasterMappingId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteAssetMasterMappingUrl(
          assetMasterMappingId: assetMasterMappingId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullMappedAssetsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAssetMasterMappingsExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AssetMasterMappingMapping/PullAssetMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAssetMasterMappingsExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullMappedAssetsForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
