import 'package:k3h_erp_app/features/masters/employee_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class WeekOffMappingMasterDatasource {
  Future<Map<String, dynamic>> apiCallPullWeekOffMappedWeekOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateMappedWeekOff({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallDeleteMappedWeekOff({
    required int shiftMasterMappingId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallPullMappedWeekOffsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class WeekOffMappingMasterDataSourceImp extends WeekOffMappingMasterDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullWeekOffMappedWeekOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullWeekOffMappingMastersUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "WeekOffManagementMasterMapping/PullWeekOffManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullWeekOffMappingMastersUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<WeekOffMappingModel>.from(
          networkResponse['data'].map((e) => WeekOffMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullWeekOffMappedWeekOff(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateMappedWeekOff({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateWeekOffMappingMasterUrl =
        "WeekOffManagementMasterMapping/AddUpdateWeekOffManagementMasterMapping";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateWeekOffMappingMasterUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateMappedWeekOff(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteMappedWeekOff({
    required int shiftMasterMappingId,
    required String uniqueKey,
  }) async {
    String deleteWeekOffMappingMasterUrl({
      required int shiftMasterMappingId,
      required String uniqueKey,
    }) {
      return "WeekOffManagementMasterMapping/DeleteWeekOffManagementMasterMapping?WeekOffManagementMasterMappingId=$shiftMasterMappingId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteWeekOffMappingMasterUrl(
          shiftMasterMappingId: shiftMasterMappingId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullMappedWeekOffsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullWeekOffMappingMastersExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "WeekOffManagementMasterMapping/PullWeekOffManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullWeekOffMappingMastersExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullMappedWeekOffsForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
