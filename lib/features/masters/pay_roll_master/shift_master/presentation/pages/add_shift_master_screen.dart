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
  late TextEditingController _shiftNameC, _shiftCodeC, _remarksC;

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
  String? graceTime;

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

  @override
  void dispose() {
    super.dispose();
    _shiftNameC.dispose();
    _shiftCodeC.dispose();
    _remarksC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _shiftNameC = TextEditingController();
    _shiftCodeC = TextEditingController();
    _remarksC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(ShiftMasterModel shiftMasterModel) {
    _shiftNameC.text = shiftMasterModel.shiftName;
    _shiftCodeC.text = shiftMasterModel.shiftCode;
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
    breakEndTime = shiftMasterModel.breakEndTime;
    breakDurationTime = shiftMasterModel.breakDurationTime;
    graceTime = shiftMasterModel.graceTime;
    _remarksC.text = shiftMasterModel.remarks;
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.shiftMasterModel != null) {
      _shiftMasterCubit.updateShift(
        index: widget.index,
        context: context,
        shiftId: widget.shiftMasterModel!.shiftManagementMasterId,
        uniqueKey: widget.shiftMasterModel!.uniqueKey,
        shiftCode: _shiftCodeC.text.trim(),
        shiftName: _shiftNameC.text.trim(),
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
        graceTime: graceTime!,
        remarks: _remarksC.text,
      );
    } else {
      _shiftMasterCubit.addShift(
        context: context,
        shiftCode: _shiftCodeC.text.trim(),
        shiftName: _shiftNameC.text.trim(),
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
        graceTime: graceTime!,
        remarks: _remarksC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Shift" : "Add Shift",
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
                  textController: _shiftNameC,
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
                  textController: _shiftCodeC,

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
                CustomTimePicker(
                  setValue: (value) {
                    graceTime = formatTimeOfDayHHmm(value);
                  },
                  title: "Grace Time",
                  isRequired: true,
                  initialTime: parseTimeOfDayFromHHmm(graceTime),
                ),
                CustomTextField(
                  title: "Remarks",
                  textController: _remarksC,

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
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
