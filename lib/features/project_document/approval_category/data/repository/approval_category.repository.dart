import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/datasource/approval_category.datasource.dart';

abstract interface class ApprovalCategoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getApprovalDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateApprovalDocumentCategory({required Map<String, dynamic> body});

  Future<Either<Failure, Map<String, dynamic>>> deleteApprovalDocumentCategory({
    required int projectApprovalDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportApprovalCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ApprovalCategoryRepositoryImpl implements ApprovalCategoryRepository {
  final ApprovalCategoryDatasource documentCategoryDatasource;

  ApprovalCategoryRepositoryImpl({required this.documentCategoryDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getApprovalDocumentCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallPullProjectApprovalDocumentCategory(
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
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateApprovalDocumentCategory({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallAddUpdateProjectApprovalDocumentCategory(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteApprovalDocumentCategory({
    required int projectApprovalDocumentCategoryId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallDeleteProjectApprovalDocumentCategory(
            projectApprovalDocumentCategoryId:
                projectApprovalDocumentCategoryId,
            projectId: projectId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportApprovalCategory({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentCategoryDatasource
          .apicallPullProjectApprovalCategoryForExport(
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
