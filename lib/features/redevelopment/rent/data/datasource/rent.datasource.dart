import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class RentDatasource {
  Future<Map<String, dynamic>> apicallPullTenantApplicantCharges({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });
}

class RentDatasourceImpl implements RentDatasource {
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
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTenantApplicantChargesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          buildingId: buildingId,
          queryParams: queryParams
        ),
      );
      return {
        'data': List<RentModel>.from(
          networkResponse["data"].map((e) => RentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

}
