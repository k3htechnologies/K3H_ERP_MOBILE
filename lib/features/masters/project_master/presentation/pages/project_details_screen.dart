// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
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
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
  // AUTHORIZATION
  late AuthorizationModel _projectDetailsRouteAuthorizationModel,
      _employeeRouteAuthorizationModel,
      _bankDetailsRouteAuthorizationModel,
      _companyRouteAuthorizationModel,
      _approvalRouteAuthorizationModel;

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
  late final List<ProjectDetailsTab> _tabs;
  @override
  void initState() {
    super.initState();
    _initAuth();
    _projectMasterCubit = context.read<ProjectMasterCubit>();

    _tabs = [
      if (_projectDetailsRouteAuthorizationModel.isView)
        ProjectDetailsTab.overview,

      if (_employeeRouteAuthorizationModel.isView) ProjectDetailsTab.employee,

      if (_bankDetailsRouteAuthorizationModel.isView)
        ProjectDetailsTab.bankDetails,

      if (_companyRouteAuthorizationModel.isView) ProjectDetailsTab.company,

      if (_approvalRouteAuthorizationModel.isView) ProjectDetailsTab.approval,
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadInitialTabData();

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

  void _initAuth() {
    _projectDetailsRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectDetails] ??
        AuthorizationModel();

    _employeeRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .projectMasterAssignEmployee] ??
        AuthorizationModel();

    _bankDetailsRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .projectMasterBankDetails] ??
        AuthorizationModel();
    _companyRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .projectMasterSetCompany] ??
        AuthorizationModel();
    _approvalRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .projectMasterApprovalSetup] ??
        AuthorizationModel();
  }

  void _loadInitialTabData() {
    final initialTab = _tabs[_tabController.index];
    context.read<ProjectMasterCubit>().onTabChanged(
      context,
      initialTab,
      projectId: widget.project.projectId,
      employeeId: 0,
    );
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

  // TAB CHANGE
  void _handleTabChange() {
    final index = _tabController.index;
    final selectedTab = _tabs[index];
    context.read<ProjectMasterCubit>().onTabChanged(
      context,
      selectedTab,
      projectId: widget.project.projectId,
      employeeId: 0,
    );
    if (selectedTab != ProjectDetailsTab.approval) {
      if (_approvalTabController != null) {
        _approvalTabController!.index = 0;
      }
    }
  }

  // PAGINATION
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

  // COMPANY PAGINATION
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

  // BANK PAGINATION
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
              tabs: _tabs.map((e) => e.title).toList(),
              onTabChanged: (_) {
                _searchEmployeeC.clear();
              },
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  if (_projectDetailsRouteAuthorizationModel.isView)
                    _overviewSection(),
                  if (_employeeRouteAuthorizationModel.isView)
                    _employeeSection(),
                  if (_bankDetailsRouteAuthorizationModel.isView)
                    _bankSection(),
                  if (_companyRouteAuthorizationModel.isView) _companySection(),
                  if (_approvalRouteAuthorizationModel.isView)
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
    final isTender = widget.project.category.toLowerCase() == "tender";
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // PROJECT IMAGES
          Column(
            children: [
              Stack(
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
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                showFilePreviewDialog(context, [
                                  projectImages[index],
                                ]);
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
                                          AppColor.grey10.withValues(
                                            alpha: 0.2,
                                          ),
                                          AppColor.grey30.withValues(
                                            alpha: 0.4,
                                          ),
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: projectStatusWidget(widget.project.projectStatus),
                  ),
                ],
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
          SectionCard(
            title: "Basic Project Details",
            icon: LucideIcons.building,
            iconColor: AppColor.primary,
            children: [
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
                    title: "File Number",
                    value: widget.project.fileNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Federation",
                    value: widget.project.isFederation ? "Yes" : "No",
                  ),
                ],
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Federation Amount",
                  value: widget.project.federationAmount.toIndianCurrency(),
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
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
                                        context,
                                        widget
                                            .project
                                            .tenderAmountChequeNumberUrl
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
                    title: "Payoder Remark",
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

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ],
                ),
                buildRowWrapper(
                  child: buildColumnTitleValue(
                    title: "Payoder Remark",
                    value: widget.project.tenderAmountPayorderRemark,
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
                children: [
                  buildColumnTitleValue(
                    title: "Name",
                    value:
                        widget.project.liasoningArchitectName.isEmpty
                            ? "-"
                            : widget.project.liasoningArchitectName,
                  ),
                  horizontalSpacing(),
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
                children: [
                  buildColumnTitleValue(
                    title: "Name",
                    value:
                        widget.project.designingArchitectName.isEmpty
                            ? "-"
                            : widget.project.designingArchitectName,
                  ),
                  horizontalSpacing(),
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
                children: [
                  buildColumnTitleValue(
                    title: "Name",
                    value:
                        widget.project.rccConsultantName.isEmpty
                            ? "-"
                            : widget.project.rccConsultantName,
                  ),
                  horizontalSpacing(),
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
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Project Location",
                    value: widget.project.projectLocation,
                  ),
                ],
              ),

              Row(
                children: [
                  buildColumnTitleValue(
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
                ],
              ),

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
          ), // PROJECT SCOPE
          SectionCard(
            title: "Project Documentation",
            icon: LucideIcons.badgeCheck,
            iconColor: AppColor.purple700,
            iconContainerColor: AppColor.purple700.withValues(alpha: 0.1),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "RERA Number",
                      value:
                          widget.project.reraNumber.isNotEmpty
                              ? widget.project.reraNumber
                              : "-",
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "RERA Certificate Date",
                      value:
                          widget.project.reraCertificateDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraCertificateDate!,
                              )
                              : "-",
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "RERA Completion Date",
                      value:
                          widget.project.reraPossessionDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.project.reraPossessionDate!,
                              )
                              : "-",
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: buildColumnTitleValueNormal(
                      title: "APF Number",
                      value: widget.project.apfNumber.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: "Project Financials",
            icon: LucideIcons.indianRupee,
            iconColor: AppColor.primary,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Project Estimate Cost",
                    value: widget.project.projectEstimateCost.toString(),
                  ),
                  horizontalSpacing(),
                  buildColumnTitleValue(
                    title: "Ongoing Budget Cost",
                    value: widget.project.onGoingBudgetCost.toString(),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Project Area (Sq.ft)",
                    value: widget.project.projectAreaInSqft.toString(),
                  ),
                  horizontalSpacing(),
                  buildColumnTitleValue(
                    title: "Project Area (Sq.mt)",
                    value: widget.project.projectAreaInSqmt.toString(),
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
              if (widget.project.siteContactName.isNotEmpty ||
                  widget.project.siteContactDesignation.isNotEmpty ||
                  widget.project.siteContactMobileNumber.isNotEmpty)
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.siteContactName.isNotEmpty
                                ? widget.project.siteContactName
                                : "-",
                            style: AppTextStyle.ts14M(),
                          ),
                          Text(
                            widget.project.siteContactDesignation.isNotEmpty
                                ? widget.project.siteContactDesignation
                                : "-",
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ],
                      ),
                      Divider(height: 30, color: AppColor.grey2),
                      CustomClickToContactText(
                        countryCode: "+91",
                        value: widget.project.siteContactMobileNumber,
                      ),
                    ],
                  ),
                ),

              if (widget.project.siteContact2Name.isNotEmpty ||
                  widget.project.siteContact2Designation.isNotEmpty ||
                  widget.project.siteContact2MobileNumber.isNotEmpty)
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.siteContact2Name.isNotEmpty
                                ? widget.project.siteContact2Name
                                : "-",
                            style: AppTextStyle.ts14M(),
                          ),
                          Text(
                            widget.project.siteContact2Designation.isNotEmpty
                                ? widget.project.siteContact2Designation
                                : "-",
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ],
                      ),
                      Divider(height: 30, color: AppColor.grey2),
                      CustomClickToContactText(
                        countryCode: "+91",
                        value: widget.project.siteContact2MobileNumber,
                      ),
                    ],
                  ),
                ),
              if (widget.project.siteContact3Name.isNotEmpty ||
                  widget.project.siteContact3Designation.isNotEmpty ||
                  widget.project.siteContact3MobileNumber.isNotEmpty)
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.siteContact3Name.isNotEmpty
                                ? widget.project.siteContact3Name
                                : "-",
                            style: AppTextStyle.ts14M(),
                          ),
                          Text(
                            widget.project.siteContact3Designation.isNotEmpty
                                ? widget.project.siteContact3Designation
                                : "-",
                            style: AppTextStyle.ts12M(color: AppColor.grey),
                          ),
                        ],
                      ),
                      Divider(height: 30, color: AppColor.grey2),
                      CustomClickToContactText(
                        countryCode: "+91",
                        value: widget.project.siteContact3MobileNumber,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SectionCard(
            title: "Action Details",
            icon: LucideIcons.history,
            iconColor: AppColor.grey,
            iconContainerColor: AppColor.lightGrey.withValues(alpha: 0.5),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Created By",
                    value: widget.project.createdBy,
                  ),
                  horizontalSpacing(),
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(widget.project.createdDate),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Modified By",
                    value: widget.project.modifiedBy,
                  ),
                  horizontalSpacing(),
                  buildColumnTitleValue(
                    title: "Modified Date",
                    value: formatDate(widget.project.modifiedDate),
                  ),
                ],
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
                  if (_employeeRouteAuthorizationModel.isAction)
                    CustomButton(
                      text:
                          state.employeeByProject.isEmpty
                              ? "Add"
                              : "Add/Update",
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        _searchEmployeeC.clear();
                        await _showEmployeeSelectionBottomSheet(context);
                      },
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
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
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(color: AppColor.primary, width: 4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Expanded(
                              child: Text(
                                employee.fullName,
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            CustomIconButton.delete(
                              isDisabled:
                                  !_employeeRouteAuthorizationModel.isAction,
                              onPressed: () {
                                _showDeleteEmployeeDialog(context, employee);
                                FocusScope.of(context).unfocus();
                                _searchEmployeeC.clear();
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColor.lightGrey,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColor.grey2),
                          ),
                          child: Text(
                            employee.employeeCode,
                            style: AppTextStyle.ts12M(
                              color: AppColor.black10.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        verticalSpacing(height: 10),
                        RichText(
                          text: TextSpan(
                            text: employee.designation,
                            style: AppTextStyle.ts14M(),
                            children: [
                              TextSpan(
                                text: " • ${employee.department}",
                                style: AppTextStyle.ts14M(color: AppColor.grey),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 28, color: AppColor.grey2),
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Mobile Number",
                              value: employee.personalMobileNumber,
                              customValueWidget: CustomClickToContactText(
                                countryCode: "+91",
                                value: employee.personalMobileNumber,
                              ),
                            ),
                            buildColumnTitleValue(
                              title: "Email Id",
                              value: employee.emailId,
                              customValueWidget: CustomClickToContactText(
                                type: ContactType.email,
                                value: employee.emailId,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 28, color: AppColor.grey2),
                        buildRowTitleValue(
                          fixesWidth: 140.w,
                          title: "Reporting Person",
                          singleLine: false,
                          value: employee.reportPersonName,
                        ),
                        buildRowTitleValue(
                          title: "Last Login",
                          fixesWidth: 140.w,
                          singleLine: false,
                          value:
                              employee.lastLogin != null
                                  ? formatDate(employee.lastLogin!)
                                  : "-",
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

  // SHOW EMPLOYEE SELECTION BOTTOM SHEET
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

  // SHOW DELETE EMPLOYEE DIALOG
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
                  if (_companyRouteAuthorizationModel.isAction)
                    CustomButton(
                      text:
                          state.companyByProject.isEmpty ? "Add" : "Add/Update",
                      onPressed: () {
                        _showCompanySelectionBottomSheet(context);
                      },
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                    ),
                ],
              ),
            ),
            state.companyByProject.isEmpty
                ? Expanded(
                  child: Center(
                    child: noDataWidget(message: "No Company's Found"),
                  ),
                )
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
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(color: AppColor.primary, width: 4),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
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
                            Divider(height: 30, color: AppColor.grey2),
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
                                    countryCode: "+91",
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
                            Divider(height: 30, color: AppColor.grey2),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  company.panNumber,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 5),
                                              CustomIconButton(
                                                isDisable:
                                                    company.panCardURL.isEmpty,
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
                                                  color:
                                                      company.panCardURL.isEmpty
                                                          ? AppColor.grey2
                                                          : AppColor.primary,
                                                ),
                                                backgroundColor:
                                                    AppColor.lightBlue,
                                              ),
                                              horizontalSpacing(width: 5),
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
                                  customValueWidget:
                                      company.gstNumber.isNotEmpty
                                          ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  company.gstNumber,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 5),
                                              CustomIconButton(
                                                isDisable:
                                                    company
                                                        .gstCertificateURL
                                                        .isEmpty,
                                                onPressed: () {
                                                  showFilePreviewDialog(
                                                    context,
                                                    company.gstCertificateURL
                                                        .split(","),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 16,
                                                  color:
                                                      company
                                                              .gstCertificateURL
                                                              .isEmpty
                                                          ? AppColor.grey2
                                                          : AppColor.primary,
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
                                  customValueWidget:
                                      company.cinNumber.isNotEmpty
                                          ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  company.cinNumber,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 5),
                                              CustomIconButton(
                                                isDisable:
                                                    company.cinURL.isEmpty,
                                                onPressed: () {
                                                  showFilePreviewDialog(
                                                    context,
                                                    company.cinURL.split(","),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 16,
                                                  color:
                                                      company.cinURL.isEmpty
                                                          ? AppColor.grey2
                                                          : AppColor.primary,
                                                ),
                                                backgroundColor:
                                                    AppColor.lightBlue,
                                              ),
                                              horizontalSpacing(width: 5),
                                            ],
                                          )
                                          : Text("-"),
                                ),
                                buildColumnTitleValue(
                                  title: "TAN Number",
                                  value: company.tanNumber,
                                  customValueWidget:
                                      company.tanNumber.isNotEmpty
                                          ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  company.tanNumber,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(width: 5),
                                              CustomIconButton(
                                                isDisable:
                                                    company.tanURL.isEmpty,
                                                onPressed: () {
                                                  showFilePreviewDialog(
                                                    context,
                                                    company.tanURL.split(","),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 16,
                                                  color:
                                                      company.tanURL.isEmpty
                                                          ? AppColor.grey2
                                                          : AppColor.primary,
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
              style: ChipTabBarStyle.underline,
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
                                      child: Column(
                                        spacing: 2,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            module.subSubModuleName,
                                            style: AppTextStyle.ts16SB(),
                                          ),
                                          if (module.employeeData.length >
                                              0) ...[
                                            RichText(
                                              text: TextSpan(
                                                text: "Assigned Employee: ",
                                                style: AppTextStyle.ts14M(
                                                  color: AppColor.grey,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        module
                                                            .employeeData
                                                            .length
                                                            .toString(),
                                                    style: AppTextStyle.ts14M(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (_approvalRouteAuthorizationModel
                                        .isAction)
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
                                                bottom: 16,
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
                                                        isDisabled:
                                                            !_approvalRouteAuthorizationModel
                                                                .isAction,
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

                                                  Divider(
                                                    height: 30,
                                                    color: AppColor.grey2,
                                                  ),
                                                  CustomClickToContactText(
                                                    countryCode: "+91",
                                                    value:
                                                        employee
                                                            .personalMobileNumber!,
                                                  ),
                                                  verticalSpacing(height: 8),
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
                    if (_bankDetailsRouteAuthorizationModel.isAction)
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
                  if (_bankDetailsRouteAuthorizationModel.isAction)
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
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(color: AppColor.primary, width: 4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x11000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                bank.beneficiaryAccountHolderName,
                                style: AppTextStyle.ts16SB(),
                              ),
                            ),
                            horizontalSpacing(),
                            Row(
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      !_bankDetailsRouteAuthorizationModel
                                          .isAction,
                                  onPressed: () {
                                    _navigateToEditBankDetails(context, bank);
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.delete(
                                  isDisabled:
                                      !_bankDetailsRouteAuthorizationModel
                                          .isAction,
                                  onPressed: () {
                                    _showDeleteBankDialog(context, bank);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        activeInactiveStatusWidget(
                          "Active",
                          textStyle: AppTextStyle.ts12M(),
                        ),
                        Divider(height: 30, color: AppColor.grey2),
                        buildRowWrapper(
                          child: buildColumnTitleValue(
                            title: "Bank Name",
                            value: bank.bankName,
                          ),
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.w,
                          children: [
                            buildColumnTitleValue(
                              title: "Nature Of Account",
                              value: bank.natureOfAccount,
                              customValueWidget: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  bank.natureOfAccount,
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(height: 30, color: AppColor.grey2),

                        Row(
                          spacing: 10.w,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Account Type",
                              value: bank.acType,
                            ),
                            buildColumnTitleValue(
                              title: "Branch",
                              value: bank.branch,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          spacing: 10.w,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildColumnTitleValue(
                              title: "Account Number",
                              value: bank.accountNumber,
                            ),
                            buildColumnTitleValue(
                              title: "IFSC Code",
                              value: bank.ifscCode,
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

  // SHOW COMPANY SELECTION BOTTOM SHEET
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

  // NAVIGATE TO ADD BANK DETAILS SCREEN
  void _navigateToAddBankDetails(BuildContext context) {
    final projectJson = jsonEncode(widget.project.toJson());
    final encryptedProject = EncryptionManager.encryptData(projectJson);

    context.pushNamed(
      AppRoutes.addBankDetails,
      queryParameters: {'project': Uri.encodeComponent(encryptedProject)},
    );
  }

  // NAVIGATE TO EDIT BANK DETAILS SCREEN
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

  // SHOW DELETE BANK DIALOG
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

  // SHOW DELETE MODULE PERMISSION DIALOG
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
