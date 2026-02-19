import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TenantViewScreen extends StatefulWidget {
  final TenantModel tenant;

  const TenantViewScreen({super.key, required this.tenant});

  @override
  State<TenantViewScreen> createState() => _TenantViewScreenState();
}

class _TenantViewScreenState extends State<TenantViewScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TenantCubit _tenantCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TAB CONTROLLER
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _tenantCubit.onTabChanged(
        _tabController.index,
        context,
        widget.tenant.projectId,
        widget.tenant.buildingId,
        widget.tenant.tenantId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant",
        authorization: _routeAuthorizationModel,
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
                    tabs: const [Tab(text: 'Overview'), Tab(text: 'Document')],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverviewTab(), _buildDocumentTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 550,
            margin: EdgeInsets.only(bottom: 10),
            decoration: commonCardDecoration(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Applicant Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    shrinkWrap: true,
                    itemCount: widget.tenant.tenantApplicantData.length,
                    itemBuilder: (_, index) {
                      final applicant =
                      widget.tenant.tenantApplicantData[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primary,
                            width: .3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          spacing: 10,
                          children: [
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    applicant.applicantName,
                                    style: AppTextStyle.ts14M(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                horizontalSpacing(),
                                _buildApplicantTypeWidget(
                                  applicant.applicantType,
                                ),
                              ],
                            ),

                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Contact Number",
                                  value:
                                  applicant.applicantMobileNumber.isEmpty
                                      ? "-"
                                      : applicant.applicantMobileNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Email ID",
                                  value:
                                  applicant.applicantEmailId.isEmpty
                                      ? "-"
                                      : applicant.applicantEmailId,
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Aadhaar Card No.",
                                  value:
                                  applicant.aadharCardNumber.isEmpty
                                      ? "-"
                                      : applicant.aadharCardNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Aadhaar Card",
                                  value:
                                  applicant.aadharCardURL.isEmpty
                                      ? "-"
                                      : applicant.aadharCardURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .aadharCardURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.aadharCardURL.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                    applicant.aadharCardURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "PAN Card No.",
                                  value:
                                  applicant.panNumber.isEmpty
                                      ? "-"
                                      : applicant.panNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "PAN Card.",
                                  value:
                                  applicant.panCardURL.isEmpty
                                      ? "-"
                                      : applicant.panCardURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant.panCardURL.isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.panCardURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable: applicant.panCardURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Driving License",
                                  value:
                                  applicant.drivingLicenseNumber.isEmpty
                                      ? "-"
                                      : applicant.drivingLicenseNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Driving License",
                                  value:
                                  applicant.drivingLicenseURL.isEmpty
                                      ? "-"
                                      : applicant.drivingLicenseURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .drivingLicenseURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.drivingLicenseURL.split(
                                            ",",
                                          ),
                                        );
                                      }
                                    },
                                    isDisable:
                                    applicant.drivingLicenseURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Voting ID No.",
                                  value:
                                  applicant.votingIdNumber.isEmpty
                                      ? "-"
                                      : applicant.votingIdNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Voting ID",
                                  value:
                                  applicant.votingIdURL.isEmpty
                                      ? "-"
                                      : applicant.votingIdURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .votingIdURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.votingIdURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable:
                                    applicant.votingIdURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Passport No.",
                                  value:
                                  applicant.passportNumber.isEmpty
                                      ? "-"
                                      : applicant.passportNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "Passport",
                                  value:
                                  applicant.passportURL.isEmpty
                                      ? "-"
                                      : applicant.passportURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .passportURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.passportURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable:
                                    applicant.passportURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "GST No.",
                                  value:
                                  applicant.gstNumber.isEmpty
                                      ? "-"
                                      : applicant.gstNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "GST",
                                  value:
                                  applicant.gstNumberURL.isEmpty
                                      ? "-"
                                      : applicant.gstNumberURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant
                                          .gstNumberURL
                                          .isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.gstNumberURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable:
                                    applicant.gstNumberURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Cheque",
                                  value:
                                  applicant.chequeURL.isEmpty
                                      ? "-"
                                      : applicant.chequeURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant.chequeURL.isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.chequeURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable: applicant.chequeURL.isEmpty,
                                  ),
                                ),
                                buildColumnTitleValue(
                                  title: "Profile Photo",
                                  value:
                                  applicant.photoURL.isEmpty
                                      ? "-"
                                      : applicant.photoURL,
                                  customValueWidget:
                                  CustomButton.documentOutline(
                                    onPressed: () {
                                      if (applicant.photoURL.isNotEmpty) {
                                        showFilePreviewDialog(
                                          context,
                                          applicant.photoURL.split(","),
                                        );
                                      }
                                    },
                                    isDisable: applicant.photoURL.isEmpty,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Bank Name",
                                  value:
                                  applicant.bankName.isEmpty
                                      ? "-"
                                      : applicant.bankName,
                                ),
                                buildColumnTitleValue(
                                  title: "Account No.",
                                  value:
                                  applicant.accountNumber.isEmpty
                                      ? "-"
                                      : applicant.accountNumber,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "IFSC Code",
                                  value:
                                  applicant.ifscCode.isEmpty
                                      ? "-"
                                      : applicant.ifscCode,
                                ),
                                Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Offer", style: AppTextStyle.ts16SB()),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Free Area Offered(%)",
                      value: widget.tenant.freeAreaOfferedPercentage.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Free Area Offered(Sq.ft)",
                      value:
                      widget.tenant.freeAreaOfferedPercentage == 0
                          ? "0"
                          : (widget.tenant.flatCarpetAreaSqFt /
                          widget.tenant.freeAreaOfferedPercentage)
                          .toString(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Total Area(Sq.ft)",
                      value: widget.tenant.totalAreaSqFt.toString(),
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Existing Unit Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit Number",
                      value:
                      widget.tenant.flatNumber.isEmpty
                          ? "-"
                          : widget.tenant.flatNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Carpet Area (Sq ft)",
                      value: widget.tenant.flatCarpetAreaSqFt.toString(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit Facing",
                      value:
                      widget.tenant.facing.isEmpty
                          ? "-"
                          : widget.tenant.facing,
                    ),
                    buildColumnTitleValue(
                      title: "Unit Type",
                      value:
                      widget.tenant.flatType.isEmpty
                          ? "-"
                          : widget.tenant.flatType,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit Configuration",
                      value:
                      widget.tenant.flatConfiguration.isEmpty
                          ? "-"
                          : widget.tenant.flatConfiguration,
                    ),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Unit Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Building Number", value: "-"),
                    buildColumnTitleValue(title: "Floor", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Unit Number", value: "-"),
                    buildColumnTitleValue(title: "Unit Type", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Unit Configuration",
                      value: "-",
                    ),
                    buildColumnTitleValue(title: "Unit Facing", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Extra Area Purchased(Sq.ft)",
                      value: "-",
                    ),
                    buildColumnTitleValue(
                      title: "RERA Carpet Area(Sq.ft)",
                      value: "-",
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Parking Number", value: "-"),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DOCUMENT
  Widget _buildDocumentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        verticalSpacing(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 160,
            child: CustomButton(
              text: "Add/Update",
              onPressed: () async {
                await goRouter.pushNamed(
                  AppRoutes.addUpdateTenantDoc,
                  queryParameters: {
                    "tenant": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        jsonEncode(widget.tenant.toJson()),
                      ),
                    ),
                  },
                );
                if (mounted) {
                  _tenantCubit.getTenantDocumentList(
                  context: context,
                  projectId: widget.tenant.projectId,
                  buildingId: widget.tenant.buildingId,
                  tenantId: widget.tenant.tenantId,
                );
                }
              },
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<TenantCubit, TenantState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) && state.tenantDocumentList.isEmpty) {
                return Center(child: loader());
              }
              if (state.tenantDocumentList.isEmpty) {
                return Center(child: noDataWidget());
              }

              final filteredDocuments = state.tenantDocumentList
                  .where((e) => e.documentUrl.trim().isNotEmpty)
                  .toList();

              if (filteredDocuments.isEmpty) {
                return Center(child: noDataWidget());
              }

              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];
                  final urls = doc.documentUrl.isEmpty
                      ? <String>[]
                      : doc.documentUrl.split(',');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            doc.documentName,
                            style: AppTextStyle.ts14SB(),
                          ),
                        ),
                        CustomIconButton(
                          onPressed: () {
                            showFilePreviewDialog(
                              context,
                              urls,
                            );
                          },
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: AppColor.primary,
                            size: 16,
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
    );
  }

  // BUILD APPLICANT TYPE WIDGET
  Widget _buildApplicantTypeWidget(String type) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
        type.toLowerCase() == "applicant"
            ? AppColor.lightBlue
            : AppColor.purple.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: AppTextStyle.ts12M(
          color:
          type.toLowerCase() == "applicant"
              ? AppColor.primary
              : AppColor.purple,
        ),
      ),
    );
  }
}
