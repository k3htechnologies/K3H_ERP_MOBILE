// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/modules_workflow_approval.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final Future<void> _delayFuture;

  late final PageController pageController;
  int currentIndex = 0;
  late final List<String> projectImages;

  // PAGINATION
  late ScrollController employeeScrollController;
  late ScrollController companyScrollController;
  late ScrollController bankScrollController;
  Timer? _debounce;
  Timer? _companyDebounce;
  Timer? _bankDebounce;

  late ProjectMasterCubit _projectMasterCubit;
  TabController? _approvalTabController;

  // TEXT CONTROLLER
  late TextEditingController _searchEmployeeC;

  @override
  void initState() {
    super.initState();

    _projectMasterCubit = context.read<ProjectMasterCubit>();

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);

    _delayFuture = Future.delayed(const Duration(seconds: 2));

    pageController = PageController();

    projectImages =
        (widget.project.projectPhotoUrl)
            .split(',')
            .map((e) => e.trim())
            .where(
              (e) =>
                  e.isNotEmpty &&
                  (e.startsWith('http://') || e.startsWith('https://')),
            )
            .toList();

    _onScroll();
    _onCompanyScroll();
    _onBankScroll();
    _searchEmployeeC = TextEditingController();
  }

  @override
  void dispose() {
    pageController.dispose();
    _tabController.dispose();
    employeeScrollController.dispose();
    companyScrollController.dispose();
    bankScrollController.dispose();
    _debounce?.cancel();
    _companyDebounce?.cancel();
    _bankDebounce?.cancel();
    _searchEmployeeC.dispose();
    super.dispose();
  }

  // <---- TAB CHANGE ---->
  void _handleTabChange() {
    final index = _tabController.index;
    context.read<ProjectMasterCubit>().onTabChanged(
      context,
      index,
      projectId: widget.project.projectId,
      employeeId: 0,
    );
    if (index != 4) {
      if (_approvalTabController != null) {
        _approvalTabController!.index = 0;
      }
    }
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    employeeScrollController = ScrollController();
    employeeScrollController.addListener(() {
      final cubit = context.read<ProjectMasterCubit>();
      const int pageSize = 10;
      final int totalPages =
          (cubit.state.employeeByProject.length / pageSize).ceil();

      if (employeeScrollController.position.pixels >=
              employeeScrollController.position.maxScrollExtent - 100 &&
          !cubit.state.isLoading! &&
          cubit.state.currentPageEmployee < totalPages) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          cubit.loadMoreEmployees();
        });
      }
    });
  }

  // <---- COMPANY PAGINATION ---->
  void _onCompanyScroll() {
    companyScrollController = ScrollController();
    companyScrollController.addListener(() {
      final cubit = context.read<ProjectMasterCubit>();
      const int pageSize = 10;
      final int totalPages =
          (cubit.state.companyByProject.length / pageSize).ceil();

      if (companyScrollController.position.pixels >=
              companyScrollController.position.maxScrollExtent - 100 &&
          !cubit.state.isLoading! &&
          cubit.state.currentPageCompany < totalPages) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_companyDebounce?.isActive ?? false) _companyDebounce?.cancel();
        _companyDebounce = Timer(const Duration(milliseconds: 300), () {
          cubit.loadMoreCompanies();
        });
      }
    });
  }

  // <---- BANK PAGINATION ---->
  void _onBankScroll() {
    bankScrollController = ScrollController();
    bankScrollController.addListener(() {
      if (!bankScrollController.hasClients) return;

      final cubit = context.read<ProjectMasterCubit>();
      final bankList = cubit.state.bankByProject;
      final currentPage = cubit.state.currentPageBank;

      if (bankList.isEmpty) return;

      const int pageSize = 10;
      final int totalPages = (bankList.length / pageSize).ceil();

      if (bankScrollController.position.pixels >=
              bankScrollController.position.maxScrollExtent - 100 &&
          !(cubit.state.isLoading ?? false) &&
          currentPage < totalPages) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_bankDebounce?.isActive ?? false) _bankDebounce?.cancel();
        _bankDebounce = Timer(const Duration(milliseconds: 300), () {
          cubit.loadMoreBanks();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Project Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.project.projectName,
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
            ),
            verticalSpacing(),
            ChipStyleTabBar(
              controller: _tabController,
              tabs: [
                "Overview",
                "Employee",
                "Bank Details",
                "Company",
                "Approval",
              ],
              onTabChanged: (_){
                _searchEmployeeC.clear();
            }
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _overviewSection(),
                  _employeeSection(),
                  _bankSection(),
                  _companySection(),
                  _approvalSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _overviewSection() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // PROJECT IMAGES
          Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder(
                  future: _delayFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.grey),
                      );
                    }

                    return PageView.builder(
                      controller: pageController,
                      itemCount: projectImages.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        if (projectImages.isEmpty) {
                          return Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: AppColor.grey30,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: (){
                            showFilePreviewDialog(context, [projectImages[index]]);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // IMAGE
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 0.8,
                                  sigmaY: 0.2,
                                ),
                                child: NetworkImageWidget(
                                  imageUrl: projectImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor.grey10.withValues(alpha: 0.2),
                                      AppColor.grey30.withValues(alpha: 0.4),
                                      AppColor.black.withValues(alpha: 0.6),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              verticalSpacing(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28,
                      color:
                          currentIndex == 0 ? AppColor.grey30 : AppColor.black,
                    ),
                    onPressed:
                        currentIndex == 0
                            ? null
                            : () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                  ),

                  Text(
                    '${currentIndex + 1} / ${projectImages.length}',
                    style: AppTextStyle.ts12R(color: AppColor.black),
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      size: 28,
                      color:
                          currentIndex == projectImages.length - 1
                              ? AppColor.grey30
                              : AppColor.black,
                    ),
                    onPressed:
                        currentIndex == projectImages.length - 1
                            ? null
                            : () {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                  ),
                ],
              ),
            ],
          ),
          verticalSpacing(),
          // BASIC DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Basic Project Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Redevelopment",
                      value: widget.project.isRedevelopment ? "Yes" : "No",
                    ),
                    buildColumnTitleValue(
                      title: "Project Name",
                      value: widget.project.projectName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "CTS Number",
                      value: widget.project.ctsNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Business Category",
                      value: widget.project.bussinessCategory,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Architect Name",
                      value: widget.project.architectName,
                    ),
                    buildColumnTitleValue(
                      title: "Architect Mobile Number",
                      value: widget.project.architectMobileNumber,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "File Number",
                      value: widget.project.fileNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LOCATION DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Project Location",
                      value: widget.project.projectLocation,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Google Location",
                      value: widget.project.googleLocation,
                      customValueWidget: GestureDetector(
                        onTap: () async {
                          final url = widget.project.googleLocation;

                          if (url.isNotEmpty) {
                            final Uri uri = Uri.parse(url);

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }
                        },
                        child: Text(
                          widget.project.googleLocation.isEmpty
                              ? "-"
                              : widget.project.googleLocation,
                          style: AppTextStyle.ts14M(
                            color: AppColor.primary,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColor.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Country",
                      value: widget.project.countryName,
                    ),
                    buildColumnTitleValue(
                      title: "State",
                      value: widget.project.stateName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "District",
                      value: widget.project.districtName,
                    ),
                    buildColumnTitleValue(
                      title: "City",
                      value: widget.project.cityName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Village",
                      value: widget.project.villageName,
                    ),
                    buildColumnTitleValue(
                      title: "PIN Code",
                      value: widget.project.zipCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT SCOPE
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Scheme & Scope Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Scope",
                      value: widget.project.projectScope,
                    ),
                    buildColumnTitleValue(
                      title: "Project Scheme",
                      value: widget.project.projectScheme,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Project Sub Scheme",
                      value: widget.project.projectSubScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT DOCUMENT
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Documentation", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Number",
                      value:
                          widget.project.reraNumber.isNotEmpty
                              ? widget.project.reraNumber
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "RERA Certificate Date",
                      value:
                          widget.project.reraCertificateDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraCertificateDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Completion Date",
                      value:
                          widget.project.reraComplitionDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraComplitionDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT FINANCIALS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Financials", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Estimate Cost",
                      value: widget.project.projectEstimateCost.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Ongoing Budget Cost",
                      value: widget.project.onGoingBudgetCost.toString(),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Area (Sq.ft)",
                      value: widget.project.projectAreaInSqft.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT TIMELINE
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Timeline", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Survey Date",
                      value:
                          widget.project.surveyDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.surveyDate!,
                              )
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Expected Start Date",
                      value:
                          widget.project.expectedStartDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.expectedStartDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Execution Start Date",
                      value:
                          widget.project.executionStartDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.executionStartDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // CONTACT INFORMATION
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Site Contact Name",
                      value:
                          widget.project.siteContactName.isNotEmpty
                              ? widget.project.siteContactName
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Site Contact Mobile Number",
                      value:
                          widget.project.siteContactMobileNumber.isNotEmpty
                              ? widget.project.siteContactMobileNumber
                              : "-",
                      customValueWidget: CustomClickToContactText(
                        value: widget.project.siteContactMobileNumber,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Status",
                      value: widget.project.projectStatus,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ACTION DETaILS
          actionCardWidget(
            createdBy: widget.project.createdBy,
            createdDate: widget.project.createdDate,
            modifiedBy: widget.project.modifiedBy,
            modifiedDate: widget.project.modifiedDate,
          ),
        ],
      ),
    );
  }

  // EMPLOYEE
  Widget _employeeSection() {
    return Column(
      children: [
        verticalSpacing(),
        BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text("Employee Details", style: AppTextStyle.ts16SB()),
                  Spacer(),
                  CustomButton(
                    text:
                        state.employeeByProject.isEmpty ? "Add" : "Add/Update",
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      _searchEmployeeC.clear();
                      await _showEmployeeSelectionBottomSheet(context);
                    },
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  ),
                ],
              ),
            );
          },
        ),
        verticalSpacing(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SearchWidget(
            hintText: "Search by Employee Name or Department",
            onSubmit: (value) async {
              await _projectMasterCubit.getProjectWithEmployee(
                context: context,
                projectId: widget.project.projectId,
                queryParams: {"FullName": value},
              );
              FocusScope.of(context).unfocus();
            },
            textController: _searchEmployeeC,
          ),
        ),
        verticalSpacing(),
        BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
          builder: (context, state) {
            if (state.isEmployeeLoading) {
              return Center(child: loader());
            }
            if (state.employeeByProject.isEmpty) {
              return Flexible(
                child: Center(
                  child: noDataWidget(message: "No Employee's Found"),
                ),
              );
            }

            final paginatedEmployees =
                _projectMasterCubit.getPaginatedEmployeeList();
            const int pageSize = 10;
            final int totalPages =
                (state.employeeByProject.length / pageSize).ceil();
            final bool hasMore = state.currentPageEmployee < totalPages;

            return Expanded(
              child: ListView.builder(
                controller: employeeScrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: paginatedEmployees.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == paginatedEmployees.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  var employee = paginatedEmployees[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                employee.fullName,
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showDeleteEmployeeDialog(context, employee);
                                FocusScope.of(context).unfocus();
                                _searchEmployeeC.clear();
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Employee Code",
                              value: employee.employeeCode,
                            ),
                            buildColumnTitleValue(
                              title: "Reporting Person",
                              value: employee.reportPersonName,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Designation",
                              value: employee.designation,
                            ),
                            buildColumnTitleValue(
                              title: "Department",
                              value: employee.department,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "E-mail ID",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  verticalSpacing(),
                                  CustomClickToContactText(
                                    value: employee.emailId,
                                    type: ContactType.email,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile Number",
                                    style: AppTextStyle.ts14M(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  verticalSpacing(),
                                  CustomClickToContactText(
                                    value: employee.personalMobileNumber,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Last Login",
                              value:
                                  employee.lastLogin != null
                                      ? formatDate(employee.lastLogin!)
                                      : "-",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // <---- SHOW EMPLOYEE SELECTION BOTTOM SHEET ---->
  Future<void> _showEmployeeSelectionBottomSheet(BuildContext context) async {
    final currentEmployees =
        _projectMasterCubit.state.employeeByProjectOriginal;
    final initialValue =
        currentEmployees
            .map(
              (employee) => {
                'zAttributesId': employee.employeeId,
                'DisplayName': employee.fullName,
              },
            )
            .toList();

    final selectedEmployees = await CustomMultipleSelectPopup.showBottomSheet(
      context: context,
      title: 'Select Employees',
      isMultiSelect: true,
      initialValue: initialValue,
      dataFetchCallBack: (int pageNumber, {String? value}) async {
        final employeeList = await _projectMasterCubit.getEmployeeMasterList(
          pageNumber: pageNumber,
          pageSize: 10,
          context: context,
          queryParams:
              value != null && value.isNotEmpty
                  ? {"EmployeeName": value, "IsCheckPermission": false}
                  : {"IsCheckPermission": false},
        );

        return {
          "itemList":
              employeeList
                  .map(
                    (employee) => {
                      "zAttributesId": employee.employeeId,
                      "DisplayName": employee.fullName,
                    },
                  )
                  .toList(),
          "totalNumberOfRecord":
              _projectMasterCubit.state.totalNumberOfRecordEmployeeMaster,
        };
      },
    );

    if (selectedEmployees != null) {
      if (selectedEmployees.isEmpty) {
        showErrorMessage(
          context,
          "Error",
          "At least one employee must be selected",
        );
        return;
      }

      final selectedEmployeeIds =
          selectedEmployees.map((e) => e['zAttributesId'] as int).toList();

      await _projectMasterCubit.addUpdateProjectWithEmployee(
        projectId: widget.project.projectId.toString(),
        uniqueKey: widget.project.uniquekey,
        selectedEmployeeIds: selectedEmployeeIds,
        context: context,
      );
    }
  }

  // <---- SHOW DELETE EMPLOYEE DIALOG ---->
  Future<void> _showDeleteEmployeeDialog(
    BuildContext context,
    UserModel employee,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a employee ?',
      'Deleting this employee will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final cubit = context.read<ProjectMasterCubit>();
      await cubit.deleteProjectWithEmployee(
        context: context,
        projectId: widget.project.projectId,
        uniquekey: widget.project.uniquekey,
        employeeId: employee.employeeId.toString(),
      );
    }
  }

  // COMPANY
  Widget _companySection() {
    return BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.companyByProject.isEmpty) {
          return Center(child: loader());
        }

        final paginatedCompanies =
            _projectMasterCubit.getPaginatedCompanyList();
        const int pageSize = 10;
        final int totalPages =
            (state.companyByProject.length / pageSize).ceil();
        final bool hasMore = state.currentPageCompany < totalPages;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text("Company Details", style: AppTextStyle.ts16SB()),
                  Spacer(),
                  CustomButton(
                    text: state.companyByProject.isEmpty ? "Add" : "Add/Update",
                    onPressed: () {
                      _showCompanySelectionBottomSheet(context);
                    },
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  ),
                ],
              ),
            ),
            state.companyByProject.isEmpty
                ? Expanded(child: Center(child: noDataWidget(message: "No Company's Found")))
                : Expanded(
                  child: ListView.builder(
                    controller: companyScrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: paginatedCompanies.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == paginatedCompanies.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      var company = paginatedCompanies[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(12),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    company.companyName,
                                    style: AppTextStyle.ts16SB(),
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Firms Type",
                                  value: company.firmsType,
                                ),
                                buildColumnTitleValue(
                                  title: "Contact Person",
                                  value: company.contactPerson,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Mobile Number",
                                  value: company.mobileNumber,
                                  customValueWidget: CustomClickToContactText(
                                    value: company.mobileNumber,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "E-mail Id",
                                  value: company.emailId,
                                  customValueWidget: CustomClickToContactText(
                                    value: company.emailId,
                                    type: ContactType.email,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "PAN Number",
                                  value: company.panNumber,
                                  customValueWidget:
                                      company.panNumber.isNotEmpty
                                          ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(child: Text(company.panNumber)),
                                              horizontalSpacing(),
                                              CustomIconButton(
                                                onPressed: () {
                                                  showFilePreviewDialog(
                                                    context,
                                                    company.panCardURL.split(
                                                      ",",
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 16,
                                                  color: AppColor.primary,
                                                ),
                                                backgroundColor:
                                                    AppColor.lightBlue,
                                              ),
                                            ],
                                          )
                                          : Text("-"),
                                ),
                                buildColumnTitleValue(
                                  title: "GST Number",
                                  value:
                                      company.gstNumber.isNotEmpty
                                          ? company.gstNumber
                                          : "-",
                                  customValueWidget:  company.gstNumber.isNotEmpty
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: Text(company.gstNumber)),
                                      horizontalSpacing(),
                                      CustomIconButton(
                                        onPressed: () {
                                          showFilePreviewDialog(
                                            context,
                                            company.gstCertificateURL.split(
                                              ",",
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye_outlined,
                                          size: 16,
                                          color: AppColor.primary,
                                        ),
                                        backgroundColor:
                                        AppColor.lightBlue,
                                      ),
                                    ],
                                  )
                                      : Text("-"),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "CIN Number",
                                  value: company.cinNumber,
                                  customValueWidget:  company.cinNumber.isNotEmpty
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: Text(company.cinNumber)),
                                      horizontalSpacing(),
                                      CustomIconButton(
                                        onPressed: () {
                                          showFilePreviewDialog(
                                            context,
                                            company.cinURL.split(
                                              ",",
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye_outlined,
                                          size: 16,
                                          color: AppColor.primary,
                                        ),
                                        backgroundColor:
                                        AppColor.lightBlue,
                                      ),
                                    ],
                                  )
                                      : Text("-"),
                                ),
                                buildColumnTitleValue(
                                  title: "TAN Number",
                                  value: company.tanNumber,
                                  customValueWidget:  company.tanNumber.isNotEmpty
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(child: Text(company.tanNumber)),
                                      horizontalSpacing(),
                                      CustomIconButton(
                                        onPressed: () {
                                          showFilePreviewDialog(
                                            context,
                                            company.tanURL.split(
                                              ",",
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye_outlined,
                                          size: 16,
                                          color: AppColor.primary,
                                        ),
                                        backgroundColor:
                                        AppColor.lightBlue,
                                      ),
                                    ],
                                  )
                                      : Text("-"),
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "City",
                                  value: company.cityName,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        );
      },
    );
  }

  //APPROVAL
  Widget _approvalSection() {
    return BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
      builder: (context, state) {
        final approvalList = state.moduleWorkflowApprovalList;

        if ((state.isLoading ?? true) && approvalList.isEmpty) {
          return Center(child: loader());
        }

        if (approvalList.isEmpty) {
          return Center(child: noDataWidget(message: "No Approval Data Found"));
        }

        // GROUP BY MODULE NAME
        final Map<String, List<ModulesWorkflowApprovalModel>> groupedData = {};
        for (var item in approvalList) {
          groupedData.putIfAbsent(item.moduleName, () => []).add(item);
        }

        final moduleNames = groupedData.keys.toList();

        // INITIALIZE TAB CONTROLLER
        if (_approvalTabController == null ||
            _approvalTabController!.length != moduleNames.length) {
          _approvalTabController = TabController(
            length: moduleNames.length,
            vsync: this,
          );
        }

        return Column(
          children: [
            //  TABS
            verticalSpacing(),
            ChipStyleTabBar(
              controller: _approvalTabController!,
              isSecondaryStyle: true,
              tabs: moduleNames.map((m) => m).toList(),
            ),
            verticalSpacing(),

            //  TAB VIEW
            Expanded(
              child: TabBarView(
                controller: _approvalTabController!,
                physics: NeverScrollableScrollPhysics(),
                children:
                    moduleNames.map((moduleName) {
                      final moduleList = groupedData[moduleName]!;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: moduleList.length,
                        itemBuilder: (context, index) {
                          final module = moduleList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        module.subSubModuleName,
                                        style: AppTextStyle.ts16SB(),
                                      ),
                                    ),
                                    CustomIconButton(
                                      onPressed: () {
                                        goRouter.pushNamed(
                                          AppRoutes.addEmployeeToModule,
                                          queryParameters: {
                                            "modulesWorkflowApprovalModel":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(module),
                                                  ),
                                                ),
                                            "projectId":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    widget.project.projectId
                                                        .toString(),
                                                  ),
                                                ),
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: AppColor.primary,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                verticalSpacing(),

                                //  EMPLOYEE DATA
                                module.employeeData.isEmpty
                                    ? Text(
                                      "No Employee Assigned",
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.grey,
                                      ),
                                    )
                                    : Column(
                                      children:
                                          module.employeeData.map<Widget>((
                                            employee,
                                          ) {
                                            return Container(
                                              padding: const EdgeInsets.all(10),
                                              margin: EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColor.white,
                                                border: Border.all(
                                                  color: AppColor.grey,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColor.black
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                spacing: 10,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              employee.fullName,
                                                              style:
                                                                  AppTextStyle.ts14M(),
                                                            ),
                                                            Text(
                                                              employee
                                                                  .designation,
                                                              style:
                                                                  AppTextStyle.ts12M(
                                                                    color:
                                                                        AppColor
                                                                            .grey,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      CustomIconButton.delete(
                                                        onPressed: () {
                                                          _showDeleteModulePermissionDialog(
                                                            context,
                                                            module,
                                                            employee.employeeId,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),

                                                  CustomClickToContactText(
                                                    value:
                                                        employee
                                                            .personalMobileNumber!,
                                                  ),
                                                  CustomClickToContactText(
                                                    value:
                                                        employee.emailId ?? "",
                                                    type: ContactType.email,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // BANK
  Widget _bankSection() {
    return BlocBuilder<ProjectMasterCubit, ProjectMasterState>(
      builder: (context, state) {
        final bankList = state.bankByProject;
        final currentPage = state.currentPageBank;

        if ((state.isLoading ?? true) && bankList.isEmpty) {
          return Center(child: loader());
        }
        if (bankList.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text("Bank Details", style: AppTextStyle.ts16SB()),
                    Spacer(),
                    CustomButton(
                      onPressed: () {
                        _navigateToAddBankDetails(context);
                      },
                      text: "Add",
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      backgroundColor: AppColor.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(child: noDataWidget(message: "No Banks Found")),
              ),
            ],
          );
        }

        final paginatedBanks = _projectMasterCubit.getPaginatedBankList();
        const int pageSize = 10;
        final int totalPages = (bankList.length / pageSize).ceil();
        final bool hasMore = currentPage < totalPages;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text("Update Bank Details", style: AppTextStyle.ts16SB()),
                  Spacer(),
                  CustomButton(
                    onPressed: () {
                      _navigateToAddBankDetails(context);
                    },
                    text: "Add",
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: AppColor.primary,
                    leading: Icon(Icons.add, color: AppColor.white, size: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: bankScrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: paginatedBanks.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == paginatedBanks.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  var bank = paginatedBanks[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(12),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                bank.bankName,
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              children: [
                                CustomIconButton.edit(
                                  onPressed: () {
                                    _navigateToEditBankDetails(context, bank);
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.delete(
                                  onPressed: () {
                                    _showDeleteBankDialog(context, bank);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Account Holder Name",
                              value: bank.beneficiaryAccountHolderName,
                            ),
                            buildColumnTitleValue(
                              title: "Account Number",
                              value: bank.accountNumber,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "IFSC Code",
                              value: bank.ifscCode,
                            ),
                            buildColumnTitleValue(
                              title: "Branch",
                              value: bank.branch,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Account Type",
                              value: bank.acType,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // <---- SHOW COMPANY SELECTION BOTTOM SHEET ---->
  Future<void> _showCompanySelectionBottomSheet(BuildContext context) async {
    final currentCompanies = _projectMasterCubit.state.companyByProject;
    final initialValue =
        currentCompanies
            .map(
              (company) => {
                'zAttributesId': company.companyId,
                'DisplayName': company.companyName,
              },
            )
            .toList();

    final selectedCompanies = await CustomMultipleSelectPopup.showBottomSheet(
      context: context,
      title: 'Select Companies',
      isMultiSelect: false,
      initialValue: initialValue,
      dataFetchCallBack: (int pageNumber, {String? value}) async {
        final companyList = await _projectMasterCubit.getCompanies(
          pageNumber: pageNumber,
          pageSize: 10,
          context: context,
          queryParams:
              value != null && value.isNotEmpty
                  ? {"CompanyName": value, "IsCheckPermission": "false"}
                  : {"IsCheckPermission": "false"},
        );

        return {
          "itemList":
              companyList
                  .map(
                    (company) => {
                      "zAttributesId": company.companyId,
                      "DisplayName": company.companyName,
                    },
                  )
                  .toList(),
          "totalNumberOfRecord":
              _projectMasterCubit.state.totalNumberOfRecordCompanyMaster,
        };
      },
    );

    if (selectedCompanies != null && selectedCompanies.isNotEmpty) {
      final selectedCompanyIds =
          selectedCompanies.map((e) => e['zAttributesId'] as int).toList();

      await _projectMasterCubit.addUpdateProjectWithCompany(
        projectId: widget.project.projectId.toString(),
        uniqueKey: widget.project.uniquekey,
        selectedCompanyIds: selectedCompanyIds,
        context: context,
        onSuccess: () {},
      );
    }
  }

  // <---- NAVIGATE TO ADD BANK DETAILS SCREEN ---->
  void _navigateToAddBankDetails(BuildContext context) {
    final projectJson = jsonEncode(widget.project.toJson());
    final encryptedProject = EncryptionManager.encryptData(projectJson);

    context.pushNamed(
      AppRoutes.addBankDetails,
      queryParameters: {'project': Uri.encodeComponent(encryptedProject)},
    );
  }

  // <---- NAVIGATE TO EDIT BANK DETAILS SCREEN ---->
  void _navigateToEditBankDetails(BuildContext context, BankDetailsModel bank) {
    final projectJson = jsonEncode(widget.project.toJson());
    final encryptedProject = EncryptionManager.encryptData(projectJson);

    final bankJson = jsonEncode(bank.toJson());
    final encryptedBank = EncryptionManager.encryptData(bankJson);

    context.pushNamed(
      AppRoutes.addBankDetails,
      queryParameters: {
        'project': Uri.encodeComponent(encryptedProject),
        'bank': Uri.encodeComponent(encryptedBank),
      },
    );
  }

  // <---- SHOW DELETE BANK DIALOG ---->
  Future<void> _showDeleteBankDialog(
    BuildContext context,
    BankDetailsModel bank,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a bank ?',
      'Deleting this bank will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final cubit = context.read<ProjectMasterCubit>();
      await cubit.deleteProjectWithBankDetails(
        context: context,
        projectWithBankDetailsId: bank.projectWithBankDetailsId,
        uniqueKey: bank.uniquekey,
        projectId: bank.projectId,
      );
    }
  }

  // <---- SHOW DELETE MODULE PERMISSION DIALOG ---->
  Future<void> _showDeleteModulePermissionDialog(
    BuildContext context,
    ModulesWorkflowApprovalModel module,
    int employeeId,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Module Permission ?',
      'Deleting this Module Permission will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _projectMasterCubit.deleteModulesWorkflowApproval(
        context: context,
        employeeId: employeeId,
        projectId: widget.project.projectId,
        modulesMasterId: module.modulesMasterId,
        subModulesMasterId: module.subModulesMasterId,
        subSubModulesMasterId: module.subSubModulesMasterId,
      );
    }
  }
}
