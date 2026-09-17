import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/datasource/test_document.datasource.dart';

abstract interface class TestDocumentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullTestDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateTestDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteTestDocument({
    required int testDocumentId,
    required int projectId,
    required int testDocumentCategoryId,
    required String uniqueKey,
  });
}

class TestDocumentRepositoryImpl extends TestDocumentRepository {
  final TestDocumentDatasource testDocumentDatasource;

  TestDocumentRepositoryImpl({required this.testDocumentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullTestDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await testDocumentDatasource.apicallPullTestDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTestDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await testDocumentDatasource.apiCallAddUpdateTestDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTestDocument({
    required int testDocumentId,
    required int projectId,
    required int testDocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await testDocumentDatasource.apicallDeleteTestDocument(
        testDocumentId: testDocumentId,
        projectId: projectId,
        testDocumentCategoryId: testDocumentCategoryId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
