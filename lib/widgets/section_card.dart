import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;

  final TextStyle? titleTextStyle;

  final Color? titleTextColor;

  final Color? iconContainerColor;

  final Color? iconColor;

  final Color? headerBackgroundColor;

  final double? childSpacing;

  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.titleTextStyle,
    this.titleTextColor,
    this.iconContainerColor = AppColor.lightBlue,
    this.iconColor,
    this.headerBackgroundColor,
    this.childSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null ? _buildViewCard() : _buildNormalCard();
  }

  Widget _buildViewCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias,
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildViewHeader(), _buildViewContent()],
      ),
    );
  }

  Widget _buildViewHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: headerBackgroundColor ?? AppColor.lightBlue,
      child: Text(
        title,
        style: AppTextStyle.ts14SB(color: titleTextColor ?? AppColor.primary),
      ),
    );
  }

  Widget _buildViewContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder:
            (_, __) => Divider(height: 20.h, color: AppColor.lightBlue),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  Widget _buildNormalCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeaderTile(
            title: title,
            textStyle:
                titleTextStyle ?? AppTextStyle.ts14SB(color: titleTextColor),
            icon: icon,
            backgroundColor: iconContainerColor ?? AppColor.lightBlue,
            iconColor: iconColor,
          ),
          verticalSpacing(),
          _buildNormalContent(),
        ],
      ),
    );
  }

  Widget _buildNormalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(children.length, (index) {
        final isLastItem = index == children.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLastItem ? 0 : childSpacing ?? 10.h,
          ),
          child: children[index],
        );
      }),
    );
  }
}
