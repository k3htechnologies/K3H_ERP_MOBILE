import 'package:flutter/material.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';

class CustomFromToDatePicker extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final String? fromDateTitle;
  final String? toDateTitle;
  final bool isRequired;
  final bool removeBottomMargin;

  final Function(DateTime? fromDate, DateTime? toDate) onToDateChanged;

  /// Validators
  final String? Function(DateTime?)? fromDateValidator;
  final String? Function(DateTime?)? toDateValidator;

  const CustomFromToDatePicker({
    super.key,
    this.initialFromDate,
    this.initialToDate,
    this.isRequired = false,
    required this.onToDateChanged,
    this.removeBottomMargin = true,
    this.fromDateTitle = 'From',
    this.toDateTitle = 'To',
    this.fromDateValidator,
    this.toDateValidator,
  });

  @override
  State<CustomFromToDatePicker> createState() => _CustomFromToDatePickerState();
}

class _CustomFromToDatePickerState extends State<CustomFromToDatePicker> {
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate;
    toDate = widget.initialToDate;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomDatePicker(
            title: widget.fromDateTitle,
            initialDate: fromDate,
            isRequired: widget.isRequired,
            endDate: toDate,
            removeBottomMargin: widget.removeBottomMargin,
            validator: widget.fromDateValidator,
            setValue: (value) {
              setState(() {
                fromDate = value;
                toDate = null;
              });
              widget.onToDateChanged(fromDate, toDate);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomDatePicker(
            title: widget.toDateTitle,
            initialDate: toDate,
            isRequired: widget.isRequired,
            startDate: fromDate,
            readOnly: fromDate == null,
            removeBottomMargin: widget.removeBottomMargin,
            validator: widget.toDateValidator,
            setValue: (value) {
              setState(() {
                toDate = value;
              });
              widget.onToDateChanged(fromDate, toDate);
            },
          ),
        ),
      ],
    );
  }
}
