import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/datasource/approval_document.datasource.dart';

abstract interface class ApprovalDocumentRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullProjectApprovalDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovalDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteApprovalDocument({
    required int approvalDocumentId,
    required int projectId,
    required int approvalDocumentCategoryId,
    required String uniqueKey,
  });
}

class ApprovalDocumentRepositoryImpl implements ApprovalDocumentRepository {
  final ApprovalDocumentDatasource documentDatasource;

  ApprovalDocumentRepositoryImpl({required this.documentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullProjectApprovalDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await documentDatasource.apicallPullProjectApprovalDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovalDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await documentDatasource.apiCallAddUpdateApprovalDocument(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteApprovalDocument({
    required int approvalDocumentId,
    required int projectId,
    required int approvalDocumentCategoryId,
    required String uniqueKey,
  }) async {
    try {
      var result = await documentDatasource.apicallDeleteApprovalDocument(
        approvalDocumentId: approvalDocumentId,
        projectId: projectId,
        approvalDocumentCategoryId: approvalDocumentCategoryId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
