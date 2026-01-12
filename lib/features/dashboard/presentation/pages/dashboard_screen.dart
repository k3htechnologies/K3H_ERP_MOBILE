import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widhet/project_selector_overlay.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
  serviceLocator<ProjectMasterRepository>();

  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  ProjectModel? _selectedProject;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await _fetchProjects(1);
    final projects = _projectListNotifier.value;
    ProjectModel? storedProject;
    final storedJson = LocalStorageManager().getString(StorageKey.selectedProject);
    if (storedJson != null && storedJson.isNotEmpty) {
      storedProject = ProjectModel.fromJson(jsonDecode(storedJson));
    }
    if (storedProject != null &&
        projects.any((p) => p.projectId == storedProject!.projectId)) {
      _selectedProject = storedProject;
    } else if (projects.isNotEmpty) {
      _selectedProject = projects.first;
      LocalStorageManager().setString(
        StorageKey.selectedProject,
        jsonEncode(_selectedProject!.toJson()),
      );
    }
    if (mounted) setState(() {});
  }

  // FETCH PROJECTS
  Future<Map<String, dynamic>> _fetchProjects(
      int pageNumber, {
        String? value,
      }) async {
    final userJson = jsonDecode(
      LocalStorageManager().getString(StorageKey.currentUser) ?? '',
    );
    final user = UserModel.fromJson(userJson);

    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 100,
      queryParams: {
        'EmployeeId': user.employeeId.toString(),
        if (value != null && value.isNotEmpty) 'ProjectName': value,
      },
    );

    return result.fold(
          (failure) {
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
          (response) {
        final List<ProjectModel> projects =
        (response['data'] as List<ProjectModel>);
        if (pageNumber == 1) {
          _projectListNotifier.value = projects;
        } else {
          _projectListNotifier.value = [
            ..._projectListNotifier.value,
            ...projects,
          ];
        }
        final List<Map<String, dynamic>> itemList =
        projects
            .map(
              (project) => {
            'zAttributesId': project.projectId,
            'DisplayName': project.projectName,
          },
        )
            .toList();
        return {
          "itemList": itemList,
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Dashboard"),
        actions: [
          ValueListenableBuilder<List<ProjectModel>>(
            valueListenable: _projectListNotifier,
            builder: (context, projects, _) {
              if (projects.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  setState(() {
                    _showOverlay = true;
                  });
                },
                icon: const Icon(Icons.apartment_rounded),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(child: Text("Jay Shree Ram..!!!")),
          if (_showOverlay)
            ProjectSelectorOverlay(
              projects: _projectListNotifier.value,
              selectedProjectId: _selectedProject?.projectId,
              onSelect: _onProjectSelected,
              onClose: () {
                setState(() {
                  _showOverlay = false;
                });
              },
            ),
        ],
      ),
    );
  }

  void _onProjectSelected(ProjectModel project) {
    _selectedProject = project;
    LocalStorageManager().setString(
      StorageKey.selectedProject,
      jsonEncode(project.toJson()),
    );
    showSuccessMessage(context,subTitle: "Project Selected ${project.projectName}");
    if (mounted) setState(() {});
  }
}
