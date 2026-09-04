import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/model/sub_material_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class SubMaterialMasterDatasource {
  Future<Map<String, dynamic>> apicallPullSubMaterialMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateSubMaterialMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteSubMaterialMaster({
    required int subMaterialMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullSubMaterialMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class SubMaterialMasterDataSourceImpl implements SubMaterialMasterDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullSubMaterialMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSubMaterialMasterUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SubMaterialMaster/PullSubMaterialMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSubMaterialMasterUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<SubMaterialMasterModel>.from(
          networkResponse["data"].map(
            (e) => SubMaterialMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSubMaterialMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateSubMaterialMaster({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateSubMaterialMasterUrl =
        "SubMaterialMaster/AddUpdateSubMaterialMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateSubMaterialMasterUrl,
        body,
      );
      return {
        'data': List<SubMaterialMasterModel>.from(
          networkResponse["data"].map(
            (e) => SubMaterialMasterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateSubMaterialMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteSubMaterialMaster({
    required int subMaterialMasterId,
    required String uniqueKey,
  }) async {
    String deleteSubMaterialMasterUrl({
      required int subMaterialMasterId,
      required String uniqueKey,
    }) {
      return "SubMaterialMaster/DeleteSubMaterialMaster?SubMaterialMasterId=$subMaterialMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteSubMaterialMasterUrl(
          subMaterialMasterId: subMaterialMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteSubMaterialMaster(
          subMaterialMasterId: subMaterialMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSubMaterialMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSubMaterialMasterExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "SubMaterialMaster/PullSubMaterialMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSubMaterialMasterExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSubMaterialMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
