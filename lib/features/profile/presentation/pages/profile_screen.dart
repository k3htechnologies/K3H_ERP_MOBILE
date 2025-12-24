import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      context.read<ProfileCubit>().onTabChanged(_tabController.index, context);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildHeader(UserModel user, ProjectModel? project) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColor.primary,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: AppTextStyle.ts24B(color: AppColor.white),
            ),
          ),
          horizontalSpacing(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: AppTextStyle.ts16SB(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.designation.isNotEmpty) ...[
                  verticalSpacing(height: 4),
                  Text(
                    user.designation,
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ],
                if (project != null) ...[
                  verticalSpacing(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business, size: 14, color: AppColor.grey),
                      horizontalSpacing(width: 4),
                      Expanded(
                        child: Text(
                          project.projectName,
                          style: AppTextStyle.ts12R(color: AppColor.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
        // Try to pair with next item if available and not fullWidth
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

  String _getDisplayValue(String? value) {
    if (value == null) return '-';
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '-';
    return value;
  }

  bool _hasBankDetails(UserModel user) {
    return user.bankName.trim().isNotEmpty ||
        user.bankBranchName.trim().isNotEmpty ||
        user.ifscCode.trim().isNotEmpty ||
        user.accountNo.trim().isNotEmpty;
  }

  Widget _buildInfoItem(
    String label,
    String? value, {
    bool isFullWidth = false,
  }) {
    final displayValue = _getDisplayValue(value);

    if (isFullWidth) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(displayValue, style: AppTextStyle.ts14R()),
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
              Text(displayValue, style: AppTextStyle.ts14R()),
            ],
          ),
        ),
      ],
    );
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
          Text('Employee Reporting Cycle', style: AppTextStyle.ts16SB()),
          verticalSpacing(height: 12),
          ...employeeReportingCycleData.map((employee) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.greyBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDisplayValue(
                                employee['FullName']?.toString(),
                              ),
                              style: AppTextStyle.ts14SB(),
                            ),
                            verticalSpacing(height: 4),
                            Text(
                              _getDisplayValue(
                                employee['Designation']?.toString(),
                              ),
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Employee Code',
                              style: AppTextStyle.ts12M(color: AppColor.grey),
                            ),
                            verticalSpacing(height: 2),
                            Text(
                              _getDisplayValue(
                                employee['EmployeeCode']?.toString(),
                              ),
                              style: AppTextStyle.ts12R(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mobile',
                              style: AppTextStyle.ts12M(color: AppColor.grey),
                            ),
                            verticalSpacing(height: 2),
                            Text(
                              _getDisplayValue(
                                employee['PersonalMobileNumber']?.toString(),
                              ),
                              style: AppTextStyle.ts12R(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: AppTextStyle.ts12M(color: AppColor.grey),
                      ),
                      verticalSpacing(height: 2),
                      Text(
                        _getDisplayValue(employee['EmailId']?.toString()),
                        style: AppTextStyle.ts12R(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () async => await logOutUser(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                color: AppColor.black.withValues(alpha: 0.12),
                spreadRadius: 0,
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColor.white),
              const SizedBox(width: 8),
              Text(
                "Log Out",
                style: AppTextStyle.ts16SB(color: AppColor.white),
              ),
            ],
          ),
        ),
      ),
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
          _buildInfoCard(
            title: 'Contact Information',
            items: [
              {'label': 'Personal Mobile', 'value': user.personalMobileNumber},
              {'label': 'Office Mobile', 'value': user.officeMobileNumber},
              {'label': 'Email', 'value': user.emailId},
              {'label': 'Office Email', 'value': user.officeEmailId},
              {
                'label': 'Emergency Contact',
                'value': user.emergencyMobileNumber,
              },
            ],
          ),
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
          if (user.employeeReportingCycleData.isNotEmpty)
            _buildEmployeeReportingCycleCard(user.employeeReportingCycleData),
          if (user.employeeReportingCycleData.isNotEmpty) verticalSpacing(),
          _buildLogoutButton(context),
          verticalSpacing(height: 20),
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

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "$title\n\nComing soon...",
          textAlign: TextAlign.center,
          style: AppTextStyle.ts16M(color: AppColor.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.user == null) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Text('Profile', style: AppTextStyle.ts16SB()),
              ),
              body: const Center(child: Text("No user information found")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: Text('Profile', style: AppTextStyle.ts16SB()),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  verticalSpacing(),
                  _buildHeader(state.user!, state.selectedProject),
                  verticalSpacing(),
                  Container(
                    height: 48,
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
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(state.user!),
                        _buildPlaceholderTab('Document'),
                        _buildPlaceholderTab('Assets'),
                        _buildProjectTab(
                          state.projectList,
                          state.isLoadingProjects,
                        ),
                        _buildPlaceholderTab('Shift Policy'),
                        _buildPlaceholderTab('Week Off Policy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
