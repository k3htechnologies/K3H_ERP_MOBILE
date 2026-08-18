import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
          SectionCard(
            title: "Basic Project Details",
            icon: LucideIcons.building,
            iconColor: AppColor.primary,
            children: [
              Row(
                spacing: 10,
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
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "CTS Number",
                    value: widget.project.ctsNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Category",
                    value: widget.project.category,
                  ),
                ],
              ),

              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "File Number",
                    value: widget.project.fileNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Business Category",
                    value: widget.project.bussinessCategory,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Federation",
                    value: widget.project.isFederation ? "Yes" : "No",
                  ),
                  buildColumnTitleValue(
                    title: "Federation Amount",
                    value: widget.project.federationAmount.toIndianCurrency(),
                  ),
                ],
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Project Status",
                  value: widget.project.projectStatus,
                ),
              ),
            ],
          ), // PROJECT DETAILS
          SectionCard(
            title: "Scheme & Scope Details",
            icon: LucideIcons.clipboardList,
            iconColor: AppColor.primary,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Project Scope",
                    value: widget.project.projectScope,
                  ),
                  horizontalSpacing(),
                  buildColumnTitleValue(
                    title: "Project Scheme",
                    value: widget.project.projectScheme,
                  ),
                ],
              ),

              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Project Sub Scheme",
                    value: widget.project.projectSubScheme
                        .split(',')
                        .join(' + '),
                  ),
                ],
              ),
            ],
          ), // PROJECT DOCUMENT
          if (isTender) ...[
            SectionCard(
              title: "Tender Amount Details",
              icon: LucideIcons.badgeDollarSign,
              iconColor: AppColor.darkGreen10,
              iconContainerColor: AppColor.darkGreen10.withValues(alpha: 0.1),
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Amount",
                      value: widget.project.tenderAmount.toIndianCurrency(),
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
                  spacing: 10,
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
                      title: "Payment Mode",
                      value: widget.project.tenderAmountPaymentMode,
                    ),
                  ],
                ),
                buildRowWrapper(
                  child: buildColumnTitleValue(
                    title: "Transaction / Cheque / DD No",
                    value: widget.project.tenderAmountChequeNumber,
                    customValueWidget:
                        (widget.project.tenderAmountChequeNumber.isEmpty)
                            ? null
                            : Row(
                              children: [
                                Text(
                                  widget.project.tenderAmountChequeNumber,
                                  style: AppTextStyle.ts14M(),
                                ),
                                CustomIconButton(
                                  onPressed: () {
                                    showFilePreviewDialog(
                                      title: "Transaction / Cheque / DD",
                                      context,
                                      widget.project.tenderAmountChequeNumberUrl
                                          .split(","),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                    color: AppColor.primary,
                                  ),
                                  backgroundColor: AppColor.white,
                                ),
                              ],
                            ),
                  ),
                ),
                buildRowWrapper(
                  child: buildColumnTitleValue(
                    title: "Payorder Remark",
                    value: widget.project.tenderAmountPayorderRemark,
                  ),
                ),
              ],
            ),
            SectionCard(
              title: "Tender EMD Details",
              icon: LucideIcons.wallet,
              iconColor: AppColor.primary,
              children: [
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "EMD Amount",
                      value: widget.project.tenderEmdAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Submission Date",
                      value:
                          widget.project.tenderSubmissionDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.tenderSubmissionDate!,
                              )
                              : "-",
                    ),
                  ],
                ),

                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Payment Mode",
                      value: widget.project.tenderEmdPaymentMode,
                    ),
                    buildColumnTitleValue(
                      title: "Transaction / Cheque / DD No",
                      value: widget.project.tenderEmdChequeNumber,
                      customValueWidget:
                          (widget.project.tenderEmdChequeNumber.isEmpty)
                              ? null
                              : Row(
                                children: [
                                  Text(
                                    widget.project.tenderEmdChequeNumber,
                                    style: AppTextStyle.ts14M(),
                                  ),
                                  CustomIconButton(
                                    onPressed: () {
                                      showFilePreviewDialog(
                                        title: "Transaction / Cheque / DD No",
                                        context,
                                        widget.project.tenderEmdChequeNumberUrl
                                            .split(","),
                                      );
                                    },
                                    icon: const Icon(
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

                buildRowWrapper(
                  child: buildColumnTitleValue(
                    title: "Payorder Remark",
                    value: widget.project.tenderEmdPayorderRemark,
                  ),
                ),
              ],
            ), // LIOSONING ARCHITECT DETAILS
          ],
          SectionCard(
            title: "Liasoning Architect",
            icon: LucideIcons.draftingCompass,
            iconColor: AppColor.primary,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    customValueWidget: CustomClickToContactText(
                      countryCode: "+91",
                      value: widget.project.liasoningArchitectMobileNumber,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SectionCard(
            title: "Designing Architect",
            icon: LucideIcons.swords,
            iconColor: AppColor.purple700,
            iconContainerColor: AppColor.purple700.withValues(alpha: 0.1),
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    customValueWidget: CustomClickToContactText(
                      countryCode: "+91",
                      value: widget.project.designingArchitectMobileNumber,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SectionCard(
            title: "RCC Consultant",
            icon: LucideIcons.landmark,
            iconColor: AppColor.primary,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    customValueWidget: CustomClickToContactText(
                      countryCode: "+91",
                      value: widget.project.rccConsultantMobileNumber,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: "Location Details",
            icon: LucideIcons.mapPin,
            iconColor: AppColor.primary,
            children: [
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Project Location",
                  value: widget.project.projectLocation,
                ),
              ),

              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Google Location",
                  value: widget.project.googleLocation,
                  customValueWidget: GestureDetector(
                    onTap: () async {
                      final url = widget.project.googleLocation;

                      if (url.isNotEmpty) {
                        final uri = Uri.parse(url);

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
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
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
          ), // PROJECT SCOPE
          SectionCard(
            title: "Project Documentation",
            icon: LucideIcons.badgeCheck,
            iconColor: AppColor.purple700,
            iconContainerColor: AppColor.purple700.withValues(alpha: 0.1),
            children: [
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

              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "RERA Completion Date",
                    value:
                        widget.project.reraPossessionDate != null
                            ? formatDateTimeAsDDMMMYYYY(
                              widget.project.reraPossessionDate!,
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
          SectionCard(
            title: "Project Timeline",
            icon: LucideIcons.calendarRange,
            iconColor: AppColor.primary,
            childSpacing: 0,
            children: [
              _buildTimeline([
                {
                  "title": "Survey Date",
                  "value": formatDateTimeAsDDMMMYYYY(widget.project.surveyDate),
                },
                {
                  "title": "Expected Start Date",
                  "value": formatDateTimeAsDDMMMYYYY(
                    widget.project.expectedStartDate,
                  ),
                },
                {
                  "title": "Execution Start Date",
                  "value": formatDateTimeAsDDMMMYYYY(
                    widget.project.executionStartDate,
                  ),
                },
              ]),
            ],
          ),
          SectionCard(
            title: "Site Contact Information",
            icon: LucideIcons.contactRound,
            iconColor: AppColor.darkGreen10,
            iconContainerColor: AppColor.darkGreen10.withValues(alpha: 0.1),
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColor.grey2.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRowTitleValue(
                      title: "Name",
                      value: widget.project.siteContactName,
                      singleLine: false,
                      fixesWidth: 90.w,
                    ),
                    buildRowTitleValue(
                      title: "Designation",
                      value: widget.project.siteContactDesignation,
                      fixesWidth: 90.w,
                      singleLine: false,
                    ),
                    Divider(height: 30, color: AppColor.grey2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        if (widget.project.siteContactMobileNumber.isEmpty)
                          SvgPicture.asset(
                            AppAssets.phoneIcon,
                            height: 16.h,
                            width: 16.w,
                          ),
                        Expanded(
                          child: CustomClickToContactText(
                            countryCode: "+91",
                            value: widget.project.siteContactMobileNumber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColor.grey2.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRowTitleValue(
                      title: "Name",
                      value: widget.project.siteContact2Name,
                      singleLine: false,
                      fixesWidth: 90.w,
                    ),
                    buildRowTitleValue(
                      title: "Designation",
                      value: widget.project.siteContact2Designation,
                      singleLine: false,
                      fixesWidth: 90.w,
                    ),
                    Divider(height: 30, color: AppColor.grey2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        if (widget.project.siteContact2MobileNumber.isEmpty)
                          SvgPicture.asset(
                            AppAssets.phoneIcon,
                            height: 16.h,
                            width: 16.w,
                          ),
                        Expanded(
                          child: CustomClickToContactText(
                            countryCode: "+91",
                            value: widget.project.siteContact2MobileNumber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColor.grey2.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRowTitleValue(
                      title: "Name",
                      value: widget.project.siteContact3Name,
                      singleLine: false,
                      fixesWidth: 90.w,
                    ),
                    buildRowTitleValue(
                      title: "Designation",
                      value: widget.project.siteContact3Designation,
                      singleLine: false,
                      fixesWidth: 90.w,
                    ),
                    Divider(height: 30, color: AppColor.grey2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        if (widget.project.siteContact3MobileNumber.isEmpty)
                          SvgPicture.asset(
                            AppAssets.phoneIcon,
                            height: 16.h,
                            width: 16.w,
                          ),
                        Expanded(
                          child: CustomClickToContactText(
                            countryCode: "+91",
                            value: widget.project.siteContact3MobileNumber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<Map<String, String>> items) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];

        return SizedBox(
          height: 60.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColor.darkGreen10,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.lightGrey, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grey.withValues(alpha: 0.5),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    if (index != items.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xffD9DEE5),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"] ?? "",
                      style: AppTextStyle.ts14R(color: AppColor.grey),
                    ),
                    verticalSpacing(height: 4),
                    Text(
                      (item["value"]?.isNotEmpty ?? false)
                          ? item["value"]!
                          : "-",
                      style: AppTextStyle.ts14M(color: AppColor.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
