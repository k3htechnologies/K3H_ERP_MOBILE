import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomMonthYearPicker extends StatefulWidget {
  final Function(DateTime) setValue;
  final bool? isRequired;
  final String? hint;
  final String? title;
  final DateTime? initialDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool readOnly;
  final FormFieldValidator<DateTime>? validator;

  const CustomMonthYearPicker({
    required this.setValue,
    this.isRequired = false,
    this.hint,
    this.title,
    super.key,
    this.initialDate,
    this.startDate,
    this.endDate,
    this.readOnly = false,
    this.validator,
  });

  @override
  State<CustomMonthYearPicker> createState() => _CustomMonthYearPickerState();
}

class _CustomMonthYearPickerState extends State<CustomMonthYearPicker> {
  DateTime? date;
  String? finalDate;

  static const List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void initState() {
    super.initState();
    date = widget.initialDate;
    finalDate = _format(date);
  }

  @override
  void didUpdateWidget(CustomMonthYearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      date = widget.initialDate;
      finalDate = _format(date);
    }
  }

  String? _format(DateTime? value) {
    if (value == null) return null;
    return "${_months[value.month - 1]} ${value.year}";
  }

  Future<void> _showPicker(FormFieldState<DateTime> state) async {
    final now = DateTime.now();

    int selectedYear = date?.year ?? now.year;
    int selectedMonth = date?.month ?? now.month;

    final minYear = widget.startDate?.year ?? 1900;
    final maxYear = widget.endDate?.year ?? 3000;

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isDisabled(int m) {
              final d = DateTime(selectedYear, m);
              if (widget.startDate != null && d.isBefore(widget.startDate!))
                return true;
              if (widget.endDate != null && d.isAfter(widget.endDate!))
                return true;
              return false;
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// YEAR HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              selectedYear > minYear
                                  ? () => setDialogState(() => selectedYear--)
                                  : null,
                          icon: const Icon(Icons.chevron_left),
                        ),

                        Expanded(
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                final year = await showModalBottomSheet<int>(
                                  context: context,
                                  builder: (_) {
                                    return ListView.builder(
                                      itemCount: maxYear - minYear + 1,
                                      itemBuilder: (_, i) {
                                        final y = minYear + i;
                                        return ListTile(
                                          title: Text(y.toString()),
                                          onTap:
                                              () => Navigator.pop(context, y),
                                        );
                                      },
                                    );
                                  },
                                );
                                if (year != null) {
                                  setDialogState(() => selectedYear = year);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColor.grey30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  selectedYear.toString(),
                                  style: AppTextStyle.ts14R(),
                                ),
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed:
                              selectedYear < maxYear
                                  ? () => setDialogState(() => selectedYear++)
                                  : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// MONTH GRID
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final selected = selectedMonth == m;
                        final disabled = isDisabled(m);

                        return InkWell(
                          onTap:
                              disabled
                                  ? null
                                  : () => Navigator.pop(
                                    context,
                                    DateTime(selectedYear, m),
                                  ),
                          child: Container(
                            width: 80,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? AppColor.primary.withValues(alpha: 0.1)
                                      : null,
                              border: Border.all(
                                color:
                                    selected
                                        ? AppColor.primary
                                        : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _months[i],
                              style: TextStyle(
                                color:
                                    disabled
                                        ? Colors.grey
                                        : selected
                                        ? AppColor.primary
                                        : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      widget.setValue(picked);
      setState(() {
        date = picked;
        finalDate = _format(picked);
        state.didChange(picked);
        state.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      validator: widget.validator,
      initialValue: date,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(widget.title!, style: AppTextStyle.ts14R()),
              const SizedBox(height: 4),
            ],

            InkWell(
              onTap: widget.readOnly ? null : () => _showPicker(state),
              child: InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  hintStyle: AppTextStyle.ts14R(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 15.0,
                  ),

                  /// ✅ FIXED HERE
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: hasError ? AppColor.error : AppColor.grey30,
                      width: 1.0,
                    ),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide: BorderSide(
                      color: hasError ? AppColor.error : AppColor.grey30,
                      width: 1.0,
                    ),
                  ),

                  errorStyle: const TextStyle(height: 0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      finalDate ?? (widget.hint ?? "MM-YYYY"),
                      style: AppTextStyle.ts14R().copyWith(
                        color:
                            finalDate != null ? AppColor.black : AppColor.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_month, color: AppColor.grey),
                  ],
                ),
              ),
            ),

            if (hasError)
              Container(
                padding: const EdgeInsets.only(left: 12, top: 4),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColor.error, size: 14),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        state.errorText ?? '',
                        style: AppTextStyle.ts12R(color: AppColor.error),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 18),
          ],
        );
      },
    );
  }
}
