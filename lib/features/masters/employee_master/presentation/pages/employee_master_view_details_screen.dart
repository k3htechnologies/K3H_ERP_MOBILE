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
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
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
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeMasterCubit, EmployeeMasterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBarWithBackButton(
            screenTitle: "Employee",
            authorization: AuthorizationModel(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                verticalSpacing(),
                Container(
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
                    tabAlignment: TabAlignment.start,
                    controller: _tabController,
                    isScrollable: true,
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
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Document'),
                      Tab(text: 'Assets'),
                      Tab(text: 'Project'),
                      Tab(text: 'Shift Policy'),
                      Tab(text: 'Week Off Policy'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(widget.employee),
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

  Widget _buildInfoCard({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts16SB()),
          verticalSpacing(height: 12),
          ..._buildInfoRows(items),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(List<Map<String, String>> items) {
    List<Widget> rows = [];
    int i = 0;

    while (i < items.length) {
      final item = items[i];
      final label = item['label'] ?? '';
      final value = item['value'] ?? '';
      final isFullWidth = item['fullWidth'] == 'true';

      if (isFullWidth) {
        rows.add(_buildInfoItem(label, value, isFullWidth: true));
        if (i < items.length - 1) {
          rows.add(verticalSpacing(height: 12));
        }
        i++;
      } else {
        if (i + 1 < items.length && items[i + 1]['fullWidth'] != 'true') {
          final nextItem = items[i + 1];
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildInfoItem(label, value)),
                horizontalSpacing(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    nextItem['label'] ?? '',
                    nextItem['value'] ?? '',
                  ),
                ),
              ],
            ),
          );
          if (i + 1 < items.length - 1) {
            rows.add(verticalSpacing(height: 12));
          }
          i += 2;
        } else {
          rows.add(_buildInfoItem(label, value));
          if (i < items.length - 1) {
            rows.add(verticalSpacing(height: 12));
          }
          i++;
        }
      }
    }

    return rows;
  }

  Widget _buildContactInformationCard(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: AppTextStyle.ts16SB()),
          verticalSpacing(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Personal Mobile',
                  user.personalMobileNumber,
                  customValueWidget:
                      user.personalMobileNumber.isNotEmpty
                          ? CustomClickToContactText(
                            value: user.personalMobileNumber,
                          )
                          : null,
                ),
              ),
              horizontalSpacing(width: 16),
              Expanded(
                child: _buildInfoItem(
                  'Office Mobile',
                  user.officeMobileNumber,
                  customValueWidget:
                      user.officeMobileNumber.isNotEmpty
                          ? CustomClickToContactText(
                            value: user.officeMobileNumber,
                          )
                          : null,
                ),
              ),
            ],
          ),
          verticalSpacing(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Email',
                  user.emailId,
                  customValueWidget:
                      user.emailId.isNotEmpty
                          ? CustomClickToContactText(
                            value: user.emailId,
                            type: ContactType.email,
                          )
                          : null,
                ),
              ),
              horizontalSpacing(width: 16),
              Expanded(
                child: _buildInfoItem(
                  'Office Email',
                  user.officeEmailId,
                  customValueWidget:
                      user.officeEmailId.isNotEmpty
                          ? CustomClickToContactText(
                            value: user.officeEmailId,
                            type: ContactType.email,
                          )
                          : null,
                ),
              ),
            ],
          ),
          verticalSpacing(height: 12),
          _buildInfoItem(
            'Emergency Contact',
            user.emergencyMobileNumber,
            customValueWidget:
                user.emergencyMobileNumber.isNotEmpty
                    ? CustomClickToContactText(
                      value: user.emergencyMobileNumber,
                    )
                    : null,
          ),
        ],
      ),
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

  Widget _buildOverviewTab(UserModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          _buildInfoCard(
            title: 'Basic Information',
            items: [
              {'label': 'Employee Code', 'value': user.employeeCode},
              {'label': 'Full Name', 'value': user.fullName},
              {
                'label': 'Date of Birth',
                'value':
                    user.dateOfBirth != null
                        ? formatDateTimeAsDDMMMYYYY(user.dateOfBirth!)
                        : '-',
              },
              {'label': 'Gender', 'value': user.gender},
              {'label': 'Marital Status', 'value': user.maritalStatus},
              {'label': 'Blood Group', 'value': user.bloodGroup},
              {
                'label': 'Probation Date',
                'value':
                    user.probationDate != null
                        ? formatDateTimeAsDDMMMYYYY(user.probationDate!)
                        : "-",
              },
              {
                'label': 'Id Card Issued Date',
                'value':
                    user.idCardIssuedDate != null
                        ? formatDateTimeAsDDMMMYYYY(user.idCardIssuedDate!)
                        : "-",
              },
              {
                'label': 'Communication Address',
                'value': user.communicationAddress,
                'fullWidth': 'true',
              },
              {
                'label': 'Permanent Address',
                'value': user.permanentAddress,
                'fullWidth': 'true',
              },
            ],
          ),
          verticalSpacing(),
          _buildContactInformationCard(user),
          verticalSpacing(),
          _buildInfoCard(
            title: 'Professional Information',
            items: [
              {'label': 'Company', 'value': user.companyName},
              {'label': 'Department', 'value': user.department},
              {'label': 'Designation', 'value': user.designation},
              {'label': 'Branch', 'value': user.branch},
              {'label': 'Employee Type', 'value': user.employeeType},
              {'label': 'Reporting To', 'value': user.reportPersonName},
              if (user.joiningDate != null)
                {
                  'label': 'Joining Date',
                  'value': formatDateTimeAsDDMMMYYYY(user.joiningDate!),
                },
            ],
          ),
          verticalSpacing(),
          if (user.employeeReportingCycleData.isNotEmpty)
            _buildEmployeeReportingCycleCard(user.employeeReportingCycleData),
          verticalSpacing(),
          _buildInfoCard(
            title: 'Address Information',
            items: [
              {'label': 'Country', 'value': user.countryName},
              {'label': 'State', 'value': user.stateName},
              {'label': 'District', 'value': user.districtName},
              {'label': 'City', 'value': user.cityName},
            ],
          ),
          verticalSpacing(),
          if (_hasBankDetails(user))
            _buildInfoCard(
              title: 'Bank Details',
              items: [
                {'label': 'Bank Name', 'value': user.bankName},
                {'label': 'Bank Branch', 'value': user.bankBranchName},
                {'label': 'IFSC Code', 'value': user.ifscCode},
                {'label': 'Account Number', 'value': user.accountNo},
              ],
            ),
          if (_hasBankDetails(user)) verticalSpacing(),
          verticalSpacing(height: 20),
        ],
      ),
    );
  }

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

                                // 🗑 DELETE
                                deleteDocument: (removeUrl) async {
                                  final files = MultiFilePickerModel(
                                    fileNameList: [],
                                    fileBytesList: [],
                                    deletedFileList: removeUrl, // ✅ FIXED
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
                                  "Asset Type",
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
                                child: _buildInfoItem("Status", asset.status),
                              ),
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Text("Purchase Details", style: AppTextStyle.ts14SB()),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Purchase Date",
                                  formatDateTimeAsDDMMMYYYY(asset.purchaseDate),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Asset Cost",
                                  asset.assetCost.toString(),
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
                                  "Warranty Expiry Date",
                                  formatDateTimeAsDDMMMYYYY(
                                    asset.warrantyExpiryDate,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _buildInfoItem(
                                  "Supplier Name",
                                  asset.supplierName,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.noDataImage,
                      width: 150.0,
                      height: 150.0,
                    ),
                    verticalSpacing(),
                    Text("No Data Available!", style: AppTextStyle.ts14B()),
                  ],
                ),
              );
        },
      ),
    );
  }

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.noDataImage,
                      width: 150.0,
                      height: 150.0,
                    ),
                    verticalSpacing(),
                    Text("No Data Available!", style: AppTextStyle.ts14B()),
                  ],
                ),
              );
        },
      ),
    );
  }

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.noDataImage,
                      width: 150.0,
                      height: 150.0,
                    ),
                    verticalSpacing(),
                    Text("No Data Available!", style: AppTextStyle.ts14B()),
                  ],
                ),
              );
        },
      ),
    );
  }

  bool _hasBankDetails(UserModel user) {
    return user.bankName.trim().isNotEmpty ||
        user.bankBranchName.trim().isNotEmpty ||
        user.ifscCode.trim().isNotEmpty ||
        user.accountNo.trim().isNotEmpty;
  }

  Widget _buildEmployeeReportingCycleCard(
    List<Map<String, dynamic>> employeeReportingCycleData,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reporting Structure', style: AppTextStyle.ts16SB()),
          verticalSpacing(height: 12),
          ...employeeReportingCycleData.map((employee) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: AppColor.lightGrey,
                            border: Border.all(
                              color: AppColor.grey.withValues(alpha: .5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              employee["FullName"][0],
                              style: AppTextStyle.ts16SB(),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee["FullName"],
                              style: AppTextStyle.ts14SB(),
                            ),
                            Text(
                              employee["Designation"],
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.purple.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      employee["EmployeeCode"],
                      style: AppTextStyle.ts12R(color: AppColor.purple),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "No projects found",
            style: AppTextStyle.ts16M(color: AppColor.grey),
          ),
        ),
      );
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
