import 'package:k3h_erp_app/features/tax_tracker/data/model/tax_tracker.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TaxTrackerDatasource {
  Future<Map<String, dynamic>> apiCallPullTaxTracker({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateTaxTrackerDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallAddUpdateTaxTracker({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class TaxTrackerDatasourceImpl implements TaxTrackerDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullTaxTracker({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTaxTrackerUrl({
      Map<String, dynamic>? queryParams,
      required int pageSize,
      required int pageNumber,
    }) {
      String url =
          "TaxTracker/PullTaxTracker?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTaxTrackerUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<TaxTrackerModel>.from(
          networkResponse['data'].map((e) => TaxTrackerModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullTaxTracker(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTaxTrackerDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectRedevelopmentUrl =
        "TaxTracker/AddUpdateTaxTrackerDocument";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectRedevelopmentUrl,
            fileList,
            body,
          );
      return {
        'data': List<TaxTrackerDocumentDetails>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => TaxTrackerDocumentDetails.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateTaxTrackerDocument(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTaxTracker({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectRedevelopmentUrl = "TaxTracker/AddUpdateTaxTracker";

    try {
      final networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectRedevelopmentUrl,
            fileList,
            body,
          );
      return {
        'data': List<TaxTrackerModel>.from(
          (networkResponse['data'] as List<dynamic>).map(
            (e) => TaxTrackerModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateTaxTracker(body: body, fileList: fileList);
      }
      rethrow;
    }
  }
}
