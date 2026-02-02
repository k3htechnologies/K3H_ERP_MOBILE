import 'package:k3h_erp_app/features/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class LitigationDatasource {
  Future<Map<String, dynamic>> apicallPullLitigation({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullLitigationHearing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallPullLitigationClosure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallPullLitigationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLitigation({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallPullDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class LitigationDatasourceImpl extends LitigationDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullLitigation({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLitigationUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Litigation/PullLitigation?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLitigationUrl(projectId: projectId, queryParams: queryParams),
      );
      return {
        'data': List<LitigationModel>.from(
          networkResponse["data"].map((e) => LitigationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullLitigation(
          projectId: projectId,
          queryParams: queryParams,
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      }
      rethrow;
    }
  }

  // EXPORT SHIFT
  @override
  Future<Map<String, dynamic>> apiCallPullLitigationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullShiftExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Litigation/PullLitigation?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullShiftExportUrl(
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
        apiCallPullLitigationForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  // ADD / UPDATE LITIGATION
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLitigation({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateLitigationUrl = "Litigation/AddUpdateLitigation";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateLitigationUrl,
        body,
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateLitigation(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLitigationClosure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  }) async {
    String pullLitigationClosureUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Litigation/PullLitigationClosure?PageSize=$pageSize&PageNumber=$pageNumber"
          "&ProjectId=$projectId&LitigationId=$litigationId";

      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLitigationClosureUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<LitigationModel>.from(
          networkResponse['data'].map((e) => LitigationModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLitigationClosure(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          litigationId: litigationId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullLitigationHearing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullLitigationHearingUrl({
      required int projectId,
      required int litigationId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Litigation/PullLitigationHearing?PageSize=$pageSize&PageNumber=$pageNumber"
          "&ProjectId=$projectId&LitigationId=$litigationId";

      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullLitigationHearingUrl(
          projectId: projectId,
          litigationId: litigationId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<LitigationHearingModel>.from(
          networkResponse['data'].map(
            (e) => LitigationHearingModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullLitigationHearing(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          litigationId: litigationId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDocumentUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LitigationDocument/PullLitigationDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDocumentUrl(projectId: projectId, queryParams: queryParams),
      );

      return {
        'data': List<LitigationDocumentModel>.from(
          networkResponse['data'].map(
            (e) => LitigationDocumentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
