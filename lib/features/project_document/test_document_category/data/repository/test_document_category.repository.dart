import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/datasource/test_document_category.datasource.dart';

abstract interface class TestDocumentCategoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTestDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class TestDocumentCategoryRepositoryImpl
    extends TestDocumentCategoryRepository {
  final TestDocumentCategoryDatasource testDocumentCategoryDatasource;

  TestDocumentCategoryRepositoryImpl({
    required this.testDocumentCategoryDatasource,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> getTestDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await testDocumentCategoryDatasource
          .apicallPullTestDocumentCategory(
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
}
