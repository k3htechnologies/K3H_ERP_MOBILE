import 'package:k3h_erp_app/features/vendor_management/data/model/vendor.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class VendorDatasource {
  Future<Map<String, dynamic>> apiCallPullVendor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateVendor({
    required Map<String, String> payload,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apiCallDeleteVendor({
    required int vendorId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullVendorForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class VendorDataSourceImpl implements VendorDatasource {
  BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullVendor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullVendorUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Vendor/PullVendor?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullVendorUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<VendorModel>.from(
          networkResponse['data'].map((x) => VendorModel.fromJson(x)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullVendor(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateVendor({
    required Map<String, String> payload,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateVendorUrl = "Vendor/AddUpdateVendor";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateVendorUrl,
            fileList,
            payload,
          );
      return {
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'data': List<VendorModel>.from(
          networkResponse["data"].map((e) => VendorModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallAddUpdateVendor(payload: payload, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteVendor({
    required int vendorId,
    required String uniqueKey,
  }) async {
    String deleteVendorUrl({required int vendorId, required String uniqueKey}) {
      return "Vendor/DeleteVendor?VendorId=$vendorId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteVendorUrl(vendorId: vendorId, uniqueKey: uniqueKey),
      );

      return {'message': networkResponse['message']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallDeleteVendor(vendorId: vendorId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullVendorForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullVendorExportUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Vendor/PullVendor?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullVendorExportUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullVendorForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
