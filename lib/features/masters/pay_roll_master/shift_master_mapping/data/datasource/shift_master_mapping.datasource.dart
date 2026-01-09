import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master_mapping/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ShiftMappingMasterDatasource {
  Future<Map<String, dynamic>> apiCallPullShiftMappedShift({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateMappedShift({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallDeleteMappedShift({
    required int shiftMasterMappingId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apiCallPullMappedShiftsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ShiftMappingMasterDataSourceImp extends ShiftMappingMasterDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullShiftMappedShift({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftMappingMastersUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ShiftManagementMasterMapping/PullShiftManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftMappingMastersUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ShiftMappingModel>.from(
          networkResponse['data'].map((e) => ShiftMappingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullShiftMappedShift(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateMappedShift({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateShiftMappingMasterUrl =
        "ShiftManagementMasterMapping/AddUpdateShiftManagementMasterMapping";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateShiftMappingMasterUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateMappedShift(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallDeleteMappedShift({
    required int shiftMasterMappingId,
    required String uniqueKey,
  }) async {
    String deleteShiftMappingMasterUrl({
      required int shiftMasterMappingId,
      required String uniqueKey,
    }) {
      return "ShiftManagementMasterMapping/DeleteShiftManagementMasterMapping?ShiftManagementMasterMappingId=$shiftMasterMappingId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteShiftMappingMasterUrl(
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
  Future<Map<String, dynamic>> apiCallPullMappedShiftsForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftMappingMastersExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ShiftManagementMasterMapping/PullShiftManagementMasterMapping?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftMappingMastersExportUrl(
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
        apiCallPullMappedShiftsForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
