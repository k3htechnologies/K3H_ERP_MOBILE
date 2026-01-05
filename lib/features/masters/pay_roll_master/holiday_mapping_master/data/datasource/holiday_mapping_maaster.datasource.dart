import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_mapping_master/data/model/holiday_mapping_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class HolidayMappingMasterDatasource {
  Future<Map<String, dynamic>> apiCallPullHolidayMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateHolidayMapping({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteHolidayMapping({
    required int holidayMappingMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullHolidayMappingForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class HolidayMappingMasterDatasourceImpl
    extends HolidayMappingMasterDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apiCallPullHolidayMapping({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullHolidayMappingUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "HolidayMappingMaster/PullHolidayMappingMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullHolidayMappingUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<HolidayMappingModel>.from(
          networkResponse["data"].map((e) => HolidayMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullHolidayMapping(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateHolidayMapping({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateMappedHolidayUrl =
        "HolidayMappingMaster/AddUpdateHolidayMappingMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateMappedHolidayUrl,
        body,
      );
      return {
        'data': List<HolidayMappingModel>.from(
          networkResponse["data"].map((e) => HolidayMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateHolidayMapping(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteHolidayMapping({
    required int holidayMappingMasterId,
    required String uniqueKey,
  }) async {
    String deleteHolidayMappingUrl({
      required int holidayMappingMasterId,
      required String uniqueKey,
    }) {
      return "HolidayMappingMaster/DeleteHolidayMaster?HolidayMappingMasterId=$holidayMappingMasterId&UniqueKey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteHolidayMappingUrl(
          holidayMappingMasterId: holidayMappingMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteHolidayMapping(
          holidayMappingMasterId: holidayMappingMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullHolidayMappingForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullMappedHolidaysExportUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "HolidayMappingMaster/PullHolidayMappingMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullMappedHolidaysExportUrl(
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
        apicallPullHolidayMappingForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
