import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProposedOfferTile extends StatelessWidget {
  final String? svgIcon;
  final IconData? icon;
  final String title;
  final Color backgroundColor;
  final double iconSize;
  final double containerSize;
  final Color? iconColor;

  const ProposedOfferTile({
    super.key,
    this.svgIcon,
    this.icon,
    required this.title,
    this.backgroundColor = const Color(0xffF5F6F8),
    this.iconSize = 18,
    this.containerSize = 34,
    this.iconColor,
  }) : assert(
         svgIcon != null || icon != null,
         'Either svgIcon or icon must be provided.',
       );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: containerSize,
          width: containerSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child:
              svgIcon != null
                  ? SvgPicture.asset(
                    svgIcon!,
                    height: iconSize,
                    width: iconSize,
                  )
                  : Icon(icon, size: 22, color: iconColor ?? AppColor.darkBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: AppTextStyle.ts14M(color: AppColor.black)),
        ),
      ],
    );
  }
}

class ProposedOfferInfoCard extends StatelessWidget {
  final String? title;
  final String? tag;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool disable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProposedOfferInfoCard({
    super.key,
    this.title,
    required this.child,
    this.tag,
    this.leading,
    this.trailing,
    this.padding,
    this.onEdit,
    this.onDelete,
    this.disable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: AppColor.darkBlue900, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTextStyle.ts14M(color: AppColor.darkBlue900),
                      ),

                    if (tag != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColor.lightGrey,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColor.grey2),
                        ),
                        child: Text(
                          tag!,
                          style: AppTextStyle.ts14M(
                            color: AppColor.black10.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (trailing != null)
                trailing!
              else
                Row(
                  spacing: 10,
                  children: [
                    if (onEdit != null)
                      CustomIconButton.edit(
                        isDisabled: disable,
                        onPressed: onEdit!,
                      ),

                    if (onDelete != null)
                      CustomIconButton.delete(
                        isDisabled: disable,
                        onPressed: onDelete!,
                      ),
                  ],
                ),
            ],
          ),

          verticalSpacing(height: 12),

          DottedDivider(
            height: 2,
            color: AppColor.grey2,
            dashWidth: 4,
            dashSpace: 4,
          ),
          verticalSpacing(height: 12),

          /// Dynamic Content
          child,
        ],
      ),
    );
  }
}
