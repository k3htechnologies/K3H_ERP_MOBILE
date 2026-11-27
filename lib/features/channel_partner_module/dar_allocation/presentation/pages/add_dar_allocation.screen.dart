import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/model/dar_allocation.model.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/presentation/cubit/dar_allocation_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_setup/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDarAllocationScreen extends StatefulWidget {
  final DarAllocationModel? darAllocationModel;
  final int? index;
  const AddDarAllocationScreen({
    super.key,
    this.darAllocationModel,
    this.index = 0,
  });

  @override
  State<AddDarAllocationScreen> createState() => _AddDarAllocationScreenState();
}

class _AddDarAllocationScreenState extends State<AddDarAllocationScreen> {
  // CUBIT
  late DarAllocationCubit _darAllocationCubit;
  // EDIT MODE
  bool get _isEditMode => widget.darAllocationModel != null;

  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;

  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  List<Map<String, dynamic>> _selectedLocations = [];

  String get selectedVillages => _selectedLocations
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _darAllocationCubit = context.read<DarAllocationCubit>();
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    if (_isEditMode) {
      _prefillDarAllocation(widget.darAllocationModel!);
    }
  }

  @override
  void dispose() {
    _selectedEmployeeNotifier.dispose();
    super.dispose();
  }

  Future<void> _prefillDarAllocation(DarAllocationModel model) async {
    final villageIds =
        model.villageMasterId
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final villageNames =
        model.villageName
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    final locationCount =
        villageIds.length < villageNames.length
            ? villageIds.length
            : villageNames.length;

    _selectedLocations = List.generate(locationCount, (index) {
      return {
        'zAttributesId': villageIds[index],
        'DisplayName': villageNames[index],
      };
    });
    _selectedEmployeeNotifier.value = [
      {
        'zAttributesId': model.employeeId,
        'DisplayName': model.employeeName,
        'department': '-',
        'designation': '-',
        'branch': '-',
        'reportingPerson': '-',
        'email': '-',
        'personalNumber': '-',
        'joiningDate': null,
      },
    ];

    await _fetchEmployeeDetailsForEdit(model.employeeId);
  }

  // FETCH EMPLOYEE
  Future<void> _fetchEmployeeDetailsForEdit(int employeeId) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 1,
      queryParams: {"isCheckPermission": false, 'EmployeeId': employeeId},
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
          "joiningDate": employee.joiningDate,
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
      pageSize: 20,
      queryParams: {
        "IsCheckPermission": false,
        "DepartmentName": "Sales",
        if (value != null && value.isNotEmpty) "EmployeeName": value,
      },
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
                  "department": employee.department,
                  "designation": employee.designation,
                  "branch": employee.branch,
                  "reportingPerson": employee.reportPersonName,
                  "email": employee.emailId,
                  "personalNumber": employee.personalMobileNumber,
                  "joiningDate": employee.joiningDate,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEmployeeNotifier.value.isEmpty) return;
    if (_selectedLocations.isEmpty) return;

    final selectedEmployee = _selectedEmployeeNotifier.value.first;

    final employeeId = int.parse(selectedEmployee['zAttributesId'].toString());

    if (_isEditMode) {
      final darAllocation = widget.darAllocationModel!;

      _darAllocationCubit.updateDarAllocation(
        context,
        darAllocationId: darAllocation.darAllocationId,
        uniquekey: darAllocation.uniquekey,
        employeeId: employeeId,
        villageMasterId: selectedVillages,
        index: widget.index!,
      );
    } else {
      _darAllocationCubit.addDarAllocation(
        context,
        employeeId: employeeId,
        villageMasterId: selectedVillages,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "DAR Allocation",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update DAR Allocation" : "Add DAR Allocation",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _selectedEmployeeNotifier,
                      builder: (context, selectedEmployee, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: 'Employee Name',
                              hintText: "Select Employee Name",

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
                                  return "Employee Name is required.";
                                }
                                return null;
                              },
                            ),
                            if (selectedEmployee.isNotEmpty) ...[
                              infoCard([
                                {
                                  "title": "Department",
                                  "value": selectedEmployee.first["department"],
                                },
                                {
                                  "title": "Designation",
                                  "value":
                                      selectedEmployee.first["designation"],
                                },
                                {
                                  "title": "Branch",
                                  "value": selectedEmployee.first["branch"],
                                },
                                {
                                  "title": "Reporting Person",
                                  "value":
                                      selectedEmployee.first["reportingPerson"],
                                },
                                {
                                  "title": "E-Mail ID",
                                  "value": selectedEmployee.first["email"],
                                  "widget": CustomClickToContactText(
                                    value: selectedEmployee.first["email"],
                                    type: ContactType.email,
                                  ),
                                },
                                {
                                  "title": "Mobile Number",
                                  "value":
                                      selectedEmployee.first["personalNumber"],
                                  "widget": CustomClickToContactText(
                                    value:
                                        selectedEmployee
                                            .first["personalNumber"],
                                    type: ContactType.phone,
                                  ),
                                },
                              ]),
                            ],
                          ],
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Location",
                      hintText: "Select Location",
                      isRequired: true,
                      isMultiSelect: true,
                      initialValue: _selectedLocations,
                      dataList: const [],
                      dataFetchCallBack: _darAllocationCubit.fetchVillages,
                      onSelected: (value) => _selectedLocations = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Location is required.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
