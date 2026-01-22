import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class OutdoorDatasource {
  Future<Map<String, dynamic>> apicallPullOutdoor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddOutdoorAttendance({
    required Map<String, dynamic> body,
  });
  //
  // Future<Map<String, dynamic>> apicallDeleteDepartmentMaster({
  //   required int departmentMasterId,
  //   required String uniqueKey,
  // });
  //
  Future<Map<String, dynamic>> apicallPullOutdoorForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class OutdoorDatasourceDataSourceImpl implements OutdoorDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullOutdoor({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOutdoorUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Outdoor/PullOutdoor?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOutdoorUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<OutdoorModel>.from(
          networkResponse["data"].map((e) => OutdoorModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullOutdoor(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddOutdoorAttendance({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateDepartmentUrl =
          "Outdoor/AddOutdoorAttendance";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateDepartmentUrl,
        body,
      );
      return {
        'data': List<OutdoorModel>.from(
          networkResponse["data"].map((e) => OutdoorModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddOutdoorAttendance(body: body);
      }
      rethrow;
    }
  }
  //
  // @override
  // Future<Map<String, dynamic>> apicallDeleteDepartmentMaster({
  //   required int departmentMasterId,
  //   required String uniqueKey,
  // }) async {
  //   String deleteDepartmentUrl({
  //     required int departmentMasterId,
  //     required String uniqueKey,
  //   }) {
  //     return "DepartmentMaster/DeleteDepartmentMaster?DepartmentMasterId=$departmentMasterId&Uniquekey=$uniqueKey";
  //   }
  //
  //   try {
  //     var networkResponse = await baseClient.deleteRequestWithAuthentication(
  //       deleteDepartmentUrl(
  //         departmentMasterId: departmentMasterId,
  //         uniqueKey: uniqueKey,
  //       ),
  //     );
  //     return {
  //       'data': networkResponse["data"],
  //       'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
  //     };
  //   } catch (error) {
  //     if (error is TokenExpiredException) {
  //       return apicallDeleteDepartmentMaster(
  //         departmentMasterId: departmentMasterId,
  //         uniqueKey: uniqueKey,
  //       );
  //     }
  //     rethrow;
  //   }
  // }
  //
  @override
  Future<Map<String, dynamic>> apicallPullOutdoorForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullOutdoorExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Outdoor/PullOutdoor?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullOutdoorExportUrl(
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
        apicallPullOutdoorForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
