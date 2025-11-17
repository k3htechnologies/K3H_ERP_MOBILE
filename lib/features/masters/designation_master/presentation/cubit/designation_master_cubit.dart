import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';

part 'designation_master_state.dart';

class DesignationMasterCubit extends Cubit<DesignationMasterState> {
  DesignationMasterCubit() : super(DesignationMasterState.initial());

  final DesignationMasterRepository _designationMasterRepository =
  serviceLocator<DesignationMasterRepository>();


  // <---- GET DESIGNATION LIST ---->
  Future getDesignationList(
      BuildContext context,
      int pageNumber,
      int pageSize,
      ) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "DesignationName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _designationMasterRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );
    result.fold(
          (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
      },
          (response) {
        List<DesignationMasterModel> updatedList = List.from(
          state.designationList,
        );
        // CONDITION TO CHECK IF THE PLATFORM IS MOBILE FOR PAGINATION
        updatedList.addAll(response['data'] as List<DesignationMasterModel>);
        emit(
          state.copyWith(
            isLoading: false,
            designationList: updatedList,
            totalNumberOfRecord:
            response['totalNumberOfRecord'] == 0 && state.currentPage != 1
                ? state.totalNumberOfRecord - 1
                : response['totalNumberOfRecord'],
            currentPage: pageNumber,
          ),
        );
      },
    );
  }

  // <---- ADD DESIGNATION ---->
  Future addDesignationMaster({
    required BuildContext context,
    required String designationName,
    required String noticePeriod,
  }) async {
    DialogHelper.showProcessingDialog(context);
    Map<String, dynamic> requestBody = {
      'DesignationName': designationName,
      'NoticePeriod': noticePeriod,
    };
    var addResult = await _designationMasterRepository.addUpdateDesignation(
      requestBody: requestBody,
    );
    goRouter.pop();
    addResult.fold(
          (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
          (response) {
        goRouter.pop();
        var list = [
          response['data'][0] as DesignationMasterModel,
          ...state.designationList,
        ];

        emit(
          state.copyWith(
            designationList: list,
            totalNumberOfRecord:
            state.totalNumberOfRecord == -1
                ? 1
                : state.totalNumberOfRecord + 1,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- UPDATE DESIGNATION ---->
  Future updateDesignationMaster({
    required BuildContext context,
    required int designationMasterId,
    required String uniqueKey,
    required String designationName,
    required String noticePeriod,
    required int index,
  }) async {
    DialogHelper.showProcessingDialog(context);
    Map<String, dynamic> requestBody = {
      'DesignationMasterId': designationMasterId,
      'UniqueKey': uniqueKey,
      'DesignationName': designationName,
      'NoticePeriod': noticePeriod,
    };

    var updateResult = await _designationMasterRepository.addUpdateDesignation(
      requestBody: requestBody,
    );
    goRouter.pop();
    updateResult.fold(
          (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
          (response) {
        final updatedList = List<DesignationMasterModel>.from(
          state.designationList,
        );
        updatedList[index] = (response['data'][0] as DesignationMasterModel);
        goRouter.pop();
        emit(
          state.copyWith(
            designationList: updatedList,
          ),
        );
        showSuccessMessage(context);
      },
    );
  }

  // <---- DELETE DESIGNATION ---->
  Future deleteDesignationMaster({
    required BuildContext context,
    required int designationMasterId,
    required String uniqueKey,
    required int pageNumber,
    required int pageSize,
    int? index,
  }) async {
    DialogHelper.showProcessingDialog(context);
    var deleteResult = await _designationMasterRepository.deleteDesignation(
      designationtMasterId: designationMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
          (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
          (response) {
        showSuccessMessage(context);
        if (index != null) {
          final updatedList = List<DesignationMasterModel>.from(
            state.designationList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              designationList: updatedList,
            ),
          );
        } else {
          getDesignationList(context, pageNumber, pageSize);
        }
      },
    );
  }

  // <---- SEARCH DESIGNATION ---->
  Future searchDesignation(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, designationList: []));
    await getDesignationList(context, 1, 20);
  }

  // <---- SORT DESIGNATION ---->
  Future sortDesignation(
      BuildContext context,
      String value,
      String direction,
      ) async {
    emit(
      state.copyWith(
        currentSortColumn: value,
        currentSortDirection: direction,
        designationList: [],
      ),
    );
    await getDesignationList(context, 1, 10);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingDialog(context);
    var result = await _designationMasterRepository.exportDesignation(
      pageNumber: 1,
      pageSize: state.totalNumberOfRecord,
      queryParams:
      state.searchText != ""
          ? {"DesignationName": state.searchText, "ExportType": exportType}
          : {"ExportType": exportType},
    );
    goRouter.pop();
    result.fold(
          (failure) {
        showErrorMessage(context, 'Error', failure.message);
      },
          (response) {
            exportExcelOrPdfMobile(
              response["data"],
              exportType.toLowerCase() == "pdf"
                  ? "designation_${DateTime.now()}.pdf"
                  : "designation_${DateTime.now()}.xlsx",
            );
      },
    );
  }

  // <---- GET MODULES PERMISSIONS ---->
  Future getModulesPermissions(
      BuildContext context,
      int designationMasterId,
      ) async {
    emit(
      state.copyWith(
        isLoading: true,
        stateType: StateType.employeeMasterModuleAccessState,
      ),
    );
    var result = await _designationMasterRepository.getModulesPermissionsList(
      designationMasterId: designationMasterId,
    );

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            stateType: StateType.employeeMasterModuleAccessState,
          ),
        );
      },
          (response) async {
        List<ModuleModel> moduleList = response['data'];
        await compute((_) {
          for (var module in moduleList) {
            for (var subModule in module.subModuleData) {
              if (subModule.subSubModuleData.isEmpty) {
                subModule.isSelected =
                    subModule.isView && subModule.isAction && subModule.isView;
              } else {
                subModule.isSelected = subModule.subSubModuleData.every(
                      (subSubModule) =>
                  subSubModule.isView &&
                      subSubModule.isAction &&
                      subSubModule.isView,
                );
              }
            }
            module.isSelected = module.subModuleData.every(
                  (subModule) => subModule.isSelected,
            );
          }
        }, '');
        emit(
          state.copyWith(
            isLoading: false,
            modulesPermissionsList: moduleList,
            isAllSelected: await isAllModulesSelected(moduleList),
            stateType: StateType.employeeMasterModuleAccessState,
          ),
        );
      },
    );
  }

  // <---- UPDATE MODULES PERMISSIONS ---->
  Future updateModulesPermissions({
    required BuildContext context,
    required int designationMasterId,
  }) async {
    DialogHelper.showProcessingDialog(context);

    var requestBody = {
      "DesignationMasterId": designationMasterId,
      "ModulesPermissionsJsonList": getPermissionUpdateJson(),
    };

    var result = await _designationMasterRepository.addUpdateModulePermissions(
      requestBody: requestBody,
    );

    goRouter.pop();
    result.fold(
          (failure) {
        showErrorMessage(context, "Error", failure.message);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            stateType: StateType.employeeMasterModuleAccessState,
          ),
        );
      },
          (response) async {
        await showSuccessMessage(context);
        List<ModuleModel> moduleList = response['data'];
        await compute((_) {
          for (var module in moduleList) {
            for (var subModule in module.subModuleData) {
              if (subModule.subSubModuleData.isEmpty) {
                subModule.isSelected =
                    subModule.isView && subModule.isAction && subModule.isView;
              } else {
                subModule.isSelected = subModule.subSubModuleData.every(
                      (subSubModule) =>
                  subSubModule.isView &&
                      subSubModule.isAction &&
                      subSubModule.isView,
                );
              }
            }
            module.isSelected = module.subModuleData.every(
                  (subModule) => subModule.isSelected,
            );
          }
        }, '');
        emit(
          state.copyWith(
            isLoading: false,
            modulesPermissionsList: moduleList,
            isAllSelected: await isAllModulesSelected(moduleList),
            stateType: StateType.employeeMasterModuleAccessState,
          ),
        );
        if (context.mounted) {
          getDesignationList(context, 1, 20);
        }
      },
    );
  }

  // <---- CHECK IF ALL MODULES ARE SELECTED ---->
  Future<bool> isAllModulesSelected(
      List<ModuleModel> modulesPermissionsList,
      ) async {
    return await compute(
          (_) => modulesPermissionsList.every(
            (module) => module.subModuleData.every(
              (subModule) => subModule.subSubModuleData.every(
                (subSubModule) =>
            subSubModule.isAction &&
                subSubModule.isView &&
                subSubModule.isExport,
          ),
        ),
      ),
      '',
    );
  }

  // <---- PERMISSION UPDATE JSON ---->
  String getPermissionUpdateJson() {
    List<Map<String, dynamic>> result = [];

    for (var module in state.modulesPermissionsList) {
      for (var subModule in module.subModuleData) {
        if (subModule.subSubModuleData.isEmpty) {
          bool subModuleFound = false;
          if (!subModuleFound &&
              (subModule.isAction || subModule.isExport || subModule.isView)) {
            // ADDING ENTRY FOR MODULE
            result.add({
              "ModulesMasterId": module.modulesMasterId,
              "SubModuleMasterId": 0,
              "SubSubModuleMasterId": 0,
              "IsAction": true,
              "IsView": true,
              "IsExport": true,
            });
            subModuleFound = true;
          }
          if (subModule.isAction || subModule.isExport || subModule.isView) {
            result.add({
              "ModulesMasterId": module.modulesMasterId,
              "SubModuleMasterId": subModule.subModulesMasterId,
              "SubSubModuleMasterId": 0,
              "IsAction": subModule.isAction,
              "IsView": subModule.isView,
              "IsExport": subModule.isExport,
            });
          }
        } else {
          for (var subSub in subModule.subSubModuleData) {
            bool subSubModuleFound = false;
            if (!subSubModuleFound &&
                (subSub.isAction || subSub.isExport || subSub.isView)) {
              // ADDING ENTRY FOR MODULE
              result.add({
                "ModulesMasterId": module.modulesMasterId,
                "SubModuleMasterId": 0,
                "SubSubModuleMasterId": 0,
                "IsAction": true,
                "IsView": true,
                "IsExport": true,
              });
              // ADDING ENTRY FOR SUB MODULE
              result.add({
                "ModulesMasterId": module.modulesMasterId,
                "SubModuleMasterId": subModule.subModulesMasterId,
                "SubSubModuleMasterId": 0,
                "IsAction": true,
                "IsView": true,
                "IsExport": true,
              });
              subSubModuleFound = true;
            }
            if (subSub.isAction || subSub.isExport || subSub.isView) {
              result.add({
                "ModulesMasterId": module.modulesMasterId,
                "SubModuleMasterId": subModule.subModulesMasterId,
                "SubSubModuleMasterId": subSub.subSubModulesMasterId,
                "IsAction": subSub.isAction,
                "IsView": subSub.isView,
                "IsExport": subSub.isExport,
              });
            }
          }
        }
      }
    }

    return jsonEncode(result);
  }

  // SELECT MODULE
  Future<void> updateRow(
      int? moduleIndex,
      int? subModuleIndex,
      int? subSubModuleIndex,
      bool value,
      String? type,
      ) async {
    List result = await updateList(
      List.from(state.modulesPermissionsList),
      moduleIndex: moduleIndex,
      subModuleIndex: subModuleIndex,
      subSubModuleIndex: subSubModuleIndex,
      value: value,
      type: type,
    );
    emit(
      state.copyWith(
        isAllSelected: result[1],
        modulesPermissionsList: result[0],
        stateType: StateType.employeeMasterModuleAccessState,
      ),
    );
  }

  Future<List> updateList(
      List<ModuleModel> list, {
        int? moduleIndex,
        int? subModuleIndex,
        int? subSubModuleIndex,
        required bool value,
        String? type,
      }) async {
    // CASE 1: Updating SubSubModule permissions
    if (subSubModuleIndex != null && subModuleIndex != null) {
      ModuleModel moduleModel = list[moduleIndex!];
      SubModuleModel subModuleModel = moduleModel.subModuleData[subModuleIndex];
      SubSubModuleModel subSubModule =
      subModuleModel.subSubModuleData[subSubModuleIndex];

      switch (type) {
        case "action":
          subSubModule.isAction = value;
          break;
        case "export":
          subSubModule.isExport = value;
          break;
        case "view":
          subSubModule.isView = value;
          break;
      }

      // Update the subModule isSelected based on ALL subSubModules
      subModuleModel.isSelected = subModuleModel.subSubModuleData.every(
            (e) => e.isView && e.isAction && e.isExport,
      );

      // Update the module isSelected based on ALL subModules
      moduleModel.isSelected = moduleModel.subModuleData.every(
            (e) => e.isSelected,
      );
    }
    // CASE 2: Updating SubModule permissions directly
    else if (subModuleIndex != null) {
      ModuleModel moduleModel = list[moduleIndex!];
      SubModuleModel subModuleModel = moduleModel.subModuleData[subModuleIndex];

      if (type != null) {
        // Update specific permission
        switch (type) {
          case "action":
            subModuleModel.isAction = value;
            break;
          case "export":
            subModuleModel.isExport = value;
            break;
          case "view":
            subModuleModel.isView = value;
            break;
        }
        // Check if all permissions are true
        subModuleModel.isSelected =
            subModuleModel.isView &&
                subModuleModel.isAction &&
                subModuleModel.isExport;
      } else {
        if (subModuleModel.subSubModuleData.isEmpty) {
          // Update all permissions
          subModuleModel.isAction = value;
          subModuleModel.isExport = value;
          subModuleModel.isView = value;
          subModuleModel.isSelected = value;
        } else {
          // Update all subSubModules
          for (var subSubModule in subModuleModel.subSubModuleData) {
            subSubModule.isAction = value;
            subSubModule.isExport = value;
            subSubModule.isView = value;
          }
          if (value) {
            subModuleModel.isSelected = subModuleModel.subSubModuleData.every(
                  (e) => e.isView && e.isAction && e.isExport,
            );
          } else {
            subModuleModel.isSelected = value;
          }
        }
      }

      // Update module selection
      moduleModel.isSelected = moduleModel.subModuleData.every(
            (e) => e.isSelected,
      );
    } else
      // CASE 3: Updating Module permissions
    if (moduleIndex != null) {
      ModuleModel moduleModel = list[moduleIndex];
      // Toggle entire module (all submodules and sub-submodules)
      for (var subModule in moduleModel.subModuleData) {
        if (subModule.subSubModuleData.isEmpty) {
          // SubModule has no subSubModules → update directly
          subModule.isAction = value;
          subModule.isExport = value;
          subModule.isView = value;
          subModule.isSelected = value;
        } else {
          // SubModule has subSubModules → update each subSubModule
          for (var subSubModule in subModule.subSubModuleData) {
            subSubModule.isAction = value;
            subSubModule.isExport = value;
            subSubModule.isView = value;
          }
          subModule.isSelected = value;
        }
      }
      moduleModel.isSelected = value;
    }
    // CASE 4: Updating all modules
    else {
      for (var module in list) {
        module.isSelected = value;
        for (var subModule in module.subModuleData) {
          if (subModule.subSubModuleData.isEmpty) {
            // No subSubModules, apply directly to subModule
            subModule.isAction = value;
            subModule.isExport = value;
            subModule.isView = value;
            subModule.isSelected = value;
          } else {
            // Has subSubModules — apply to all of them
            for (var subSubModule in subModule.subSubModuleData) {
              subSubModule.isAction = value;
              subSubModule.isExport = value;
              subSubModule.isView = value;
            }

            // Mark subModule as selected only if all subSubModules meet condition
            subModule.isSelected = value;
          }
        }
      }
    }
    return [list, await compute((_) => list.every((e) => e.isSelected), '')];
  }
}
