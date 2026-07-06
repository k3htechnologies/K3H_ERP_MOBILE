import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/model/leave_encashment_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLeaveEncashmentMasterScreen extends StatefulWidget {
  final LeaveEncashmentMasterModel? leaveEncashmentMasterModel;
  final int index;
  const AddLeaveEncashmentMasterScreen({
    super.key,
    required this.leaveEncashmentMasterModel,
    this.index = 0,
  });

  @override
  State<AddLeaveEncashmentMasterScreen> createState() =>
      _AddLeaveEncashmentMasterScreenState();
}

class _AddLeaveEncashmentMasterScreenState
    extends State<AddLeaveEncashmentMasterScreen> {
  //CUBIT
  late LeaveEncashmentMasterCubit _leaveEncashmentMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // SELECT EARNING
  List<Map<String, dynamic>> _selectedEarning = [];

  // STATIC LIST
  List<Map<String, dynamic>> earningList = [
    {"zAttributesId": 1, "DisplayName": "Basic Salary"},
    {"zAttributesId": 2, "DisplayName": "HRA"},
    {"zAttributesId": 3, "DisplayName": "DA"},
    {"zAttributesId": 4, "DisplayName": "Conveyance Allowance"},
    {"zAttributesId": 5, "DisplayName": "Medical Allowance"},
    {"zAttributesId": 6, "DisplayName": "Special Allowance"},
    {"zAttributesId": 7, "DisplayName": "Other Allowance"},
    {"zAttributesId": 8, "DisplayName": "LTA"},
    {"zAttributesId": 9, "DisplayName": "Performance Bonus"},
    {"zAttributesId": 10, "DisplayName": "Incentive"},
    {"zAttributesId": 11, "DisplayName": "Variable Pay"},
    {"zAttributesId": 12, "DisplayName": "Annual Bonus"},
    {"zAttributesId": 13, "DisplayName": "Joining Bonus"},
    {"zAttributesId": 14, "DisplayName": "Retention Bonus"},
    {"zAttributesId": 15, "DisplayName": "Mobile Reimbursement"},
    {"zAttributesId": 16, "DisplayName": "Internet Reimbursement"},
    {"zAttributesId": 17, "DisplayName": "Fuel Reimbursement"},
    {"zAttributesId": 18, "DisplayName": "Food Allowance"},
    {"zAttributesId": 19, "DisplayName": "Shift Allowance"},
    {"zAttributesId": 20, "DisplayName": "Night Shift Allowance"},
    {"zAttributesId": 21, "DisplayName": "City Compensatory Allowance"},
    {"zAttributesId": 22, "DisplayName": "Employer PF"},
    {"zAttributesId": 23, "DisplayName": "Employer ESI"},
    {"zAttributesId": 24, "DisplayName": "Gratuity"},
    {"zAttributesId": 25, "DisplayName": "Superannuation"},
    {"zAttributesId": 26, "DisplayName": "NPS Employer"},
    {"zAttributesId": 27, "DisplayName": "Health Insurance"},
    {"zAttributesId": 28, "DisplayName": "Overtime Pay"},
    {"zAttributesId": 29, "DisplayName": "Leave Encashment"},
    {"zAttributesId": 30, "DisplayName": "Arrears"},
    {"zAttributesId": 31, "DisplayName": "Ex-Gratia"},
    {"zAttributesId": 32, "DisplayName": "Relocation Allowance"},
  ];

  //EDIT MODE
  bool get _isEditMode => widget.leaveEncashmentMasterModel != null;

  //TEXT EDITING CONTROLLERS
  late TextEditingController _minSalaryC;
  late TextEditingController _maxSalaryC;
  late TextEditingController _encashmentRateC;

  @override
  void initState() {
    super.initState();
    _leaveEncashmentMasterCubit = context.read<LeaveEncashmentMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .addLeaveEncashmentMaster] ??
        AuthorizationModel();
    _initializeTextEditingControllers();
    if (_isEditMode && widget.leaveEncashmentMasterModel != null) {
      _populateFormFields(widget.leaveEncashmentMasterModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _minSalaryC.dispose();
    _maxSalaryC.dispose();
    _encashmentRateC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _minSalaryC = TextEditingController();
    _maxSalaryC = TextEditingController();
    _encashmentRateC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(LeaveEncashmentMasterModel leaveEncashmentModel) {
    final names =
        leaveEncashmentModel.earningMasterName
            .split(',')
            .map((e) => e.trim())
            .toList();

    _selectedEarning =
        earningList
            .where((item) => names.contains(item["DisplayName"]))
            .toList();
    _minSalaryC.text = leaveEncashmentModel.minSalary.toString();
    _maxSalaryC.text = leaveEncashmentModel.maxSalary.toString();
    _encashmentRateC.text = leaveEncashmentModel.encashmentRate.toString();
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final earningNames = _selectedEarning
        .map((e) => e["DisplayName"].toString())
        .join(",");
    if (_isEditMode && widget.leaveEncashmentMasterModel != null) {
      _leaveEncashmentMasterCubit.updateLeaveEncashment(
        index: widget.index,
        context: context,
        leaveEncashmentSlabsId:
            widget.leaveEncashmentMasterModel!.leaveEncashmentSlabId,
        uniqueKey: widget.leaveEncashmentMasterModel!.uniqueKey,
        earningMasterName: earningNames,
        minSalary: double.parse(_minSalaryC.text.trim()),
        maxSalary: double.parse(_maxSalaryC.text.trim()),
        encashmentRate: double.parse(_encashmentRateC.text.trim()),
      );
    } else {
      _leaveEncashmentMasterCubit.addLeaveEncashment(
        context: context,
        earningMasterName: earningNames,
        minSalary: double.parse(_minSalaryC.text),
        maxSalary: double.parse(_maxSalaryC.text),
        encashmentRate: double.parse(_encashmentRateC.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.lightGreyBackground,

      appBar: CustomAppBarWithBackButton(
        screenTitle: "Leave Enhancement Master",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode
                    ? "Update Leave Encashment"
                    : "Add Leave Encashment",
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
                      title: 'Earning Name',
                      hintText: "Select Earning Name",
                      isMultiSelect: true,
                      initialValue: _selectedEarning,
                      dataList: earningList,
                      onSelected: (value) {
                        _selectedEarning = value;
                      },
                      dataFetchCallBack: (pageNumber, {value}) async {
                        return {
                          "itemList": earningList,
                          "totalNumberOfRecord": earningList.length,
                        };
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Earning Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Encashment Rate (%)",
                      textController: _encashmentRateC,
                      hint: "Enter Encashment Rate",
                      prefixWidget: Icon(
                        Icons.percent,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      inputFormatterList: InputValidator.percentage(),
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Encashment rate is required";
                        }

                        final rate = double.tryParse(value.trim());

                        if (rate == null) {
                          return "Please enter a valid number";
                        }

                        if (rate < 1 || rate > 100) {
                          return "Encashment rate must be between 1 and 100";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Minimum Salary (₹)",
                      textController: _minSalaryC,
                      hint: "Enter minimum salary",
                      inputFormatterList: InputValidator.digit(10),
                      prefixWidget: Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Minimum salary is reqiured";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Maximum Salary (₹)",
                      textController: _maxSalaryC,
                      hint: "Enter Maximum Salary",
                      prefixWidget: Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: AppColor.grey,
                      ),
                      inputFormatterList: InputValidator.digit(10),
                      keyboardType: TextInputType.number,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Maximum salary is reqiured";
                        }

                        final maxSalary = double.tryParse(value.trim());
                        final minSalary = double.tryParse(
                          _minSalaryC.text.trim(),
                        );

                        if (maxSalary == null || minSalary == null) {
                          return "Please enter a valid number";
                        }

                        if (maxSalary <= minSalary) {
                          return "Max salary must be greater than min salary";
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
