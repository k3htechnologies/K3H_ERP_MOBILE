import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry.model.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/model/enquiry_followup.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/common_function.dart';

abstract interface class EnquiryDatasource {
  Future<Map<String, dynamic>> apiCallPullEnquiry({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateEnquiry({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullEnquiryFollowUp({
    required int pageNumber,
    required int projectId,

    required int pageSize,
    required int enquiryId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateEnquiryFollowUp({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullEnquiryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallDeleteEnquiryFollowUp({
    required int projectId,
    required int enquiryId,
    required int followUpId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallDeleteEnquiry({
    required int enquiryId,
    required int projectId,
    required String uniqueKey,
  });
}

class EnquiryDatasourceImpl extends EnquiryDatasource {
  final BaseClient baseClient = BaseClient();

  /// FETCH ENQUIRY LIST
  @override
  Future<Map<String, dynamic>> apiCallPullEnquiry({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEnquiryUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Enquiry/PullEnquiry?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEnquiryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<EnquiryModel>.from(
          networkResponse["data"].map((e) => EnquiryModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullEnquiry(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  /// ADD OR UPDATE ENQUIRY
  @override
  Future<Map<String, dynamic>> apicallAddUpdateEnquiry({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectDocumentCategoryUrl = "Enquiry/AddUpdateEnquiry";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<EnquiryModel>.from(
          networkResponse["data"].map((e) => EnquiryModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateEnquiry(body: body);
      }
      rethrow;
    }
  }

  /// EXPORT ENQUIRY DATA
  @override
  Future<Map<String, dynamic>> apiCallPullEnquiryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEnquiryExportUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Enquiry/PullEnquiry?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEnquiryExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse["data"], // RAW for Excel export
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullEnquiryForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  /// FETCH ENQUIRY FOLLOW-UP LIST
  @override
  Future<Map<String, dynamic>> apiCallPullEnquiryFollowUp({
    required int pageNumber,
    required int pageSize,
    required int enquiryId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullEnquiryFollowUpUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      required int enquiryId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "EnquiryFollowUp/PullEnquiryFollowUp?PageSize=$pageSize&PageNumber=$pageNumber&EnquiryId=$enquiryId&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullEnquiryFollowUpUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          enquiryId: enquiryId,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<EnquiryFollowUpModel>.from(
          networkResponse["data"].map((e) => EnquiryFollowUpModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apiCallPullEnquiryFollowUp(
          pageNumber: pageNumber,
          pageSize: pageSize,
          enquiryId: enquiryId,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  /// ADD OR UPDATE ENQUIRY FOLLOW-UP
  @override
  Future<Map<String, dynamic>> apicallAddUpdateEnquiryFollowUp({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectDocumentCategoryUrl =
        "EnquiryFollowUp/AddUpdateEnquiryFollowUp";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<EnquiryFollowUpModel>.from(
          networkResponse["data"].map((e) => EnquiryFollowUpModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateEnquiryFollowUp(body: body);
      }
      rethrow;
    }
  }

  /// DELETE ENQUIRY FOLLOW-UP
  @override
  Future<Map<String, dynamic>> apicallDeleteEnquiryFollowUp({
    required int followUpId,
    required int enquiryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteFollowUpUrl({
      required int enquiryId,
      required int followUpId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "EnquiryFollowUp/DeleteEnquiryFollowUp?"
          "EnquiryFollowUpId=$followUpId"
          "&Uniquekey=$uniqueKey"
          "&EnquiryId=$enquiryId"
          "&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteFollowUpUrl(
          followUpId: followUpId,
          uniqueKey: uniqueKey,
          enquiryId: enquiryId,
          projectId: projectId,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      // Handle token expiration by retrying once
      if (error is TokenExpiredException) {
        return apicallDeleteEnquiryFollowUp(
          followUpId: followUpId,
          uniqueKey: uniqueKey,
          enquiryId: enquiryId,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  // DELETE ENQUIRY
  @override
  Future<Map<String, dynamic>> apicallDeleteEnquiry({
    required int enquiryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteFollowUpUrl({
      required int enquiryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "Enquiry/DeleteEnquiry?"
          "Uniquekey=$uniqueKey"
          "&EnquiryId=$enquiryId"
          "&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteFollowUpUrl(
          uniqueKey: uniqueKey,
          enquiryId: enquiryId,
          projectId: projectId,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse["message"],
      };
    } catch (error) {
      // Handle token expiration by retrying once
      if (error is TokenExpiredException) {
        return apicallDeleteEnquiry(
          uniqueKey: uniqueKey,
          enquiryId: enquiryId,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
