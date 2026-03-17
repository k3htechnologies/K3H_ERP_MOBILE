import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/data/model/shift_master_mapping.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_mapping_master/presentation/cubit/shift_master_mapping_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  // DROPDOWN SELECTIONS
  List<Map<String, dynamic>> _selectedShift = [];
  List<Map<String, dynamic>> _selectedEmployee = [];
  List<Map<String, dynamic>> _selectedDepartment = [];

  //EDIT MODE
  bool get _isEditMode => widget.shiftMappingModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addShiftMappingMaster] ??
        AuthorizationModel();
    _shiftMappingMasterCubit = context.read<ShiftMappingMasterCubit>();
    if (_isEditMode) {
      _populateFormFields(widget.shiftMappingModel!);
    }
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(ShiftMappingModel shiftMapping) {
    _selectedEmployee = [
      {
        'zAttributesId': shiftMapping.employeeId,
        'DisplayName': shiftMapping.employeeName,
      },
    ];
    _selectedShift = [
      {
        'zAttributesId': shiftMapping.shiftManagementMasterId,
        'DisplayName': shiftMapping.shiftName,
      },
    ];
    _selectedDepartment = [
      {
        'zAttributesId': shiftMapping.departmentMasterId,
        'DisplayName': shiftMapping.departmentName,
      },
    ];
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedShift.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select a shift');
      return;
    }
    if (_selectedEmployee.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select an employee');
      return;
    }

    if (_selectedDepartment.isEmpty) {
      showErrorMessage(context, 'Error', 'Please select department');
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
        employeeId: _selectedEmployee.first['zAttributesId'].toString(),
        departmentMasterId:
            _selectedDepartment.first['zAttributesId'].toString(),
      );
    } else {
      _shiftMappingMasterCubit.addShiftMapping(
        context: context,
        employeeId: _selectedEmployee.first['zAttributesId'].toString(),
        shiftMasterId: _selectedShift.first['zAttributesId'] as int,
        departmentMasterId:
            _selectedDepartment.first['zAttributesId'].toString(),
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

                    CustomMultipleSelectPopup(
                      title: 'Employee',
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectedEmployee,
                      dataList: [],
                      onSelected: (value) {
                        _selectedEmployee = value;
                      },
                      dataFetchCallBack:
                          _shiftMappingMasterCubit.fetchEmployees,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Employee is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: 'Department',
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectedDepartment,
                      dataList: [],
                      onSelected: (value) {
                        _selectedDepartment = value;
                      },
                      dataFetchCallBack:
                          _shiftMappingMasterCubit.fetchDepartment,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Department is required";
                        }
                        return null;
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
