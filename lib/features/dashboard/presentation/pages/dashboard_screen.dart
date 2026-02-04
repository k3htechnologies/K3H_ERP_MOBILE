import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/presentation/pages/main_screen.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/widget/project_selector_overlay.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/utils/call_history_helper.dart';
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

  final ValueNotifier<bool> _showOverlayNotifier = ValueNotifier(false);

  ProjectModel? _selectedProject;

  // Call history (Android only)
  List<String> _callHistoryLogs = [];
  String? _callHistoryError;
  bool _callHistoryLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    if (Platform.isAndroid) {
      _loadCallHistory();
    }
  }

  @override
  void dispose() {
    _showOverlayNotifier.dispose();
    super.dispose();
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

  Future<void> _loadCallHistory() async {
    if (!Platform.isAndroid) return;
    setState(() {
      _callHistoryLoading = true;
      _callHistoryError = null;
      _callHistoryLogs = [];
    });
    final result = await getCallHistory();
    for (final line in result.logLines) {
      debugPrint('[CallHistory] $line');
    }
    if (!result.success && result.errorMessage != null) {
      debugPrint('[CallHistory] Error: ${result.errorMessage}');
    }
    if (mounted) {
      setState(() {
        _callHistoryLoading = false;
        _callHistoryError = result.errorMessage;
        _callHistoryLogs = result.logLines;
      });
    }
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
        title: const Text("Dashboard"),
        actions: [
          ValueListenableBuilder<List<ProjectModel>>(
            valueListenable: _projectListNotifier,
            builder: (context, projects, _) {
              if (projects.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  _showOverlayNotifier.value = true;
                },
                icon: const Icon(Icons.apartment_rounded),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text("Jay Shree Ram..!!!")),
              ),
              if (Platform.isAndroid) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "Call history (Android)",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(width: 8),
                      if (_callHistoryLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: _loadCallHistory,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Refresh"),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child:
                        _callHistoryLoading && _callHistoryLogs.isEmpty
                            ? const Center(
                              child: Text("Loading call history..."),
                            )
                            : _callHistoryError != null &&
                                _callHistoryLogs.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Text(
                                  _callHistoryError!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            )
                            : _callHistoryLogs.isEmpty
                            ? const Center(
                              child: Text(
                                "No call history or permission denied.",
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _callHistoryLogs.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  child: SelectableText(
                                    _callHistoryLogs[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("Call history: Android only")),
                ),
            ],
          ),
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
}
