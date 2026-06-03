import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';

abstract interface class UtilsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAppVersion();
  Future<Either<Failure, Map<String, dynamic>>> getMenu({
    required int employeeId,
  });

  Future<Either<Failure, Map<String, dynamic>>> excelImport({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getMaterialMasterSubMaterialMasterUOMMaster({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

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
    required String name,
    String? companyName,
    String? projectName,
    String? source,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullModuleApprovalStatus({
    required String moduleName,
    required int id,
    required int projectId,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullModulesWorkflowApproval({
    int? employeeId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteModulesWorkflowApproval({
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  pullPaginationProjectWithEmployee({
    required int projectId,
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateModulesWorkflowApproval({
    required String employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  });

  Future<Either<Failure, AddressParsedResult>> getAddressMaster();

  Future<Either<Failure, Map<String, dynamic>>> getVillageList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class UtilsRepositoryImpl implements UtilsRepository {
  final UtilsDatasource _utilsDatasource;

  UtilsRepositoryImpl(this._utilsDatasource);
  @override
  Future<Either<Failure, Map<String, dynamic>>> getAppVersion() async {
    try {
      var result = await _utilsDatasource.apicallPullAppVersion();
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL MENU
  @override
  Future<Either<Failure, Map<String, dynamic>>> getMenu({
    required int employeeId,
  }) async {
    try {
      var result = await _utilsDatasource.apicallPullMenu(
        employeeId: employeeId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // EXCEL IMPORT
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

  // PULL MATERIAL MASTER SUB MATERIAL MASTER UOM MASTER
  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getMaterialMasterSubMaterialMasterUOMMaster({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await _utilsDatasource
          .apicallPullMaterialMasterSubMaterialMasterUOMMaster(
            projectId: projectId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL EXCEL SAMPLE
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

  // PULL EMPLOYEE WITH MENU LIST
  @override
  Future<Either<Failure, UserModel>> pullEmployeeWithMenuList() async {
    try {
      var result = await _utilsDatasource.apicallIsPullEmployeeWithMenuList();
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL PROJECT SUMMARY
  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectSummery({
    required int projectId,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallToPullProjectSummary(
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  //SEND MODULE BASED OTP
  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOTPModuleBased({
    required String mobileNumber,
    required String module,
    required String name,
    String? companyName,
    String? projectName,
    String? source,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallSendOTPModuleBased(
        mobileNumber: mobileNumber,
        module: module,
        name: name,
        companyName: companyName,
        projectName: projectName,
        source: source,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // UPDATE MODULES WORKFLOW APPROVAL (FOR ACTION LIKE APPROVE AND REJECT)
  @override
  Future<Either<Failure, Map<String, dynamic>>> updateModulesWorkflowApproval({
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallUpdateModulesWorkflowApproval(
        moduleName: moduleName,
        id: id,
        projectId: projectId,
        isApproved: isApproved,
        remark: remark,
        subId: subId,
        subSubId: subSubId,
        subSubSubId: subSubSubId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ADD UPDATE MODULES WORKFLOW APPROVAL (FOR ADDING EMPLOYEES TO APPROVAL MODULES)
  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateModulesWorkflowApproval({
    required String employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    try {
      final result = await _utilsDatasource
          .apiCallAddUpdateModulesWorkflowApproval(
            employeeId: employeeId,
            projectId: projectId,
            modulesMasterId: modulesMasterId,
            subModulesMasterId: subModulesMasterId,
            subSubModulesMasterId: subSubModulesMasterId,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // MODULE BASED APPROVAL STATUS
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullModuleApprovalStatus({
    required String moduleName,
    required int id,
    required int projectId,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallPullModuleApprovalStatus(
        moduleName: moduleName,
        id: id,
        projectId: projectId,
        subId: subId,
        subSubId: subSubId,
        subSubSubId: subSubSubId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL MODULES WORKFLOW APPROVAL FOR PROJECT DETAILS APPROVAL TAB
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullModulesWorkflowApproval({
    int? employeeId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallPullModulesWorkflowApproval(
        employeeId: employeeId,
        projectId: projectId,
        queryParams: queryParams,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // DELETE EMPLOYEE FROM MODULE WORKFLOW APPROVAL
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteModulesWorkflowApproval({
    required int employeeId,
    required int projectId,
    required int modulesMasterId,
    required int subModulesMasterId,
    required int subSubModulesMasterId,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallDeleteModuleWorkflowApproval(
        employeeId: employeeId,
        projectId: projectId,
        modulesMasterId: modulesMasterId,
        subModulesMasterId: subModulesMasterId,
        subSubModulesMasterId: subSubModulesMasterId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // PULL PAGINATION PROJECT WITH EMPLOYEE
  @override
  Future<Either<Failure, Map<String, dynamic>>>
  pullPaginationProjectWithEmployee({
    required int projectId,
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await _utilsDatasource
          .apiCallPullPaginationProjectWithEmployee(
            projectId: projectId,
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
  Future<Either<Failure, AddressParsedResult>> getAddressMaster({
    bool forceRefresh = false,
  }) async {
    final storage = LocalStorageManager();

    try {
      /// ---------------- CACHE ----------------
      if (!forceRefresh) {
        final cachedData = storage.getRawString(StorageKey.addressMasterData);

        if (cachedData != null && cachedData.isNotEmpty) {
          final parsed = processAddressData(cachedData);
          return right(parsed);
        }
      }

      /// ---------------- API ----------------
      final result =
          await _utilsDatasource.pullCountryStateCityDistrictVillage();

      final data = result["data"]["CountryStateCityDistrictVillageData"];

      /// Encode in isolate
      final encodedData = jsonEncode(data);

      await storage.setRawString(StorageKey.addressMasterData, encodedData);

      final parsed = await compute(processAddressData, encodedData);

      return right(parsed);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  /// FETCH VILLAGE LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>> getVillageList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await _utilsDatasource.apiCallPullVillage(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
