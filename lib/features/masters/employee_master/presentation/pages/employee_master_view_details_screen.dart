import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/cubit/employee_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/widgets/employee_document_dialog.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeMasterViewDetailsScreen extends StatefulWidget {
  final UserModel employee;
  const EmployeeMasterViewDetailsScreen({super.key, required this.employee});

  @override
  State<EmployeeMasterViewDetailsScreen> createState() =>
      _EmployeeMasterViewDetailsScreenState();
}

class _EmployeeMasterViewDetailsScreenState
    extends State<EmployeeMasterViewDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGES
  void _handleTabChange() {
    final index = _tabController.index;
    if (index == _lastTabIndex) return;

    _lastTabIndex = index;

    context.read<EmployeeMasterCubit>().onTabChanged(
      context,
      index,
      widget.employee.employeeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Employee Master",
            authorization: AuthorizationModel(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                verticalSpacing(),
                ChipStyleTabBar(
                  controller: _tabController,
                  tabs: const [
                    "Overview",
                    "Education Details",
                    "Experience Details",
                    "Branch Associations",
                    "Document",
                    "Assets",
                    "Project",
                    "Shift Policy",
                    "Week Off Policy",
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(widget.employee),
                      _buildEducationTab(),
                      _buildExperienceTab(),
                      _buildBankAssociationTab(),
                      _buildDocumentTab(),
                      _buildAssetTab(),
                      _buildProjectTab(
                        state.projectList,
                        state.isLoadingProjects,
                      ),
                      _buildShiftPolicyTab(),
                      _buildWeekOffPolicyTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDisplayValue(String? value) {
    if (value == null) return '-';
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '-';
    return value;
  }

  Widget _buildInfoItem(
    String label,
    String? value, {
    bool isFullWidth = false,
    Widget? customValueWidget,
  }) {
    final displayValue = _getDisplayValue(value);
    final valueWidget =
        customValueWidget ?? Text(displayValue, style: AppTextStyle.ts14R());

    if (isFullWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          valueWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyle.ts14M(color: AppColor.grey)),
              verticalSpacing(height: 4),
              valueWidget,
            ],
          ),
        ),
      ],
    );
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab(UserModel user) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          // BASIC DETAILS
          Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basic Details', style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "First Name",
                      value: user.firstName,
                    ),
                    buildColumnTitleValue(
                      title: "Middle Name",
                      value: user.middleName,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Last Name",
                      value: user.lastName,
                    ),
                    buildColumnTitleValue(title: "Gender", value: user.gender),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Marital Status",
                      value: user.maritalStatus,
                    ),
                    buildColumnTitleValue(
                      title: "Blood Group",
                      value: user.bloodGroup,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "DOB",
                      value:
                          user.dateOfBirth != null
                              ? formatDateTimeAsDDMMMYYYY(user.dateOfBirth!)
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Email ID",
                      value: user.emailId,
                      customValueWidget: CustomClickToContactText(
                        value: user.emailId,
                        type: ContactType.email,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Personal Mobile Number",
                      value: user.personalMobileNumber,
                      customValueWidget: CustomClickToContactText(
                        countryCode: "+91",
                        value: user.personalMobileNumber,
                        type: ContactType.phone,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Aadhaar Card Number",
                      value: user.aadharCardNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "PAN Number",
                      value: user.panCardNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Passport Number",
                      value: user.passportNumber,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Driving Licence Number",
                      value: user.drivingLicenceNumber,
                    ),
                    buildColumnTitleValue(
                      title: "Voter Card Number",
                      value: user.voterCardNumber,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Communication Address",
                      value: user.communicationAddress,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Permanent Address",
                      value: user.permanentAddress,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ADDRESS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Address", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 5),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Country",
                      value: user.countryName,
                    ),
                    buildColumnTitleValue(
                      title: "State",
                      value: user.stateName,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "District",
                      value: user.districtName,
                    ),
                    buildColumnTitleValue(title: "City", value: user.cityName),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Village",
                      value: user.villageName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // EMPLOYEE INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Employee Information", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Employee Code",
                      value: user.employeeCode,
                    ),
                    buildColumnTitleValue(
                      title: "Company Name",
                      value: user.companyName,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(title: "Branch", value: user.branch),
                    buildColumnTitleValue(
                      title: "Department",
                      value: user.department,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Designation",
                      value: user.designation,
                    ),
                    buildColumnTitleValue(
                      title: "Joining Date",
                      value:
                          user.joiningDate != null
                              ? formatDateTimeAsDDMMMYYYY(user.joiningDate!)
                              : "-",
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Reporting Person",
                      value: user.reportPersonName,
                    ),
                    buildColumnTitleValue(
                      title: "Employee Type",
                      value: user.employeeType,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Office Number",
                      value: user.officeMobileNumber,
                      customValueWidget: CustomClickToContactText(
                        countryCode: "+91",
                        value: user.officeMobileNumber,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Office E-mail Id",
                      value: user.officeEmailId,
                      customValueWidget: CustomClickToContactText(
                        value: user.officeEmailId,
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
                      title: "Probation Date",
                      value:
                          user.probationDate != null
                              ? formatDateTimeAsDDMMMYYYY(user.probationDate!)
                              : "-",
                    ),
                    buildColumnTitleValue(
                      title: "Id Card Issued Date",
                      value:
                          user.idCardIssuedDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                user.idCardIssuedDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // BANK DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bank Details", style: AppTextStyle.ts16SB()),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Bank Name",
                      value: user.bankName,
                    ),
                    buildColumnTitleValue(
                      title: "Account Number",
                      value: user.accountNo,
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Bank Branch Name",
                      value: user.bankBranchName,
                    ),
                    buildColumnTitleValue(
                      title: "IFSC Code",
                      value: user.ifscCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // EMPLOYEE REPORTING CYCLE
          if (user.employeeReportingCycleData.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporting Structure', style: AppTextStyle.ts16SB()),
                  verticalSpacing(height: 12),

                  Column(
                    children: List.generate(
                      user.employeeReportingCycleData.length,
                      (index) {
                        final employee = user.employeeReportingCycleData[index];
                        final bool isLast =
                            index == user.employeeReportingCycleData.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///  TIMELINE INDICATOR
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColor.primary,
                                    child: Text(
                                      (employee["FullName"] ?? "")
                                          .toString()
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              ///  DETAILS
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// NAME + CODE
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              employee["FullName"] ?? "-",
                                              style: AppTextStyle.ts14SB(),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          if (employee["EmployeeCode"] !=
                                                  null &&
                                              employee["EmployeeCode"]
                                                  .isNotEmpty)
                                            Text(
                                              "(${employee["EmployeeCode"]})",
                                              style: AppTextStyle.ts12R(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      /// DESIGNATION
                                      Text(
                                        employee["Designation"] ?? "-",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),

                                      /// EMAIL
                                      if (employee["EmailId"] != null &&
                                          employee["EmailId"].isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          employee["EmailId"],
                                          style: AppTextStyle.ts12R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ],

                                      /// PHONE
                                      if (employee["PersonalMobileNumber"] !=
                                              null &&
                                          employee["PersonalMobileNumber"]
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          employee["PersonalMobileNumber"],
                                          style: AppTextStyle.ts12R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
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
          ],
          // EMERGENCY CONTACT DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Emergency Contact Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 5),
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Relation to Emergency Contact",
                      value: user.emergencyContactPersonRelationship,
                    ),
                    buildColumnTitleValue(
                      title: "Emergency Contact Number",
                      value: user.emergencyMobileNumber,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ACTION DETAILS
          actionCardWidget(
            createdBy: user.createdBy,
            createdDate: user.createdDate,
            modifiedBy: user.modifiedBy,
            modifiedDate: user.modifiedDate,
          ),
        ],
      ),
    );
  }

  // BUILD EDUCATION TAB
  Widget _buildEducationTab() {
    return BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
      builder: (context, state) {
        if (state.isLoading == true &&
            state.employeeEducationDetailsList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.employeeEducationDetailsList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Education Details Found"),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shrinkWrap: true,
          itemCount: state.employeeEducationDetailsList.length,
          itemBuilder: (_, index) {
            final education = state.employeeEducationDetailsList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Qualification",
                        value: education.qualification,
                      ),
                      buildColumnTitleValue(
                        title: "Passing Year",
                        value: education.passing,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "College",
                        value: education.collegeName,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD EXPERIENCE TAB
  Widget _buildExperienceTab() {
    return BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
      builder: (context, state) {
        if (state.isLoading == true &&
            state.employeeExperienceDetailsList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.employeeExperienceDetailsList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Experience Details Found"),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shrinkWrap: true,
          itemCount: state.employeeExperienceDetailsList.length,
          itemBuilder: (_, index) {
            final experience = state.employeeExperienceDetailsList[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Column(
                spacing: 10,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Company",
                        value: experience.companyName,
                      ),
                      buildColumnTitleValue(
                        title: "Role",
                        value: experience.role,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      buildColumnTitleValue(
                        title: "Tenure",
                        value: experience.tenure,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BUILD BANK ASSOCIATION TAB
  Widget _buildBankAssociationTab() {
    return BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
      builder: (_, state) {
        if (state.isLoading == true && state.branchAssociationList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.branchAssociationList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Branch Associations Found"),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shrinkWrap: true,
          itemCount: state.branchAssociationList.length,
          itemBuilder: (_, index) {
            final branch = state.branchAssociationList[index];
            return Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              child: Text(branch.branchName, style: AppTextStyle.ts14R()),
            );
          },
        );
      },
    );
  }

  // BUILD DOCUMENT TAB
  Widget _buildDocumentTab() {
    return SingleChildScrollView(
      child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
        builder: (context, state) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: state.employeeDocumentList.length,
            itemBuilder: (context, index) {
              final doc = state.employeeDocumentList[index];

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
                    Text(doc.documentName, style: AppTextStyle.ts14SB()),
                    const Spacer(),

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

                                //  ADD / UPLOAD
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

                                  await context
                                      .read<EmployeeMasterCubit>()
                                      .updateEmployeeDocument(
                                        context: context,
                                        employeeDocumentId:
                                            doc.employeeDocumentId,
                                        uniqueKey: doc.uniquekey,
                                        employeeId: doc.employeeId.toString(),
                                        documentName: doc.documentName,
                                        removeDocumentURL: "",
                                        files: files,
                                      );
                                },

                                // DELETE
                                deleteDocument: (removeUrl) async {
                                  final files = MultiFilePickerModel(
                                    fileNameList: [],
                                    fileBytesList: [],
                                    deletedFileList: removeUrl,
                                  );

                                  await context
                                      .read<EmployeeMasterCubit>()
                                      .updateEmployeeDocument(
                                        context: context,
                                        employeeDocumentId:
                                            doc.employeeDocumentId,
                                        uniqueKey: doc.uniquekey,
                                        employeeId: doc.employeeId.toString(),
                                        documentName: doc.documentName,
                                        removeDocumentURL: removeUrl,
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

  // BUILD ASSETS TAB
  Widget _buildAssetTab() {
    return SingleChildScrollView(
      child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
        builder: (context, state) {
          return state.assetMappingList.isNotEmpty
              ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: state.assetMappingList.length,
                itemBuilder: (context, index) {
                  final asset = state.assetMappingList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asset.assetName, style: AppTextStyle.ts14SB()),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Asset Code",
                                  asset.assetCode,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Asset Brand",
                                  asset.assetBrand,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Asset Model",
                                  asset.assetModel,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Serial Type",
                                  asset.assetType,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Serial Number",
                                  asset.serialNumber,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Assigned Date",
                                  formatDateTimeAsDDMMMYYYY(asset.assignedDate),
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Assigned By",
                                  asset.createdBy,
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
              : SizedBox(
                height: getActualHeight(context) * 0.7,
                child: noDataWidget(message: "No Assets Found"),
              );
        },
      ),
    );
  }

  // BUILD SHIFT POLICY TAB
  Widget _buildShiftPolicyTab() {
    return SingleChildScrollView(
      child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
        builder: (context, state) {
          return state.shiftManagementList.isNotEmpty
              ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: state.shiftManagementList.length,
                itemBuilder: (context, index) {
                  final shiftManagement = state.shiftManagementList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shift Policy Details",
                          style: AppTextStyle.ts14SB(),
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Employee Name",
                                  shiftManagement.employeeName,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Department Name",
                                  shiftManagement.departmentName,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift Type",
                                  shiftManagement.shiftName,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift Code",
                                  shiftManagement.shiftCode,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift Begin Time",
                                  shiftManagement.shiftBeginTime,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift End Time",
                                  shiftManagement.shiftEndTime,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift Duration Time",
                                  shiftManagement.shiftDurationTime,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Shift Work Duration",
                                  shiftManagement.shiftWorkDurationTime,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Remark",
                                  shiftManagement.remarks,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
              : SizedBox(
                height: getActualHeight(context) * 0.7,
                child: Center(
                  child: noDataWidget(message: "No Shift Policies Found"),
                ),
              );
        },
      ),
    );
  }

  // BUILD WEEK OFF POLICY TAB
  Widget _buildWeekOffPolicyTab() {
    return SingleChildScrollView(
      child: BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
        builder: (context, state) {
          return state.weekOffMappingList.isNotEmpty
              ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: state.weekOffMappingList.length,
                itemBuilder: (context, index) {
                  final weekOffMapping = state.weekOffMappingList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Week Off Policy", style: AppTextStyle.ts14SB()),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Employee Name",
                                  weekOffMapping.employeeName,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Department Name",
                                  weekOffMapping.departmentName,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Off Policy Name",
                                  weekOffMapping.weekOffPolicyName,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Off Policy Code",
                                  weekOffMapping.weekOffPolicyCode,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Days",
                                  weekOffMapping.weekDays.toString(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Days Starts On",
                                  weekOffMapping.weekDaysStartsOn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Off",
                                  weekOffMapping.weeklyOff,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Off 2",
                                  weekOffMapping.weeklyOff2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Not Applicable Months",
                                  weekOffMapping.notApplicableForMonths,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Week Off 2 Type",
                                  weekOffMapping.weeklyOff2Type,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
              : SizedBox(
                height: getActualHeight(context) * 0.7,
                child: Center(
                  child: noDataWidget(message: "No Week Off Policies Found"),
                ),
              );
        },
      ),
    );
  }

  // BUILD PROJECT TAB
  Widget _buildProjectTab(
    List<ProjectModel> projectList,
    bool isLoadingProjects,
  ) {
    if (isLoadingProjects) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (projectList.isEmpty) {
      return Center(child: noDataWidget(message: "No Projects Found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projectList.length,
      itemBuilder: (context, index) {
        final project = projectList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: commonCardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (project.projectPhotoUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: project.projectPhotoUrl,
                    width: 84,
                    height: 69,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                    errorWidget: Container(
                      width: 84,
                      height: 69,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 84,
                  height: 69,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
              horizontalSpacing(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.projectName,
                      style: AppTextStyle.ts14SB(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpacing(height: 4),
                    Text(
                      project.projectLocation,
                      style: AppTextStyle.ts12R(color: AppColor.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.ctsNumber.isNotEmpty) ...[
                      verticalSpacing(height: 4),
                      Text(
                        'CTS: ${project.ctsNumber}',
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
