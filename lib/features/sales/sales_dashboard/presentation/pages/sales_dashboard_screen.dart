import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_dashboard/presentation/cubit/sales_dashboard_cubit.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  // PROJECT MASTER REPOSITORY
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  // CUBIT
  late SalesDashboardCubit _salesDashboardCubit;

  final ValueNotifier<List<ProjectModel>> _projectListNotifier = ValueNotifier(
    [],
  );

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);

  ProjectModel? _selectedProject;
  void _onProjectSelected(ProjectModel project) {
    _selectedProject = project;
    LocalStorageManager().setString(
      StorageKey.selectedProject,
      jsonEncode(project.toJson()),
    );
    showSuccessMessage(
      context,
      subTitle: "Project Selected ${project.projectName}",
    );
  }

  @override
  void initState() {
    super.initState();
    _salesDashboardCubit = context.read<SalesDashboardCubit>();
    _loadProjects();
    _salesDashboardCubit.getSalesDashboardList(context);
  }

  Future<void> _loadProjects() async {
    await _fetchProjects(1);
    final projects = _projectListNotifier.value;
    ProjectModel? storedProject;
    final storedJson = LocalStorageManager().getString(
      StorageKey.selectedProject,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            mobileScreenGlobalScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text("Sales Dashboard"),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  DialogHelper.showProcessingOverlay(context);
                },
                icon: SvgPicture.asset(
                  AppAssets.dashboardNotificationIcon,
                  height: 32,
                  width: 32,
                ),
              ),
              ValueListenableBuilder<List<ProjectModel>>(
                valueListenable: _projectListNotifier,
                builder: (context, projects, _) {
                  if (projects.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () {
                      _showOverlayNotifier.value = true;
                    },
                    icon: SvgPicture.asset(
                      AppAssets.projectIcon,
                      height: 32,
                      width: 32,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          Text("hello"),
          ValueListenableBuilder<bool>(
            valueListenable: _showOverlayNotifier,
            builder: (context, showOverlay, _) {
              if (!showOverlay) return const SizedBox.shrink();
              return ProjectSelectorOverlay(
                projects: _projectListNotifier.value,
                selectedProjectId: _selectedProject?.projectId,
                onSelect: _onProjectSelected,
                onClose: () {
                  _showOverlayNotifier.value = false;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
