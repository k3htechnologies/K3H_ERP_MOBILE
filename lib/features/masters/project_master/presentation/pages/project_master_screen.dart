import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectMasterScreen extends StatefulWidget {
  const ProjectMasterScreen({super.key});

  @override
  State<ProjectMasterScreen> createState() => _ProjectMasterScreenState();
}

class _ProjectMasterScreenState extends State<ProjectMasterScreen> {
  // CUBIT
  late ProjectMasterCubit _projectMasterCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC,
      _filterVillageC,
      _filterLiasoningArchitectNameC,
      _filterRERANumberC,
      _filterProjectLocationC,
      _filterCTSNumberC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  final ValueNotifier<Map<String, dynamic>?> selectedProjectStatus =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> selectedProjectSchemeNotifier =
      ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedProjectSubSchemeNotifier =
      ValueNotifier(null);
  ValueNotifier<bool?> isRedevelopement = ValueNotifier(false);
  late AuthorizationModel _routeAuthorizationModel;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  // STATIC LISTS
  List<Map<String, dynamic>> projectSchemeList = [
    {"zAttributesId": 1, "DisplayName": "BMC"},
    {"zAttributesId": 2, "DisplayName": "MHADA"},
    {"zAttributesId": 3, "DisplayName": "SRA"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeBMCList = [
    {"zAttributesId": 1, "DisplayName": "33 (20) B"},
    {"zAttributesId": 2, "DisplayName": "33 (19)"},
    {"zAttributesId": 3, "DisplayName": "33 (7)"},
    {"zAttributesId": 3, "DisplayName": "33 (7) B"},
    {"zAttributesId": 4, "DisplayName": "33 (7) A"},
    {"zAttributesId": 5, "DisplayName": "33 (9)"},
    {"zAttributesId": 6, "DisplayName": "33 (12) B"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeMHADAList = [
    {"zAttributesId": 1, "DisplayName": "33 (5)"},
  ];

  // STATIC LISTS
  List<Map<String, dynamic>> projectSubSchemeSRAList = [
    {"zAttributesId": 1, "DisplayName": "33 (10)"},
    {"zAttributesId": 2, "DisplayName": "33 (11)"},
  ];

  @override
  void initState() {
    super.initState();
    _initialiseTextController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectDetails]!;

    _projectMasterCubit = BlocProvider.of<ProjectMasterCubit>(context);
    _projectMasterCubit.getProjectList(context: context, pageNumber: 1);
    _onScroll();
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterVillageC.dispose();
    _filterLiasoningArchitectNameC.dispose();
    _filterRERANumberC.dispose();
    _filterProjectLocationC.dispose();
    _filterCTSNumberC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
  }

  // INITIALISING TEXT CONTROLLER
  void _initialiseTextController() {
    _searchC = TextEditingController();

    _filterCTSNumberC = TextEditingController();
    _filterProjectLocationC = TextEditingController();
    _filterVillageC = TextEditingController();
    _filterLiasoningArchitectNameC = TextEditingController();
    _filterRERANumberC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_projectMasterCubit.state.isLoading! &&
          _projectMasterCubit.state.projectList.length <
              _projectMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _projectMasterCubit.getProjectList(
            context: context,
            pageNumber: _projectMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    return item["DisplayName"] ?? "";
  }

  // PROJECT FILTER
  Future<void> _showBottomSheetToFilterProjectMaster(
    BuildContext context,
  ) async {
    final state = _projectMasterCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Project Name"
            ? state.currentSortDirection
            : null;

    final String? initialDirection = selectedDirection;
    _filterCTSNumberC.text = state.filterCTSNumber;
    _filterProjectLocationC.text = state.filterProjectLocation;
    final String initialProjectName = state.searchText;
    final String initialProjectLocation = state.filterProjectLocation;
    final String initialCTSNumber = state.filterCTSNumber;
    final String? initialProjectScheme = state.filterProjectScheme;
    final String? initialProjectSubScheme = state.filterProjectSubScheme;
    final String initialArchitectName =
        state.filterLiasoningArchitectName ?? "";
    final String initialRERANumber = state.filterRERANumber ?? "";
    final String initialProjectStatus = state.filterProjectStatus;
    final String initialVillage = state.filterVillage ?? "";
    final bool? initialIsRedevelopement = state.isRedevelopment;
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialProjectName) ||
            (_filterProjectLocationC.text.trim() != initialProjectLocation) ||
            (_filterCTSNumberC.text.trim() != initialCTSNumber) ||
            (getDisplayOrEmpty(selectedProjectSchemeNotifier.value) !=
                initialProjectScheme) ||
            (getDisplayOrEmpty(selectedProjectSubSchemeNotifier.value) !=
                initialProjectSubScheme) ||
            (_filterLiasoningArchitectNameC.text.trim() !=
                initialArchitectName) ||
            (_filterRERANumberC.text.trim() != initialRERANumber) ||
            (getDisplayOrEmpty(selectedProjectStatus.value) !=
                initialProjectStatus) ||
            (_filterVillageC.text.trim() != initialVillage) ||
            (isRedevelopement.value != initialIsRedevelopement) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Project Master",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Project Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),
                    horizontalSpacing(),
                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 20),
                Text("Is Redevelopment", style: AppTextStyle.ts14M()),
                ValueListenableBuilder<bool?>(
                  valueListenable: isRedevelopement,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          // ignore: deprecated_member_use
                          groupValue: value,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            isRedevelopement.value = val;
                            updateApplyState(innerState);
                          },
                        ),
                        Text("Yes", style: AppTextStyle.ts14R()),

                        horizontalSpacing(),

                        Radio<bool>(
                          value: false,
                          // ignore: deprecated_member_use
                          groupValue: value,
                          // ignore: deprecated_member_use
                          onChanged: (val) {
                            isRedevelopement.value = val;
                            updateApplyState(innerState);
                          },
                        ),
                        Text("No", style: AppTextStyle.ts14R()),
                      ],
                    );
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Project Name",
                  hint: "Enter Project Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Project Location",
                  hint: "Enter Project Location",
                  textController: _filterProjectLocationC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "CTS Number",
                  hint: "Enter CTS Number",
                  textController: _filterCTSNumberC,
                  inputFormatterList: [],
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                ValueListenableBuilder(
                  valueListenable: selectedProjectStatus,
                  builder: (context, value, child) {
                    return CustomDropDownWidget(
                      title: 'Project Status',
                      hintText: "Select Project Status",
                      initialValue: value,
                      dataList: projectStatusList,
                      onSelected: (value) {
                        selectedProjectStatus.value = value;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        selectedProjectStatus.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                CustomTextField(
                  title: "Village",
                  hint: "Enter Village",
                  textController: _filterVillageC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Liasoning Architect Name",
                  hint: "Enter Liasoning Architect Name",
                  textController: _filterLiasoningArchitectNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "RERA Number",
                  hint: "Enter RERA Number",
                  textController: _filterRERANumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedProjectSchemeNotifier,
                  builder: (context, selectedProjectScheme, _) {
                    return CustomDropDownWidget(
                      title: 'Project Scheme',
                      hintText: 'Select Project Scheme',
                      initialValue: selectedProjectScheme,
                      dataList: projectSchemeList,
                      onSelected: (value) {
                        selectedProjectSchemeNotifier.value = value;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        selectedProjectSchemeNotifier.value = null;
                        selectedProjectSubSchemeNotifier.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: selectedProjectSchemeNotifier,
                  builder: (context, selectedProjectScheme, _) {
                    return ValueListenableBuilder(
                      valueListenable: selectedProjectSubSchemeNotifier,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: 'Project Sub Scheme',
                          hintText: "Select Project Sub Scheme",
                          initialValue: value,
                          dataList: _currentSubSchemeList,
                          isDisabled: selectedProjectScheme == null,
                          onSelected: (value) {
                            selectedProjectSubSchemeNotifier.value = value;
                            updateApplyState(innerState);
                          },
                          onValueClear: () {
                            selectedProjectSubSchemeNotifier.value = null;
                            updateApplyState(innerState);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterCTSNumberC.clear();
        _filterProjectLocationC.clear();
        _filterLiasoningArchitectNameC.clear();
        _filterRERANumberC.clear();
        _filterVillageC.clear();
        selectedProjectSchemeNotifier.value = null;
        selectedProjectSubSchemeNotifier.value = null;
        selectedProjectStatus.value = null;
        isRedevelopement.value = false;
        _searchC.clear();
        _projectMasterCubit.sortProject(context: context, isClear: true);
      },
      onApply: () {
        applied = true;
        _projectMasterCubit.sortProject(
          context: context,
          projectName: _searchC.text.trim(),
          ctsNumber: _filterCTSNumberC.text.trim(),
          projectLocation: _filterProjectLocationC.text.trim(),
          village: _filterVillageC.text.trim(),
          liasoningArchitectName: _filterLiasoningArchitectNameC.text.trim(),
          projectStatus: selectedProjectStatus.value?['DisplayName'] ?? "",
          projectScheme: getDisplayOrEmpty(selectedProjectSchemeNotifier.value),
          projectSubScheme: getDisplayOrEmpty(
            selectedProjectSubSchemeNotifier.value,
          ),
          sortColumn: selectedDirection != null ? "Project Name" : null,
          sortDirection: selectedDirection,
          isRedevelopment: isRedevelopement.value,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterCTSNumberC.clear();
      _filterProjectLocationC.clear();
    }
  }

  List<Map<String, dynamic>> get _currentSubSchemeList {
    if (selectedProjectSchemeNotifier.value == null) return [{}];
    final id = selectedProjectSchemeNotifier.value!["zAttributesId"] as int?;
    if (id == null || id == -1) return projectSubSchemeBMCList;
    switch (id) {
      case 1:
        return projectSubSchemeBMCList; // BMC
      case 2:
        return projectSubSchemeMHADAList; // MHADA
      case 3:
        return projectSubSchemeSRAList; // SRA
      default:
        return projectSubSchemeBMCList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectMasterCubit, ProjectMasterState>(
      listener: (context, state) {
        _filterCount.value = _projectMasterCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Project Management",
          authorization: _routeAuthorizationModel,
          onSearchSubmit: (value) {
            _projectMasterCubit.searchProject(context, value);
          },
          filterCountNotifier: _filterCount,
          textController: _searchC,
          searchHintText: "Search by Project Name",
          onAddCallback: () async {
            await goRouter.pushNamed(AppRoutes.addProjectMaster);
            if (context.mounted) {
              _projectMasterCubit.searchProject(context, "");
            }
          },
          onExportCallback: (value) {
            if (_projectMasterCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _projectMasterCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterProjectMaster(context);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _projectMasterCubit.searchProject(context, "");
          },
          child: BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.projectList.isEmpty) {
                return Center(child: loader());
              }
              if (state.projectList.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: getActualHeight(context) * .7,
                      child: Center(
                        child: noDataWidget(message: "No projects found"),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _projectMasterCubit.state.projectList.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.projectList.length) {
                    return state.projectList.length < state.totalNumberOfRecord
                        ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var project = state.projectList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: commonCardDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  goRouter.pushNamed(
                                    AppRoutes.projectDetails,
                                    queryParameters: {
                                      "project": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(project),
                                        ),
                                      ),
                                    },
                                  );
                                },
                                child: Text(
                                  project.projectName,
                                  style: AppTextStyle.ts16M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                            CustomIconButton.edit(
                              isDisabled: !_routeAuthorizationModel.isAction,
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addProjectMaster,
                                  queryParameters: {
                                    "project": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(project),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            // TITLE
                            SizedBox(
                              width: 140,
                              child: Text(
                                "Project Status",
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                            ),

                            // COLON
                            SizedBox(
                              width: 20,
                              child: Text(
                                ":",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColor.grey),
                              ),
                            ),
                            project.projectStatus.isNotEmpty
                                ?
                                // VALUE
                                projectStatusWidget(project.projectStatus)
                                : Text("-"),
                          ],
                        ),
                        buildRowTitleValue(
                          title: "Project Location",
                          value: project.projectLocation,
                        ),
                        buildRowTitleValue(
                          title: "CTS Number",
                          value: project.ctsNumber,
                        ),
                        buildRowTitleValue(
                          title: "Business Category",
                          value: project.bussinessCategory,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
