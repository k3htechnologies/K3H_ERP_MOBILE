// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/data/model/shift_master.model.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/shift_master/presentation/cubit/shift_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  String? _selectedLateArrivalAction;

  // FORM KEYS (one per section)
  final _formKeys = [
    GlobalKey<FormState>(), // SHIFT DETAILS
    GlobalKey<FormState>(), // SHIFT TIME DETAILS
    GlobalKey<FormState>(), // SHIFT BREAK DETAILS
    GlobalKey<FormState>(), // Advance Setting
    GlobalKey<FormState>(), // Time Allowed for Late Entry Details
    GlobalKey<FormState>(), //Remarks
  ];

  //TEXT EDITING CONTROLLERS
  late TextEditingController _shiftNameC,
      _shiftCodeC,
      _remarksC,
      _lateCountC,
      _markAbsentInMinutesC,
      _markHalfDayInMinutesC,
      _markHalfDayIfIntimeAfterC,
      _markHalfDayIfOutTimeBeforeC,
      _graceTimeC,
      _shiftDurationC,
      _breakDurationC,
      _shiftWorkDurationC;

  //TIME VARIABLES
  String? shiftBeginTime;
  String? shiftEndTime;
  String? firstHalfUpTo;
  String? markHalfDayIfInTimeIsAfterWorkingHour;
  String? markHalfDayIfOutTimeBefpreWorkingHours;
  String? breakBeginTime;
  String? breakEndTime;

  // VALUE NOTIFIERS

  final absentWorkingHoursVN = ValueNotifier<String>("00:00");
  final halfDayWorkingHoursVN = ValueNotifier<String>("00:00");
  final halfDayInAfterVN = ValueNotifier<String>("00:00");
  final halfDayOutBeforeVN = ValueNotifier<String>("00:00");

  final graceTimeVN = ValueNotifier<String>("0");

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
      _calculateAllDurations();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _shiftNameC.dispose();
    _shiftCodeC.dispose();
    _remarksC.dispose();
    _lateCountC.dispose();
    _markAbsentInMinutesC.dispose();
    _markHalfDayInMinutesC.dispose();
    _markHalfDayIfIntimeAfterC.dispose();
    _markHalfDayIfOutTimeBeforeC.dispose();
    _graceTimeC.dispose();
    _shiftDurationC.dispose();
    _breakDurationC.dispose();
    _shiftWorkDurationC.dispose();

    absentWorkingHoursVN.dispose();
    halfDayWorkingHoursVN.dispose();
    halfDayInAfterVN.dispose();
    halfDayOutBeforeVN.dispose();
    graceTimeVN.dispose();
  }

  // ON TIME CHANGED
  void _onTimeChanged(Function(String) setter, TimeOfDay value) {
    setter(formatTimeOfDayHHmm(value));
    _calculateAllDurations();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingControllers() {
    _shiftNameC = TextEditingController();
    _shiftCodeC = TextEditingController();
    _remarksC = TextEditingController();
    _lateCountC = TextEditingController();
    _markAbsentInMinutesC = TextEditingController();
    _markHalfDayInMinutesC = TextEditingController();
    _markHalfDayIfIntimeAfterC = TextEditingController();
    _markHalfDayIfOutTimeBeforeC = TextEditingController();
    _graceTimeC = TextEditingController();
    _shiftDurationC = TextEditingController();
    _breakDurationC = TextEditingController();
    _shiftWorkDurationC = TextEditingController();
  }

  // CHECK IF END TIME IS VALID
  bool _isEndTimeValid(String? start, String? end) {
    if (start == null || end == null) return true;

    final startParts = start.split(':');
    final endParts = end.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return endMinutes > startMinutes;
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(ShiftMasterModel shiftMasterModel) {
    _shiftNameC.text = shiftMasterModel.shiftName;
    _shiftCodeC.text = shiftMasterModel.shiftCode;

    shiftBeginTime = normalizeTime(shiftMasterModel.shiftBeginTime);
    shiftEndTime = normalizeTime(shiftMasterModel.shiftEndTime);

    firstHalfUpTo = shiftMasterModel.firstHalfUpTo;

    //  SHIFT DURATIONS
    _shiftWorkDurationC.text = normalizeTime(
      shiftMasterModel.shiftDurationTime,
    );

    _shiftWorkDurationC.text = normalizeTime(
      shiftMasterModel.shiftWorkDurationTime,
    );

    // _shiftWorkDurationC.text = shiftWorkDurationVN.value;

    // ABSENT WORKING HOURS
    final absent = shiftMasterModel.absentWorkingHours;
    absentWorkingHoursVN.value = absent;
    _markAbsentInMinutesC.text = convertHHmmToMinutes(absent).toString();

    //  HALF DAY WORKING HOURS
    final halfDay = shiftMasterModel.halfDayWorkingHours;
    halfDayWorkingHoursVN.value = halfDay;
    _markHalfDayInMinutesC.text = convertHHmmToMinutes(halfDay).toString();

    //  HALF DAY IN TIME AFTER
    final inAfter = shiftMasterModel.halfDayInTimeAfter;
    halfDayInAfterVN.value = inAfter;
    _markHalfDayIfIntimeAfterC.text = convertHHmmToMinutes(inAfter).toString();

    // HALF DAY OUT TIME BEFORE
    final outBefore = shiftMasterModel.halfDayOutTimeBefore;
    halfDayOutBeforeVN.value = outBefore;
    _markHalfDayIfOutTimeBeforeC.text =
        convertHHmmToMinutes(outBefore).toString();

    //  BREAK
    breakBeginTime = normalizeTime(shiftMasterModel.breakBeginTime);
    breakEndTime = normalizeTime(shiftMasterModel.breakEndTime);

    _breakDurationC.text = normalizeTime(shiftMasterModel.breakDurationTime);

    //  GRACE TIME
    final grace = shiftMasterModel.graceTime;
    graceTimeVN.value = grace;
    _graceTimeC.text = grace;

    //  OTHER FIELDS
    _selectedLateArrivalAction = shiftMasterModel.lateArrivalAction;
    _lateCountC.text = shiftMasterModel.lateCount.toString();
    _remarksC.text = shiftMasterModel.remarks;
  }

  // SUBMIT FORM
  void _submitForm() {
    final isShiftValid = _formKeys[0].currentState?.validate() ?? false;
    final isTimeDetailsValid = _formKeys[1].currentState?.validate() ?? false;
    final isBreakDetails = _formKeys[2].currentState?.validate() ?? false;
    final isAdvanceSettingValid =
        _formKeys[3].currentState?.validate() ?? false;
    final isTimeAllowedForLateEntryDetailsValid =
        _formKeys[4].currentState?.validate() ?? false;
    final isRemarkValid = _formKeys[5].currentState?.validate() ?? false;

    if (!isShiftValid ||
        !isTimeDetailsValid ||
        !isBreakDetails ||
        !isAdvanceSettingValid ||
        !isTimeAllowedForLateEntryDetailsValid ||
        !isRemarkValid) {
      return;
    }

    _calculateAllDurations();

    //  GET VALUES FROM VALUE NOTIFIERS
    final shiftDuration = _shiftDurationC.text;
    final shiftWorkDuration = _shiftWorkDurationC.text;
    final breakDuration = _breakDurationC.text;

    final absentWorkingHours = absentWorkingHoursVN.value;
    final halfDayWorkingHours = halfDayWorkingHoursVN.value;
    final halfDayInAfter = halfDayInAfterVN.value;
    final halfDayOutBefore = halfDayOutBeforeVN.value;

    final graceTime = graceTimeVN.value;

    if (_isEditMode && widget.shiftMasterModel != null) {
      _shiftMasterCubit.updateShift(
        index: widget.index,
        context: context,
        shiftId: widget.shiftMasterModel!.shiftManagementMasterId,
        uniqueKey: widget.shiftMasterModel!.uniquekey,
        shiftCode: _shiftCodeC.text.trim(),
        shiftName: _shiftNameC.text.trim(),
        shiftBeginTime: shiftBeginTime ?? "",
        shiftEndTime: shiftEndTime ?? "",
        shiftDurationTime: shiftDuration,
        shiftWorkDurationTime: shiftWorkDuration,
        firstHalfUpTo: firstHalfUpTo ?? "",
        absentWorkingHours: absentWorkingHours,
        halfDayWorkingHours: halfDayWorkingHours,
        halfDayInTimeAfter: halfDayInAfter,
        halfDayOutTimeBefore: halfDayOutBefore,
        breakBeginTime: breakBeginTime ?? "",
        breakEndTime: breakEndTime ?? "",
        breakDurationTime: breakDuration,
        graceTime: graceTime,
        lateArrivalAction: _selectedLateArrivalAction,
        lateCount: double.parse(_lateCountC.text.trim()),
        remarks: _remarksC.text.trim(),
      );
    } else {
      _shiftMasterCubit.addShift(
        context: context,
        shiftCode: _shiftCodeC.text.trim(),
        shiftName: _shiftNameC.text.trim(),
        shiftBeginTime: shiftBeginTime!,
        shiftEndTime: shiftEndTime!,
        shiftDurationTime: shiftDuration,
        shiftWorkDurationTime: shiftWorkDuration,
        firstHalfUpTo: firstHalfUpTo!,
        absentWorkingHours: absentWorkingHours,
        halfDayWorkingHours: halfDayWorkingHours,
        halfDayInTimeAfter: halfDayInAfter,
        halfDayOutTimeBefore: halfDayOutBefore,
        breakBeginTime: breakBeginTime!,
        breakEndTime: breakEndTime!,
        breakDurationTime: breakDuration,
        graceTime: graceTime,
        lateArrivalAction: _selectedLateArrivalAction,
        lateCount:
            _lateCountC.text.isNotEmpty
                ? double.parse(_lateCountC.text.trim())
                : 0,
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildShiftDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildShiftTimeDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildShiftBreakTimeDetailsSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildShiftAdvanceTimeDetailsSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildShiftTimeAllowedForLateEntryDetailsSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildRemarkSection()),
            ),
          ],
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

  // ------------------------- UI SECTION BUILDERS ------------------------- //

  Widget _buildSectionContainer(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyle.ts16M(color: AppColor.black.withValues(alpha: .5)),
      ),
    );
  }

  // BUILD SHIFT DETAILS SECTION
  Widget _buildShiftDetailsSection() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Details'),
          CustomTextField(
            title: "Shift Name",
            textController: _shiftNameC,
            hint: "Enter Shift Name",
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
        ],
      ),
    );
  }

  // BUILD SHIFT DETAILS SECTION
  Widget _buildShiftTimeDetailsSection() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Time Details'),
          CustomTimePicker(
            setValue: (value) {
              final selected = formatTimeOfDayHHmm(value);

              shiftBeginTime = selected;

              if (shiftEndTime != null &&
                  !_isEndTimeValid(shiftBeginTime, shiftEndTime)) {
                shiftEndTime = null;
              }

              _calculateAllDurations();
            },
            title: "Shift Begin Time",
            isRequired: true,
            initialTime: parseTimeOfDayFromHHmm(shiftBeginTime),
            validator: (value) {
              if (value == null) {
                return "Shift Begin Time is required";
              }
              return null;
            },
          ),
          CustomTimePicker(
            setValue: (value) {
              final selected = formatTimeOfDayHHmm(value);

              shiftEndTime = selected;
              _calculateAllDurations();
            },
            title: "Shift End Time",
            isRequired: true,
            initialTime: parseTimeOfDayFromHHmm(shiftEndTime),
            validator: (value) {
              if (value == null) {
                return "Shift End Time is required";
              }

              final selected = formatTimeOfDayHHmm(value);

              if (!_isEndTimeValid(shiftBeginTime, selected)) {
                return "End time must be after start time";
              }

              return null;
            },
          ),
          CustomTextField(
            textController: _shiftDurationC,
            title: "Shift Duration (24 hours Format)",
            readOnly: true,
            hint: _shiftDurationC.text,
          ),
          CustomTextField(
            textController: _shiftWorkDurationC,
            title: "Shift Work Duration (24 hours Format)",
            readOnly: true,
            hint: _shiftWorkDurationC.text,
          ),
        ],
      ),
    );
  }

  // BUILD SHIFT BREAK TIME DETAILS SECTION
  Widget _buildShiftBreakTimeDetailsSection() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Break Details'),

          CustomTimePicker(
            setValue:
                (value) => _onTimeChanged((val) => breakBeginTime = val, value),
            title: "Break Begin Time",
            isRequired: true,
            initialTime: parseTimeOfDayFromHHmm(breakBeginTime),
            validator: (value) {
              if (value == null) {
                return "Break Begin Time is required";
              }
              return null;
            },
          ),

          CustomTimePicker(
            setValue:
                (value) => _onTimeChanged((val) => breakEndTime = val, value),

            title: "Break End Time",
            isRequired: true,
            initialTime: parseTimeOfDayFromHHmm(breakEndTime),
            validator: (value) {
              if (value == null) {
                return "Break End Time is required";
              }

              final selected = formatTimeOfDayHHmm(value);

              if (!_isEndTimeValid(breakBeginTime, selected)) {
                return "End time must be after start time";
              }

              return null;
            },
          ),
          CustomTextField(
            textController: _breakDurationC,
            title: "Break Duration Time",
            readOnly: true,
            hint: _breakDurationC.text,
          ),
        ],
      ),
    );
  }

  void _calculateAllDurations() {
    final shiftMinutes = getDiffInMinutes(shiftBeginTime, shiftEndTime);
    _shiftDurationC.text = toHHmm(shiftMinutes);

    final breakMinutes = getDiffInMinutes(breakBeginTime, breakEndTime);
    _breakDurationC.text = toHHmm(breakMinutes);

    int workMinutes = shiftMinutes - breakMinutes;
    if (workMinutes < 0) workMinutes = 0;

    _shiftWorkDurationC.text = toHHmm(workMinutes);
  }

  // BUILD ADVANCE SETTING
  Widget _buildShiftAdvanceTimeDetailsSection() {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Advance Setting'),
          CustomTimePicker(
            setValue: (value) {
              firstHalfUpTo = formatTimeOfDayHHmm(value);
            },
            title: "First Half Up To",
            isRequired: true,
            initialTime: parseTimeOfDayFromHHmm(firstHalfUpTo),
            validator: (value) {
              if (value == null) {
                return "First Half Up To is required";
              }
              return null;
            },
          ),
          CustomTextField(
            title: "Mark Absent If Working Hour less than (in Minutes)",
            textController: _markAbsentInMinutesC,
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            hint: "Enter Minutes",
            onChangeFunction: (value) {
              final minutes = int.tryParse(value) ?? 0;
              final hours = minutes ~/ 60;
              final remainingMinutes = minutes % 60;

              absentWorkingHoursVN.value =
                  "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: absentWorkingHoursVN,
            builder: (_, value, __) {
              return CustomTextField(
                title: "Mark Absent If Working Hour Less than (in Hours)",
                hint: value,
                readOnly: true,
                textController: TextEditingController(),
              );
            },
          ),
          CustomTextField(
            title: "Mark Half Day If Working Hour Less than (in Minutes)",
            textController: _markHalfDayInMinutesC,
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            hint: "Enter Minutes",
            onChangeFunction: (value) {
              final minutes = int.tryParse(value) ?? 0;
              final hours = minutes ~/ 60;
              final remainingMinutes = minutes % 60;

              halfDayWorkingHoursVN.value =
                  "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: halfDayWorkingHoursVN,
            builder: (_, value, __) {
              return CustomTextField(
                title: "Mark Half Day If Working Hour Less than (in Hours)",
                hint: value,
                readOnly: true,
                textController: TextEditingController(),
              );
            },
          ),
          CustomTextField(
            title: "Mark Half Day if Intime After (in Minutes)",
            textController: _markHalfDayIfIntimeAfterC,
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            hint: "Enter Minutes",
            onChangeFunction: (value) {
              final minutes = int.tryParse(value) ?? 0;
              final hours = minutes ~/ 60;
              final remainingMinutes = minutes % 60;

              halfDayInAfterVN.value =
                  "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: halfDayInAfterVN,
            builder: (_, value, __) {
              return CustomTextField(
                title: "Mark Half Day if Intime After (in Hours)",
                readOnly: true,
                hint: value,
                textController: TextEditingController(),
              );
            },
          ),
          CustomTextField(
            title: "Mark Half Day if Outtime Before (in Minutes)",
            textController: _markHalfDayIfOutTimeBeforeC,
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            hint: "Enter Minutes",
            onChangeFunction: (value) {
              final minutes = int.tryParse(value) ?? 0;
              final hours = minutes ~/ 60;
              final remainingMinutes = minutes % 60;

              halfDayOutBeforeVN.value =
                  "${hours.toString().padLeft(2, '0')}:${remainingMinutes.toString().padLeft(2, '0')}";
            },
          ),
          ValueListenableBuilder<String>(
            valueListenable: halfDayOutBeforeVN,
            builder: (_, value, __) {
              return CustomTextField(
                title: "Mark Half Day if Outtime Before (in Hours)",
                readOnly: true,
                hint: value,
                textController: TextEditingController(),
              );
            },
          ),
        ],
      ),
    );
  }

  // BUILD TIME ALLOWED FOR LATE ENTRY DETAILS
  Widget _buildShiftTimeAllowedForLateEntryDetailsSection() {
    return Form(
      key: _formKeys[4],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Time Allowed for Late Entry Details'),
          CustomTextField(
            title: "Grace Time In Minutes",
            isRequired: true,
            textController: _graceTimeC,
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.digit(4),
            hint: "Enter Grace Time",
            onChangeFunction: (value) {
              final minutes = int.tryParse(value) ?? 0;

              graceTimeVN.value = minutes.toString();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Grace Time is required";
              }
              return null;
            },
          ),
          _buildSectionHeader('Late Arrival Action'),
          _buildRadioOption("Count As Late (No Deduction)"),
          _buildRadioOption("Deduct Salary Automatically"),
          _buildRadioOption("Mark As Half Day"),

          if (_selectedLateArrivalAction != null) ...[
            verticalSpacing(),
            CustomTextField(
              title: "Late Count",
              isRequired: true,
              hint: "Enter Late Count",
              keyboardType: TextInputType.number,
              textController: _lateCountC,
              validator: (value) {
                if (_selectedLateArrivalAction != null &&
                    (value == null || value.trim().isEmpty)) {
                  return "Late Count is required";
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  // BUILD RADIO OPTION
  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedLateArrivalAction,
          onChanged: (val) {
            setState(() {
              _selectedLateArrivalAction = val;
            });
          },
        ),
        Expanded(
          child: Text(value, style: AppTextStyle.ts14R(color: AppColor.grey)),
        ),
      ],
    );
  }

  // BUILD REMARKS SECTION
  Widget _buildRemarkSection() {
    return Form(
      key: _formKeys[5],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Remarks'),
          CustomTextField(
            title: "Remarks",
            textController: _remarksC,
            hint: "Enter Remarks",
            keyboardType: TextInputType.text,
            minLines: 3,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
