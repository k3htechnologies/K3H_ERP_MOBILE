// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/data/model/week_off_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_cubit.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/week_off_mapping_master/presentation/cubit/week_off_mapping_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
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

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedWeekOff = [];
  List<Map<String, dynamic>> _selectedEmployee = [];
  List<Map<String, dynamic>> _selectedDepartment = [];

  //EDIT MODE
  bool get _isEditMode => widget.weekOffMappingMasterModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //RADIO BUTTON OPTIONS
  List<String> options = ['Employee', 'Department'];

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .addWeekOffMappingMaster] ??
        AuthorizationModel();
    _weekOffMappingMasterCubit = context.read<WeekOffMappingMasterCubit>();
    if (_isEditMode) {
      _populateFormFields(widget.weekOffMappingMasterModel!);
    }
  }

  void _populateFormFields(WeekOffMappingModel weekOffMapping) {
    _selectedEmployee = [
      {
        'zAttributesId': weekOffMapping.employeeId,
        'DisplayName': weekOffMapping.employeeName,
      },
    ];
    _selectedWeekOff = [
      {
        'zAttributesId': weekOffMapping.weekOffPolicyMasterId,
        'DisplayName': weekOffMapping.weekOffPolicyName,
      },
    ];
    _selectedDepartment = [
      {
        'zAttributesId': weekOffMapping.departmentMasterId,
        'DisplayName': weekOffMapping.departmentName,
      },
    ];
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWeekOff.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select a week off');
      return;
    }
    // if (_selectedEmployee.isEmpty) {
    //   showErrorMessage(context, 'Error', 'Please select an employee');
    //   return;
    // }

    // if (_selectedDepartment.isEmpty) {
    //   showErrorMessage(context, 'Error', 'Please select department');
    //   return;
    // }

    if (_isEditMode && widget.weekOffMappingMasterModel != null) {
      _weekOffMappingMasterCubit.updateWeekOffMapping(
        index: widget.index,
        context: context,
        uniqueKey: widget.weekOffMappingMasterModel!.uniquekey,
        weekOffMappingMasterId:
            widget.weekOffMappingMasterModel!.weekOffPolicyMasterMappingId,
        weekOffMasterId: _selectedWeekOff.first['zAttributesId'] as int,
        employeeId:
            _selectedEmployee.isEmpty
                ? null
                : _selectedEmployee.first['zAttributesId'].toString(),
        departmentMasterId:
            _selectedDepartment.isEmpty
                ? null
                : _selectedDepartment.first['zAttributesId'].toString(),
      );
    } else {
      _weekOffMappingMasterCubit.addWeekOffMapping(
        context: context,
        weekOffMasterId: _selectedWeekOff.first['zAttributesId'] as int,
        employeeId:
            _selectedEmployee.isEmpty
                ? null
                : _selectedEmployee.first['zAttributesId'].toString(),
        departmentMasterId:
            _selectedDepartment.isEmpty
                ? null
                : _selectedDepartment.first['zAttributesId'].toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            _isEditMode ? "Update Week Off Mapping" : "Add Week Off Mapping",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
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
                      title: 'Week Off Name',
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
                          return "Week off Name is required";
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: state.options[0],
                          groupValue: state.selectedOption,
                          onChanged: (value) {
                            _weekOffMappingMasterCubit.onSelectedOptionChanged(
                              value!,
                            );
                          },
                        ),
                        Text("Employee", style: AppTextStyle.ts14R()),
                        horizontalSpacing(),
                        Radio<String>(
                          value: state.options[1],
                          groupValue: state.selectedOption,
                          onChanged: (value) {
                            _weekOffMappingMasterCubit.onSelectedOptionChanged(
                              value!,
                            );
                          },
                        ),
                        Text("Department", style: AppTextStyle.ts14R()),
                      ],
                    ),
                    verticalSpacing(),
                    Visibility(
                      visible: state.selectedOption == state.options[0],
                      child: CustomMultipleSelectPopup(
                        title: 'Employee',
                        isRequired: true,
                        isMultiSelect: false,
                        initialValue: _selectedEmployee,
                        dataList: [],
                        onSelected: (value) {
                          _selectedEmployee = value;
                        },
                        dataFetchCallBack:
                            _weekOffMappingMasterCubit.fetchEmployees,
                        validator: (value) {
                          if ((state.selectedOption.toLowerCase() ==
                                  state.options[0].toLowerCase()) &&
                              (value == null || value.isEmpty)) {
                            return "Employee is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    Visibility(
                      visible: state.selectedOption == state.options[1],

                      child: CustomMultipleSelectPopup(
                        title: 'Department',
                        isRequired: true,
                        isMultiSelect: false,
                        initialValue: _selectedDepartment,
                        dataList: [],
                        onSelected: (value) {
                          _selectedDepartment = value;
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
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text:
                _isEditMode
                    ? "Update Week Off Mapping"
                    : "Add Week Off Mapping",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
