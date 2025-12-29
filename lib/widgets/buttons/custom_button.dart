import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget? leading;
  final double elevation;
  final bool isDisable;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final TextStyle? titleTextStyle;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.backgroundColor = AppColor.primary,
    this.textColor = AppColor.white,
    this.borderRadius = 6,
    this.padding = const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
    this.leading,
    this.elevation = 5.0,
    this.isDisable = false,
    required this.onPressed,
    this.borderColor,
    this.titleTextStyle,
    this.boxShadow,
    this.gradient,   // <-- new
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisable ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: gradient != null ? Colors.transparent : backgroundColor,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          // FOR GRADIENT BUTTONS
          gradient: gradient,

          // FOR NORMAL BUTTONS (NOT GRADIENT)
          color: (gradient == null && borderColor == null) ? backgroundColor : null,

          // FOR OUTLINE BUTTONS
          border: borderColor != null ? Border.all(color: borderColor!) : null,

          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                horizontalSpacing(width: 6),
              ],
              Flexible(
                child: Text(
                  text,
                  style: titleTextStyle ??
                      AppTextStyle.ts12SB(
                          color: isDisable ? AppColor.black : textColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Named Constructors ===

  CustomButton.save({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Save',
    leading: Icon(Icons.bookmark_added, color: AppColor.white),
    backgroundColor: AppColor.green.withValues(alpha: 0.8),
    boxShadow: [
      BoxShadow(
        color: AppColor.darkGreen,
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  CustomButton.add({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Add',
    leading: Icon(Icons.add, color: AppColor.white),
    gradient: LinearGradient(
      colors: [AppColor.green, AppColor.darkGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  CustomButton.view({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'View',
    backgroundColor: AppColor.info,
    textColor: AppColor.white,
    boxShadow: [
      BoxShadow(
        color: AppColor.black10.withValues(alpha: 0.02),
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  CustomButton.smallView({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'View',
    backgroundColor: AppColor.info,
    textColor: AppColor.white,
    borderRadius: 10.0,
    titleTextStyle: AppTextStyle.ts14M(color: AppColor.white),
    elevation: 3.0,
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    boxShadow: [
      BoxShadow(
        color: AppColor.black10.withValues(alpha: 0.02),
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  // ---------------- OUTLINE BUTTONS ----------------

// CANCEL (OUTLINE)
  CustomButton.cancelOutline({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Cancel',
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
    textColor: AppColor.grey,
    borderColor: AppColor.grey,
    elevation: 0,
    boxShadow: [],
  );

// RESET (OUTLINE)
  CustomButton.resetOutline({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Reset',
    backgroundColor: Colors.transparent,
    textColor: AppColor.warning,
    borderColor: AppColor.warning,
    elevation: 0,
    boxShadow: [],
  );

}