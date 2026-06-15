import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

abstract interface class InwardOutwardDatasource {
  Future<Map<String, dynamic>> apicallPullInwardOutwardMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateInwardOutwardMaster({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallAddUpdateInwardOutwardRevert({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallDeleteInwardOutward({
    required int inwardOutwardId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallPullSenderReceiverByMobileNo({
    required String mobileNumber,
  });
  Future<Map<String, dynamic>> apicallPullInwardOutwardMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class InwardOutwardDatasourceImp implements InwardOutwardDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallPullInwardOutwardMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInwardOutwardUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "InwardOutward/PullInwardOutward?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInwardOutwardUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<InwardOutwardModel>.from(
          networkResponse["data"].map((e) => InwardOutwardModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullInwardOutwardMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateInwardOutwardMaster({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateInwardOutwardUrl = "InwardOutward/AddUpdateInwardOutward";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateInwardOutwardUrl,
            fileList,
            body,
          );
      return {
        'data': List<InwardOutwardModel>.from(
          networkResponse["data"].map((e) => InwardOutwardModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateInwardOutwardMaster(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateInwardOutwardRevert({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateInwardOutwardRevert =
        "InwardOutward/AddUpdateInwardOutward";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateInwardOutwardRevert,
            fileList,
            body,
          );
      return {
        'data': List<InwardOutwardModel>.from(
          networkResponse["data"].map((e) => InwardOutwardModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateInwardOutwardRevert(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteInwardOutward({
    required int inwardOutwardId,
    required String uniqueKey,
  }) async {
    String deleteInwardOutwardUrl({
      required int inwardOutwardId,
      required String uniqueKey,
    }) {
      return "InwardOutward/DeleteInwardOutward?"
          "Uniquekey=$uniqueKey"
          "&InwardOutwardId=$inwardOutwardId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteInwardOutwardUrl(
          uniqueKey: uniqueKey,
          inwardOutwardId: inwardOutwardId,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse["message"],
      };
    } catch (error) {
      // Handle token expiration by retrying once
      if (error is TokenExpiredException) {
        return apicallDeleteInwardOutward(
          uniqueKey: uniqueKey,
          inwardOutwardId: inwardOutwardId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullSenderReceiverByMobileNo({
    required String mobileNumber,
  }) async {
    String pullSenderReceiverByMobileNo({required String mobileNumber}) {
      String url =
          "InwardOutward/PullSenderReceiverByMobileNo?MobileNumber=$mobileNumber";
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSenderReceiverByMobileNo(mobileNumber: mobileNumber),
      );
      return {
        'data': List<InwardOutwardModel>.from(
          networkResponse["data"].map((e) => InwardOutwardModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSenderReceiverByMobileNo(mobileNumber: mobileNumber);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullInwardOutwardMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInwardOutwardUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "InwardOutward/PullInwardOutward?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInwardOutwardUrl(
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
        apicallPullInwardOutwardMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
