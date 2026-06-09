import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class OtherChargesDatasource {
  Future<Map<String, dynamic>> apicallPullOtherCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateOtherCharges({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteOtherCharges({
    required int projectId,
    required int otherChargesId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullOtherChargesForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class OtherChargesDatasourceImpl extends OtherChargesDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullOtherCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOtherChargesUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "OtherCharges/PullOtherCharges?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOtherChargesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<OtherChargeModel>.from(
          networkResponse["data"].map((e) => OtherChargeModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullOtherCharges(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateOtherCharges({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateOtherChargesUrl = "OtherCharges/AddUpdateOtherCharges";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateOtherChargesUrl,
        body,
      );
      return {
        'data': List<OtherChargeModel>.from(
          networkResponse["data"].map((e) => OtherChargeModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateOtherCharges(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteOtherCharges({
    required int projectId,
    required int otherChargesId,
    required String uniqueKey,
  }) async {
    String deleteOtherChargesUrl({
      required int projectId,
      required int otherChargesId,
      required String uniqueKey,
    }) {
      return "OtherCharges/DeleteOtherCharges?OtherChargesId=$otherChargesId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteOtherChargesUrl(
          projectId: projectId,
          otherChargesId: otherChargesId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteOtherCharges(
          projectId: projectId,
          otherChargesId: otherChargesId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullOtherChargesForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOtherChargesExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "OtherCharges/PullOtherCharges?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOtherChargesExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullOtherChargesForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
