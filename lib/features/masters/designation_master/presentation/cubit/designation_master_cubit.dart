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
    required String probationPeriod,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      'DesignationName': designationName,
      'NoticePeriod': noticePeriod,
      'ProbationPeriod': probationPeriod,
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
        showSuccessMessage(context, subTitle: 'Designation Added Successfully');
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
    required String probationPeriod,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      'DesignationMasterId': designationMasterId,
      'UniqueKey': uniqueKey,
      'DesignationName': designationName,
      'NoticePeriod': noticePeriod,
      'ProbationPeriod': probationPeriod,
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
          subTitle: 'Designation Updated Successfully',
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
          subTitle: 'Designation Deleted Successfully',
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
        showSuccessMessage(
          context,
          subTitle: 'Successfully Exported as $exportType',
        );
        exportExcelOrPdfMobile(
          response["data"],
          exportType.toLowerCase() == "pdf"
              ? "Designation Master ${DateTime.now()}.pdf"
              : "Designation Master ${DateTime.now()}.xlsx",
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
          subTitle: response['message'] ?? 'Permissions Saved Successfully',
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
        goRouter.pop();
      },
    );
  }

  // <---- CHECK IF ALL MODULES ARE SELECTED ---->
  Future<bool> isAllModulesSelected(
    List<ModuleModel> modulesPermissionsList,
  ) async {
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
    // CREATE DEEP COPY OF LIST FOR REFRESHING UI
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
    // FOR REFRESHING UI
    final updatedList = List<ModuleModel>.from(result[0]);
    emit(
      state.copyWith(
        isAllSelected: result[1],
        modulesPermissionsList: updatedList,
        stateType: StateType.employeeMasterModuleAccessState,
        updateCounter: state.updateCounter + 1,
      ),
    );
  }

  // UPDATE LIST
  Future<List> updateList(
    List<ModuleModel> list, {
    int? moduleIndex,
    int? subModuleIndex,
    int? subSubModuleIndex,
    required bool value,
    String? type,
  }) async {
    /// CASE 1 : SUB SUB MODULE
    if (subSubModuleIndex != null && subModuleIndex != null) {
      final module = list[moduleIndex!];
      final subModule = module.subModuleData[subModuleIndex];
      final subSub = subModule.subSubModuleData[subSubModuleIndex];

      switch (type) {
        case "action":
          subSub.isAction = value;
          if (value) subSub.isView = true;
          break;

        case "export":
          subSub.isExport = value;
          if (value) subSub.isView = true;
          break;

        case "view":
          subSub.isView = value;
          if (!value) {
            subSub.isAction = false;
            subSub.isExport = false;
          }
          break;
      }

      /// RECALC SUBMODULE
      subModule.isAction = subModule.subSubModuleData.every((e) => e.isAction);

      subModule.isExport = subModule.subSubModuleData.every((e) => e.isExport);

      subModule.isView = subModule.subSubModuleData.every((e) => e.isView);

      subModule.isSelected = subModule.subSubModuleData.every(
        (e) => e.isAction && e.isView && e.isExport,
      );

      /// RECALC MODULE
      module.isSelected = module.subModuleData.every((e) => e.isSelected);
    }
    /// CASE 2 : SUB MODULE
    else if (subModuleIndex != null) {
      final module = list[moduleIndex!];
      final subModule = module.subModuleData[subModuleIndex];

      if (type != null) {
        switch (type) {
          case "action":
            subModule.isAction = value;
            if (value) subModule.isView = true;

            for (var s in subModule.subSubModuleData) {
              s.isAction = value;
              if (value) s.isView = true;
            }
            break;

          case "export":
            subModule.isExport = value;
            if (value) subModule.isView = true;

            for (var s in subModule.subSubModuleData) {
              s.isExport = value;
              if (value) s.isView = true;
            }
            break;

          case "view":
            subModule.isView = value;

            for (var s in subModule.subSubModuleData) {
              s.isView = value;

              if (!value) {
                s.isAction = false;
                s.isExport = false;
              }
            }

            if (!value) {
              subModule.isAction = false;
              subModule.isExport = false;
            }
            break;
        }
      }

      /// RECALC SELECTED
      if (subModule.subSubModuleData.isEmpty) {
        subModule.isSelected =
            subModule.isAction && subModule.isView && subModule.isExport;
      } else {
        subModule.isAction = subModule.subSubModuleData.every(
          (e) => e.isAction,
        );

        subModule.isExport = subModule.subSubModuleData.every(
          (e) => e.isExport,
        );

        subModule.isView = subModule.subSubModuleData.every((e) => e.isView);

        subModule.isSelected = subModule.subSubModuleData.every(
          (e) => e.isAction && e.isView && e.isExport,
        );
      }

      module.isSelected = module.subModuleData.every((e) => e.isSelected);
    }
    /// CASE 3 : MODULE
    else if (moduleIndex != null) {
      final module = list[moduleIndex];

      for (var sub in module.subModuleData) {
        if (sub.subSubModuleData.isEmpty) {
          sub.isAction = value;
          sub.isExport = value;
          sub.isView = value;
          sub.isSelected = value;
        } else {
          for (var s in sub.subSubModuleData) {
            s.isAction = value;
            s.isExport = value;
            s.isView = value;
          }

          sub.isSelected = value;
        }
      }

      module.isSelected = value;
    }
    /// CASE 4 : SELECT ALL
    else {
      for (var module in list) {
        module.isSelected = value;

        for (var sub in module.subModuleData) {
          if (sub.subSubModuleData.isEmpty) {
            sub.isAction = value;
            sub.isExport = value;
            sub.isView = value;
            sub.isSelected = value;
          } else {
            sub.isAction = value;
            sub.isExport = value;
            sub.isView = value;

            for (var s in sub.subSubModuleData) {
              s.isAction = value;
              s.isExport = value;
              s.isView = value;
            }

            sub.isSelected = value;
          }
        }
      }
    }

    return [list, list.every((e) => e.isSelected)];
  }

  // <---- MERGE MODULE LISTS TO PRESERVE UNSAVED CHANGES ---->
  List<ModuleModel> _mergeModuleLists({
    required List<ModuleModel> existingList,
    required List<ModuleModel> apiList,
  }) {
    final Map<int, ModuleModel> existingModulesMap = {};
    for (var module in existingList) {
      existingModulesMap[module.modulesMasterId] = module;
    }

    List<ModuleModel> mergedList =
        apiList.map((apiModule) {
          final existingModule = existingModulesMap[apiModule.modulesMasterId];

          if (existingModule == null) {
            return apiModule;
          }

          final Map<int, SubModuleModel> existingSubModulesMap = {};
          for (var subModule in existingModule.subModuleData) {
            existingSubModulesMap[subModule.subModulesMasterId] = subModule;
          }

          List<SubModuleModel> mergedSubModules =
              apiModule.subModuleData.map((apiSubModule) {
                final existingSubModule =
                    existingSubModulesMap[apiSubModule.subModulesMasterId];

                if (existingSubModule == null) {
                  return apiSubModule;
                }

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

                      if (existingSubSubModule == null) {
                        return apiSubSubModule;
                      }

                      apiSubSubModule.isAction = existingSubSubModule.isAction;
                      apiSubSubModule.isView = existingSubSubModule.isView;
                      apiSubSubModule.isExport = existingSubSubModule.isExport;

                      return apiSubSubModule;
                    }).toList();

                // UPDATE - SUB MODULE
                apiSubModule.subSubModuleData = mergedSubSubModules;

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
                  // IF ACTION OR EXPORT CHECKED, AUTOMATICALLY CHECK VIEW AS WELL
                  if (apiSubModule.isAction || apiSubModule.isExport) {
                    apiSubModule.isView = true;
                  }
                }

                return apiSubModule;
              }).toList();

          // CREATE MERGE MODULE
          return ModuleModel(
            modulesMasterId: apiModule.modulesMasterId,
            moduleName: apiModule.moduleName,
            icon: apiModule.icon,
            subModuleData: mergedSubModules,
            isSelected: apiModule.isSelected,
          );
        }).toList();

    return mergedList;
  }
}
