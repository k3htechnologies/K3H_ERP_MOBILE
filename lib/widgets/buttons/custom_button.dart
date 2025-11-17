import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final IconData? icon;
  final Color iconColor;
  final double elevation;
  final double height;
  final Color? borderColor;
  final TextStyle? titleTextStyle;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColor.primary,
    this.textColor = AppColor.white,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    this.icon,
    this.iconColor = AppColor.white,
    this.elevation = 5.0,
    this.height = 44.0,
    this.borderColor,
    this.titleTextStyle,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow:
        boxShadow ??
            [
              BoxShadow(
                color: AppColor.black,
                offset: Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
                inset: true,
              ),
            ],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.transparent,
          surfaceTintColor: AppColor.grey,
          disabledBackgroundColor: AppColor.white,
          side: BorderSide(color: borderColor ?? Colors.transparent),
          padding: padding,
          elevation: 0, // disable internal elevation, using shadow instead
          fixedSize: Size.fromHeight(height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                text,
                style: titleTextStyle ?? AppTextStyle.ts16SB(color: textColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
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
    icon: Icons.bookmark_added,
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

  CustomButton.cancel({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Cancel',
    icon: Icons.do_disturb_alt,
    backgroundColor: AppColor.error,
    textColor: AppColor.white,
    iconColor: AppColor.white,
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

  CustomButton.add({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Add',
    icon: Icons.add,
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

  CustomButton.import({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Import',
    icon: Icons.upload_file,
    backgroundColor: AppColor.warning,
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

  CustomButton.close({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Close',
    icon: Icons.cancel_outlined,
    backgroundColor: Color(0XFF9E9E9E),
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

  CustomButton.copy({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Copy',
    icon: Icons.copy,
    backgroundColor: AppColor.info,
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
    height: 30.0,
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

  CustomButton.small({
    Key? key,
    required String title,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
  }) : this(
    key: key,
    onPressed: onPressed,
    text: title,
    icon: icon,
    backgroundColor:
    backgroundColor ?? AppColor.green.withValues(alpha: 0.8),
    borderRadius: 10,
    height: 36,
    titleTextStyle: AppTextStyle.ts14M(color: AppColor.white),
    elevation: 3,
    padding: EdgeInsets.symmetric(horizontal: 10),
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

  CustomButton.smallSave({Key? key, required VoidCallback onPressed})
      : this.small(
    key: key,
    title: 'Save',
    onPressed: onPressed,
    icon: Icons.bookmark_added,
  );

  CustomButton.split({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Split',
    icon: Icons.swap_horiz,
    backgroundColor: AppColor.green.withValues(alpha: 0.8),
    textColor: AppColor.white,
    iconColor: AppColor.white,
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

  CustomButton.export({
    Key? key,
    required BuildContext context,
    required Function(String) onPressed,
  }) : this(
    key: key,
    onPressed: () async {
      final RenderBox button = context.findRenderObject() as RenderBox;
      final Offset offset = button.localToGlobal(Offset.zero);

      final selected = await showMenu<String>(
        context: context,
        color: AppColor.white,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + button.size.height * 0.23,
          0,
          0,
        ),
        items: [
          PopupMenuItem(
            value: 'PDF',
            child: Text('Export as PDF', style: AppTextStyle.ts14M()),
          ),
          PopupMenuDivider(height: 0.2),
          PopupMenuItem(
            value: 'EXCEL',
            child: Text('Export as Excel', style: AppTextStyle.ts14M()),
          ),
        ],
      );

      if (selected != null) {
        onPressed(selected);
      }
    },
    text: 'Export',
    icon: Icons.save_alt_rounded,
    backgroundColor: AppColor.blue,
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

  CustomButton.approveReject({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'App / Rej',
    backgroundColor: AppColor.green.withValues(alpha: 0.8),
    textColor: AppColor.white,
    iconColor: AppColor.white,
    boxShadow: [],
  );
}