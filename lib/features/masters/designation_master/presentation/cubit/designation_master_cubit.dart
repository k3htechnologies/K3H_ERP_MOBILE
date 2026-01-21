import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

part 'designation_master_state.dart';

class DesignationMasterCubit extends Cubit<DesignationMasterState> {
  DesignationMasterCubit() : super(DesignationMasterState.initial());

  final DesignationMasterRepository _designationMasterRepository =
      serviceLocator<DesignationMasterRepository>();

  // <---- GET DESIGNATION LIST ---->
  Future getDesignationList(BuildContext context, int pageNumber) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> queryParams = {
      "DesignationName": state.searchText,
      "SortBy": "${state.currentSortColumn} ${state.currentSortDirection}",
    };
    var result = await _designationMasterRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: 10,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
      },
      (response) {
        final List<DesignationMasterModel> newData =
            List<DesignationMasterModel>.from(response['data'] ?? []);

        // Replace list when pageNumber == 1, otherwise append for pagination
        List<DesignationMasterModel> updatedList =
            pageNumber == 1 ? newData : [...state.designationList, ...newData];
        emit(
          state.copyWith(
            isLoading: false,
            designationList: updatedList,
            totalNumberOfRecord: response['totalNumberOfRecord'],
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
    DialogHelper.showProcessingOverlay(context);
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
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
        return;
      },
      (response) {
        goRouter.pop();
        showSuccessMessage(
          context,
          subTitle: 'Designation Added Successfully!!!',
        );
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
    DialogHelper.showProcessingOverlay(context);
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
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
        return;
      },
      (response) {
        goRouter.pop();
        final updatedDesignation =
            response['data'][0] as DesignationMasterModel;

        // Check if list is not empty and index is valid before updating by index
        // This prevents RangeError when the cubit instance has an empty list
        if (state.designationList.isNotEmpty &&
            index < state.designationList.length) {
          final updatedList = List<DesignationMasterModel>.from(
            state.designationList,
          );
          updatedList[index] = updatedDesignation;
          emit(state.copyWith(designationList: updatedList, isLoading: false));
        }

        showSuccessMessage(
          context,
          subTitle: 'Designation Updated Successfully!!!',
        );
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
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _designationMasterRepository.deleteDesignation(
      designationtMasterId: designationMasterId,
      uniqueKey: uniqueKey,
    );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Designation Deleted Successfully!!!',
        );
        if (index != null) {
          final updatedList = List<DesignationMasterModel>.from(
            state.designationList,
          );
          updatedList.removeAt(index);
          emit(
            state.copyWith(
              designationList: updatedList,
              totalNumberOfRecord:
                  state.totalNumberOfRecord > 0
                      ? state.totalNumberOfRecord - 1
                      : 0,
            ),
          );
        } else {
          getDesignationList(context, pageNumber);
        }
      },
    );
  }

  // <---- SEARCH DESIGNATION ---->
  Future searchDesignation(BuildContext context, String value) async {
    emit(state.copyWith(searchText: value, designationList: []));
    await getDesignationList(context, 1);
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
    await getDesignationList(context, 1);
  }

  // <---- EXPORT EXCEL PDF ---->
  Future exportExcelPdf(BuildContext context, String exportType) async {
    DialogHelper.showProcessingOverlay(context);
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
        showErrorMessage(
          context,
          'Error',
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
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

        // If we have existing data for the same designation, merge API response with local state
        // to preserve unsaved user changes
        List<ModuleModel> finalModuleList = moduleList;
        if (state.currentDesignationId == designationMasterId &&
            state.modulesPermissionsList.isNotEmpty &&
            state.stateType == StateType.employeeMasterModuleAccessState) {
          // Merge API data with existing local state to preserve unsaved changes
          finalModuleList = _mergeModuleLists(
            existingList: state.modulesPermissionsList,
            apiList: moduleList,
          );
        }

        // Process modules directly (no need for compute as this is simple boolean logic)
        for (var module in finalModuleList) {
          for (var subModule in module.subModuleData) {
            if (subModule.subSubModuleData.isEmpty) {
              subModule.isSelected =
                  subModule.isView && subModule.isAction && subModule.isExport;
            } else {
              // For submodules with sub-submodules, derive submodule's checkbox state
              // from its sub-submodules: if ALL sub-submodules have a permission checked,
              // then the submodule's checkbox should be checked
              if (subModule.subSubModuleData.isNotEmpty) {
                subModule.isAction = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isAction,
                );
                subModule.isView = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isView,
                );
                subModule.isExport = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isExport,
                );
                // If action or export is checked, automatically check view as well
                if (subModule.isAction || subModule.isExport) {
                  subModule.isView = true;
                }
              }
              // isSelected depends on whether all sub-submodules have all permissions
              subModule.isSelected = subModule.subSubModuleData.every(
                (subSubModule) =>
                    subSubModule.isView &&
                    subSubModule.isAction &&
                    subSubModule.isExport,
              );
            }
          }
          module.isSelected = module.subModuleData.every(
            (subModule) => subModule.isSelected,
          );
        }
        emit(
          state.copyWith(
            isLoading: false,
            modulesPermissionsList: finalModuleList,
            isAllSelected: await isAllModulesSelected(finalModuleList),
            stateType: StateType.employeeMasterModuleAccessState,
            currentDesignationId: designationMasterId,
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
    DialogHelper.showProcessingOverlay(context);

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
        showErrorMessage(
          context,
          "Error",
          failure.message,
          isMenuChanged: failure.isMenuChanged,
        );
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            stateType: StateType.employeeMasterModuleAccessState,
          ),
        );
      },
      (response) async {
        // Check if the current user's designation matches the updated designation
        // Do this check first before processing response
        bool shouldShowAuthorizationDialog = false;
        try {
          final currentUserString = LocalStorageManager().getString(
            StorageKey.currentUser,
          );
          if (currentUserString != null) {
            final currentUser = UserModel.fromJson(
              jsonDecode(currentUserString),
            );
            if (currentUser.designationMasterId == designationMasterId) {
              shouldShowAuthorizationDialog = true;
            }
          }
        } catch (e) {
          // If there's an error getting current user, continue without showing dialog
          developer.log('Error checking current user designation: $e');
        }

        await showSuccessMessage(
          context,
          subTitle: 'Access Updated Successfully!!!',
        );

        // Show authorization dialog immediately after success message if needed
        if (shouldShowAuthorizationDialog && context.mounted) {
          await DialogHelper.showMenuChangedErrorDialog(context: context);
          return; // Don't continue with other operations if authorization dialog is shown
        }

        List<ModuleModel> moduleList = response['data'];
        // Process modules directly (no need for compute as this is simple boolean logic)
        for (var module in moduleList) {
          for (var subModule in module.subModuleData) {
            if (subModule.subSubModuleData.isEmpty) {
              subModule.isSelected =
                  subModule.isView && subModule.isAction && subModule.isExport;
            } else {
              // For submodules with sub-submodules, derive submodule's checkbox state
              // from its sub-submodules: if ALL sub-submodules have a permission checked,
              // then the submodule's checkbox should be checked
              if (subModule.subSubModuleData.isNotEmpty) {
                subModule.isAction = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isAction,
                );
                subModule.isView = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isView,
                );
                subModule.isExport = subModule.subSubModuleData.every(
                  (subSubModule) => subSubModule.isExport,
                );
                // If action or export is checked, automatically check view as well
                if (subModule.isAction || subModule.isExport) {
                  subModule.isView = true;
                }
              }
              // isSelected depends on whether all sub-submodules have all permissions
              subModule.isSelected = subModule.subSubModuleData.every(
                (subSubModule) =>
                    subSubModule.isView &&
                    subSubModule.isAction &&
                    subSubModule.isExport,
              );
            }
          }
          module.isSelected = module.subModuleData.every(
            (subModule) => subModule.isSelected,
          );
        }
        emit(
          state.copyWith(
            isLoading: false,
            modulesPermissionsList: moduleList,
            isAllSelected: await isAllModulesSelected(moduleList),
            stateType: StateType.employeeMasterModuleAccessState,
            currentDesignationId: designationMasterId,
          ),
        );
        if (context.mounted) {
          getDesignationList(context, 1);
        }
      },
    );
  }

  // <---- CHECK IF ALL MODULES ARE SELECTED ---->
  Future<bool> isAllModulesSelected(
    List<ModuleModel> modulesPermissionsList,
  ) async {
    // Process directly (no need for compute as this is simple boolean logic)
    return modulesPermissionsList.every(
      (module) => module.subModuleData.every(
        (subModule) => subModule.subSubModuleData.every(
          (subSubModule) =>
              subSubModule.isAction &&
              subSubModule.isView &&
              subSubModule.isExport,
        ),
      ),
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
    // Create a deep copy of the list to ensure new references
    List<ModuleModel> newList =
        state.modulesPermissionsList.map((module) {
          return ModuleModel(
            modulesMasterId: module.modulesMasterId,
            moduleName: module.moduleName,
            icon: module.icon,
            subModuleData:
                module.subModuleData.map((subModule) {
                  return SubModuleModel(
                    subModulesMasterId: subModule.subModulesMasterId,
                    subModuleName: subModule.subModuleName,
                    icon: subModule.icon,
                    path: subModule.path,
                    isAction: subModule.isAction,
                    isView: subModule.isView,
                    isExport: subModule.isExport,
                    isSelected: subModule.isSelected,
                    subSubModuleData:
                        subModule.subSubModuleData.map((subSubModule) {
                          return SubSubModuleModel(
                            subSubModulesMasterId:
                                subSubModule.subSubModulesMasterId,
                            subSubModuleName: subSubModule.subSubModuleName,
                            icon: subSubModule.icon,
                            path: subSubModule.path,
                            isDisplay: subSubModule.isDisplay,
                            isAction: subSubModule.isAction,
                            isView: subSubModule.isView,
                            isExport: subSubModule.isExport,
                          );
                        }).toList(),
                  );
                }).toList(),
            isSelected: module.isSelected,
          );
        }).toList();

    List result = await updateList(
      newList,
      moduleIndex: moduleIndex,
      subModuleIndex: subModuleIndex,
      subSubModuleIndex: subSubModuleIndex,
      value: value,
      type: type,
    );
    // Force a new list instance to ensure state change is detected
    final updatedList = List<ModuleModel>.from(result[0]);
    emit(
      state.copyWith(
        isAllSelected: result[1],
        modulesPermissionsList: updatedList,
        stateType: StateType.employeeMasterModuleAccessState,
        updateCounter:
            state.updateCounter + 1, // Increment counter to force state change
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
          // If action is checked, automatically check view as well
          if (value) {
            subSubModule.isView = true;
          }
          break;
        case "export":
          subSubModule.isExport = value;
          // If export is checked, automatically check view as well
          if (value) {
            subSubModule.isView = true;
          }
          break;
        case "view":
          subSubModule.isView = value;
          break;
      }

      // For submodules with sub-submodules, derive submodule's checkbox state
      // from its sub-submodules: if ALL sub-submodules have a permission checked,
      // then the submodule's checkbox is checked; if ANY is unchecked, submodule is unchecked
      if (subModuleModel.subSubModuleData.isNotEmpty) {
        subModuleModel.isAction = subModuleModel.subSubModuleData.every(
          (subSubModule) => subSubModule.isAction,
        );
        subModuleModel.isView = subModuleModel.subSubModuleData.every(
          (subSubModule) => subSubModule.isView,
        );
        subModuleModel.isExport = subModuleModel.subSubModuleData.every(
          (subSubModule) => subSubModule.isExport,
        );
        // If action or export is checked, automatically check view as well
        if (subModuleModel.isAction || subModuleModel.isExport) {
          subModuleModel.isView = true;
        }
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
        // Update specific permission on sub-module
        switch (type) {
          case "action":
            subModuleModel.isAction = value;
            // If action is checked, automatically check view as well
            if (value) {
              subModuleModel.isView = true;
            }
            // Also update all sub-sub-modules' action checkboxes
            for (var subSubModule in subModuleModel.subSubModuleData) {
              subSubModule.isAction = value;
              // If action is checked, automatically check view as well
              if (value) {
                subSubModule.isView = true;
              }
            }
            break;
          case "export":
            subModuleModel.isExport = value;
            // If export is checked, automatically check view as well
            if (value) {
              subModuleModel.isView = true;
            }
            // Also update all sub-sub-modules' export checkboxes
            for (var subSubModule in subModuleModel.subSubModuleData) {
              subSubModule.isExport = value;
              // If export is checked, automatically check view as well
              if (value) {
                subSubModule.isView = true;
              }
            }
            break;
          case "view":
            subModuleModel.isView = value;
            // Also update all sub-sub-modules' view checkboxes
            for (var subSubModule in subModuleModel.subSubModuleData) {
              subSubModule.isView = value;
            }
            break;
        }
        // Update subModule isSelected based on all permissions and sub-sub-modules
        if (subModuleModel.subSubModuleData.isEmpty) {
          // No sub-sub-modules, check if all permissions are true
          subModuleModel.isSelected =
              subModuleModel.isView &&
              subModuleModel.isAction &&
              subModuleModel.isExport;
        } else {
          // Has sub-sub-modules, derive submodule's checkbox state from sub-submodules
          // and ensure isView is true if isAction or isExport is true
          subModuleModel.isAction = subModuleModel.subSubModuleData.every(
            (e) => e.isAction,
          );
          subModuleModel.isView = subModuleModel.subSubModuleData.every(
            (e) => e.isView,
          );
          subModuleModel.isExport = subModuleModel.subSubModuleData.every(
            (e) => e.isExport,
          );
          // If action or export is checked, automatically check view as well
          if (subModuleModel.isAction || subModuleModel.isExport) {
            subModuleModel.isView = true;
          }
          // isSelected depends on whether all sub-sub-modules have all permissions
          subModuleModel.isSelected = subModuleModel.subSubModuleData.every(
            (e) => e.isView && e.isAction && e.isExport,
          );
        }
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
            // Has subSubModules — apply to all of them AND to the sub-module itself
            subModule.isAction = value;
            subModule.isExport = value;
            subModule.isView = value;
            for (var subSubModule in subModule.subSubModuleData) {
              subSubModule.isAction = value;
              subSubModule.isExport = value;
              subSubModule.isView = value;
            }
            // Mark subModule as selected
            subModule.isSelected = value;
          }
        }
      }
    }
    // Process directly (no need for compute as this is simple boolean logic)
    return [list, list.every((e) => e.isSelected)];
  }

  // <---- MERGE MODULE LISTS TO PRESERVE UNSAVED CHANGES ---->
  List<ModuleModel> _mergeModuleLists({
    required List<ModuleModel> existingList,
    required List<ModuleModel> apiList,
  }) {
    // Create a map of existing modules by ID for quick lookup
    final Map<int, ModuleModel> existingModulesMap = {};
    for (var module in existingList) {
      existingModulesMap[module.modulesMasterId] = module;
    }

    // Merge API data with existing local state
    List<ModuleModel> mergedList =
        apiList.map((apiModule) {
          final existingModule = existingModulesMap[apiModule.modulesMasterId];

          // If module doesn't exist in local state, use API data
          if (existingModule == null) {
            return apiModule;
          }

          // Merge submodules
          final Map<int, SubModuleModel> existingSubModulesMap = {};
          for (var subModule in existingModule.subModuleData) {
            existingSubModulesMap[subModule.subModulesMasterId] = subModule;
          }

          List<SubModuleModel> mergedSubModules =
              apiModule.subModuleData.map((apiSubModule) {
                final existingSubModule =
                    existingSubModulesMap[apiSubModule.subModulesMasterId];

                // If submodule doesn't exist in local state, use API data
                if (existingSubModule == null) {
                  return apiSubModule;
                }

                // Merge sub-submodules first
                final Map<int, SubSubModuleModel> existingSubSubModulesMap = {};
                for (var subSubModule in existingSubModule.subSubModuleData) {
                  existingSubSubModulesMap[subSubModule.subSubModulesMasterId] =
                      subSubModule;
                }

                List<SubSubModuleModel> mergedSubSubModules =
                    apiSubModule.subSubModuleData.map((apiSubSubModule) {
                      final existingSubSubModule =
                          existingSubSubModulesMap[apiSubSubModule
                              .subSubModulesMasterId];

                      // If sub-submodule doesn't exist in local state, use API data
                      if (existingSubSubModule == null) {
                        return apiSubSubModule;
                      }

                      // Always preserve local changes to sub-submodule permissions
                      // This ensures unsaved user changes are not lost when API is called
                      apiSubSubModule.isAction = existingSubSubModule.isAction;
                      apiSubSubModule.isView = existingSubSubModule.isView;
                      apiSubSubModule.isExport = existingSubSubModule.isExport;

                      return apiSubSubModule;
                    }).toList();

                // Update sub-submodules list
                apiSubModule.subSubModuleData = mergedSubSubModules;

                // For submodules with sub-submodules, ALWAYS derive submodule's checkbox state
                // from its sub-submodules (don't preserve submodule's local state)
                // If ALL sub-submodules have a permission checked, then submodule's checkbox is checked
                // If ANY sub-submodule has a permission unchecked, then submodule's checkbox is unchecked
                if (apiSubModule.subSubModuleData.isNotEmpty) {
                  apiSubModule.isAction = apiSubModule.subSubModuleData.every(
                    (subSubModule) => subSubModule.isAction,
                  );
                  apiSubModule.isView = apiSubModule.subSubModuleData.every(
                    (subSubModule) => subSubModule.isView,
                  );
                  apiSubModule.isExport = apiSubModule.subSubModuleData.every(
                    (subSubModule) => subSubModule.isExport,
                  );
                  // If action or export is checked, automatically check view as well
                  if (apiSubModule.isAction || apiSubModule.isExport) {
                    apiSubModule.isView = true;
                  }
                }

                return apiSubModule;
              }).toList();

          // Create merged module
          return ModuleModel(
            modulesMasterId: apiModule.modulesMasterId,
            moduleName: apiModule.moduleName,
            icon: apiModule.icon,
            subModuleData: mergedSubModules,
            isSelected: apiModule.isSelected, // Will be recalculated later
          );
        }).toList();

    return mergedList;
  }
}
