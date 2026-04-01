import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

enum SelectionType { employee, department }

class AddShiftMappingMasterScreen extends StatefulWidget {
  final ShiftMappingModel? shiftMappingModel;
  final int index;
  const AddShiftMappingMasterScreen({
    super.key,
    required this.shiftMappingModel,
    this.index = 0,
  });

  @override
  State<AddShiftMappingMasterScreen> createState() =>
      _AddShiftMappingMasterScreenState();
}

class _AddShiftMappingMasterScreenState
    extends State<AddShiftMappingMasterScreen> {
  //CUBIT
  late ShiftMappingMasterCubit _shiftMappingMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // EMPLOYEE REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
  serviceLocator<EmployeeMasterRepository>();

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedShift = [];
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedDepartmentNotifier;

  //EDIT MODE
  bool get _isEditMode => widget.shiftMappingModel != null;

  // SELECTION TYPE
  late final ValueNotifier<SelectionType> _selectionTypeNotifier;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addShiftMappingMaster] ??
        AuthorizationModel();
    _selectedEmployeeNotifier = ValueNotifier([]);
    _selectedDepartmentNotifier = ValueNotifier([]);
    _selectionTypeNotifier = ValueNotifier<SelectionType>(
      SelectionType.department,
    );
    _shiftMappingMasterCubit = context.read<ShiftMappingMasterCubit>();
    if (_isEditMode) {
      _populateFormFields(widget.shiftMappingModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectionTypeNotifier.dispose();
    _selectedEmployeeNotifier.dispose();
    _selectedDepartmentNotifier.dispose();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(ShiftMappingModel shiftMapping) {
    if (shiftMapping.employeeId.isNotEmpty) {
      final employeeId = int.parse(shiftMapping.employeeId);

      _selectedEmployeeNotifier.value = [
        {
          'zAttributesId': employeeId,
          'DisplayName': shiftMapping.employeeName,
        },
      ];

      _fetchEmployeeDetailsForEdit(employeeId);

      _selectionTypeNotifier.value = SelectionType.employee;
    }

    _selectedShift = [
      {
        'zAttributesId': shiftMapping.shiftManagementMasterId,
        'DisplayName': shiftMapping.shiftName,
      },
    ];

    if (shiftMapping.departmentMasterId.isNotEmpty) {
      _selectedDepartmentNotifier.value = [
        {
          'zAttributesId': shiftMapping.departmentMasterId,
          'DisplayName': shiftMapping.departmentName,
        },
      ];

      if (shiftMapping.employeeId.isEmpty) {
        _selectionTypeNotifier.value = SelectionType.department;
      }
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode && widget.shiftMappingModel != null) {
      _shiftMappingMasterCubit.updateShiftMapping(
        index: widget.index,
        context: context,
        uniqueKey: widget.shiftMappingModel!.uniquekey,
        shiftMappingMasterId:
            widget.shiftMappingModel!.shiftManagementMasterMappingId,
        shiftMasterId: _selectedShift.first['zAttributesId'] as int,
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
      _shiftMappingMasterCubit.addShiftMapping(
        context: context,
        employeeId:
            _selectedEmployeeNotifier.value.isEmpty
                ? null
                : _selectedEmployeeNotifier.value.first['zAttributesId']
                    .toString(),
        shiftMasterId: _selectedShift.first['zAttributesId'] as int,
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
        screenTitle: "Shift Mapping Master",
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
                _isEditMode ? "Update Shift Mapping" : "Add Shift Mapping",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultipleSelectPopup(
                      title: 'Shift Name',
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectedShift,
                      dataList: [],
                      onSelected: (value) {
                        _selectedShift = value;
                      },
                      dataFetchCallBack: _shiftMappingMasterCubit.fetchShift,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Shift Name is required";
                        }
                        return null;
                      },
                    ),

                    ValueListenableBuilder<SelectionType>(
                      valueListenable: _selectionTypeNotifier,
                      builder: (context, selectionType, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Select Type", style: AppTextStyle.ts14M()),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Radio<SelectionType>(
                                      value: SelectionType.department,
                                      // ignore: deprecated_member_use
                                      groupValue: selectionType,
                                      // ignore: deprecated_member_use
                                      onChanged: (value) {
                                        _selectionTypeNotifier.value = value!;

                                        _selectedEmployeeNotifier.value = [];
                                        _selectedDepartmentNotifier.value = [];

                                        _formKey.currentState?.reset();
                                      },
                                    ),
                                    Text(
                                      "Department",
                                      style: AppTextStyle.ts14M(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio<SelectionType>(
                                      value: SelectionType.employee,
                                      // ignore: deprecated_member_use
                                      groupValue: selectionType,
                                      // ignore: deprecated_member_use
                                      onChanged: (value) {
                                        _selectionTypeNotifier.value = value!;

                                        _selectedEmployeeNotifier.value = [];
                                        _selectedDepartmentNotifier.value = [];

                                        _formKey.currentState?.reset();
                                      },
                                    ),
                                    Text(
                                      "Employee",
                                      style: AppTextStyle.ts14M(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            verticalSpacing(),
                          ],
                        );
                      },
                    ),

                    ValueListenableBuilder<SelectionType>(
                      valueListenable: _selectionTypeNotifier,
                      builder: (context, selectionType, _) {
                        if (selectionType == SelectionType.employee) {
                          return ValueListenableBuilder<
                            List<Map<String, dynamic>>
                          >(
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
                                    dataList: [],
                                    onSelected: (value) {
                                      _selectedEmployeeNotifier.value = value;
                                    },
                                    dataFetchCallBack:
                                        _shiftMappingMasterCubit.fetchEmployees,
                                  ),

                                  if (selectedEmployee.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColor.lightBlue,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Row(
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
                          );
                        } else {
                          return ValueListenableBuilder<
                            List<Map<String, dynamic>>
                          >(
                            valueListenable: _selectedDepartmentNotifier,
                            builder: (context, selectedDepartment, _) {
                              return Column(
                                children: [
                                  CustomMultipleSelectPopup(
                                    title: 'Department',
                                    isRequired: true,
                                    isMultiSelect: false,
                                    initialValue: selectedDepartment,
                                    dataList: [],
                                    onSelected: (value) {
                                      _selectedDepartmentNotifier.value = value;
                                    },
                                    dataFetchCallBack:
                                        _shiftMappingMasterCubit
                                            .fetchDepartment,
                                  ),

                                  if (selectedDepartment.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        color: AppColor.lightBlue,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColor.primary,
                                          width: .5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  "This shift will be applied to ",
                                              style: AppTextStyle.ts12R(),
                                            ),
                                            TextSpan(
                                              text:
                                                  "all employees in this department.",
                                              style: AppTextStyle.ts12SB(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          );
                        }
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
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
