import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState.initial()) {
    _loadUserData();
  }

  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  void _loadUserData() {
    final user = _getUser();
    final project = _getSelectedProject();
    if (user != null) {
      emit(state.copyWith(
        user: user,
        selectedProject: project,
        projectList: user.projectData, // Initialize with user's projectData
      ));
    }
  }

  UserModel? _getUser() {
    String? userString =
        LocalStorageManager().getString(StorageKey.currentUser);
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
      final projectIds = state.user!.projectData.map((p) => p.projectId).toList();

      final result = await _projectMasterRepository.getProjectList(
        pageNumber: 1,
        pageSize: 100,
        queryParams: null,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            projectList: state.user!.projectData,
            isLoadingProjects: false,
          ));
        },
        (response) {
          final allProjects = response['data'] as List<ProjectModel>;
          if (allProjects.isEmpty) {
            // If API returns empty, use user's projectData
            emit(state.copyWith(
              projectList: state.user!.projectData,
              isLoadingProjects: false,
            ));
            return;
          }
          
          final filteredProjects =
              allProjects.where((p) => projectIds.contains(p.projectId)).toList();

          // Use filtered projects if found, otherwise fallback to user's projectData
          emit(state.copyWith(
            projectList: filteredProjects.isNotEmpty
                ? filteredProjects
                : state.user!.projectData,
            isLoadingProjects: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        projectList: state.user?.projectData ?? [],
        isLoadingProjects: false,
      ));
    }
  }

  void onTabChanged(int index, BuildContext context) {
    emit(state.copyWith(currentTabIndex: index));
    if (index == 3 && state.user != null) {
      // Project tab is selected (index 3)
      // Only fetch if we want to refresh, otherwise use existing projectList
      if (state.projectList.isEmpty && state.user!.projectData.isNotEmpty) {
        fetchProjects(context);
      }
    }
  }
}

