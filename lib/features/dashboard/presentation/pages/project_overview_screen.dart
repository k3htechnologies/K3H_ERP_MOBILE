import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectOverviewScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectOverviewScreen({super.key, required this.project});

  @override
  State<ProjectOverviewScreen> createState() => _ProjectOverviewScreenState();
}

class _ProjectOverviewScreenState extends State<ProjectOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CUBIT
  late DashboardCubit _dashboardCubit;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchEmployeeC;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = context.read<DashboardCubit>();
    _initializeTextEditingControllers();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _dashboardCubit.getProjectEmployeesList(context, widget.project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _searchEmployeeC = TextEditingController();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _dashboardCubit.onTabChanged(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.project.projectName,
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [Tab(text: 'Overview'), Tab(text: 'Employee')],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverView(), _buildEmployee()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD OVERVIEW
  Widget _buildOverView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // BASIC DETAILS
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Basic Project Details", style: AppTextStyle.ts16M()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Redevelopment",
                      value: widget.project.isRedevelopment ? "Yes" : "No",
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
                    buildColumnTitleValue(
                      title: "CTS Number",
                      value: widget.project.ctsNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LOCATION DETAILS
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location Details", style: AppTextStyle.ts16M()),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Project Location",
                      value: widget.project.projectLocation,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Google Location",
                      value: widget.project.googleLocation,
                      valueTextStyle: AppTextStyle.ts14M(
                        color: AppColor.primary,
                      ),
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
                Row(
                  spacing: 10,
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
                Row(
                  spacing: 10,
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
          // SCHEMA AND SCOPE DETAILS
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Scheme & Scope Details", style: AppTextStyle.ts16M()),
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
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Documentation", style: AppTextStyle.ts16M()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "RERA Number",
                      value: widget.project.reraNumber,
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
                Row(
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
          // PROJECT TIME LINE
          Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Timeline", style: AppTextStyle.ts16M()),
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
                Row(
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
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact Information", style: AppTextStyle.ts16M()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Site Contact Name",
                      value: widget.project.siteContactName,
                    ),
                    buildColumnTitleValue(
                      title: "Site Contact Mobile Number",
                      value: widget.project.siteContactMobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value: widget.project.siteContactMobileNumber,
                      ),
                    ),
                  ],
                ),
                Row(
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
        ],
      ),
    );
  }

  // BUILD OVERVIEW
  Widget _buildEmployee() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
      child: Column(
        children: [
          SearchWidget(
            onSubmit: (value) {
              _dashboardCubit.getProjectEmployeesList(context, widget.project.projectId, searchText: value);
            },
            textController: _searchEmployeeC,
            hintText: "Search by Employee Name",
          ),
          verticalSpacing(),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {

                if (state.isLoading == true) {
                  return loader();
                }

                if (state.employeeByProject == null || state.employeeByProject!.isEmpty) {
                  return noDataWidget(message: "No Employee Found");
                }

                return ListView.builder(
                  itemCount: state.employeeByProject!.length,
                  itemBuilder: (_, index) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColor.grey30),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Text(state.employeeByProject![index].fullName[0].toUpperCase()),
                          ),
                          horizontalSpacing(),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.employeeByProject![index].fullName,style: AppTextStyle.ts14M(),),
                                Text(state.employeeByProject![index].personalMobileNumber,style: AppTextStyle.ts12R(color: AppColor.grey)),
                                Text(state.employeeByProject![index].department,style: AppTextStyle.ts12R(color: AppColor.grey)),
                                Text(state.employeeByProject![index].designation,style: AppTextStyle.ts12R(color: AppColor.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          ),
        ],
      ),
    );
  }
  
}
