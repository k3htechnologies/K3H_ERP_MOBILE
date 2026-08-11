import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TenantViewScreen extends StatefulWidget {
  final TenantModel tenant;
  const TenantViewScreen({super.key, required this.tenant});
  @override
  State<TenantViewScreen> createState() => _TenantViewScreenState();
}

class _TenantViewScreenState extends State<TenantViewScreen>
    with SingleTickerProviderStateMixin {
  late TenantCubit _tenantCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TabController _tabController;
  late TextEditingController _searchDocumentNameC;
  MultiFilePickerModel _documentFiles = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<Map<String, dynamic>?> _selectedDocumentName =
      ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.tenant] ??
        AuthorizationModel();
    _tabController = TabController(length: 2, vsync: this);
    _searchDocumentNameC = TextEditingController();
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedDocumentName.dispose();
    super.dispose();
  }

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

  Future<void> _showPopupToDeleteTenantDocument({
    required BuildContext context,
    required TenantDocumentModel tenantModel,
    required int index,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a tenant document ?',
      'Deleting this tenant document will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _tenantCubit.deleteTenantDocument(
        context: context,
        buildingId: tenantModel.buildingId,
        projectId: tenantModel.projectId,
        uniqueKey: tenantModel.uniquekey,
        index: index,
        tenantDocumentId: tenantModel.tenantDocumentId,
        tenantId: tenantModel.tenantId,
      );
    }
  }

  Future<void> _showAddDocumentBottomSheet({
    TenantDocumentModel? doc,
    int? index,
  }) async {
    _documentFiles = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList:
          ((doc != null && doc.documentUrl.isNotEmpty)
              ? doc.documentUrl.split(',').toList()
              : []),
      deletedFileList: "",
    );
    _selectedDocumentName.value = tenantDocumentTypesList.firstWhereOrNull(
      (item) => item["DisplayName"] == doc?.documentName,
    );
    await DialogHelper.showCustomBottomSheet(
      context,
      "${doc != null ? 'Update' : 'Add'} Document",
      contentWidget: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder(
              valueListenable: _selectedDocumentName,
              builder: (context, documentName, child) {
                return CustomDropDownWidget(
                  title: 'Document Name',
                  hintText: 'Select Document Name',
                  initialValue: documentName,
                  isRequired: true,
                  dataList: tenantDocumentTypesList,
                  onSelected: (v) {
                    _selectedDocumentName.value = v;
                  },
                  onValueClear: () {
                    _selectedDocumentName.value = null;
                  },
                  validator: (v) {
                    if (v == null) {
                      return "Document Name is required.";
                    }
                    return null;
                  },
                );
              },
            ),
            CustomMultiFilePicker(
              title: "Files",
              isRequired: true,
              initialFileList: _documentFiles.fileNameList,
              onFilePickedCallback: (bytesList, fileNameList) {
                _documentFiles.fileBytesList = bytesList;
                _documentFiles.fileNameList = fileNameList;
              },
              onFileDeleteCallback: (fileBytesList, fileNameList, deleted) {
                _documentFiles.fileBytesList = fileBytesList;
                _documentFiles.fileNameList = fileNameList;
                _documentFiles.deletedFileList = deleted;
              },
              validator: (fileList) {
                if (fileList == null || fileList.isEmpty) {
                  return "Files is required.";
                }
                return null;
              },
            ),
            verticalSpacing(height: 16),
          ],
        ),
      ),
      bottomActions: CustomButton(
        text: "${doc == null ? 'Add' : 'Update'} Document",
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          if (doc == null) {
            await _tenantCubit.addTenantDocument(
              context: context,
              tenantId: widget.tenant.tenantId,
              projectId: widget.tenant.projectId,
              buildingId: widget.tenant.buildingId,
              documentName: _selectedDocumentName.value?['DisplayName'] ?? '',
              files: _documentFiles,
            );
          } else {
            await _tenantCubit.updateTenantDocument(
              context: context,
              tenantDocumentId: doc.tenantDocumentId,
              uniqueKey: doc.uniquekey,
              tenantId: doc.tenantId,
              projectId: doc.projectId,
              buildingId: doc.buildingId,
              documentName: _selectedDocumentName.value?['DisplayName'] ?? '',
              files: _documentFiles,
              index: index!,
            );
          }
          if (!mounted) return;
          goRouter.pop();
          _selectedDocumentName.value = null;
        },
      ),
    );
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
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Overview", "Document"],
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          SectionCard(
            title: "Applicant Details",
            titleTextColor: AppColor.orange,
            headerBackgroundColor: AppColor.lightOrangeBg.withValues(
              alpha: 0.5,
            ),
            children: [
              SizedBox(
                height: 0.4.sh,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.tenant.tenantApplicantData.length,
                  itemBuilder: (_, index) {
                    final applicant = widget.tenant.tenantApplicantData[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.primary, width: .3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
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
                              _buildApplicantTypeWidget(
                                applicant.applicantType,
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
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
                            spacing: 10,
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
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.aadharCardURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Aadhaar Card",
                                        context,
                                        applicant.aadharCardURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.aadharCardURL.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
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
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.panCardURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "PAN Card.",
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
                            spacing: 10,
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
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant
                                        .drivingLicenseURL
                                        .isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Driving License",
                                        context,
                                        applicant.drivingLicenseURL.split(","),
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
                            spacing: 10,
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
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.votingIdURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Voting ID",
                                        context,
                                        applicant.votingIdURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.votingIdURL.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
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
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.passportURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Passport",
                                        context,
                                        applicant.passportURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.passportURL.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
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
                                title: "GST Certificate",
                                value:
                                    applicant.gstNumberURL.isEmpty
                                        ? "-"
                                        : applicant.gstNumberURL,
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.gstNumberURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "GST Certificate",
                                        context,
                                        applicant.gstNumberURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.gstNumberURL.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Profile Photo",
                                value:
                                    applicant.photoURL.isEmpty
                                        ? "-"
                                        : applicant.photoURL,
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.photoURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Profile Photo",
                                        context,
                                        applicant.photoURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.photoURL.isEmpty,
                                ),
                              ),
                              buildColumnTitleValue(
                                title: "Cheque / Cancelled Cheque",
                                value:
                                    applicant.chequeURL.isEmpty
                                        ? "-"
                                        : applicant.chequeURL,
                                customValueWidget: CustomButton.documentOutline(
                                  onPressed: () {
                                    if (applicant.chequeURL.isNotEmpty) {
                                      showFilePreviewDialog(
                                        title: "Cheque / Cancelled Cheque",
                                        context,
                                        applicant.chequeURL.split(","),
                                      );
                                    }
                                  },
                                  isDisable: applicant.chequeURL.isEmpty,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            spacing: 10,
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
                            spacing: 10,
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
          SectionCard(
            title: "Exisiting Unit Details",
            titleTextColor: AppColor.darkBlue29,
            headerBackgroundColor: AppColor.darkBlue29.withValues(alpha: 0.1),
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Tenant Code",
                    value: widget.tenant.systemGeneratedCode,
                  ),
                  buildColumnTitleValue(
                    title: "Unit / Annexure / Survey Number",
                    value: widget.tenant.unitAnnexureSurveyNumber,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Unit Type",
                    value: widget.tenant.unitType,
                  ),
                  buildColumnTitleValue(
                    title: "Unit Configuration",
                    value: widget.tenant.unitConfiguration,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Unit Carpet Area (SqFt)",
                    value: widget.tenant.unitCarpetAreaSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Unit Facing",
                    value: widget.tenant.unitFacing,
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Eligibility Details in Carpet Area (SqFt)',
            titleTextColor: AppColor.brown,
            headerBackgroundColor: AppColor.lightYellow,
            children: [
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Extra Free Carpet Area Offered (%)",
                    value:
                        widget.tenant.extraFreeCarpetAreaOfferedPercent
                            .addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Free MOFA Carpet Area (SqFt)",
                    value: widget.tenant.freeMOFACarpetAreaSqFt.addCommas(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Existing Terrace Area (SqFt)",
                    value: widget.tenant.existingTerraceAreaSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "New Eligibility MOFA Carpet Area (SqFt)",
                    value:
                        widget.tenant.newEligibilityMOFACarpetAreaSqFt
                            .addCommas(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "New Eligibility RERA Carpet Area (SqFt)",
                    value:
                        widget.tenant.newEligibilityRERACarpetAreaSqFt
                            .addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "(A) Area Against Terrace (SqFt)",
                    value: widget.tenant.areaAgainstTerraceSqFt.addCommas(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "MOFA Carpet Area Purchased (SqFt)",
                    value:
                        widget.tenant.mofaCarpetAreaPurchasedSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "RERA Carpet Area Purchased (SqFt)",
                    value:
                        widget.tenant.reraCarpetAreaPurchasedSqFt.addCommas(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "(B) Deck Area (SqFt)",
                    value: widget.tenant.deckAreaSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Total New MOFA Carpet Area (SqFt)",
                    value: widget.tenant.totalNewMOFACarpetAreaSqFt.addCommas(),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "(C) Total New RERA Carpet Area (SqFt)",
                    value: widget.tenant.totalNewRERACarpetAreaSqFt.addCommas(),
                  ),
                ],
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title:
                      "Area Against Terrace + Deck Area + Total New RERA Carpet Area (SqFt) (A + B + C)",
                  value:
                      (widget.tenant.totalNewRERACarpetAreaSqFt +
                              widget.tenant.deckAreaSqFt +
                              widget.tenant.areaAgainstTerraceSqFt)
                          .addCommas(),
                ),
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Remark",
                  value: widget.tenant.remark,
                ),
              ),
            ],
          ),
          SectionCard(
            title: "New Unit Details",
            titleTextColor: AppColor.darkBlue29,
            headerBackgroundColor: AppColor.darkBlue29.withValues(alpha: 0.1),
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Building Number",
                    value: widget.tenant.buildingNumber,
                  ),
                  buildColumnTitleValue(
                    title: "Wing",
                    value: widget.tenant.wing,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Floor",
                    value: widget.tenant.floor,
                  ),
                  buildColumnTitleValue(
                    title: "Unit Number",
                    value: widget.tenant.flat,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "RERA Carpet Area(Sq.ft)",
                    value: widget.tenant.reraCarpetAreaSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Unit Type",
                    value: widget.tenant.inventoryFlatType,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Unit Configuration",
                    value: widget.tenant.inventoryFlatConfiguration,
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Action Details',
            titleTextColor: AppColor.black,
            headerBackgroundColor: AppColor.grey20,
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Created By",
                    value: widget.tenant.createdBy,
                  ),
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(widget.tenant.createdDate),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Modified By",
                    value: widget.tenant.modifiedBy,
                  ),
                  buildColumnTitleValue(
                    title: "Modified Date",
                    value: formatDate(widget.tenant.modifiedDate),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        verticalSpacing(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: SearchWidget(
                      onSubmit: (v) {
                        _tenantCubit.searchTenantDocument(
                          buildingId: widget.tenant.buildingId,
                          context: context,
                          projectId: widget.tenant.projectId,
                          value: v,
                          tenantId: widget.tenant.tenantId,
                        );
                      },
                      hintText: "Search By Document Name",
                      textController: _searchDocumentNameC,
                    ),
                  ),
                  CustomIconButton.add(
                    isDisabled: !_routeAuthorizationModel.isAction,
                    onPressed: () async {
                      _showAddDocumentBottomSheet();
                    },
                  ),
                ],
              ),
              verticalSpacing(height: 12),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<TenantCubit, TenantState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) &&
                  state.tenantDocumentList.isEmpty) {
                return Center(child: loader());
              }
              if (state.tenantDocumentList.isEmpty) {
                return Center(
                  child: noDataWidget(message: 'No Documents Found'),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                separatorBuilder:
                    (context, index) => verticalSpacing(height: 12),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: state.tenantDocumentList.length,
                itemBuilder: (context, index) {
                  final doc = state.tenantDocumentList[index];
                  return Container(
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                            right: 16,
                            left: 16,
                            top: 16,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.lightBluebg.withValues(alpha: 0.5),
                            border: Border.all(color: AppColor.lightBlue),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  doc.documentName,
                                  style: AppTextStyle.ts14M(),
                                ),
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  CustomIconButton(
                                    isDisable: doc.documentUrl.isEmpty,
                                    onPressed: () {
                                      showFilePreviewDialog(
                                        title: doc.documentName,
                                        context,
                                        doc.documentUrl.split(","),
                                      );
                                    },
                                    backgroundColor: Colors.transparent,
                                    icon: Icon(
                                      Icons.remove_red_eye_outlined,
                                      color:
                                          doc.documentUrl.isEmpty
                                              ? AppColor.grey2
                                              : AppColor.primary,
                                      size: 18,
                                    ),
                                  ),
                                  CustomIconButton.edit(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () {
                                      _showAddDocumentBottomSheet(
                                        doc: doc,
                                        index: index,
                                      );
                                    },
                                  ),
                                  CustomIconButton.delete(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () {
                                      _showPopupToDeleteTenantDocument(
                                        context: context,
                                        index: index,
                                        tenantModel: doc,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 16,
                            left: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            children: [
                              buildRowTitleValue(
                                title: "Document Count",
                                fixesWidth: 140.w,
                                value:
                                    doc.documentUrl
                                        .split(',')
                                        .length
                                        .toString(),
                              ),
                              buildRowTitleValue(
                                title: "Upload By / Date",
                                fixesWidth: 140.w,
                                singleLine: false,
                                value:
                                    doc.modifiedDate == null
                                        ? '${doc.createdBy} / ${formatDate(doc.createdDate)}'
                                        : '${doc.modifiedBy} / ${formatDate(doc.modifiedDate)}',
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
    );
  }

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
