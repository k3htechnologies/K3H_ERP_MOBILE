import 'package:k3h_erp_app/features/marketing/content/data/model/content_document.model.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_folder.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ContentDataSource {
  Future<Map<String, dynamic>> apicallPullMarketingContentFolder({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullMarketingContent({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int marketingContentFolderId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateMarketingContentFolder({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallAddUpdateContentDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteMarketingContentFolder({
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallDeleteMarketingContent({
    required int marketingContentId,
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  });
}

class ContentDataSourceImpl implements ContentDataSource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullMarketingContentFolder({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullMarketingContentFolderUrl({
        required int pageNumber,
        required int pageSize,
        required int projectId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MarketingContent/PullMarketingContentFolder?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullMarketingContentFolderUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ContentFolderModel>.from(
          networkResponse["data"].map((e) => ContentFolderModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullMarketingContentFolder(
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
  Future<Map<String, dynamic>> apicallPullMarketingContent({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int marketingContentFolderId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullMarketingContentUrl({
      required int pageNumber,
      required int pageSize,
      required int projectId,
      required int marketingContentFolderId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "MarketingContent/PullMarketingContent?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId&MarketingContentFolderId=$marketingContentFolderId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullMarketingContentUrl(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          marketingContentFolderId: marketingContentFolderId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ContentDocumentModel>.from(
          networkResponse["data"].map((e) => ContentDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullMarketingContent(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          marketingContentFolderId: marketingContentFolderId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateMarketingContentFolder({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateMarketingContentFolderUrl =
          "MarketingContent/AddUpdateMarketingContentFolder";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateMarketingContentFolderUrl,
        body,
      );
      return {
        'data': List<ContentFolderModel>.from(
          networkResponse["data"].map((e) => ContentFolderModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateMarketingContentFolder(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateContentDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateMarketingContentUrl =
          "MarketingContent/AddUpdateMarketingContent";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateMarketingContentUrl,
            fileList,
            body,
          );
      return {
        'data': List<ContentDocumentModel>.from(
          networkResponse["data"].map((e) => ContentDocumentModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateContentDocument(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteMarketingContentFolder({
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      String deleteMarketingContentFolderUrl({
        required int marketingContentFolderId,
        required int projectId,
        required String uniquekey,
      }) {
        return "MarketingContent/DeleteMarketingContentFolder?MarketingContentFolderId=$marketingContentFolderId&Uniquekey=$uniquekey&ProjectId=$projectId";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteMarketingContentFolderUrl(
          marketingContentFolderId: marketingContentFolderId,
          projectId: projectId,
          uniquekey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteMarketingContentFolder(
          marketingContentFolderId: marketingContentFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteMarketingContent({
    required int marketingContentId,
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      String deleteMarketingContentUrl({
        required int marketingContentId,
        required int projectId,
        required int marketingContentFolderId,
        required String uniquekey,
      }) {
        return "MarketingContent/DeleteMarketingContent?MarketingContentId=$marketingContentId&Uniquekey=$uniquekey&ProjectId=$projectId&MarketingContentFolderId=$marketingContentFolderId";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteMarketingContentUrl(
          marketingContentId: marketingContentId,
          projectId: projectId,
          marketingContentFolderId: marketingContentFolderId,
          uniquekey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteMarketingContent(
          marketingContentId: marketingContentId,
          marketingContentFolderId: marketingContentFolderId,
          projectId: projectId,
          uniqueKey: uniqueKey,
        );
      }
      rethrow;
    }
  }
}
