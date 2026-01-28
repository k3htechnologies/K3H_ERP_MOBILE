import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off_dates.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class CompOffDatasource {
  Future<Map<String, dynamic>> apicallPullCompOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullCompOffDates({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateCompOff({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteCompOff({
    required int compOffId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullCompOffExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CompOffDatasourceImpl implements CompOffDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullCompOff({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCompOffUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CompOff/PullCompOff?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompOffUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CompOffModel>.from(
          networkResponse["data"].map((e) => CompOffModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullCompOff(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullCompOffDates({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCompOffDatesUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CompOff/PullCompOffDates?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompOffDatesUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<CompOffDatesModel>.from(
          networkResponse["data"].map((e) => CompOffDatesModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullCompOffDates(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateCompOff({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateCompOffUrl = "CompOff/AddUpdateCompOff";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateCompOffUrl,
        body,
      );
      return {
        'data': List<CompOffModel>.from(
          networkResponse["data"].map((e) => CompOffModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateCompOff(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCompOff({
    required int compOffId,
    required String uniqueKey,
  }) async {
    String deleteCompOffUrl({
      required int compOffId,
      required String uniqueKey,
    }) {
      return "CompOff/DeleteCompOff?CompOffId=$compOffId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteCompOffUrl(compOffId: compOffId, uniqueKey: uniqueKey),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteCompOff(compOffId: compOffId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullCompOffExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullCompOffExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "CompOff/PullCompOff?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompOffExportUrl(
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
        apicallPullCompOffExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
