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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
      _filterProjectLocationC,
      _filterCTSNumberC;

  // FOR ACTIONS ( ADD/EDIT/DELETE/EXPORT )
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initialiseTextController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectMaster]!;
    _projectMasterCubit = BlocProvider.of<ProjectMasterCubit>(context);
    _projectMasterCubit.getProjectList(context: context, pageNumber: 1);
    _onScroll();
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  // INITIALISING TEXT CONTROLLER
  void _initialiseTextController() {
    _searchC = TextEditingController();

    _filterCTSNumberC = TextEditingController();
    _filterProjectLocationC = TextEditingController();
  }

  // <---- PAGINATION ---->
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

  // VENDOR FILTER
  Future<void> _showBottomSheetToFilterProjectMaster(
    BuildContext context,
  ) async {
    final state = _projectMasterCubit.state;

    _filterCTSNumberC.text = state.filterCTSNumber;
    _filterProjectLocationC.text = state.filterProjectLocation;

    final String initialProjectLocation = _filterProjectLocationC.text;
    final String initialCTSNumber = _filterCTSNumberC.text;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterCTSNumberC.text.trim() != initialCTSNumber) ||
            (_filterProjectLocationC.text.trim() != initialProjectLocation);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Project",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(height: 5),
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
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterCTSNumberC.clear();
        _filterProjectLocationC.clear();
        _projectMasterCubit.sortProject(context: context, isClear: true);
      },
      onApply: () {
        applied = true;
        _projectMasterCubit.sortProject(
          context: context,
          ctsNumber: _filterCTSNumberC.text.trim(),
          projectLocation: _filterProjectLocationC.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Project Management",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          _projectMasterCubit.searchProject(context, value);
        },
        textController: _searchC,
        searchHintText: "Search by Project Name",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addProjectMaster);
          if (context.mounted) {
            _projectMasterCubit.getProjectList(context: context, pageNumber: 1);
          }
        },
        onExportCallback: (value) {
          if(_projectMasterCubit.state.totalNumberOfRecord==0){
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
      body: BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.projectList.isEmpty) {
            return Center(child: loader());
          }
          if (state.projectList.isEmpty) {
            return Center(child: noDataWidget());
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    project.projectName,
                                    style: AppTextStyle.ts16M(
                                      color: AppColor.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        CustomIconButton.edit(
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

                        // VALUE
                        _buildProjectStatusWidget(project.projectStatus),
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
    );
  }

  // BUILD PROJECT STATUS WIDGET
  Widget _buildProjectStatusWidget(String projectStatus) {
    if (projectStatus.isEmpty) return const SizedBox.shrink();

    Color bgColor;
    Color textColor;

    switch (projectStatus) {
      case 'Completed':
        bgColor = AppColor.lightGreen;
        textColor = AppColor.darkGreen;
        break;

      case 'On-Going':
        bgColor = AppColor.lightBlue;
        textColor = AppColor.primary;
        break;

      case 'On-Hold':
        bgColor = AppColor.lightRed;
        textColor = AppColor.error;
        break;
      case 'Cancelled':
        bgColor = AppColor.lightRed;
        textColor = AppColor.error;
        break;
      case 'Planning':
        bgColor = AppColor.lightRed;
        textColor = AppColor.error;
        break;

      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        projectStatus,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.ts14R(color: textColor),
      ),
    );
  }
}
