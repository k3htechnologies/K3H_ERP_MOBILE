import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomDatePicker extends StatefulWidget {
  final Function(DateTime?) setValue;
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
    final firstDate = widget.startDate ?? DateTime(1900);
    final lastDate = widget.endDate ?? DateTime(3000);

    DateTime initialDate = date ?? DateTime.now();

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
        });

        state.didChange(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  widget.title!,
                  style: AppTextStyle.ts14R(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (widget.isRequired == true)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    "*",
                    style: AppTextStyle.ts14R(color: AppColor.error),
                  ),
                ),
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
                          Expanded(
                            child: Text(
                              finalDate ?? "DD-MM-YYYY",
                              style: AppTextStyle.ts14R().copyWith(
                                color:
                                    finalDate != null
                                        ? AppColor.black
                                        : AppColor.grey,
                              ),
                            ),
                          ),

                          // CLEAR BUTTON
                          if (finalDate != null && !widget.readOnly)
                            GestureDetector(
                              onTap: () {
                                widget.setValue(null);

                                setState(() {
                                  date = null;
                                  finalDate = null;
                                });

                                formFieldState.didChange(null);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColor.grey,
                                ),
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
