import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/model/notice_section.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class NoticeSectionMasterDatasource {
  Future<Map<String, dynamic>> apiCallPullNoticeSection({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallPullNoticeSectionForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apiCallAddUpdateNoticeSection({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteNoticeSection({
    required int noticeSectionMasterId,
    required String uniqueKey,
  });
}

class NoticeSectionMasterDatasourceImpl
    implements NoticeSectionMasterDatasource {
  final BaseClient baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apiCallPullNoticeSection({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullNoticeSection({Map<String, dynamic>? queryParams}) {
      String url =
          "NoticeSectionMaster/PullNoticeSectionMaster?pageNumber=$pageNumber&pageSize=$pageSize";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullNoticeSection(queryParams: queryParams),
      );
      return {
        'data': List<NoticeSectionModel>.from(
          networkResponse["data"].map((e) => NoticeSectionModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullNoticeSection(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateNoticeSection({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectNoticeSectionUrl =
        "NoticeSectionMaster/AddUpdateNoticeSectionMaster";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectNoticeSectionUrl,
        body,
      );
      return {
        'data': List<NoticeSectionModel>.from(
          networkResponse["data"].map((e) => NoticeSectionModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateNoticeSection(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteNoticeSection({
    required int noticeSectionMasterId,
    required String uniqueKey,
  }) async {
    String deleteProjectNoticeSectionUrl({
      required int noticeSectionMasterId,
      required String uniqueKey,
    }) {
      return "NoticeSectionMaster/DeleteNoticeSectionMaster?NoticeSectionMasterId=$noticeSectionMasterId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectNoticeSectionUrl(
          noticeSectionMasterId: noticeSectionMasterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteNoticeSection(
          noticeSectionMasterId: noticeSectionMasterId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullNoticeSectionForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullNoticeSection({Map<String, dynamic>? queryParams}) {
      String url =
          "NoticeSectionMaster/PullNoticeSectionMaster?pageNumber=$pageNumber&pageSize=$pageSize";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullNoticeSection(queryParams: queryParams),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullNoticeSection(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
