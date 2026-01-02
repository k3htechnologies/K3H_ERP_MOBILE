import 'package:k3h_erp_app/features/masters/pay_roll_master/holiday_master/data/model/holiday_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class HolidayMasterDataSource {
  Future<Map<String, dynamic>> pullHolidays({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> appUpdateHoliday({
    required List<Map<String, dynamic>> fileList,
    required Map<String, String> body,
  });

  Future<Map<String, dynamic>> deleteHoliday({
    required int holidayMasterId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> pullHolidaysForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
}

class HolidayMasterDataSourceImpl extends HolidayMasterDataSource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> pullHolidays({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullHolidaysUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "HolidayMaster/PullHolidayMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullHolidaysUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<HolidayMasterModel>.from(
          networkResponse['data'].map((e) => HolidayMasterModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        pullHolidays(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> appUpdateHoliday({
    required List<Map<String, dynamic>> fileList,
    required Map<String, String> body,
  }) async {
    String addUpdateHolidayUrl = "HolidayMaster/AddUpdateHolidayMaster";

    try {
      var networkReponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateHolidayUrl,
            fileList,
            body,
          );
      return {
        'data': networkReponse['data'],
        'totalNumberOfRecord': networkReponse['totalNumberOfRecord'],
        'message': networkReponse['message'],
      };
    } catch (e) {
      if (e is TokenExpiredException) {
        appUpdateHoliday(fileList: fileList, body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteHoliday({
    required int holidayMasterId,
    required String uniqueKey,
  }) async {
    String deleteHolidayUrl({
      required int holidayMasterId,
      required String uniqueKey,
    }) {
      return "HolidayMaster/DeleteHolidayMaster?HolidayMasterId=$holidayMasterId&UniqueKey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteHolidayUrl(
          holidayMasterId: holidayMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (e) {
      if (e is TokenExpiredException) {
        deleteHoliday(holidayMasterId: holidayMasterId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> pullHolidaysForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullHolidaysExportUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "HolidayMaster/PullHolidayMaster?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullHolidaysExportUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (e) {
      if (e is TokenExpiredException) {
        pullHolidaysForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
