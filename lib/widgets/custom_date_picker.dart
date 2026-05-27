import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomDatePicker extends StatefulWidget {
  final Function(DateTime) setValue;
  final bool? isRequired;
  final String? hint;
  final String? label;
  final String? title;
  final DateTime? initialDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool readOnly;
  final FormFieldValidator<DateTime>? validator;
  final bool removeBottomMargin;

  const CustomDatePicker({
    required this.setValue,
    this.isRequired = false,
    this.hint,
    this.label,
    this.title,
    super.key,
    this.initialDate,
    this.startDate,
    this.endDate,
    this.readOnly = false,
    this.validator,
    this.removeBottomMargin = false,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? date;
  String? finalDate;

  @override
  void initState() {
    super.initState();
    date = widget.initialDate;
    finalDate = date != null ? formatDateTimeAsDDMMMYYYY(date!) : null;
  }

  @override
  void didUpdateWidget(CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      date = widget.initialDate;
      finalDate = date != null ? formatDateTimeAsDDMMMYYYY(date!) : null;
    }
  }

  _showDatePicker(BuildContext context, FormFieldState<DateTime> state) {
    showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: widget.startDate ?? DateTime(1900),
      lastDate: widget.endDate ?? DateTime(3000),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.dark(
              primary: AppColor.primary,
              onPrimary: AppColor.white,
              surface: AppColor.white,
              onSurface: AppColor.grey,
            ),
            dialogTheme: DialogThemeData(backgroundColor: AppColor.grey),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        widget.setValue(value);
        setState(() {
          date = value;
          finalDate = formatDateTimeAsDDMMMYYYY(value);
          state.didChange(date);
        });
      }
    });
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
                  : SizedBox(),
            ],
          ),
        FormField<DateTime>(
          validator: widget.validator,
          initialValue: date,
          builder: (FormFieldState<DateTime> formFieldState) {
            final hasError = formFieldState.hasError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: AppColor.white,
                  ),
                  child: InkWell(
                    onTap:
                        () =>
                            widget.readOnly
                                ? null
                                : _showDatePicker(context, formFieldState),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        isDense: true,
                        hintStyle: AppTextStyle.ts14R(),
                        labelText: widget.label,
                        labelStyle: AppTextStyle.ts14R(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 15.0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color:
                                formFieldState.hasError
                                    ? AppColor.error
                                    : AppColor.grey30,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color:
                                formFieldState.hasError
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
                            finalDate ?? "DD-MM-YYYY",
                            style: AppTextStyle.ts14R().copyWith(
                              color:
                                  finalDate != null
                                      ? AppColor.black
                                      : AppColor.grey,
                            ),
                          ),
                          Icon(
                            Icons.calendar_month_outlined,
                            color: AppColor.grey,
                            size: 18.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                hasError
                    ? Container(
                      padding: const EdgeInsets.only(left: 6.0, top: 4.0),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColor.error,
                            size: 14,
                          ),
                          horizontalSpacing(width: 5),
                          Expanded(
                            child: Text(
                              formFieldState.errorText ?? '',
                              style: AppTextStyle.ts12R(color: AppColor.error),
                            ),
                          ),
                        ],
                      ),
                    )
                    : widget.removeBottomMargin
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 18),
              ],
            );
          },
        ),
      ],
    );
  }
}
