import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_document.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class LitigationDatasource {
  Future<Map<String, dynamic>> apicallPullLitigation({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLitigation({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallDeleteLitigation({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Map<String, dynamic>> apiCallPullLitigationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullLitigationHearing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLitigationHearing({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteLitigationHearing({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationHearingId,
  });

  Future<Map<String, dynamic>> apicallPullLitigationClosure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLitigationClosure({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallPullDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateLitigationDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteLitigationDocument({
    required int litigationId,
    required int litigationDocumentId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Map<String, dynamic>> apicallUpdateLitigationReopen({
    required Map<String, dynamic> body,
  });
}

class LitigationDatasourceImpl extends LitigationDatasource {
  final baseClient = BaseClient();

  //GET LITIGATION
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

  //DELETE LITIGAITON
  @override
  Future<Map<String, dynamic>> apicallDeleteLitigation({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteLitigationUrl({
      required int litigationId,
      required String uniqueKey,
      required int projectId,
    }) {
      return "Litigation/DeleteLitigation?LitigationId=$litigationId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLitigationUrl(
          litigationId: litigationId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteLitigation(
          litigationId: litigationId,
          uniqueKey: uniqueKey,
          projectId: projectId,
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

  // EXPORT LITIGATION
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

  // GET LITIGATION HEARING
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

  // ADD / UPDATE LITIGATION HEARING
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLitigationHearing({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateLitigationUrl = "Litigation/AddUpdateLitigationHearing";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateLitigationUrl,
            fileList,
            body,
          );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateLitigationHearing(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  //DELETE LITIGATION HEARING
  @override
  Future<Map<String, dynamic>> apicallDeleteLitigationHearing({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationHearingId,
  }) async {
    String deleteLitigationHearingUrl({
      required int litigationId,
      required String uniqueKey,
      required int projectId,
      required int litigationHearingId,
    }) {
      return "Litigation/DeleteLitigationHearing?LitigationId=$litigationId&Uniquekey=$uniqueKey&ProjectId=$projectId&LitigationHearingId=$litigationHearingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLitigationHearingUrl(
          litigationId: litigationId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          litigationHearingId: litigationHearingId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteLitigationHearing(
          litigationId: litigationId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          litigationHearingId: litigationHearingId,
        );
      }
      rethrow;
    }
  }

  // GET LITIGATION CLOSURE
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

  // ADD / UPDATE LITIGATION CLOSURE
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLitigationClosure({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateLitigationUrl = "Litigation/AddUpdateLitigationClosure";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateLitigationUrl,
            fileList,
            body,
          );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateLitigationClosure(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  //GET LITIGATION DOCUMENTS
  @override
  Future<Map<String, dynamic>> apicallPullDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullDocumentUrl({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      required int litigationId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "LitigationDocument/PullLitigationDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&LitigationId=$litigationId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullDocumentUrl(
          projectId: projectId,
          pageNumber: pageNumber,
          pageSize: pageSize,
          litigationId: litigationId,
          queryParams: queryParams,
        ),
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
          litigationId: litigationId,
        );
      }
      rethrow;
    }
  }

  // ADD / UPDATE LITIGATION DOCUMENT
  @override
  Future<Map<String, dynamic>> apiCallAddUpdateLitigationDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateLitigationUrl =
        "LitigationDocument/AddUpdateLitigationDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateLitigationUrl,
            fileList,
            body,
          );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateLitigationDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  //DELETE LITIGATION DOCUMENTS
  @override
  Future<Map<String, dynamic>> apicallDeleteLitigationDocument({
    required int litigationId,
    required int litigationDocumentId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteLitigationDocumentUrl({
      required int litigationId,
      required String uniqueKey,
      required int litigationDocumentId,
      required int projectId,
    }) {
      return "LitigationDocument/DeleteLitigationDocument?LitigationDocumentId=$litigationDocumentId&Uniquekey=$uniqueKey&ProjectId=$projectId&LitigationId=$litigationId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteLitigationDocumentUrl(
          litigationId: litigationId,
          uniqueKey: uniqueKey,
          projectId: projectId,
          litigationDocumentId: litigationDocumentId,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteLitigationDocument(
          litigationId: litigationId,
          litigationDocumentId: litigationDocumentId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  // REQUEST FOR LITIGATION REOPEN
  @override
  Future<Map<String, dynamic>> apicallUpdateLitigationReopen({
    required Map<String, dynamic> body,
  }) async {
    String updateLitigationReopen = 'Litigation/UpdateLitigationReopen';

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateLitigationReopen,
        body,
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallUpdateLitigationReopen(body: body);
      }
      rethrow;
    }
  }
}
