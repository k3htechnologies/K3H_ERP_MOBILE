import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TermsAndConditionsDatasource {
  Future<Map<String, dynamic>> apicallPullTermsAndConditionsMaster({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateTermsAndConditionMaster({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteTermsAndConditionsMaster({
    required int termsAndConditionsMasterId,
    required String uniquekey,
  });

  Future<Map<String, dynamic>> apicallPullTermsAndConditionsMasterForExport({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  });
}

class TermsAndConditionsDatasourceImpl extends TermsAndConditionsDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTermsAndConditionsMaster({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermsAndConditionsMasterUrl({
      required int pageNumber,
      required int pageSize,
      required String moduleName,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "TermsAndConditionsMaster/PullTermsAndConditionsMaster?PageSize=$pageSize&PageNumber=$pageNumber&ModuleName=$moduleName";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermsAndConditionsMasterUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          moduleName: moduleName,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TermsAndConditionsModel>.from(
          networkResponse["data"].map(
            (e) => TermsAndConditionsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTermsAndConditionsMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          moduleName: moduleName,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTermsAndConditionMaster({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateTermsAndConditionMasterUrl =
        "TermsAndConditionsMaster/AddUpdateTermsAndConditionsMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateTermsAndConditionMasterUrl,
        body,
      );
      return {
        'data': List<TermsAndConditionsModel>.from(
          networkResponse["data"].map(
            (e) => TermsAndConditionsModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTermsAndConditionMaster(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTermsAndConditionsMaster({
    required int termsAndConditionsMasterId,
    required String uniquekey,
  }) async {
    String deleteTermsAndConditionMasterUrl({
      required int termsAndConditionsMasterId,
      required String uniquekey,
    }) {
      return "TermsAndConditionsMaster/DeleteTermsAndConditionsMaster?TermsAndConditionsMasterId=$termsAndConditionsMasterId&Uniquekey=$uniquekey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTermsAndConditionMasterUrl(
          termsAndConditionsMasterId: termsAndConditionsMasterId,
          uniquekey: uniquekey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteTermsAndConditionsMaster(
          termsAndConditionsMasterId: termsAndConditionsMasterId,
          uniquekey: uniquekey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullTermsAndConditionsMasterForExport({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTermsAndConditionsMasterExportUrl({
      required int pageNumber,
      required int pageSize,
      required String moduleName,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "TermsAndConditionsMaster/PullTermsAndConditionsMaster?PageSize=$pageSize&PageNumber=$pageNumber&ModuleName=$moduleName";
      queryParams?.forEach((key, value) {
        final encoded = Uri.encodeQueryComponent(value?.toString() ?? '');
        url += "&$key=$encoded";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTermsAndConditionsMasterExportUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          moduleName: moduleName,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTermsAndConditionsMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          moduleName: moduleName,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
