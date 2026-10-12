import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/inventory_drawing_document.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class DrawingDocumentDatasource {
  Future<Map<String, dynamic>> apicallPullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apiCallAddUpdateDrawingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteDrawingDocument({
    required int drawingDocumentId,
    required int projectId,
    required int drawingDocumentCategoryId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullInventoryDrawingDocument({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DrawingDocumentDatasourceImpl extends DrawingDocumentDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullDrawingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDocumentUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DrawingDocument/PullDrawingDocument?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDocumentUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DrawingDocumentModel>.from(
          networkResponse["data"].map((e) => DrawingDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullDrawingDocument(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddUpdateDrawingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String addUpdateProjectDocumentUrl =
        "DrawingDocument/AddUpdateDrawingDocument";

    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateProjectDocumentUrl,
            fileList,
            body,
          );
      return {
        'data': List<DrawingDocumentModel>.from(
          networkResponse["data"].map((e) => DrawingDocumentModel.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallAddUpdateDrawingDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDrawingDocument({
    required int drawingDocumentId,
    required int projectId,
    required int drawingDocumentCategoryId,
    required String uniqueKey,
  }) async {
    String deleteProjectDocumentUrl({
      required int drawingDocumentId,
      required int projectId,
      required int drawingDocumentCategoryId,
      required String uniqueKey,
    }) {
      return "DrawingDocument/DeleteDrawingDocument?DrawingDocumentId=$drawingDocumentId&ProjectId=$projectId&DrawingDocumentCategoryId=$drawingDocumentCategoryId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectDocumentUrl(
          drawingDocumentId: drawingDocumentId,
          drawingDocumentCategoryId: drawingDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteDrawingDocument(
          drawingDocumentId: drawingDocumentId,
          projectId: projectId,
          drawingDocumentCategoryId: drawingDocumentCategoryId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullInventoryDrawingDocument({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInventoryDrawingDocumentUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DrawingDocument/PullInventoryDrawingDocument?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInventoryDrawingDocumentUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<InventoryDrawingDocumentModel>.from(
          networkResponse["data"].map(
            (e) => InventoryDrawingDocumentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        pullInventoryDrawingDocumentUrl(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
