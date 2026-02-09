import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/asset_master_mapping/data/model/asset_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_document.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial()) {
    _loadUserData();
  }

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  void _loadUserData() {
    final user = _getUser();
    final project = _getSelectedProject();
    if (user != null) {
      emit(
        state.copyWith(
          user: user,
          selectedProject: project,
          projectList: user.projectData, // Initialize with user's projectData
        ),
      );
    }
  }

  UserModel? _getUser() {
    String? userString = LocalStorageManager().getString(
      StorageKey.currentUser,
    );
    if (userString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(userString));
  }

  ProjectModel? _getSelectedProject() {
    return getProject();
  }

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

          // Use filtered projects if found, otherwise fallback to user's projectData
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

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
    if (state.user == null) return;

    final employeeId = state.user!.employeeId;
    if (index == 1) {
      // Document tab
      getEmployeeEducationDetailsList(context, 1, 100, employeeId);
    } else if (index == 3) {
      // Document tab
      getEmployeeDocumentList(context, 1, 100, employeeId);
    } else if (index == 4) {
      // Assets tab
      getEmployeeAssetList(context, 1, 100, employeeId);
    } else if (index == 5) {
      // Project tab
      if (state.projectList.isEmpty && state.user!.projectData.isNotEmpty) {
        fetchProjects(context);
      }
    } else if (index == 6) {
      // Shift Policy tab
      getShiftManagementList(context, 1, 100, employeeId);
    } else if (index == 7) {
      // Week Off Policy tab
      getWeekOffMappingList(context, 1, 100, employeeId);
    }
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
      queryParams: {"EmployeeId": employeeId},
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
          queryParams: {"EmployeeId": employeeId},
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
          queryParams: {"EmployeeId": employeeId},
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
}
