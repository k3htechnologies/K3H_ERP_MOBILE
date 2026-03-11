import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/data/repository/login.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_experience_details.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_document.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/repository/branch_association_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/main.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial()) {
    _loadUserData();
  }

  // REPOSITORY
  final LoginRepository _loginRepository = serviceLocator<LoginRepository>();

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final BranchAssociationMasterRepository _branchAssociationMasterRepository =
      serviceLocator<BranchAssociationMasterRepository>();

  // LOCAL STORAGE MANAGER
  final _localStorage = LocalStorageManager();

  // LOAD USER DATA
  Future<void> _loadUserData() async {
    final user = await _getUser();
    final project = _getSelectedProject();

    if (user != null) {
      emit(
        state.copyWith(
          user: user,
          selectedProject: project,
          projectList: user.projectData,
        ),
      );

      /// AUTO LOAD OVERVIEW
      getEmployeeMasterList(
        navigatorKey.currentContext!,
        1,
        100,
        user.employeeId,
      );
    }
  }

  // GET USER
  Future<UserModel?> _getUser() async {
    String? userString = _localStorage.getString(StorageKey.currentUser);
    if (userString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(userString));
  }

  // GET SELECTED PROJECT
  ProjectModel? _getSelectedProject() {
    return getProject();
  }

  // FETCH PROJECT
  Future<void> fetchProjects(BuildContext context) async {
    if (state.user == null || state.user!.projectData.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingProjects: true));

    try {
      final projectIds =
          state.user!.projectData.map((p) => p.projectId).toList();

      final result = await _projectMasterRepository.getProjectList(
        pageNumber: 1,
        pageSize: 100,
        queryParams: null,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              projectList: state.user!.projectData,
              isLoadingProjects: false,
            ),
          );
        },
        (response) {
          final allProjects = response['data'] as List<ProjectModel>;
          if (allProjects.isEmpty) {
            // If API returns empty, use user's projectData
            emit(
              state.copyWith(
                projectList: state.user!.projectData,
                isLoadingProjects: false,
              ),
            );
            return;
          }

          final filteredProjects =
              allProjects
                  .where((p) => projectIds.contains(p.projectId))
                  .toList();

          emit(
            state.copyWith(
              projectList:
                  filteredProjects.isNotEmpty
                      ? filteredProjects
                      : state.user!.projectData,
              isLoadingProjects: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          projectList: state.user?.projectData ?? [],
          isLoadingProjects: false,
        ),
      );
    }
  }

  // ON TAB CHANGES METHOD
  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
    if (state.user == null) return;

    final employeeId = state.user!.employeeId;
    if (index == 0) {
      getEmployeeMasterList(context, 1, 100, employeeId);
    } else if (index == 1) {
      // Education tab
      getEmployeeEducationDetailsList(context, 1, 100, employeeId);
    } else if (index == 2) {
      // Experience tab
      getEmployeeExperienceDetailsList(context, 1, 100, employeeId);
    } else if (index == 3) {
      // Document tab
      getBranchAssociationList(context, 1, 100, employeeId);
    } else if (index == 4) {
      // Document tab
      getEmployeeDocumentList(context, 1, 100, employeeId);
    } else if (index == 5) {
      // Assets tab
      getEmployeeAssetList(context, 1, 100, employeeId);
    } else if (index == 6) {
      // Project tab
      if (state.projectList.isEmpty && state.user!.projectData.isNotEmpty) {
        fetchProjects(context);
      }
    } else if (index == 7) {
      // Shift Policy tab
      getShiftManagementList(context, 1, 100, employeeId);
    } else if (index == 8) {
      // Week Off Policy tab
      getWeekOffMappingList(context, 1, 100, employeeId);
    }
  }

  // <---- GET EMPLOYEE MASTER LIST ---->
  Future getEmployeeMasterList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {"EmployeeId": employeeId, "IsCheckPermission": false},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<UserModel> newList =
            pageNumber == 1
                ? List<UserModel>.from(dataList)
                : [
                  ...state.employeeMasterList,
                  ...List<UserModel>.from(dataList),
                ];
        emit(state.copyWith(isLoading: false, employeeMasterList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE DOCUMENT LIST ---->
  Future getEmployeeDocumentList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository.getEmployeeDocumentList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {"EmployeeId": employeeId},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List<EmployeeDocumentModel>;

        emit(state.copyWith(isLoading: false, employeeDocumentList: dataList));
      },
    );
  }

  // <---- GET EMPLOYEE ASSET LIST ---->
  Future getEmployeeAssetList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository.getEmployeeAssetList(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: {"EmployeeId": employeeId,"IsCheckPermission":"false"},
    );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<AssetMappingModel> newList =
            pageNumber == 1
                ? List<AssetMappingModel>.from(dataList)
                : [
                  ...state.assetMappingList,
                  ...List<AssetMappingModel>.from(dataList),
                ];

        emit(state.copyWith(isLoading: false, assetMappingList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE SHIFT MANAGEMENT LIST ---->
  Future getShiftManagementList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository
        .getEmployeeShiftManagementList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId,"IsCheckPermission":"false"},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<ShiftMappingModel> newList =
            pageNumber == 1
                ? List<ShiftMappingModel>.from(dataList)
                : [
                  ...state.shiftManagementList,
                  ...List<ShiftMappingModel>.from(dataList),
                ];

        emit(state.copyWith(isLoading: false, shiftManagementList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE WEEK OFF MAPPING LIST ---->
  Future getWeekOffMappingList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository
        .getEmployeeWeekOffMappingList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId,"IsCheckPermission":"false"},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<WeekOffMappingModel> newList =
            pageNumber == 1
                ? List<WeekOffMappingModel>.from(dataList)
                : [
                  ...state.weekOffMappingList,
                  ...List<WeekOffMappingModel>.from(dataList),
                ];

        emit(state.copyWith(isLoading: false, weekOffMappingList: newList));
      },
    );
  }

  // <---- GET EMPLOYEE EDUCATION DETAILS LIST ---->
  Future getEmployeeEducationDetailsList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository
        .getEmployeeEducationDetailsList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<EmployeeEducationDetailsModel> newList =
            pageNumber == 1
                ? List<EmployeeEducationDetailsModel>.from(dataList)
                : [
                  ...state.employeeEducationDetailsList,
                  ...List<EmployeeEducationDetailsModel>.from(dataList),
                ];

        emit(
          state.copyWith(
            isLoading: false,
            employeeEducationDetailsList: newList,
          ),
        );
      },
    );
  }

  // <---- ADD DEPARTMENT ---->
  Future addEmployeeEducationDetails({
    required BuildContext context,
    required String employeeId,
    required String qualification,
    required String collegeName,
    required String passing,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "EmployeeEducationDetailsId": 0,
      "EmployeeId": employeeId,
      "Qualification": qualification,
      "CollegeName": collegeName,
      "Passing": passing,
    };
    var addResult = await _employeeMasterRepository
        .addUpdateEmployeeEducationDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Employee education details added successfully',
        );
        if (state.user != null) {
          getEmployeeEducationDetailsList(
            context,
            1,
            100,
            state.user!.employeeId,
          );
        }
      },
    );
  }

  // <---- UPDATE DEPARTMENT ---->
  Future updateEmployeeEducationDetails({
    required BuildContext context,
    required int employeeEducationDetailsId,
    required String uniqueKey,
    required String employeeId,
    required String qualification,
    required String collegeName,
    required String passing,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "EmployeeEducationDetailsId": employeeEducationDetailsId,
      "Uniquekey": uniqueKey,
      "EmployeeId": employeeId,
      "Qualification": qualification,
      "CollegeName": collegeName,
      "Passing": passing,
    };
    var addResult = await _employeeMasterRepository
        .addUpdateEmployeeEducationDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedEducation =
            response['data'][0] as EmployeeEducationDetailsModel;

        if (state.employeeEducationDetailsList.isNotEmpty &&
            index < state.employeeEducationDetailsList.length) {
          final updatedList = List<EmployeeEducationDetailsModel>.from(
            state.employeeEducationDetailsList,
          );
          updatedList[index] = updatedEducation;
          emit(
            state.copyWith(
              employeeEducationDetailsList: updatedList,
              isLoading: false,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Employee education details updated successfully',
        );
      },
    );
  }

  // <---- DELETE EMPLOYEE EDUCATION DETAILS ---->
  Future deleteEmployeeEducationDetails({
    required BuildContext context,
    required int employeeEducationDetailsId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _employeeMasterRepository
        .deleteEmployeeEducationDetails(
          employeeEducationDetailsId: employeeEducationDetailsId,
          uniqueKey: uniqueKey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Employee Education Details Deleted Successfully',
        );
        if (index != null) {
          final updatedList = List<EmployeeEducationDetailsModel>.from(
            state.employeeEducationDetailsList,
          );
          updatedList.removeAt(index);

          emit(state.copyWith(employeeEducationDetailsList: updatedList));
        } else {
          getEmployeeEducationDetailsList(
            context,
            1,
            100,
            state.user!.employeeId,
          );
        }
      },
    );
  }

  // <---- GET EMPLOYEE EXPERIENCE DETAILS LIST ---->
  Future getEmployeeExperienceDetailsList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _employeeMasterRepository
        .getEmployeeExperienceDetailsList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<EmployeeExperienceDetailsModel> newList =
            pageNumber == 1
                ? List<EmployeeExperienceDetailsModel>.from(dataList)
                : [
                  ...state.employeeExperienceDetailsList,
                  ...List<EmployeeExperienceDetailsModel>.from(dataList),
                ];

        emit(
          state.copyWith(
            isLoading: false,
            employeeExperienceDetailsList: newList,
          ),
        );
      },
    );
  }

  // <---- ADD EXPERIENCE DETAILS ---->
  Future addEmployeeExperienceDetails({
    required BuildContext context,
    required String employeeId,
    required String companyName,
    required String role,
    required String tenure,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "EmployeeExperienceDetailsId": 0,
      "EmployeeId": employeeId,
      "CompanyName": companyName,
      "Role": role,
      "Tenure": tenure,
    };
    var addResult = await _employeeMasterRepository
        .addUpdateEmployeeExperienceDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Employee experience details added successfully',
        );
        if (state.user != null) {
          getEmployeeExperienceDetailsList(
            context,
            1,
            100,
            state.user!.employeeId,
          );
        }
      },
    );
  }

  // <---- UPDATE EXPERIENCE DETAILS ---->
  Future updateEmployeeExperienceDetails({
    required BuildContext context,
    required int employeeExperienceDetailsId,
    required String uniqueKey,
    required String employeeId,
    required String companyName,
    required String role,
    required String tenure,
    required int index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, dynamic> requestBody = {
      "EmployeeExperienceDetailsId": employeeExperienceDetailsId,
      "Uniquekey": uniqueKey,
      "EmployeeId": employeeId,
      "CompanyName": companyName,
      "Role": role,
      "Tenure": tenure,
    };
    var addResult = await _employeeMasterRepository
        .addUpdateEmployeeExperienceDetails(body: requestBody);
    goRouter.pop();
    addResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        final updatedEducation =
            response['data'][0] as EmployeeExperienceDetailsModel;

        if (state.employeeExperienceDetailsList.isNotEmpty &&
            index < state.employeeExperienceDetailsList.length) {
          final updatedList = List<EmployeeExperienceDetailsModel>.from(
            state.employeeExperienceDetailsList,
          );
          updatedList[index] = updatedEducation;
          emit(
            state.copyWith(
              employeeExperienceDetailsList: updatedList,
              isLoading: false,
            ),
          );
        }

        showSuccessMessage(
          context,
          subTitle: 'Employee experience details updated successfully',
        );
      },
    );
  }

  // <---- DELETE EMPLOYEE EXPERIENCE DETAILS ---->
  Future deleteEmployeeExperienceDetails({
    required BuildContext context,
    required int employeeExperienceDetailsId,
    required String uniqueKey,
    int? index,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    var deleteResult = await _employeeMasterRepository
        .deleteEmployeeExperienceDetails(
          employeeExperienceDetailsId: employeeExperienceDetailsId,
          uniqueKey: uniqueKey,
        );
    goRouter.pop();
    deleteResult.fold(
      (failure) {
        showErrorMessage(context, 'Error', failure.message);
        return;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: 'Employee Experience Details Deleted Successfully',
        );
        if (index != null) {
          final updatedList = List<EmployeeExperienceDetailsModel>.from(
            state.employeeExperienceDetailsList,
          );
          updatedList.removeAt(index);

          emit(state.copyWith(employeeExperienceDetailsList: updatedList));
        } else {
          getEmployeeExperienceDetailsList(
            context,
            1,
            100,
            state.user!.employeeId,
          );
        }
      },
    );
  }

  // <---- GET BRANCH ASSOCIATION LIST ---->
  Future getBranchAssociationList(
    BuildContext context,
    int pageNumber,
    int pageSize,
    int employeeId,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _branchAssociationMasterRepository
        .getBranchAssociationList(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: {"EmployeeId": employeeId,"IsCheckPermission":"false"},
        );

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
      },
      (response) {
        final dataList = response['data'] as List;
        List<BranchAssociationModel> newList =
            pageNumber == 1
                ? List<BranchAssociationModel>.from(dataList)
                : [
                  ...state.branchAssociationList,
                  ...List<BranchAssociationModel>.from(dataList),
                ];

        emit(state.copyWith(isLoading: false, branchAssociationList: newList));
      },
    );
  }

  Future<void> sepMpin({
    required BuildContext context,
    required String pin,
    required int employeeId,
    required String uniqueKey,
  }) async {
    try {
      Map<String, dynamic> body = {
        "EmployeeId": employeeId,
        "UniqueKey": uniqueKey,
        "MPIN": pin,
      };

      final result = await _loginRepository.setMpin(body: body);

      result.fold(
        (failure) {
          goRouter.pop();
          showErrorMessage(context, "Error", failure.message);
        },
        (message) async {
          goRouter.pop();
          if (context.mounted) {
            showSuccessMessage(context, subTitle: message);
          }

          Future.delayed(Duration(seconds: 1), () async {
            await _localStorage.removeAll();
            goRouter.replace(AppRoutes.splashScreen);
          });
        },
      );
    } catch (e) {
      debugPrint("Jay Shree Ram!!!");
    }
  }

  // <---- UPDATE EMPLOYEE DOCUMENT ---->
  Future updateEmployeeDocument({
    required BuildContext context,
    required int employeeDocumentId,
    required String uniqueKey,
    required String employeeId,
    required String documentName,
    required String removeDocumentURL,
    required MultiFilePickerModel files,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    Map<String, String> requestBody = {
      'EmployeeDocumentId': employeeDocumentId.toString(),
      'UniqueKey': uniqueKey,
      "EmployeeId": employeeId,
      "DocumentName": documentName,
      "RemoveDocumentURL": removeDocumentURL,
    };

    List<Map<String, dynamic>> fileList = [];

    for (int i = 0; i < files.fileNameList.length; i++) {
      if (files.fileNameList[i].contains("http")) {
        continue;
      }
      fileList.add({
        "key": "DocumentURL",
        "value": files.fileBytesList[i],
        "fileName": files.fileNameList[i],
      });
    }

    var updateResult = await _employeeMasterRepository
        .addUpdateEmployeeDocument(
          requestBody: requestBody,
          fileList: fileList,
        );
    goRouter.pop();
    updateResult.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error Message', failure.message);
        return;
      },
      (response) async {
        showSuccessMessage(context, subTitle: response["successMessage"]);
        await getEmployeeDocumentList(context, 1, 100, int.parse(employeeId));
      },
    );
  }
}
