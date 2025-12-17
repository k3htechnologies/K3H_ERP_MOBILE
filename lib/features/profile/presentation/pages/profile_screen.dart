import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

UserModel? _getUser() {
  String? userString = LocalStorageManager().getString(StorageKey.currentUser);
  if (userString == null) {
    return null;
  }
  return UserModel.fromJson(jsonDecode(userString));
}

ProjectModel? _getSelectedProject() {
  String? projectString = LocalStorageManager().getString(
    StorageKey.selectedProject,
  );
  if (projectString == null) {
    return null;
  }
  return ProjectModel.fromJson(jsonDecode(projectString));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildHeader(UserModel user, ProjectModel? project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColor.primary.withValues(alpha: 0.1)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColor.primary,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
              style: AppTextStyle.ts24B(color: AppColor.white),
            ),
          ),
          const SizedBox(width: 16),
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
                  const SizedBox(height: 4),
                  Text(
                    user.designation,
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),
                ],
                if (project != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    project.projectName,
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
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(title, style: AppTextStyle.ts16SB()),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColor.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: AppTextStyle.ts14R(),
              textAlign: TextAlign.end,
            ),
          ),
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
            color: AppColor.error,
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
              Image.asset(AppAssets.logoutImage),
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

  @override
  Widget build(BuildContext context) {
    final user = _getUser();
    final project = _getSelectedProject();

    if (user == null) {
      return Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Profile",
          authorization: AuthorizationModel(),
        ),
        body: const Center(child: Text("No user information found")),
      );
    }

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Profile",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user, project),
            verticalSpacing(height: 20),
            _buildSection('Personal Information'),
            _buildInfoRow('Employee Code', user.employeeCode),
            _buildInfoRow('Full Name', user.fullName),
            _buildInfoRow('Gender', user.gender),
            _buildInfoRow('Marital Status', user.maritalStatus),
            _buildInfoRow(
              'Date of Birth',
              user.dateOfBirth != null
                  ? formatDateTimeAsDDMMMYYYY(user.dateOfBirth!)
                  : '-',
            ),
            _buildInfoRow('Blood Group', user.bloodGroup),
            verticalSpacing(height: 20),
            _buildSection('Contact Information'),
            _buildInfoRow('Personal Mobile', user.personalMobileNumber),
            _buildInfoRow('Office Mobile', user.officeMobileNumber),
            _buildInfoRow('Email', user.emailId),
            _buildInfoRow('Office Email', user.officeEmailId),
            _buildInfoRow('Emergency Contact', user.emergencyMobileNumber),
            verticalSpacing(height: 20),
            _buildSection('Professional Information'),
            _buildInfoRow('Department', user.department),
            _buildInfoRow('Designation', user.designation),
            _buildInfoRow('Branch', user.branch),
            _buildInfoRow('Company', user.companyName),
            _buildInfoRow('Employee Type', user.employeeType),
            _buildInfoRow('Reporting To', user.reportPersonName),
            if (user.joiningDate != null) ...[
              _buildInfoRow(
                'Joining Date',
                formatDateTimeAsDDMMMYYYY(user.joiningDate!),
              ),
            ],
            verticalSpacing(height: 20),
            _buildSection('Address Information'),
            _buildInfoRow('Communication Address', user.communicationAddress),
            _buildInfoRow('Permanent Address', user.permanentAddress),
            _buildInfoRow('City', user.cityName),
            _buildInfoRow('State', user.stateName),
            _buildInfoRow('Country', user.countryName),
            verticalSpacing(height: 20),
            _buildLogoutButton(context),
            verticalSpacing(height: 20),
          ],
        ),
      ),
    );
  }
}
