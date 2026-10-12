import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class DrawingDocumentCategoryDatasource {
  Future<Map<String, dynamic>> apicallPullDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateDrawingDocumentCategory({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteDrawingDocumentCategory({
    required int drawingDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallPulDrawingDocumentCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class DrawingDocumentCategoryDatasourceImpl
    extends DrawingDocumentCategoryDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullDrawingDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProjectDocumentCategoryUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DrawingDocumentCategory/PullDrawingDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProjectDocumentCategoryUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<DrawingDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => DrawingDocumentCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullDrawingDocumentCategory(
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
  Future<Map<String, dynamic>> apicallAddUpdateDrawingDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateProjectDocumentCategoryUrl =
        "DrawingDocumentCategory/AddUpdateDrawingDocumentCategory";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProjectDocumentCategoryUrl,
        body,
      );
      return {
        'data': List<DrawingDocumentCategoryModel>.from(
          networkResponse["data"].map(
            (e) => DrawingDocumentCategoryModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateDrawingDocumentCategory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteDrawingDocumentCategory({
    required int drawingDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    String deleteProjectDrawingDocumentCategoryUrl({
      required int drawingDocumentCategoryId,
      required int projectId,
      required String uniqueKey,
    }) {
      return "DrawingDocumentCategory/DeleteDrawingDocumentCategory?DrawingDocumentCategoryId=$drawingDocumentCategoryId&ProjectId=$projectId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteProjectDrawingDocumentCategoryUrl(
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
        apicallDeleteDrawingDocumentCategory(
          drawingDocumentCategoryId: drawingDocumentCategoryId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPulDrawingDocumentCategoryForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullChannelPartnerExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "DrawingDocumentCategory/PullDrawingDocumentCategory?PageSize=$pageSize&PageNumber=$pageNumber&projectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullChannelPartnerExportUrl(
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
        apicallPulDrawingDocumentCategoryForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
