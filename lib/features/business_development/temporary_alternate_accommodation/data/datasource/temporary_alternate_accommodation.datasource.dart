import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class TemporaryAlternateAccommodationDatasource {
  Future<Map<String, dynamic>> apicallPullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdatePayTrackRent({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallPullPayTrackRentLedger({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallDeletePayTrackRent({
    required int payTrackRentId,
    required String uniqueKey,
    required int projectId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
  });
}

class TemporaryAlternateAccommodationDatasourceImpl
    implements TemporaryAlternateAccommodationDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTenantApplicantChargesUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Rent/PullTenantApplicantCharges?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTenantApplicantChargesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TemporaryAlternativeAccommodationModel>.from(
          networkResponse["data"].map(
            (e) => TemporaryAlternativeAccommodationModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTenantApplicantCharges(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdatePayTrackRent({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdatePayTrackRentUrl = "PayTrackRent/AddUpdatePayTrackRent";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdatePayTrackRentUrl,
            fileList,
            requestBody,
          );
      return networkResponse;
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdatePayTrackRent(
          requestBody: requestBody,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullPayTrackRentLedger({
    required int pageNumber,
    required int pageSize,
    required int tenantId,
    required int tenantApplicantId,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPayTrackRentLedgerUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int buildingId,
      required int tenantId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "PayTrackRent/PullPayTrackRentLedger?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&BuildingId=$buildingId&TenantId=$tenantId";

      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullPayTrackRentLedgerUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          tenantId: tenantId,
          queryParams: {
            ...?queryParams,
            'PageNumber': pageNumber.toString(),
            'PageSize': pageSize.toString(),
            'TenantApplicantId': tenantApplicantId.toString(),
          },
        ),
      );
      return {
        'data': List<PaymentLedgerModel>.from(
          networkResponse["data"].map((e) => PaymentLedgerModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullPayTrackRentLedger(
          pageNumber: pageNumber,
          pageSize: pageSize,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeletePayTrackRent({
    required int payTrackRentId,
    required String uniqueKey,
    required int projectId,
    required int tenantId,
    required int tenantApplicantId,
    required int buildingId,
  }) async {
    String deletePayTrackRentUrl({
      required int payTrackRentId,
      required String uniqueKey,
      required int projectId,
      required int tenantId,
      required int tenantApplicantId,
      required int buildingId,
    }) {
      return "PayTrackRent/DeletePayTrackRent?PayTrackRentId=$payTrackRentId&Uniquekey=$uniqueKey&ProjectId=$projectId&TenantId=$tenantId&TenantApplicantId=$tenantApplicantId&BuildingId=$buildingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deletePayTrackRentUrl(
          payTrackRentId: payTrackRentId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
          buildingId: buildingId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeletePayTrackRent(
          payTrackRentId: payTrackRentId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          tenantId: tenantId,
          tenantApplicantId: tenantApplicantId,
          buildingId: buildingId,
        );
      }
      rethrow;
    }
  }
}
