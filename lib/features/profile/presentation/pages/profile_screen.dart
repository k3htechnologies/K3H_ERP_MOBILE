import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_education_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/model/employee_experience_details.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/widgets/employee_document_dialog.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? data;
  const ProfileScreen({super.key, this.data});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CUBIT
  late ProfileCubit _profileCubit;

  // TEXT EDITING CONTROLLER
  late TextEditingController _qualificationC,
      _collageNameC,
      _passingC,
      _setMPIN;
  late TextEditingController _companyNameC, _roleC, _tenureC;

  // APP VERSION
  late String version;

  // FORM KEY FOR BOTTOM SHEETS
  final _educationFormKey = GlobalKey<FormState>();
  final _experienceFormKey = GlobalKey<FormState>();
  final _mpinFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _profileCubit = context.read<ProfileCubit>();
    _initializeTextEditingControllers();
    version = LocalStorageManager().getString(StorageKey.appVersion) ?? "";
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _profileCubit.state.user;

      if (user != null) {
        _profileCubit.getEmployeeMasterList(1, 100, user.employeeId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qualificationC.dispose();
    _collageNameC.dispose();
    _passingC.dispose();
    _companyNameC.dispose();
    _roleC.dispose();
    _tenureC.dispose();
    _setMPIN.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _qualificationC = TextEditingController();
    _collageNameC = TextEditingController();
    _passingC = TextEditingController();
    _companyNameC = TextEditingController();
    _roleC = TextEditingController();
    _tenureC = TextEditingController();
    _setMPIN = TextEditingController();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _profileCubit.onTabChanged(_tabController.index, context);
    }
  }

  // HELPER METHOD
  String _getDisplayValue(String? value) {
    if (value == null) return '-';
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return '-';
    return value;
  }

  // HELPER METHOD
  bool _hasBankDetails(UserModel user) {
    return user.bankName.trim().isNotEmpty ||
        user.bankBranchName.trim().isNotEmpty ||
        user.ifscCode.trim().isNotEmpty ||
        user.accountNo.trim().isNotEmpty;
  }

  // <---- ADD / UPDATE EDUCATION ---->
  Future<void> _showBottomSheetToAddUpdateEducation(
    BuildContext context, {
    EmployeeEducationDetailsModel? education,
    int? index,
  }) async {
    final isUpdate = education != null && index != null;
    if (isUpdate) {
      _qualificationC.text = education.qualification;
      _collageNameC.text = education.collegeName;
      _passingC.text = education.passing;
    } else {
      _qualificationC.clear();
      _collageNameC.clear();
      _passingC.clear();
    }

    DialogHelper.showCustomBottomSheet(
      context,
      isUpdate ? "Update Education Details" : "Add Education Details",
      Builder(
        builder: (bottomSheetContext) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Form(
              key: _educationFormKey,
              child: Column(
                children: [
                  CustomTextField(
                    title: "Qualification",
                    isRequired: true,
                    hint: "Enter Qualification",
                    textController: _qualificationC,
                    inputFormatterList: [LengthLimitingTextInputFormatter(250)],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Qualification is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "School/College Name",
                    isRequired: true,
                    hint: "Enter College Name",
                    inputFormatterList: [LengthLimitingTextInputFormatter(250)],
                    textController: _collageNameC,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'College Name is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "Passing Year",
                    isRequired: true,
                    hint: "Enter Passing Year",
                    keyboardType: TextInputType.number,
                    inputFormatterList: InputValidator.digit(4),
                    textController: _passingC,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Passing Year is required';
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 30),
                  CustomButton(
                    leading: Icon(
                      isUpdate ? Icons.edit : Icons.add,
                      size: 18,
                      color: AppColor.white,
                    ),
                    text: isUpdate ? "Update" : "Add",
                    onPressed: () async {
                      if (_educationFormKey.currentState?.validate() != true) {
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(bottomSheetContext);
                      final qualification = _qualificationC.text.trim();
                      final collegeName = _collageNameC.text.trim();
                      final passing = _passingC.text.trim();
                      final employeeId =
                          _profileCubit.state.user?.employeeId.toString() ?? '';
                      if (employeeId.isEmpty) return;
                      if (isUpdate) {
                        await _profileCubit.updateEmployeeEducationDetails(
                          context: context,
                          employeeEducationDetailsId:
                              education.employeeEducationDetailsId,
                          uniqueKey: education.uniquekey,
                          employeeId: employeeId,
                          qualification: qualification,
                          collegeName: collegeName,
                          passing: passing,
                          index: index,
                        );
                      } else {
                        await _profileCubit.addEmployeeEducationDetails(
                          context: context,
                          employeeId: employeeId,
                          qualification: qualification,
                          collegeName: collegeName,
                          passing: passing,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // <---- DELETE EMPLOYEE EDUCAtION DETAILS ---->
  Future<void> _showPopupToDeleteEmployeeEducationDetails(
    BuildContext context,
    EmployeeEducationDetailsModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a education?',
      'Deleting this education will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _profileCubit.deleteEmployeeEducationDetails(
        context: context,
        employeeEducationDetailsId: obj.employeeEducationDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // <---- ADD / UPDATE EXPERIENCE ---->
  Future<void> _showBottomSheetToAddUpdateExperience(
    BuildContext context, {
    EmployeeExperienceDetailsModel? experience,
    int? index,
  }) async {
    final isUpdate = experience != null && index != null;
    if (isUpdate) {
      _companyNameC.text = experience.companyName;
      _roleC.text = experience.role;
      _tenureC.text = experience.tenure;
    } else {
      _companyNameC.clear();
      _roleC.clear();
      _tenureC.clear();
    }

    DialogHelper.showCustomBottomSheet(
      context,
      isUpdate ? "Update Experience Details" : "Add Experience Details",
      Builder(
        builder: (bottomSheetContext) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Form(
              key: _experienceFormKey,
              child: Column(
                children: [
                  CustomTextField(
                    title: "Company Name",
                    isRequired: true,
                    hint: "Enter Company Name",
                    textController: _companyNameC,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Company Name is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "Role",
                    isRequired: true,
                    hint: "Enter Role",
                    textController: _roleC,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Role is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: "Tenure",
                    isRequired: true,
                    hint: "Enter Tenure (e.g. 2 years)",
                    inputFormatterList: [LengthLimitingTextInputFormatter(20)],
                    textController: _tenureC,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tenure is required';
                      }
                      return null;
                    },
                  ),
                  verticalSpacing(height: 30),
                  CustomButton(
                    leading: Icon(
                      isUpdate ? Icons.edit : Icons.add,
                      size: 18,
                      color: AppColor.white,
                    ),
                    text: isUpdate ? "Update" : "Add",
                    onPressed: () async {
                      if (_experienceFormKey.currentState?.validate() != true) {
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(bottomSheetContext);
                      final companyName = _companyNameC.text.trim();
                      final role = _roleC.text.trim();
                      final tenure = _tenureC.text.trim();
                      final employeeId =
                          _profileCubit.state.user?.employeeId.toString() ?? '';
                      if (employeeId.isEmpty) return;
                      if (isUpdate) {
                        await _profileCubit.updateEmployeeExperienceDetails(
                          context: context,
                          employeeExperienceDetailsId:
                              experience.employeeExperienceDetailsId,
                          uniqueKey: experience.uniquekey,
                          employeeId: employeeId,
                          companyName: companyName,
                          role: role,
                          tenure: tenure,
                          index: index,
                        );
                      } else {
                        await _profileCubit.addEmployeeExperienceDetails(
                          context: context,
                          employeeId: employeeId,
                          companyName: companyName,
                          role: role,
                          tenure: tenure,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // <---- DELETE EMPLOYEE EXPERIENCE DETAILS ---->
  Future<void> _showPopupToDeleteEmployeeExperienceDetails(
    BuildContext context,
    EmployeeExperienceDetailsModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this experience?',
      'Deleting this experience will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _profileCubit.deleteEmployeeExperienceDetails(
        context: context,
        employeeExperienceDetailsId: obj.employeeExperienceDetailsId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  // <---- DELETE EMPLOYEE EXPERIENCE DETAILS ---->
  Future<void> _showPopupToSetMpin(UserModel user) async {
    DialogHelper.showCustomDialogue(
      context,
      title: "Set MPIN",
      childContent: Column(
        children: [
          Form(
            key: _mpinFormKey,
            child: CustomTextField(
              title: "For your security, please enter your 4-digit MPIN",
              hint: "Enter MPIN",
              textController: _setMPIN,
              keyboardType: TextInputType.number,
              inputFormatterList: [LengthLimitingTextInputFormatter(4)],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter MPIN';
                }
                return null;
              },
            ),
          ),
          verticalSpacing(),
          CustomButton(
            text: "Set",
            onPressed: () {
              if (_mpinFormKey.currentState?.validate() == true) {
                _profileCubit.sepMpin(
                  context: context,
                  pin: _setMPIN.text,
                  employeeId: user.employeeId,
                  uniqueKey: user.uniqueKey,
                );
              }
            },
          ),
        ],
      ),
    );
    _setMPIN.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
                ChipStyleTabBar(
                  controller: _tabController,
                  tabs: [
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
                      _buildOverviewTab(),
                      _buildEducationDetailsTab(),
                      _buildExperienceDetailsTab(),
                      _buildBranchAssociationTab(),
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

  // BUILD HEADER
  Widget _buildHeader(UserModel user, ProjectModel? project) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // AVATAR
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColor.primary,
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: AppTextStyle.ts24B(color: AppColor.white),
                ),
              ),

              // LIGHT BLACK OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.black.withValues(alpha: 0.25),
                  ),
                ),
              ),

              // EDIT ICON
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.lightBlue,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.edit, size: 14, color: AppColor.primary),
                ),
              ),
            ],
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
                verticalSpacing(height: 4),
                Text(
                  user.department.isNotEmpty ? user.department : '-',
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(height: 4),
                Text(
                  user.designation.isNotEmpty ? user.designation : '-',
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(height: 4),
                SizedBox(
                  width: 140,
                  child: CustomButton(
                    text: "Set MPIN",
                    onPressed: () {
                      _showPopupToSetMpin(user);
                    },
                    backgroundColor: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUILD INFO CARD
  Widget _buildInfoCard({
    required String title,
    required List<Map<String, String>> items,
    VoidCallback? onUpdateCallback,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: AppTextStyle.ts16SB())),
              // SHOW EDIT BUTTON ONLY IF CALLBACK IS PROVIDED
              if (onUpdateCallback != null)
                CustomIconButton.edit(onPressed: onUpdateCallback),
            ],
          ),
          verticalSpacing(height: 12),
          ..._buildInfoRows(items),
        ],
      ),
    );
  }

  // BUILD INFO ROWS
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

  // BUILD INFO ITEM
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

  // BUILD EMPLOYEE REPORTING CYCLE CARD
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
          const SizedBox(height: 16),

          // TIMELINE LIST
          Column(
            children: List.generate(employeeReportingCycleData.length, (index) {
              final employee = employeeReportingCycleData[index];
              final bool isLast =
                  index == employeeReportingCycleData.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIMELINE INDICATOR
                    Column(
                      children: [
                        // CIRCLE AVATAR
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColor.primary,
                          child: Text(
                            (employee['FullName'] ?? '')
                                .toString()
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // VERTICAL LINE
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // EMPLOYEE DETAILS
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _getDisplayValue(
                                      employee['FullName']?.toString(),
                                    ),
                                    style: AppTextStyle.ts14SB(),
                                  ),
                                ),
                                horizontalSpacing(),
                                if (employee['EmployeeCode'] != null &&
                                    employee['EmployeeCode']!.isNotEmpty)
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: Text(
                                      "(${employee['EmployeeCode'] ?? '-'})",
                                      style: AppTextStyle.ts12R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDisplayValue(
                                employee['Designation']?.toString(),
                              ),
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getDisplayValue(employee['EmailId']?.toString()),
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            if (employee['PersonalMobileNumber'] != null &&
                                employee['PersonalMobileNumber']!
                                    .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                _getDisplayValue(
                                  employee['PersonalMobileNumber']?.toString(),
                                ),
                                style: AppTextStyle.ts12R(color: AppColor.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // BUILD LOGOUT BUTTON
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: CustomButton(
        text: "Logout",
        leading: Icon(Icons.login, size: 18, color: AppColor.white),
        backgroundColor: AppColor.error,
        onPressed: () async {
          logOutUser(context);
        },
      ),
    );
  }

  // BUILD OVERVIEW TAB
  Widget _buildOverviewTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading == true && state.employeeMasterList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.employeeMasterList.isEmpty) {
          return Center(child: noDataWidget(message: "No Overview Data Found"));
        }
        final overview = state.employeeMasterList[0];
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpacing(),
              _buildInfoCard(
                title: 'Basic Details',
                items: [
                  {
                    'label': 'Full Name',
                    'value': overview.fullName,
                    'fullWidth': 'true',
                  },
                  {'label': 'Gender', 'value': overview.gender},
                  {'label': 'Marital Status', 'value': overview.maritalStatus},
                  {'label': 'Blood Group', 'value': overview.bloodGroup},
                  {
                    'label': 'Date of Birth',
                    'value':
                        overview.dateOfBirth != null
                            ? formatDateTimeAsDDMMMYYYY(overview.dateOfBirth!)
                            : '-',
                  },
                  {'label': 'Email ID', 'value': overview.emailId},
                  {
                    'label': 'Personal Mobile No.',
                    'value': overview.personalMobileNumber,
                  },
                  {
                    'label': 'Aadhaar Card Number',
                    'value': overview.aadharCardNumber,
                  },
                  {'label': 'PAN Number', 'value': overview.panCardNumber},
                  {
                    'label': 'Passport Number',
                    'value': overview.passportNumber,
                  },
                  {
                    'label': 'Driving / Licence Number',
                    'value': overview.drivingLicenceNumber,
                  },
                  {
                    'label': 'Voter Card Number',
                    'value': overview.voterCardNumber,
                  },

                  {
                    'label': 'Communication Address',
                    'value': overview.communicationAddress,
                    'fullWidth': 'true',
                  },
                  {
                    'label': 'Permanent Address',
                    'value': overview.permanentAddress,
                    'fullWidth': 'true',
                  },
                ],
                onUpdateCallback: () async {
                  goRouter.pushNamed(
                    AppRoutes.updateUserBasicDetails,
                    queryParameters: {
                      "updateUserBasicDetails": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          jsonEncode(overview.toJson()),
                        ),
                      ),
                    },
                  );
                },
              ),
              verticalSpacing(),
              _buildInfoCard(
                title: 'Address Information',
                items: [
                  {'label': 'Country', 'value': overview.countryName},
                  {'label': 'State', 'value': overview.stateName},
                  {'label': 'District', 'value': overview.districtName},
                  {'label': 'City', 'value': overview.cityName},
                ],
              ),
              verticalSpacing(),
              _buildInfoCard(
                title: 'Employee Information',
                items: [
                  {'label': 'Company Name', 'value': overview.companyName},
                  {'label': 'Branch', 'value': overview.branch},
                  {'label': 'Department', 'value': overview.department},
                  {'label': 'Designation', 'value': overview.designation},
                  {
                    'label': 'Joining Date',
                    'value':
                        overview.joiningDate != null
                            ? formatDateTimeAsDDMMMYYYY(overview.joiningDate!)
                            : "-",
                  },
                  {
                    'label': 'Reporting Person',
                    'value': overview.reportPersonName,
                  },
                  {'label': 'Employment Type', 'value': overview.employeeType},
                  {
                    'label': 'Office Number',
                    'value': overview.officeMobileNumber,
                  },
                  {
                    'label': 'Office E-mail ID',
                    'value': overview.officeEmailId,
                  },
                  {
                    'label': 'Probation Date',
                    'value':
                        overview.probationDate != null
                            ? formatDateTimeAsDDMMMYYYY(overview.probationDate!)
                            : "-",
                  },
                  {
                    'label': 'Id Card Issued Date',
                    'value':
                        overview.idCardIssuedDate != null
                            ? formatDateTimeAsDDMMMYYYY(
                              overview.idCardIssuedDate!,
                            )
                            : "-",
                  },
                ],
              ),
              verticalSpacing(),
              if (_hasBankDetails(overview))
                _buildInfoCard(
                  title: 'Bank Details',
                  items: [
                    {'label': 'Bank Name', 'value': overview.bankName},
                    {'label': 'Account Number', 'value': overview.accountNo},
                    {
                      'label': 'Bank Branch Name',
                      'value': overview.bankBranchName,
                    },
                    {'label': 'IFSC Code', 'value': overview.ifscCode},
                  ],
                ),
              verticalSpacing(),
              _buildInfoCard(
                title: 'Emergency Contact Details',
                items: [
                  {
                    'label': 'Relation to Emergency Contact',
                    'value': overview.emergencyContactPersonRelationship,
                    'fullWidth': "true",
                  },
                  {
                    'label': 'Emergency Contact Number',
                    'value': overview.emergencyMobileNumber,
                    'fullWidth': "true",
                  },
                ],
              ),
              if (_hasBankDetails(overview)) verticalSpacing(),
              if (overview.employeeReportingCycleData.isNotEmpty)
                _buildEmployeeReportingCycleCard(
                  overview.employeeReportingCycleData,
                ),
              verticalSpacing(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: actionCardWidget(
                  createdBy: overview.createdBy,
                  createdDate: overview.createdDate,
                  modifiedBy: overview.modifiedBy,
                  modifiedDate: overview.modifiedDate,
                ),
              ),
              if (overview.employeeReportingCycleData.isNotEmpty)
                verticalSpacing(),
              _buildLogoutButton(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Version: ",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  Text(version, style: AppTextStyle.ts12M()),
                ],
              ),
              verticalSpacing(height: 20),
            ],
          ),
        );
      },
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
      return Center(child: noDataWidget(message: "No Project Found"));
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

  // BUILD ASSETS TAB
  Widget _buildAssetTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading == true && state.assetMappingList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.assetMappingList.isEmpty) {
          return Center(child: noDataWidget(message: "No Assets Found"));
        }

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          child: _buildInfoItem("Asset Code", asset.assetCode),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Asset Brand",
                            asset.assetBrand,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Asset Model",
                            asset.assetModel,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem("Asset Type", asset.assetType),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Serial Number",
                            asset.serialNumber,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(child: _buildInfoItem("Status", asset.status)),
                      ],
                    ),
                    verticalSpacing(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // BUILD SHIFT POLICY TAB
  Widget _buildShiftPolicyTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading == true && state.shiftManagementList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.shiftManagementList.isEmpty) {
          return Center(child: noDataWidget(message: "No Shift Policy Found"));
        }

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    Text("Shift Policy Details", style: AppTextStyle.ts14SB()),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Employee Name",
                            shiftManagement.employeeName,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Department Name",
                            shiftManagement.departmentName,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Shift Type",
                            shiftManagement.shiftName,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Shift Code",
                            shiftManagement.shiftCode,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Shift Begin Time",
                            shiftManagement.shiftBeginTime,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Shift End Time",
                            shiftManagement.shiftEndTime,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Shift Duration Time",
                            shiftManagement.shiftDurationTime,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Shift Work Duration",
                            shiftManagement.shiftWorkDurationTime,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "First Half Up To",
                            shiftManagement.firstHalfUpTo,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Calculate Absent if working hours less than",
                            shiftManagement.absentWorkingHours,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Mark Half Day if Outtime After",
                            shiftManagement.halfDayOutTimeBefore,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Mark Half Day if Intime After",
                            shiftManagement.halfDayInTimeAfter,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Break Begin Time",
                            shiftManagement.breakBeginTime,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Break End Time",
                            shiftManagement.breakEndTime,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Break Duration Time",
                            shiftManagement.breakDurationTime,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            "Grace Time In Minutes",
                            shiftManagement.graceTime,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Remark",
                            shiftManagement.remarks,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // BUILD WEEK OFF POLICY TAB
  Widget _buildWeekOffPolicyTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.isLoading == true && state.weekOffMappingList.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.weekOffMappingList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Week Off Policy Found"),
          );
        }

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Employee Name",
                            weekOffMapping.employeeName,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Department Name",
                            weekOffMapping.departmentName,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Week Off Policy Name",
                            weekOffMapping.weekOffPolicyName,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Week Off Policy Code",
                            weekOffMapping.weekOffPolicyCode,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Week Days",
                            weekOffMapping.weekDays.toString(),
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Week Days Starts On",
                            weekOffMapping.weekDaysStartsOn,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Week Off",
                            weekOffMapping.weeklyOff,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Week Off 2",
                            weekOffMapping.weeklyOff2,
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            "Not Applicable Months",
                            weekOffMapping.notApplicableForMonths,
                          ),
                        ),
                        horizontalSpacing(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            "Week Off 2 Type",
                            weekOffMapping.weeklyOff2Type,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // EDUCATION DETAILS TAB
  Widget _buildEducationDetailsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Add Education", style: AppTextStyle.ts14SB()),
              CustomIconButton(
                onPressed: () {
                  _showBottomSheetToAddUpdateEducation(context);
                },
                icon: Icon(Icons.add, size: 16, color: AppColor.darkGreen),
                backgroundColor: AppColor.lightGreen,
              ),
            ],
          ),
          verticalSpacing(height: 15),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
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
                    child: noDataWidget(message: "No education details found"),
                  );
                }
                return ListView.builder(
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
                            children: [
                              buildColumnTitleValue(
                                title: "Qualification",
                                value: education.qualification,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "School / College Name",
                                value: education.collegeName,
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildColumnTitleValue(
                                title: "Passing Year",
                                value: education.passing,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () {
                                      _showBottomSheetToAddUpdateEducation(
                                        context,
                                        education: education,
                                        index: index,
                                      );
                                    },
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    onPressed: () {
                                      _showPopupToDeleteEmployeeEducationDetails(
                                        context,
                                        education,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
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

  // EXPERIENCE DETAILS TAB
  Widget _buildExperienceDetailsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Add Experience", style: AppTextStyle.ts14SB()),
              CustomIconButton(
                onPressed: () {
                  _showBottomSheetToAddUpdateExperience(context);
                },
                icon: Icon(Icons.add, size: 16, color: AppColor.darkGreen),
                backgroundColor: AppColor.lightGreen,
              ),
            ],
          ),
          verticalSpacing(height: 15),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
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
                    child: noDataWidget(message: "No experience details found"),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.employeeExperienceDetailsList.length,
                  itemBuilder: (_, index) {
                    final experience =
                        state.employeeExperienceDetailsList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(16),
                      decoration: commonCardDecoration(),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            children: [
                              buildColumnTitleValue(
                                title: "Company",
                                value: experience.companyName,
                              ),
                            ],
                          ),
                          Row(
                            children: [
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () {
                                      _showBottomSheetToAddUpdateExperience(
                                        context,
                                        experience: experience,
                                        index: index,
                                      );
                                    },
                                  ),
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    onPressed: () {
                                      _showPopupToDeleteEmployeeExperienceDetails(
                                        context,
                                        experience,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
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

  // BRANCH ASSOCIATION TAB
  Widget _buildBranchAssociationTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
            child: noDataWidget(
              message: "No Branch Associations Details Found",
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: BlocBuilder<ProfileCubit, ProfileState>(
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

                                  await _profileCubit.updateEmployeeDocument(
                                    context: context,
                                    employeeDocumentId: doc.employeeDocumentId,
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
                                    deletedFileList: removeUrl,
                                  );

                                  await _profileCubit.updateEmployeeDocument(
                                    context: context,
                                    employeeDocumentId: doc.employeeDocumentId,
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
}
