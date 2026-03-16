import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';

abstract interface class UtilsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getMenu({
    required int employeeId,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> excelImport({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getMaterialMasterSubMaterialMasterUOMMaster({required int projectId});

  Future<Either<Failure, Map<String, dynamic>>> pullExcelSample({
    required String tableName,
  });

  Future<Either<Failure, UserModel>> pullEmployeeWithMenuList();

  Future<Either<Failure, Map<String, dynamic>>> getProjectSummery({
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> sendOTPModuleBased({
    required String mobileNumber,
    required String module,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    Map<String, dynamic>? queryParams,
  });
}

class UtilsRepositoryImpl implements UtilsRepository {
  final UtilsDatasource _utilsDatasource;

  UtilsRepositoryImpl(this._utilsDatasource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMenu({
    required int employeeId,
    required int projectId,
  }) async {
    try {
      var result = await _utilsDatasource.apicallPullMenu(
        employeeId: employeeId,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> excelImport({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await _utilsDatasource.apicallExcelImport(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getMaterialMasterSubMaterialMasterUOMMaster({required int projectId}) async {
    try {
      var result = await _utilsDatasource
          .apicallPullMaterialMasterSubMaterialMasterUOMMaster(
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullExcelSample({
    required String tableName,
  }) async {
    try {
      var result = await _utilsDatasource.apicalPullExcelSample(
        tableName: tableName,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, UserModel>> pullEmployeeWithMenuList() async {
    try {
      var result = await _utilsDatasource.apicallIsPullEmployeeWithMenuList();
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectSummery({
    required int projectId,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallToPullProjectSummery(
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOTPModuleBased({
    required String mobileNumber,
    required String module,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallSendOTPModuleBased(
        mobileNumber: mobileNumber,
        module: module,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallUpdateModulesWorkflowApproval(
        moduleName: moduleName,
        id: id,
        projectId: projectId,
        isApproved: isApproved,
        remark: remark,
        queryParams: queryParams,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
