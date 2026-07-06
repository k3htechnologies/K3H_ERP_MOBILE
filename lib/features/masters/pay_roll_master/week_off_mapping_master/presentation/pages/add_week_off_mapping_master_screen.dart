// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddWeekOffMappingMasterScreen extends StatefulWidget {
  final WeekOffMappingModel? weekOffMappingMasterModel;
  final int index;
  const AddWeekOffMappingMasterScreen({
    super.key,
    required this.weekOffMappingMasterModel,
    this.index = 0,
  });

  @override
  State<AddWeekOffMappingMasterScreen> createState() =>
      _AddWeekOffMappingMasterScreenState();
}

class _AddWeekOffMappingMasterScreenState
    extends State<AddWeekOffMappingMasterScreen> {
  //CUBIT
  late WeekOffMappingMasterCubit _weekOffMappingMasterCubit;

  // EMPLOYEE REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedWeekOff = [];
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedDepartmentNotifier;

  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;

  //EDIT MODE
  bool get _isEditMode => widget.weekOffMappingMasterModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .addWeekOffMappingMaster] ??
        AuthorizationModel();
    _weekOffMappingMasterCubit = context.read<WeekOffMappingMasterCubit>();

    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

    _selectedDepartmentNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);

    if (_isEditMode) {
      _populateFormFields(widget.weekOffMappingMasterModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedEmployeeNotifier.dispose();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(WeekOffMappingModel weekOffMapping) {
    if (weekOffMapping.employeeId.isNotEmpty) {
      final employeeId = int.parse(weekOffMapping.employeeId);

      _selectedEmployeeNotifier.value = [
        {
          'zAttributesId': employeeId,
          'DisplayName': weekOffMapping.employeeName,
        },
      ];

      _fetchEmployeeDetailsForEdit(employeeId);
    }

    _selectedWeekOff = [
      {
        'zAttributesId': weekOffMapping.weekOffPolicyMasterId,
        'DisplayName': weekOffMapping.weekOffPolicyName,
      },
    ];
    if (weekOffMapping.departmentMasterId.isNotEmpty) {
      _selectedDepartmentNotifier.value = [
        {
          'zAttributesId': weekOffMapping.departmentMasterId,
          'DisplayName': weekOffMapping.departmentName,
        },
      ];
    }

    if (weekOffMapping.employeeId.isNotEmpty) {
      _weekOffMappingMasterCubit.onSelectedOptionChanged("Employee");
    } else {
      _weekOffMappingMasterCubit.onSelectedOptionChanged("Department");
    }
  }

  // FETCH EMPLOYEE
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
          'emailId': employee.emailId,
          'personalMobileNumber': employee.personalMobileNumber,
        },
      ];
    });
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWeekOff.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select a week off');
      return;
    }

    if (_isEditMode && widget.weekOffMappingMasterModel != null) {
      _weekOffMappingMasterCubit.updateWeekOffMapping(
        index: widget.index,
        context: context,
        uniqueKey: widget.weekOffMappingMasterModel!.uniquekey,
        weekOffMappingMasterId:
            widget.weekOffMappingMasterModel!.weekOffPolicyMasterMappingId,
        weekOffMasterId: _selectedWeekOff.first['zAttributesId'] as int,
        employeeId:
            _selectedEmployeeNotifier.value.isEmpty
                ? null
                : _selectedEmployeeNotifier.value.first['zAttributesId']
                    .toString(),
        departmentMasterId:
            _selectedDepartmentNotifier.value.isEmpty
                ? null
                : _selectedDepartmentNotifier.value.first['zAttributesId']
                    .toString(),
      );
    } else {
      _weekOffMappingMasterCubit.addWeekOffMapping(
        context: context,
        weekOffMasterId: _selectedWeekOff.first['zAttributesId'] as int,
        employeeId:
            _selectedEmployeeNotifier.value.isEmpty
                ? null
                : _selectedEmployeeNotifier.value.first['zAttributesId']
                    .toString(),
        departmentMasterId:
            _selectedDepartmentNotifier.value.isEmpty
                ? null
                : _selectedDepartmentNotifier.value.first['zAttributesId']
                    .toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Week Off Mapping Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? "Update Week Off Mapping"
                    : "Add Week Off Mapping",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: BlocBuilder<
                  WeekOffMappingMasterCubit,
                  WeekOffMappingMasterState
                >(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomMultipleSelectPopup(
                          title: 'Week Off Policy Name',
                          hintText: "Select Week Off Policy Name",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: _selectedWeekOff,
                          dataList: [],
                          onSelected: (value) {
                            _selectedWeekOff = value;
                          },
                          dataFetchCallBack:
                              _weekOffMappingMasterCubit.fetchWeekOff,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Week off Policy Name is required";
                            }
                            return null;
                          },
                        ),
                        verticalSpacing(),
                        Text("Mapping",style: AppTextStyle.ts14R(),),
                        Row(
                          children: [
                            Radio<String>(
                              value: state.options[0],
                              groupValue: state.selectedOption,
                              onChanged: (value) {
                                _weekOffMappingMasterCubit
                                    .onSelectedOptionChanged(value!);
                                _selectedEmployeeNotifier.value = [];
                                _selectedDepartmentNotifier.value = [];
                              },
                            ),
                            Text("Employee", style: AppTextStyle.ts14R()),
                            horizontalSpacing(),
                            Radio<String>(
                              value: state.options[1],
                              groupValue: state.selectedOption,
                              onChanged: (value) {
                                _weekOffMappingMasterCubit
                                    .onSelectedOptionChanged(value!);
                                _selectedEmployeeNotifier.value = [];
                                _selectedDepartmentNotifier.value = [];
                              },
                            ),
                            Text("Department", style: AppTextStyle.ts14R()),
                          ],
                        ),
                        verticalSpacing(),
                        Visibility(
                          visible: state.selectedOption == state.options[0],
                          child: ValueListenableBuilder<
                            List<Map<String, dynamic>>
                          >(
                            valueListenable: _selectedEmployeeNotifier,
                            builder: (context, selectedEmployee, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomMultipleSelectPopup(
                                    title: 'Employee',
                                    hintText: "Select Employee",
                                    isRequired: true,
                                    isMultiSelect: false,
                                    initialValue: selectedEmployee,
                                    dataList: [],
                                    onSelected: (value) {
                                      _selectedEmployeeNotifier.value = value;
                                    },
                                    dataFetchCallBack:
                                        _weekOffMappingMasterCubit
                                            .fetchEmployees,
                                    validator: (value) {
                                      if ((state.selectedOption.toLowerCase() ==
                                              state.options[0].toLowerCase()) &&
                                          (value == null || value.isEmpty)) {
                                        return "Employee is required";
                                      }
                                      return null;
                                    },
                                  ),

                                  if (selectedEmployee.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColor.lightBlue,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        spacing: 10,
                                        children: [
                                          Row(
                                            spacing: 10,
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
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Email ID",
                                                value:
                                                    selectedEmployee
                                                        .first["emailId"] ??
                                                    '',
                                              ),
                                              buildColumnTitleValue(
                                                title: "Personal Mobile Number",
                                                value:
                                                    selectedEmployee
                                                        .first["personalMobileNumber"] ??
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
                        ),
                        Visibility(
                          visible: state.selectedOption == state.options[1],

                          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                            valueListenable: _selectedDepartmentNotifier,
                            builder: (context, selectedDepartment, _) {
                              return Column(
                                children: [
                                  CustomMultipleSelectPopup(
                                    title: 'Department',
                                    hintText: "Select Department",
                                    isRequired: true,
                                    isMultiSelect: false,
                                    initialValue: selectedDepartment,
                                    dataList: [],
                                    onSelected: (value) {
                                      _selectedDepartmentNotifier.value = value;
                                    },
                                    dataFetchCallBack:
                                    _weekOffMappingMasterCubit.fetchDepartment,
                                    validator: (value) {
                                      if ((state.selectedOption.toLowerCase() ==
                                          state.options[1].toLowerCase()) &&
                                          (value == null || value.isEmpty)) {
                                        return "Department is required";
                                      }
                                      return null;
                                    },
                                  ),

                                  if (selectedDepartment.isNotEmpty) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColor.lightBlue,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColor.primary,
                                          width: .5,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "This week-off policy will be applied to ",
                                              style: AppTextStyle.ts12R(),
                                            ),
                                            TextSpan(
                                              text: "all employees in this department.",
                                              style: AppTextStyle.ts12SB(),
                                            ),
                                          ],
                                        ),
                                      )
                                    ),
                                  ],
                                ],
                              );
                            },
                          )
                        ),
                      ],
                    );
                  },
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
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
