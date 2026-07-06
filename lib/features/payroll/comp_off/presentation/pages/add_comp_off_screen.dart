import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddCompOffScreen extends StatefulWidget {
  final CompOffModel? compOffModel;
  final int? index;
  const AddCompOffScreen({super.key, this.compOffModel, this.index = 0});

  @override
  State<AddCompOffScreen> createState() => _AddCompOffScreenState();
}

class _AddCompOffScreenState extends State<AddCompOffScreen> {
  // CUBIT
  late CompOffCubit _compOffCubit;

  late DateTime _visibleMonth;
  final TextEditingController _reasonController = TextEditingController();

  //EDIT MODE
  bool get _isEditMode => widget.compOffModel != null;

  @override
  void initState() {
    super.initState();
    _compOffCubit = context.read<CompOffCubit>();
    final prefillMonth =
        _isEditMode
            ? DateTime(
              widget.compOffModel!.workingDate.year,
              widget.compOffModel!.workingDate.month,
              1,
            )
            : DateTime.now();
    _visibleMonth = DateTime(prefillMonth.year, prefillMonth.month, 1);

    if (_isEditMode) {
      _prefillForEdit();
    }
    _fetchCompOffDates();
  }

  void _prefillForEdit() {
    final model = widget.compOffModel;
    if (model == null) return;
    _compOffCubit.setWorkedDate(model.workingDate);
    _compOffCubit.setCompOffDate(model.compOffDate);
    _compOffCubit.setReason(model.reason);
    _reasonController.text = model.reason;
  }

  Future<void> _handleSubmit() async {
    final s = _compOffCubit.state;
    final reason = _reasonController.text.trim();

    if (s.workedDate == null) {
      showErrorMessage(context, 'Error', 'Please select Worked Date');
      return;
    }
    if (s.compOffDate == null) {
      showErrorMessage(context, 'Error', 'Please select Comp-Off Date');
      return;
    }
    if (reason.isEmpty) {
      showErrorMessage(context, 'Error', 'Please enter Reason');
      return;
    }

    if (_isEditMode) {
      final model = widget.compOffModel!;
      _compOffCubit.updateCompOff(
        context: context,
        compOffId: model.compOffId,
        uniqueKey: model.uniquekey,
        compOffDate: s.compOffDate!,
        workingDate: s.workedDate!,
        reason: reason,
        index: widget.index ?? 0,
      );
    }

    _compOffCubit.addCompOff(
      context: context,
      compOffDate: s.compOffDate!,
      workingDate: s.workedDate!,
      reason: reason,
    );
  }

  void _fetchCompOffDates() {
    final start = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final end = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
      23,
      59,
    );
    _compOffCubit.getCompOffDatesList(context, 1, start, end);
  }

  bool _isDateHighlighted(DateTime date) {
    return _compOffCubit.state.compOffDatesList.any((compOffDate) {
      final compDate = compOffDate.attendanceDate;
      return compDate.year == date.year &&
          compDate.month == date.month &&
          compDate.day == date.day;
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _onDateSelected(DateTime date) {
    final currentState = _compOffCubit.state;

    if (currentState.workedDate != null && currentState.compOffDate != null) {
      return;
    }

    if (currentState.workedDate == null) {
      if (_isDateHighlighted(date)) {
        _compOffCubit.setWorkedDate(date);
      }
    } else if (currentState.compOffDate == null) {
      if (_isDateHighlighted(date)) {
        _compOffCubit.setWorkedDate(date);
      } else {
        _compOffCubit.setCompOffDate(date);
      }
    }
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _monthTitle(DateTime month) {
    return DateFormat('MMMM').format(month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
    _fetchCompOffDates();
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
    _fetchCompOffDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Comp-Off",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<CompOffCubit, CompOffState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
                Text(
                  _isEditMode ? "Update Comp-Off" : "Add Comp-Off",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(height: 10),

                // CALENDAR WIDGET
                _buildCalendar(state),
                verticalSpacing(height: 20),

                Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // WORKED DATE FIELD
                      _buildDateField(
                        title: "Working Date",
                        date: state.workedDate,
                        onClear: () {
                          _compOffCubit.clearWorkedDate();
                        },
                      ),
                      verticalSpacing(height: 16),

                      // COMP OFF DATE FIELD
                      _buildDateField(
                        title: "Comp-Off Date",
                        date: state.compOffDate,
                        onClear: () {
                          _compOffCubit.clearCompOffDate();
                        },
                      ),
                      verticalSpacing(height: 16),

                      // REASON FIELD
                      CustomTextField(
                        textController: _reasonController,
                        title: "Reason",
                        isRequired: true,
                        hint: "Enter Reason",
                        minLines: 3,
                        maxLines: 5,
                        onChangeFunction: (value) {
                          _compOffCubit.setReason(value);
                        },
                      ),
                    ],
                  ),
                ),

                verticalSpacing(height: 30),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            onPressed: _handleSubmit,
            text: _isEditMode ? "Update" : "Save",
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(CompOffState state) {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final daysInMonth = _daysInMonth(_visibleMonth);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday -> 0
    final totalGridItems = startWeekday + daysInMonth;
    final rows = math.max(6, ((totalGridItems + 6) / 7).floor());
    final paddedItemCount = rows * 7;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.grey30, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month and Year Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: _goToPreviousMonth,
                color: AppColor.primary,
              ),
              Text(_monthTitle(_visibleMonth), style: AppTextStyle.ts16SB()),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: _goToNextMonth,
                color: AppColor.primary,
              ),
            ],
          ),
          verticalSpacing(height: 8),

          // Weekday Header
          _buildWeekdayHeader(),
          verticalSpacing(height: 8),

          // Calendar Grid
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 4.0;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemCount: paddedItemCount,
                itemBuilder: (context, index) {
                  DateTime currentDate;
                  bool isOutOfMonth = false;

                  if (index < startWeekday) {
                    final prevMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month - 1,
                      1,
                    );
                    final prevMonthDays = _daysInMonth(prevMonth);
                    final day = prevMonthDays - (startWeekday - index) + 1;
                    currentDate = DateTime(
                      prevMonth.year,
                      prevMonth.month,
                      day.toInt(),
                    );
                    isOutOfMonth = true;
                  } else if (index >= totalGridItems) {
                    final day = index - totalGridItems + 1;
                    final nextMonth = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month + 1,
                      1,
                    );
                    currentDate = DateTime(
                      nextMonth.year,
                      nextMonth.month,
                      day.toInt(),
                    );
                    isOutOfMonth = true;
                  } else {
                    final day = index - startWeekday + 1;
                    currentDate = DateTime(
                      _visibleMonth.year,
                      _visibleMonth.month,
                      day.toInt(),
                    );
                  }

                  final isHighlighted = _isDateHighlighted(currentDate);
                  final isWorkedDate =
                      state.workedDate != null &&
                      _isSameDate(currentDate, state.workedDate!);
                  final isCompOffDate =
                      state.compOffDate != null &&
                      _isSameDate(currentDate, state.compOffDate!);

                  // Check if selection is disabled (both dates filled)
                  final isSelectionDisabled =
                      state.workedDate != null && state.compOffDate != null;

                  // If worked date is null, only highlighted dates are selectable
                  // If worked date exists, all dates are selectable (for comp-off date)
                  final isDateSelectable =
                      isSelectionDisabled
                          ? false
                          : (state.workedDate == null
                              ? isHighlighted // Only highlighted dates when worked date is null
                              : true); // All dates when worked date exists

                  return GestureDetector(
                    onTap:
                        isDateSelectable
                            ? () => _onDateSelected(currentDate)
                            : null,
                    child: Opacity(
                      opacity: isDateSelectable ? 1.0 : 0.5,
                      child: _DayCell(
                        day: currentDate.day,
                        isHighlighted: isHighlighted,
                        isWorkedDate: isWorkedDate,
                        isCompOffDate: isCompOffDate,
                        isOutOfMonth: isOutOfMonth,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          weekdays.map((day) {
            final isWeekend = day == 'Sa' || day == 'Su';
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTextStyle.ts12R(
                    color: isWeekend ? AppColor.primary : AppColor.grey,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDateField({
    required String title,
    required DateTime? date,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyle.ts14R()),
            Text("*", style: AppTextStyle.ts14R(color: AppColor.error)),
          ],
        ),
        verticalSpacing(height: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: AppColor.white,
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              hintText: "DD/MM/YYYY",
              hintStyle: AppTextStyle.ts14R().copyWith(color: AppColor.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 15.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: AppColor.grey30, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(color: AppColor.primary, width: 1.0),
              ),
              suffixIcon:
                  date != null
                      ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: onClear,
                        color: AppColor.grey,
                      )
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? formatDateTimeAsDDMMMYYYY(date) : "DD/MM/YYYY",
                  style: AppTextStyle.ts14R().copyWith(
                    color: date != null ? AppColor.black : AppColor.grey,
                  ),
                ),
                if (date == null) SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  void dispose() {
    // Clear all state
    _compOffCubit.clearWorkedDate();
    _compOffCubit.setReason('');
    _reasonController.dispose();
    super.dispose();
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isHighlighted;
  final bool isWorkedDate;
  final bool isCompOffDate;
  final bool isOutOfMonth;

  const _DayCell({
    required this.day,
    required this.isHighlighted,
    required this.isWorkedDate,
    required this.isCompOffDate,
    required this.isOutOfMonth,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColor.white;
    Color textColor = AppColor.black;
    Border? border;

    if (isOutOfMonth) {
      textColor = AppColor.grey30;
    } else if (isHighlighted) {
      // Highlighted dates from API - light blue border
      border = Border.all(color: AppColor.primary, width: 1.5);
      backgroundColor = AppColor.lightBlue.withValues(alpha: 0.3);
    } else if (isWorkedDate) {
      // Worked date - different background
      backgroundColor = AppColor.lightGreen;
      textColor = AppColor.darkGreen;
      border = Border.all(color: AppColor.darkGreen, width: 1.5);
    } else if (isCompOffDate) {
      // Comp-off date - green color
      backgroundColor = AppColor.lightGreen;
      textColor = AppColor.darkGreen;
      border = Border.all(color: AppColor.darkGreen, width: 1.5);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: border,
      ),
      child: Center(
        child: Text('$day', style: AppTextStyle.ts12R(color: textColor)),
      ),
    );
  }
}
