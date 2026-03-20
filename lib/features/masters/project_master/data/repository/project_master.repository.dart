import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/datasource/project_master.datasource.dart';

abstract interface class ProjectMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProjectList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpateProject({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> getProjectWithCompany({
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getProjectWithBankDetails({
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getProjectWithEmployee({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateProjectWithBankDetails({
    required Map<String, dynamic> bankRequestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteProjectWithBankDetails({
    required int projectWithBankDetailsId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectWithCompany({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectWithEmployee({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportProject({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteProjectWithEmployee({
    required int projectId,
    required String uniquekey,
    required String employeeId,
  });
}

class ProjectMasterRepositoryImpl implements ProjectMasterRepository {
  final ProjectMasterDatasource projectMasterDatasource;

  ProjectMasterRepositoryImpl({required this.projectMasterDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectMasterDatasource.apicallPullProject(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpateProject({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await projectMasterDatasource.apicallAddUpdateProjectMaster(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectWithCompany({
    required int projectId,
  }) async {
    try {
      var result = await projectMasterDatasource.apicallGetProjectWithCompany(
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectWithBankDetails({
    required int projectId,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallGetProjectWithBankDetails(projectId: projectId);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectWithEmployee({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectMasterDatasource.apicallGetProjectWithEmployee(
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
  addUpdateProjectWithBankDetails({
    required Map<String, dynamic> bankRequestBody,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallAddUpdateProjectWithBankDetails(
            bankRequestBody: bankRequestBody,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectWithCompany({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallAddUpdateProjectWithCompany(requestBody: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectWithEmployee({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallAddUpdateProjectWithEmployee(requestBody: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteProjectWithBankDetails({
    required int projectWithBankDetailsId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallDeleteProjectWithBankDetails(
            projectWithBankDetailsId: projectWithBankDetailsId,
            uniqueKey: uniqueKey,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportProject({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallPullProjectMasterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteProjectWithEmployee({
    required int projectId,
    required String uniquekey,
    required String employeeId,
  }) async {
    try {
      var result = await projectMasterDatasource
          .apicallDeleteProjectWithEmployee(
            projectId: projectId,
            uniquekey: uniquekey,
            employeeId: employeeId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
