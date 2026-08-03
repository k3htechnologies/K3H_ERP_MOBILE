import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomCheckBox extends StatefulWidget {
  final bool isSelected;
  final String? title;
  final Function(bool)? onChanged;
  final bool isDisabled;
  const CustomCheckBox({
    super.key,
    required this.isSelected,
    this.title,
    this.onChanged,
    this.isDisabled = false,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  void didUpdateWidget(CustomCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state when widget's isSelected changes
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6.0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (widget.isDisabled) {
              return;
            }
            if (widget.onChanged != null) {
              widget.onChanged!(!widget.isSelected);
            }
          },
          child: Container(
            width: 20,
            height: 20,
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  widget.isSelected
                      ? widget.isDisabled
                          ? AppColor.grey2.withValues(alpha: 0.2)
                          : AppColor.lightBlue
                      : AppColor.white,
              border:
                  widget.isDisabled
                      ? Border.all(color: AppColor.grey2, width: 1.0)
                      : widget.isSelected
                      ? Border.all(color: AppColor.primary, width: 1.0)
                      : Border.all(color: AppColor.grey, width: 1.0),
              borderRadius: BorderRadius.circular(2),
            ),
            child:
                widget.isSelected
                    ? Icon(
                      Icons.check,
                      size: 18,
                      color:
                          widget.isDisabled ? AppColor.grey2 : AppColor.primary,
                    )
                    : null,
          ),
        ),

        if (widget.title != null)
          Flexible(
            child: Text(
              widget.title!,
              style: AppTextStyle.ts14M(
                color:
                    widget.isDisabled
                        ? AppColor.grey2
                        : widget.isSelected
                        ? AppColor.grey
                        : AppColor.black,
              ),
            ),
          ),
      ],
    );
  }
}
