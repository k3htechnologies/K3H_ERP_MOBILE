import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master/data/model/asset_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract class AssetMasterDataSource {
  Future<Map<String, dynamic>> apiCallPullAssets({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateAsset({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallDeleteAsset({
    required int assetMasterId,
    required String uniqueKey,
  });
}

class AssetMasterDataSourceImpl extends AssetMasterDataSource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullAssets({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullAssetsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "AssetMaster/PullAssetMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullAssetsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<AssetMasterModel>.from(
                  networkResponse['data'].map(
                    (e) => AssetMasterModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullAssets(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateAsset({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateAssetUrl = "AssetMaster/AddUpdateAssetMaster";

    try {
      var networkResponse = await baseClient.multipartRequestWithAuthenticationBytes(
        addUpdateAssetUrl,
        fileList,
        body
      );

      return {
        'data': AssetMasterModel.fromJson(networkResponse['data'][0]),
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateAsset(body: body,fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteAsset({
    required int assetMasterId,
    required String uniqueKey,
  }) async {
    String deleteAssetUrl({required int assetId, required String uniqueKey}) {
      return "AssetMaster/DeleteAssetMaster?AssetMasterId=$assetId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteAssetUrl(assetId: assetMasterId, uniqueKey: uniqueKey),
      );
      return {
        'data': networkResponse['data'],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteAsset(assetMasterId: assetMasterId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }
}
