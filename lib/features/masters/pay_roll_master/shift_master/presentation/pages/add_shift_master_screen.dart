import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddShiftMasterScreen extends StatefulWidget {
  final ShiftMasterModel? shiftMasterModel;
  final int index;
  const AddShiftMasterScreen({
    super.key,
    required this.shiftMasterModel,
    this.index = 0,
  });

  @override
  State<AddShiftMasterScreen> createState() => _AddShiftMasterScreenState();
}

class _AddShiftMasterScreenState extends State<AddShiftMasterScreen> {
  //CUBIT
  late ShiftMasterCubit _shiftMasterCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  //EDIT MODE
  bool get _isEditMode => widget.shiftMasterModel != null;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //TEXT EDITING CONTROLLERS
  late TextEditingController _shiftName, _shiftCode, _graceTime, _remarks;

  //TIME VARIABLES
  String? shiftBeginTime;
  String? shiftEndTime;
  String? shiftDurationTime;
  String? shiftWorkDurationTime;
  String? firstHalfUpTo;
  String? absentWorkingHours;
  String? halfDayWorkingHours;
  String? halfDayInTimeAfter;
  String? halfDayOutTimeBefore;
  String? breakBeginTime;
  String? breakEndTime;
  String? breakDurationTime;

  @override
  void initState() {
    super.initState();

    _shiftMasterCubit = context.read<ShiftMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addShiftMaster] ??
        AuthorizationModel();
    _initializeTextEditingControllers();
    if (_isEditMode && widget.shiftMasterModel != null) {
      _populateFormFields(widget.shiftMasterModel!);
    }
  }

  void _populateFormFields(ShiftMasterModel shiftMasterModel) {
    _shiftName.text = shiftMasterModel.shiftName;
    _shiftCode.text = shiftMasterModel.shiftCode;
    shiftBeginTime = shiftMasterModel.shiftBeginTime;
    shiftEndTime = shiftMasterModel.shiftEndTime;
    shiftDurationTime = shiftMasterModel.shiftDurationTime;
    shiftWorkDurationTime = shiftMasterModel.shiftWorkDurationTime;
    firstHalfUpTo = shiftMasterModel.firstHalfUpTo;
    absentWorkingHours = shiftMasterModel.absentWorkingHours;
    halfDayWorkingHours = shiftMasterModel.halfDayWorkingHours;
    halfDayInTimeAfter = shiftMasterModel.halfDayInTimeAfter;
    halfDayOutTimeBefore = shiftMasterModel.halfDayOutTimeBefore;
    breakBeginTime = shiftMasterModel.breakBeginTime;
    breakEndTime = shiftMasterModel.breakBeginTime;
    breakDurationTime = shiftMasterModel.breakDurationTime;
    _graceTime.text = shiftMasterModel.graceTime;
    _remarks.text = shiftMasterModel.remarks;
  }

  void _initializeTextEditingControllers() {
    _shiftName = TextEditingController();
    _shiftCode = TextEditingController();
    _graceTime = TextEditingController();
    _remarks = TextEditingController();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.shiftMasterModel != null) {
      _shiftMasterCubit.updateshift(
        index: widget.index,
        context: context,
        shiftId: widget.shiftMasterModel!.shiftManagementMasterId,
        uniqueKey: widget.shiftMasterModel!.uniqueKey,
        shiftCode: _shiftCode.text.trim(),
        shiftName: _shiftName.text.trim(),
        shiftBeginTime: shiftBeginTime!,
        shiftEndTime: shiftEndTime!,
        shiftDurationTime: shiftDurationTime!,
        shiftWorkDurationTime: shiftWorkDurationTime!,
        firstHalfUpTo: firstHalfUpTo!,
        absentWorkingHours: absentWorkingHours!,
        halfDayWorkingHours: halfDayWorkingHours!,
        halfDayInTimeAfter: halfDayInTimeAfter!,
        halfDayOutTimeBefore: halfDayOutTimeBefore!,
        breakBeginTime: breakBeginTime!,
        breakEndTime: breakEndTime!,
        breakDurationTime: breakDurationTime!,
        graceTime: _graceTime.text,
        remarks: _remarks.text,
      );
    } else {
      _shiftMasterCubit.addshift(
        context: context,
        shiftCode: _shiftCode.text.trim(),
        shiftName: _shiftName.text.trim(),
        shiftBeginTime: shiftBeginTime!,
        shiftEndTime: shiftEndTime!,
        shiftDurationTime: shiftDurationTime!,
        shiftWorkDurationTime: shiftWorkDurationTime!,
        firstHalfUpTo: firstHalfUpTo!,
        absentWorkingHours: absentWorkingHours!,
        halfDayWorkingHours: halfDayWorkingHours!,
        halfDayInTimeAfter: halfDayInTimeAfter!,
        halfDayOutTimeBefore: halfDayOutTimeBefore!,
        breakBeginTime: breakBeginTime!,
        breakEndTime: breakEndTime!,
        breakDurationTime: breakDurationTime!,
        graceTime: _graceTime.text,
        remarks: _remarks.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Edit Shift" : "Add Shift",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Shift Name",
                  textController: _shiftName,
                  hint: "Enter Shift Name",
                  inputFormatterList: [InputValidator.digitAndCharacterOnly()],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Shift Name is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "Shift Code",
                  textController: _shiftCode,

                  hint: "Enter Shift Code",
                  inputFormatterList: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Shift Code is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTimePicker(
                  setValue: (value) {
                    shiftBeginTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Shift Begin Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(shiftBeginTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    shiftEndTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Shift End Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(shiftEndTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    shiftDurationTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Shift Duration Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(shiftDurationTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    shiftWorkDurationTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Shift Working Duration Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(shiftWorkDurationTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    firstHalfUpTo = formatTimeOfDayHHmm(value);
                  },
                  title: "First Half Up To",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(firstHalfUpTo),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    absentWorkingHours = formatTimeOfDayHHmm(value);
                  },
                  title: "Absent Working Hours",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(absentWorkingHours),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    halfDayWorkingHours = formatTimeOfDayHHmm(value);
                  },
                  title: "Half Day Working Hours",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(halfDayWorkingHours),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    halfDayInTimeAfter = formatTimeOfDayHHmm(value);
                  },
                  title: "Half DayIn Time After",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(halfDayInTimeAfter),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    halfDayOutTimeBefore = formatTimeOfDayHHmm(value);
                  },
                  title: "Half DayOut Time Before",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(halfDayOutTimeBefore),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    breakBeginTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Break Begin Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(breakBeginTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    breakEndTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Break End Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(breakEndTime),
                ),

                CustomTimePicker(
                  setValue: (value) {
                    breakDurationTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Break Duration Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(breakDurationTime),
                ),
                CustomTextField(
                  title: "Grace Time",
                  textController: _graceTime,
                  hint: "Enter Grace Time",
                  inputFormatterList: [InputValidator.digitAndCharacterOnly()],
                  keyboardType: TextInputType.text,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Grace Time is reqiured";
                    }

                    return null;
                  },
                ),
                CustomTextField(
                  title: "Remarks",
                  textController: _remarks,

                  hint: "Enter Remarks",
                  inputFormatterList: InputValidator.textOnly(200),
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Remarks is reqiured";
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Shift" : "Add Shift",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
