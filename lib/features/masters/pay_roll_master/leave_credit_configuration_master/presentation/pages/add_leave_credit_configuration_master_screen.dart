import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/model/department.model.dart';
import 'package:k3h_erp_app/features/masters/department_master/data/repository/department_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/data/model/leave_credit_configuration_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_credit_configuration_master/presentation/cubit/leave_credit_configuration_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLeaveCreditConfigurationMasterScreen extends StatefulWidget {
  final LeaveCreditConfigurationMasterModel?
  leaveCreditConfigurationMasterModel;
  final int index;
  const AddLeaveCreditConfigurationMasterScreen({
    super.key,
    this.leaveCreditConfigurationMasterModel,
    this.index = 0,
  });

  @override
  State<AddLeaveCreditConfigurationMasterScreen> createState() =>
      _AddLeaveCreditConfigurationMasterScreenState();
}

class _AddLeaveCreditConfigurationMasterScreenState
    extends State<AddLeaveCreditConfigurationMasterScreen> {
  // CUBIT
  late LeaveCreditConfigurationMasterCubit _leaveCreditConfigurationMasterCubit;

  // DEPARTMENT REPOSITORY
  final DepartmentMasterRepository _departmentMasterRepository =
      serviceLocator<DepartmentMasterRepository>();

  // DESECTINATION REPOSITORY
  final DesignationMasterRepository _designationMasterRepository =
      serviceLocator<DesignationMasterRepository>();

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //EDIT MODE
  bool get _isEditMode => widget.leaveCreditConfigurationMasterModel != null;

  // STATIC LEAVE PERIOD LIST
  List<Map<String, dynamic>> leavePeriodList = [
    {"zAttributesId": -1, "DisplayName": "Select Leave Period"},
    {"zAttributesId": 1, "DisplayName": "Yearly"},
    {"zAttributesId": 2, "DisplayName": "Monthly"},
  ];

  // DROPDOWN VARIABLE
  Map<String, dynamic>? selectedLeavePeriod;

  // DATE VARIABLES
  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier(null);

  // DEPARTMENT VARIABLE
  final ValueNotifier<List<Map<String, dynamic>>> _selectedDepartmentNotifier =
      ValueNotifier([]);

  // DEPARTMENT VARIABLE
  final ValueNotifier<List<Map<String, dynamic>>> _selectedDesignationNotifier =
      ValueNotifier([]);

  // LOCAL LEAVE BALANCE TYPE LIST
  final ValueNotifier<List<LeaveBalanceType>> _leaveBalanceTypeListNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _leaveCreditConfigurationMasterCubit =
        context.read<LeaveCreditConfigurationMasterCubit>();
    selectedLeavePeriod = leavePeriodList.first;

    if (_isEditMode && widget.leaveCreditConfigurationMasterModel != null) {
      final model = widget.leaveCreditConfigurationMasterModel!;

      // Set leave period
      selectedLeavePeriod = leavePeriodList.firstWhere(
        (element) => element['DisplayName'] == model.leavePeriodMode,
        orElse: () => leavePeriodList.first,
      );

      _startDateNotifier.value = model.financialYearStartDate;
      _endDateNotifier.value = model.financialYearEndDate;

      _selectedDepartmentNotifier.value = [
        {
          "zAttributesId": model.departmentMasterId,
          "DisplayName": model.departmentName,
        },
      ];

      if ((model.designationId).isNotEmpty && model.designationId != "0") {
        final designationIds = model.designationId.split(',');
        final designationNames = model.designationName.split(',');

        _selectedDesignationNotifier.value = List.generate(
          designationIds.length,
          (index) => {
            "zAttributesId": int.tryParse(designationIds[index].trim()) ?? 0,
            "DisplayName":
                designationNames.length > index
                    ? designationNames[index].trim()
                    : "",
          },
        );
      } else {
        _selectedDesignationNotifier.value = [];
      }

      _leaveBalanceTypeListNotifier.value = List.from(model.leaveBalanceType);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _leaveBalanceTypeListNotifier.dispose();
  }

  // FETCH DEPARTMENT
  Future<Map<String, dynamic>> _fetchDepartment(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _departmentMasterRepository.getDepartmentList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"DepartmentName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final departments = response['data'] as List<DepartmentModel>;

        return {
          "itemList":
              departments.map((department) {
                return {
                  "zAttributesId": department.departmentMasterId,
                  "DisplayName": department.departmentName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // FETCH DESIGNATION
  Future<Map<String, dynamic>> _fetchDesignation(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _designationMasterRepository.getDesignationList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty ? {"DesignationName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final designations = response['data'] as List<DesignationMasterModel>;

        return {
          "itemList":
              designations.map((designation) {
                return {
                  "zAttributesId": designation.designationMasterId,
                  "DisplayName": designation.designationName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  // NAVIGATE TO ADD LEAVE BALANCE TYPE SCREEN
  Future<void> _navigateToAddLeaveBalanceType() async {
    final existingLeaveBalanceTypesJson = jsonEncode(
      _leaveBalanceTypeListNotifier.value.map((item) => item.toJson()).toList(),
    );
    final encryptedData = EncryptionManager.encryptData(
      existingLeaveBalanceTypesJson,
    );

    final result = await goRouter.pushNamed<LeaveBalanceType>(
      AppRoutes.addLeaveBalanceType,
      queryParameters: {
        'existingLeaveBalanceTypes': Uri.encodeComponent(encryptedData),
      },
    );

    if (result != null) {
      _leaveBalanceTypeListNotifier.value = [
        ..._leaveBalanceTypeListNotifier.value,
        result,
      ];
    }
  }

  // DELETE LEAVE BALANCE TYPE
  void _deleteLeaveBalanceType(int index) {
    final updatedList = List<LeaveBalanceType>.from(
      _leaveBalanceTypeListNotifier.value,
    );
    updatedList.removeAt(index);
    _leaveBalanceTypeListNotifier.value = updatedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave Credit Configuration",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? "Update Leave Credit Configuration Master"
                    : "Add Leave Credit Configuration Master",
                style: AppTextStyle.ts16M(),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    CustomDropDownWidget(
                      dataList: leavePeriodList,
                      onSelected: (value) {
                        selectedLeavePeriod = value;
                      },
                      initialValue: selectedLeavePeriod,
                      title: "Leave Period Mode",
                      hintText: "Enter Leave Period Mode",
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Leave Period Mode is required';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return CustomDatePicker(
                                title: "Start Date",
                                isRequired: true,
                                initialDate: startDate,
                                setValue: (value) {
                                  _startDateNotifier.value = value;
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Start Date is required';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        ),
                        horizontalSpacing(),
                        Expanded(
                          child: ValueListenableBuilder<DateTime?>(
                            valueListenable: _endDateNotifier,
                            builder: (context, endDate, child) {
                              return ValueListenableBuilder<DateTime?>(
                                valueListenable: _startDateNotifier,
                                builder: (context, startDate, child) {
                                  return CustomDatePicker(
                                    title: "End Date",
                                    isRequired: true,
                                    initialDate: endDate,
                                    setValue: (value) {
                                      _endDateNotifier.value = value;
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'End Date is required';
                                      }
                                      if (startDate != null) {
                                        // Compare dates by day (ignoring time)
                                        final startDateOnly = DateTime(
                                          startDate.year,
                                          startDate.month,
                                          startDate.day,
                                        );
                                        final endDateOnly = DateTime(
                                          value.year,
                                          value.month,
                                          value.day,
                                        );
                                        if (endDateOnly.isBefore(
                                              startDateOnly,
                                            ) ||
                                            endDateOnly.isAtSameMomentAs(
                                              startDateOnly,
                                            )) {
                                          return 'End Date must be after Start Date';
                                        }
                                      }
                                      return null;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedDepartmentNotifier,
                      builder: (context, selectedDept, child) {
                        return CustomMultipleSelectPopup(
                          title: "Department",
                          hintText: "Select Department",
                          isRequired: true,
                          isReadOnly: _isEditMode,
                          isMultiSelect: false,
                          initialValue: selectedDept,
                          dataFetchCallBack: _fetchDepartment,
                          onSelected: (value) {
                            _selectedDepartmentNotifier.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Department is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedDesignationNotifier,
                      builder: (context, selectedDes, child) {
                        return CustomMultipleSelectPopup(
                          title: "Designation",
                          hintText: "Select Designation",
                          isMultiSelect: true,
                          isReadOnly: _isEditMode,
                          initialValue: selectedDes,
                          dataFetchCallBack: _fetchDesignation,
                          onSelected: (value) {
                            _selectedDesignationNotifier.value = value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Leave Balance Type", style: AppTextStyle.ts16M()),
                        Spacer(),
                        CustomButton(
                          leading: Icon(
                            Icons.add,
                            size: 18,
                            color: AppColor.white,
                          ),
                          text: "Add",
                          onPressed: () {
                            _navigateToAddLeaveBalanceType();
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<List<LeaveBalanceType>>(
                      valueListenable: _leaveBalanceTypeListNotifier,
                      builder: (context, leaveBalanceTypeList, child) {
                        if (leaveBalanceTypeList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                "No leave balance types added yet",
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children:
                              leaveBalanceTypeList.asMap().entries.map((entry) {
                                final index = entry.key;
                                final leaveBalanceType = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: commonCardDecoration(),
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              leaveBalanceType.leaveTypeName,
                                              style: AppTextStyle.ts14M(),
                                            ),
                                            verticalSpacing(height: 5),
                                            Text(
                                              "Leave Credit: ${leaveBalanceType.leaveCredit}",
                                              style: AppTextStyle.ts12R(
                                                color: AppColor.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomIconButton.delete(
                                        onPressed: () {
                                          _deleteLeaveBalanceType(index);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
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
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_leaveBalanceTypeListNotifier.value.isEmpty) {
                  DialogHelper.showErrorMessage(
                    context: context,
                    title: "Error",
                    message: "Please add at least one leave balance type.",
                  );
                  return;
                }
                final leaveBalanceTypeList =
                    _leaveBalanceTypeListNotifier.value.map((item) {
                      return {
                        "LeaveTypeBalanceId": item.leaveTypeBalanceId,
                        "LeaveCreditConfigurationId":
                            item.leaveCreditConfigurationId,
                        "LeaveTypeId": item.leaveTypeId,
                        "LeaveCredit": item.leaveCredit,
                      };
                    }).toList();

                final departmentMasterId =
                    _selectedDepartmentNotifier.value.isNotEmpty
                        ? _selectedDepartmentNotifier.value[0]["zAttributesId"]
                        : 0;

                final designationIds = _selectedDesignationNotifier.value
                    .map((ele) => ele['zAttributesId'].toString())
                    .join(",");

                if (_isEditMode &&
                    widget.leaveCreditConfigurationMasterModel != null) {
                  final model = widget.leaveCreditConfigurationMasterModel!;
                  _leaveCreditConfigurationMasterCubit
                      .updateLeaveCreditConfigurationMaster(
                        context: context,
                        leaveCreditConfigurationId:
                            model.leaveCreditConfigurationId,
                        uniquekey: model.uniquekey,
                        leavePeriodMode: selectedLeavePeriod!["DisplayName"],
                        financialYearStartDate: _startDateNotifier.value!,
                        financialYearEndDate: _endDateNotifier.value!,
                        departmentMasterId: departmentMasterId,
                        designationIds: designationIds,
                        leaveBalanceTypeList: leaveBalanceTypeList,
                        index: widget.index,
                      );
                } else {
                  _leaveCreditConfigurationMasterCubit
                      .addLeaveCreditConfigurationMaster(
                        context: context,
                        leavePeriodMode: selectedLeavePeriod!["DisplayName"],
                        financialYearStartDate: _startDateNotifier.value!,
                        financialYearEndDate: _endDateNotifier.value!,
                        departmentMasterId: departmentMasterId,
                        designationIds: designationIds,
                        leaveBalanceTypeList: leaveBalanceTypeList,
                      );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
