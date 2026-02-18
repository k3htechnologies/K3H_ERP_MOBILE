import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomTimePicker extends StatefulWidget {
  final Function(TimeOfDay) setValue;
  final bool? isRequired;
  final String? hint;
  final String? label;
  final String? title;
  final TimeOfDay? initialTime;
  final bool readOnly;
  final FormFieldValidator<TimeOfDay>? validator;

  const CustomTimePicker({
    required this.setValue,
    this.isRequired = false,
    this.hint,
    this.label,
    this.title,
    this.initialTime,
    this.readOnly = false,
    this.validator,
    super.key,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? time;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    time = widget.initialTime;
    selectedDateTime =
    time != null ? _timeOfDayToDateTime(time!) : null;
  }

  @override
  void didUpdateWidget(CustomTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      time = widget.initialTime;
      selectedDateTime =
      time != null ? _timeOfDayToDateTime(time!) : null;
    }
  }

  DateTime _timeOfDayToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
  }

  _showTimePicker(BuildContext context, FormFieldState<TimeOfDay> state) {
    TimeOfDay selected = time ?? TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                verticalSpacing(),
                Text("Select Time", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                Divider(
                  color: AppColor.grey,
                  thickness: .5,
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2021,
                      1,
                      1,
                      selected.hour,
                      selected.minute,
                    ),
                    use24hFormat: true,
                    onDateTimeChanged: (dateTime) {
                      selected = TimeOfDay(
                        hour: dateTime.hour,
                        minute: dateTime.minute,
                      );
                    },
                  ),
                ),
          
                // Done button
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(12.0),
                  child: CustomButton(
                    text: "Done",
                    gradient: LinearGradient(
                      colors: [AppColor.primary, AppColor.primary, AppColor.darkBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      final dateTime = _timeOfDayToDateTime(selected);

                      widget.setValue(selected); // keep TimeOfDay if needed

                      setState(() {
                        time = selected;
                        selectedDateTime = dateTime;
                        state.didChange(selected);
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (widget.title != null)
          Row(
            children: [
              Text(widget.title!, style: AppTextStyle.ts14R()),
              widget.isRequired == true
                  ? Text("*", style: AppTextStyle.ts14R(color: AppColor.error))
                  : const SizedBox(),
            ],
          ),

        FormField<TimeOfDay>(
          validator: widget.validator,
          initialValue: time,
          builder: (formFieldState) {
            final hasError = formFieldState.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColor.white,
                  ),
                  child: InkWell(
                    onTap: widget.readOnly
                        ? null
                        : () => _showTimePicker(context, formFieldState),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: widget.label,
                        labelStyle: AppTextStyle.ts14R(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: hasError
                                ? AppColor.error
                                : AppColor.grey30,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: hasError
                                ? AppColor.error
                                : AppColor.grey30,
                            width: 1.0,
                          ),
                        ),
                        errorStyle: const TextStyle(height: 0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDateTime != null
                                ? DateFormat('HH:mm').format(selectedDateTime!)
                                : "HH:mm",
                            style: AppTextStyle.ts14R().copyWith(
                              color: selectedDateTime != null
                                  ? AppColor.black
                                  : AppColor.grey,
                            ),
                          ),
                          Icon(
                            Icons.access_time,
                            color: AppColor.grey,
                            size: 18,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                hasError
                    ? Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,color: AppColor.error,size: 14,),
                      horizontalSpacing(width: 5),
                      Text(
                        formFieldState.errorText ?? "",
                        style:
                        AppTextStyle.ts12R(color: AppColor.error),
                      ),
                    ],
                  ),
                )
                    : const SizedBox(height: 18),
              ],
            );
          },
        ),
      ],
    );
  }
}