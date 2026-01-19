import 'package:k3h_erp_app/features/parking/data/model/parking.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ParkingDatasource {
  Future<Map<String, dynamic>> apicallPullParking({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullParkingWithPagination({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallUpdateParking({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullParkingForExport({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  });
}

class ParkingDatasourceImpl implements ParkingDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullParking({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullParkingUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Parking/PullParking?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullParkingUrl(projectId: projectId, queryParams: queryParams),
      );
      return {
        'data': List<ParkingModel>.from(
          networkResponse["data"].map((e) => ParkingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullParking(projectId: projectId, queryParams: queryParams);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullParkingWithPagination({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullParkingWithPaginationUrl({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Parking/PullParkingWithPagination?ProjectId=$projectId&pageNumber=$pageNumber&pageSize=$pageSize";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullParkingWithPaginationUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ParkingModel>.from(
          networkResponse["data"].map((e) => ParkingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullParkingWithPagination(
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
  Future<Map<String, dynamic>> apicallUpdateParking({
    required Map<String, dynamic> body,
  }) async {
    String updateParkingUrl = "Parking/UpdateParking";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateParkingUrl,
        body,
      );
      return {
        'data': List<ParkingModel>.from(
          networkResponse["data"].map((e) => ParkingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallUpdateParking(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullParkingForExport({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  }) async {
    String pullParkingExportUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Parking/PullParking?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullParkingExportUrl(projectId: projectId),
      );
      return {
        'data': networkResponse["data"] ?? networkResponse["Data"],
        'totalNumberOfRecord':
            networkResponse['totalNumberOfRecord'] ??
            networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullParkingForExport(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
