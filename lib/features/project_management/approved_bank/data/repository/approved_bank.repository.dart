import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/datasource/approved_bank.datasource.dart';

abstract interface class ApprovedBankRepository {
  Future<Either<Failure, Map<String, dynamic>>> getApprovedBankFolderList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getApprovedBankFileList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovedBankFolder({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovedBankFile({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteApprovedBankFolder({
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteApprovedBankFile({
    required int approvedBankFileId,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  });
}

class ApprovedBankRepositoryImpl extends ApprovedBankRepository {
  final ApprovedBankDatasource approvedBankDatasource;

  ApprovedBankRepositoryImpl({required this.approvedBankDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getApprovedBankFolderList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await approvedBankDatasource.apicallPullApprovedBankFolder(
        pageSize: pageSize,
        pageNumber: pageNumber,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getApprovedBankFileList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await approvedBankDatasource.apicallPullApprovedBankFile(
        pageSize: pageSize,
        pageNumber: pageNumber,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovedBankFolder({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await approvedBankDatasource
          .apicallAddUpdateApprovedBankFolder(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateApprovedBankFile({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await approvedBankDatasource
          .apicallAddUpdateApprovedBankFile(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteApprovedBankFolder({
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await approvedBankDatasource.apicallDeleteApprovedBankFolder(
        approvedBankFolderId: approvedBankFolderId,
        projectId: projectId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteApprovedBankFile({
    required int approvedBankFileId,
    required int approvedBankFolderId,
    required int projectId,
    required String uniqueKey,
  }) async {
    try {
      var result = await approvedBankDatasource.apicallDeleteApprovedBankFile(
        approvedBankFileId: approvedBankFileId,
        approvedBankFolderId: approvedBankFolderId,
        projectId: projectId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
