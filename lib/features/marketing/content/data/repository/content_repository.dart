import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/marketing/content/data/datasource/content_datasource.dart';

abstract interface class ContentRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMarketingContentFolderList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getMarketingContentList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int marketingContentFolderId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateContentFolder({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateContentDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteMarketingContentFolder({
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteMarketingContent({
    required int marketingContentFolderId,
    required int marketingContentId,
    required int projectId,
    required String uniqueKey,
  });
}

class ContentRepositoryImpl implements ContentRepository {
  final ContentDataSource contentDatasource;

  ContentRepositoryImpl({required this.contentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMarketingContentFolderList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await contentDatasource.apicallPullMarketingContentFolder(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMarketingContentList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int marketingContentFolderId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await contentDatasource.apicallPullMarketingContent(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        marketingContentFolderId: marketingContentFolderId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateContentFolder({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await contentDatasource
          .apicallAddUpdateMarketingContentFolder(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateContentDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await contentDatasource.apicallAddUpdateContentDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteMarketingContentFolder({
    required int marketingContentFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await contentDatasource.apicallDeleteMarketingContentFolder(
        marketingContentFolderId: marketingContentFolderId,
        projectId: projectId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteMarketingContent({
    required int marketingContentFolderId,
    required int marketingContentId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await contentDatasource.apicallDeleteMarketingContent(
        marketingContentId: marketingContentId,
        marketingContentFolderId: marketingContentFolderId,
        projectId: projectId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
