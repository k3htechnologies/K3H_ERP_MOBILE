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
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
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
    final isTender = widget.project.category.toLowerCase() == "tender";

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // BASIC DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Basic Project Details", style: AppTextStyle.ts16SB()),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Business Category",
                      value: widget.project.bussinessCategory,
                    ),
                    buildColumnTitleValue(
                      title: "File Number",
                      value: widget.project.fileNumber,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "CTS Number",
                      value: widget.project.ctsNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROJECT DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Project Category", style: AppTextStyle.ts16SB()),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Category",
                      value: widget.project.category,
                    ),

                    if (isTender) ...[
                      horizontalSpacing(),
                      buildColumnTitleValue(
                        title: "Amount",
                        value: widget.project.tenderAmount.toIndianCurrency(),
                      ),
                    ],
                  ],
                ),

                if (isTender) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "EMD Amount",
                        value:
                            widget.project.tenderEmdAmount.toIndianCurrency(),
                      ),
                      buildColumnTitleValue(
                        title: "Purchase Start Date",
                        value:
                            widget.project.tenderPurchaseStartDate != null
                                ? formatDateTimeAsDDMMMYYYY(
                                  widget.project.tenderPurchaseStartDate!,
                                )
                                : "-",
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Purchase End Date",
                        value:
                            widget.project.tenderPurchaseEndDate != null
                                ? formatDateTimeAsDDMMMYYYY(
                                  widget.project.tenderPurchaseEndDate!,
                                )
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Cheque Number",
                        value: widget.project.tenderChequeNumber ?? "-",
                        customValueWidget:
                            (widget.project.tenderChequeNumber == null ||
                                    widget.project.tenderChequeNumber!.isEmpty)
                                ? null
                                : Row(
                                  children: [
                                    Text(
                                      widget.project.tenderChequeNumber ?? "-",
                                      style: AppTextStyle.ts14M(),
                                    ),

                                    CustomIconButton(
                                      onPressed: () {
                                        showFilePreviewDialog(
                                          context,
                                          widget.project.tenderChequeNumberUrl!
                                              .split(","),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                      backgroundColor: AppColor.white,
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Submission Date",
                        value:
                            widget.project.tenderSubmissionDate != null
                                ? formatDateTimeAsDDMMMYYYY(
                                  widget.project.tenderSubmissionDate!,
                                )
                                : "-",
                      ),
                      buildColumnTitleValue(
                        title: "Issue Date",
                        value:
                            widget.project.tenderIssueDate != null
                                ? formatDateTimeAsDDMMMYYYY(
                                  widget.project.tenderIssueDate!,
                                )
                                : "-",
                      ),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Payorder Remark",
                        value: widget.project.tenderPayorderRemark ?? "-",
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // LIOSONING ARCHITECT DETAILS
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Liasoning Architect", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Name",
                      value:
                          widget.project.liasoningArchitectName.isEmpty
                              ? "-"
                              : widget.project.liasoningArchitectName,
                    ),
                    buildColumnTitleValue(
                      title: "Mobile Number",
                      value:
                          widget.project.liasoningArchitectMobileNumber.isEmpty
                              ? "-"
                              : widget.project.liasoningArchitectMobileNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Designing Architect", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Name",
                      value:
                          widget.project.designingArchitectName.isEmpty
                              ? "-"
                              : widget.project.designingArchitectName,
                    ),
                    buildColumnTitleValue(
                      title: "Mobile Number",
                      value:
                          widget.project.designingArchitectMobileNumber.isEmpty
                              ? "-"
                              : widget.project.designingArchitectMobileNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("RCC Consultant", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Name",
                      value:
                          widget.project.rccConsultantName.isEmpty
                              ? "-"
                              : widget.project.rccConsultantName,
                    ),
                    buildColumnTitleValue(
                      title: "Mobile Number",
                      value:
                          widget.project.rccConsultantMobileNumber.isEmpty
                              ? "-"
                              : widget.project.rccConsultantMobileNumber,
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
                    buildColumnTitleValue(
                      title: "APF Number",
                      value: widget.project.apfNumber.toString(),
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
                    buildColumnTitleValue(
                      title: "Project Area (Sq.mt)",
                      value: widget.project.projectAreaInSqmt.toString(),
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
              _dashboardCubit.getProjectEmployeesList(
                context,
                widget.project.projectId,
                searchText: value,
              );
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

                if (state.employeeByProject == null ||
                    state.employeeByProject!.isEmpty) {
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
                            backgroundColor: AppColor.primary,
                            child:
                                state
                                        .employeeByProject![index]
                                        .profilePhotoURL
                                        .isNotEmpty
                                    ? ClipOval(
                                      child: NetworkImageWidget(
                                        key: ValueKey(
                                          state
                                              .employeeByProject![index]
                                              .profilePhotoURL,
                                        ),
                                        imageUrl:
                                            state
                                                .employeeByProject![index]
                                                .profilePhotoURL,
                                        fit: BoxFit.fill,
                                        width: 70,
                                        height: 70,
                                      ),
                                    )
                                    : Text(
                                      state
                                              .employeeByProject![index]
                                              .fullName
                                              .isNotEmpty
                                          ? state
                                              .employeeByProject![index]
                                              .fullName[0]
                                              .toUpperCase()
                                          : 'U',
                                      style: AppTextStyle.ts16B(
                                        color: AppColor.white,
                                      ),
                                    ),
                          ),
                          horizontalSpacing(),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.employeeByProject![index].fullName,
                                  style: AppTextStyle.ts14M(),
                                ),
                                Text(
                                  state
                                      .employeeByProject![index]
                                      .personalMobileNumber,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  state.employeeByProject![index].department,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                Text(
                                  state.employeeByProject![index].designation,
                                  style: AppTextStyle.ts12R(
                                    color: AppColor.grey,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
