import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/presentation/cubit/branch_association_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/model/branch_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_master/data/repository/branch_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';

class AddBranchAssociationMasterScreen extends StatefulWidget {
  final BranchAssociationModel? branchAssociation;
  final int index;
  const AddBranchAssociationMasterScreen({
    super.key,
    this.branchAssociation,
    this.index = 0,
  });

  @override
  State<AddBranchAssociationMasterScreen> createState() =>
      _AddBranchAssociationMasterScreenState();
}

class _AddBranchAssociationMasterScreenState
    extends State<AddBranchAssociationMasterScreen> {
  // CUBIT
  late BranchAssociationMasterCubit _branchAssociationMasterCubit;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final BranchMasterRepository _branchMasterRepository =
      serviceLocator<BranchMasterRepository>();

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // DROPDOWN SELECTIONS
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedBranchNotifier;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  bool get _isEditMode => widget.branchAssociation != null;

  @override
  void initState() {
    super.initState();
    _branchAssociationMasterCubit =
        context.read<BranchAssociationMasterCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedBranchNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    if (_isEditMode && widget.branchAssociation != null) {
      _populateFormFields(widget.branchAssociation!);
    }
  }

  @override
  void dispose() {
    _selectedEmployeeNotifier.dispose();
    _selectedBranchNotifier.dispose();
    super.dispose();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(BranchAssociationModel branchAssociation) {
    _selectedEmployeeNotifier.value = [
      {
        'zAttributesId': branchAssociation.employeeId,
        'DisplayName': branchAssociation.employeeName,
      },
    ];
    _selectedBranchNotifier.value = [
      {
        'zAttributesId': int.parse(branchAssociation.branchMasterId),
        'DisplayName': branchAssociation.branchName,
      },
    ];
    _fetchEmployeeDetailsForEdit(branchAssociation.employeeId);
  }

  // FETCH EMPLOYEE DETAILS FOR EDIT
  Future<void> _fetchEmployeeDetailsForEdit(int employeeId) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {'EmployeeId': employeeId},
    );
    result.fold((_) {}, (response) {
      final employees = response['data'] as List<UserModel>? ?? [];
      if (employees.isEmpty) return;
      final employee = employees.first;
      if (!mounted) return;
      _selectedEmployeeNotifier.value = [
        {
          'zAttributesId': employee.employeeId,
          'DisplayName': employee.fullName,
          'employeeCode': employee.employeeCode,
          'department': employee.department,
          'designation': employee.designation,
          'branch': employee.branch,
          'reportingPerson': employee.reportPersonName,
          'email': employee.emailId,
          'personalNumber': employee.personalMobileNumber,
        },
      ];
    });
  }

  // FETCH EMPLOYEES
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"EmployeeName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                  "employeeCode": employee.employeeCode,
                  "department": employee.department,
                  "designation": employee.designation,
                  "branch": employee.branch,
                  "reportingPerson": employee.reportPersonName,
                  "email": employee.emailId,
                  "personalNumber": employee.personalMobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final selectedEmployee = _selectedEmployeeNotifier.value;
    final selectedBranch = _selectedBranchNotifier.value;
    if (selectedEmployee.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an employee');
      return;
    }
    if (selectedBranch.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select a branch');
      return;
    }
    final employeeId = selectedEmployee.first['zAttributesId'] as int;
    final branchMasterId =
        selectedBranch.first['zAttributesId'] is int
            ? selectedBranch.first['zAttributesId'] as int
            : int.parse(selectedBranch.first['zAttributesId'].toString());

    if (_isEditMode && widget.branchAssociation != null) {
      _branchAssociationMasterCubit.updateBranchAssociation(
        index: widget.index,
        context: context,
        branchAssociationsId: widget.branchAssociation!.branchAssociationsId,
        employeeId: employeeId,
        branchMasterId: branchMasterId,
        uniqueKey: widget.branchAssociation!.uniquekey,
      );
    } else {
      _branchAssociationMasterCubit.addBranchAssociation(
        context: context,
        employeeId: employeeId,
        branchMasterId: branchMasterId,
      );
    }
  }

  // FETCH BRANCH
  Future<Map<String, dynamic>> _fetchBranch(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _branchMasterRepository.getBranchList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"BranchName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final assets = response['data'] as List<BranchMasterModel>;

        return {
          "itemList":
              assets.map((asset) {
                return {
                  "zAttributesId": asset.branchMasterId,
                  "DisplayName": asset.branchName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Branch Association Master",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                _isEditMode
                    ? "Update Branch Association"
                    : "Add Branch Association",
                style: AppTextStyle.ts16SB(),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  spacing: 10,
                  children: [
                    // BRANCH SELECT
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedBranchNotifier,
                      builder: (context, selectedBranch, _) {
                        return CustomMultipleSelectPopup(
                          title: 'Branch',
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedBranch,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedBranchNotifier.value = value;
                          },
                          dataFetchCallBack: _fetchBranch,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Branch is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    // EMPLOYEE SELECT + CARD
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedEmployeeNotifier,
                      builder: (context, selectedEmployee, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Employee',
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedEmployee,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedEmployeeNotifier.value = value;
                              },
                              dataFetchCallBack: _fetchEmployees,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Employee is required";
                                }
                                return null;
                              },
                            ),
                            if (selectedEmployee.isNotEmpty) ...[
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColor.lightBlue),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Department",
                                          value:
                                              selectedEmployee
                                                  .first["department"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Designation",
                                          value:
                                              selectedEmployee
                                                  .first["designation"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Branch",
                                          value:
                                              selectedEmployee
                                                  .first["branch"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Reporting Person",
                                          value:
                                              selectedEmployee
                                                  .first["reportingPerson"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildColumnTitleValue(
                                          title: "Email Id",
                                          value:
                                              selectedEmployee.first["email"] ??
                                              '',
                                        ),
                                        buildColumnTitleValue(
                                          title: "Personal Mobile Number",
                                          value:
                                              selectedEmployee
                                                  .first["personalNumber"] ??
                                              '',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text:
                _isEditMode
                    ? "Update Branch Association"
                    : "Add Branch Association",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
