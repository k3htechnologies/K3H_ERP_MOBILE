import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/widgets/employee_document_dialog.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
        widget.tenant.tenantId
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColumnTitleValue(
                                  title: "Contact Number",
                                  value:
                                      applicant.applicantMobileNumber.isEmpty
                                          ? "-"
                                          : applicant.applicantMobileNumber,
                                ),
                                _buildColumnTitleValue(
                                  title: "Email ID",
                                  value:
                                      applicant.applicantEmailId.isEmpty
                                          ? "-"
                                          : applicant.applicantEmailId,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColumnTitleValue(
                                  title: "Aadhaar Card No.",
                                  value:
                                      applicant.aadharCardNumber.isEmpty
                                          ? "-"
                                          : applicant.aadharCardNumber,
                                ),
                                _buildColumnTitleValue(
                                  title: "PANCard No.",
                                  value:
                                      applicant.panNumber.isEmpty
                                          ? "-"
                                          : applicant.panNumber,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColumnTitleValue(
                                  title: "Driving License",
                                  value:
                                      applicant.drivingLicenseNumber.isEmpty
                                          ? "-"
                                          : applicant.drivingLicenseNumber,
                                ),
                                _buildColumnTitleValue(
                                  title: "Voting ID No.",
                                  value:
                                      applicant.votingIdNumber.isEmpty
                                          ? "-"
                                          : applicant.votingIdNumber,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColumnTitleValue(
                                  title: "Passport No.",
                                  value:
                                      applicant.passportNumber.isEmpty
                                          ? "-"
                                          : applicant.passportNumber,
                                ),
                                _buildColumnTitleValue(
                                  title: "GST No.",
                                  value:
                                      applicant.gstNumber.isEmpty
                                          ? "-"
                                          : applicant.gstNumber,
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColumnTitleValue(
                                  title: "Bank Name",
                                  value:
                                      applicant.bankName.isEmpty
                                          ? "-"
                                          : applicant.bankName,
                                ),
                                _buildColumnTitleValue(
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
                                _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Free Area Offered(%)",
                      value: widget.tenant.freeAreaOfferedPercentage.toString(),
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Unit Number",
                      value:
                          widget.tenant.flatNumber.isEmpty
                              ? "-"
                              : widget.tenant.flatNumber,
                    ),
                    _buildColumnTitleValue(
                      title: "Carpet Area (Sq ft)",
                      value: widget.tenant.flatCarpetAreaSqFt.toString(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "Unit Facing",
                      value:
                          widget.tenant.facing.isEmpty
                              ? "-"
                              : widget.tenant.facing,
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Building Number",
                      value: "-",
                    ),
                    _buildColumnTitleValue(title: "Floor", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(title: "Unit Number", value: "-"),
                    _buildColumnTitleValue(title: "Unit Type", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "Unit Configuration",
                      value: "-",
                    ),
                    _buildColumnTitleValue(title: "Unit Facing", value: "-"),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "Extra Area Purchased(Sq.ft)",
                      value: "-",
                    ),
                    _buildColumnTitleValue(
                      title: "RERA Carpet Area(Sq.ft)",
                      value: "-",
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(title: "Parking Number", value: "-"),
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
    return SingleChildScrollView(
      child: BlocBuilder<TenantCubit, TenantState>(
        builder: (context, state) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: state.tenantDocumentList.length,
            itemBuilder: (context, index) {
              final doc = state.tenantDocumentList[index];

              final urls =
                  doc.documentUrl.isEmpty
                      ? <String>[]
                      : doc.documentUrl.split(',');

              final isFresh = urls.isEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Row(
                  children: [
                    Expanded(child: Text(doc.documentName, style: AppTextStyle.ts14SB())),
                    horizontalSpacing(),

                    CustomIconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (_) => EmployeeDocumentDialog(
                                title: doc.documentName,
                                urls: urls,
                                isFreshAdd: isFresh,

                                // ➕ ADD / UPLOAD
                                addDocument: (pickedFiles) async {
                                  final files = MultiFilePickerModel(
                                    fileNameList:
                                        pickedFiles.map((e) => e.name).toList(),
                                    fileBytesList:
                                        pickedFiles
                                            .where((e) => e.bytes != null)
                                            .map((e) => e.bytes!)
                                            .toList(),
                                    deletedFileList: "",
                                  );

                                  await _tenantCubit.updateBuildingDocument(
                                    context: context,
                                    tenantDocumentId: doc.tenantDocumentId,
                                    uniqueKey: doc.uniquekey,
                                    projectId: doc.projectId,
                                    buildingId: doc.buildingId,
                                    documentName: doc.documentName,
                                    tenantId: doc.tenantId,
                                    files: files,
                                  );
                                },

                                // 🗑 DELETE
                                deleteDocument: (removeUrl) async {
                                  final files = MultiFilePickerModel(
                                    fileNameList: [],
                                    fileBytesList: [],
                                    deletedFileList: removeUrl,
                                  );

                                  await _tenantCubit.updateBuildingDocument(
                                    context: context,
                                    tenantDocumentId: doc.tenantDocumentId,
                                    uniqueKey: doc.uniquekey,
                                    projectId: doc.projectId,
                                    buildingId: doc.buildingId,
                                    documentName: doc.documentName,
                                    tenantId: doc.tenantId,
                                    files: files,
                                  );
                                },
                              ),
                        );
                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: isFresh ? AppColor.grey : AppColor.primary,
                      ),
                      backgroundColor:
                          isFresh ? AppColor.lightGrey : AppColor.lightBlue,
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

  // BUILD COLUMN TITLE VALUE
  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14R()),
        ],
      ),
    );
  }
}
