import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

enum ChipTabBarStyle { outlined, underline, segmented, classic }

class ChipStyleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsets margin;
  final ChipTabBarStyle style;
  final Function(int index)? onTabChanged;

  const ChipStyleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin = const EdgeInsets.only(left: 10),
    this.onTabChanged,
    this.style = ChipTabBarStyle.outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: margin,
        height:
            style == ChipTabBarStyle.underline ||
                    style == ChipTabBarStyle.classic
                ? 35.h
                : 44.h,
        child: switch (style) {
          ChipTabBarStyle.outlined => _buildOutlinedTabBar(),
          ChipTabBarStyle.underline => _buildUnderlineTabBar(),
          ChipTabBarStyle.segmented => _buildSegmentedTabBar(),
          ChipTabBarStyle.classic => _buildClassicTabBar(),
        },
      ),
    );
  }

  /// Outlined Style
  Widget _buildOutlinedTabBar() {
    return TabBar(
      padding: EdgeInsets.zero,

      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: AppColor.primary,
      unselectedLabelColor: AppColor.grey,
      indicator: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 6),
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      dividerColor: Colors.transparent,
      labelStyle: AppTextStyle.ts14M(),
      unselectedLabelStyle: AppTextStyle.ts14M(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      onTap: (index) {
        onTabChanged?.call(index);
      },
      tabs:
          tabs.map((title) {
            return Tab(
              child: Material(
                shadowColor: Colors.transparent,
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(title.isEmpty ? 'Unknown' : title),
                ),
              ),
            );
          }).toList(),
    );
  }

  /// Underline Style
  Widget _buildUnderlineTabBar() {
    return TabBar(
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: 12),
      controller: controller,
      isScrollable: true,
      labelColor: AppColor.primary,
      unselectedLabelColor: AppColor.grey,
      labelStyle: AppTextStyle.ts14SB(),
      unselectedLabelStyle: AppTextStyle.ts14M(),
      tabAlignment: TabAlignment.start,
      dividerColor: AppColor.lightBlue,
      dividerHeight: 1,
      indicator: UnderlineTabIndicator(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(width: 2, color: AppColor.primary),
      ),
      tabs:
          tabs
              .map((title) => Tab(text: title.isEmpty ? 'Unknown' : title))
              .toList(),
    );
  }

  /// Segmented Style
  Widget _buildSegmentedTabBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEF7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6D6E3), width: 1),
        ),
        child: AnimatedBuilder(
          animation: controller.animation!,
          builder: (context, _) {
            final animValue = controller.animation!.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tabs.length, (index) {
                final t = (1 - (animValue - index).abs()).clamp(0.0, 1.0);
                final title = tabs[index].isEmpty ? "Unknown" : tabs[index];

                final bgColor = Color.lerp(
                  AppColor.primary.withValues(alpha: 0),
                  AppColor.primary,
                  t,
                );
                final textColor = Color.lerp(AppColor.grey, Colors.white, t);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.animateTo(index);
                    onTabChanged?.call(index);
                  },
                  child: Container(
                    height: 25.h,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title,
                      style: (t > 0.5
                              ? AppTextStyle.ts14SB()
                              : AppTextStyle.ts14M())
                          .copyWith(color: textColor),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  /// Classic Style
  Widget _buildClassicTabBar() {
    return IntrinsicWidth(
      child: Container(
        height: 35.h,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColor.primary,
          unselectedLabelColor: AppColor.grey,
          indicator: BoxDecoration(
            color: AppColor.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelStyle: AppTextStyle.ts14M(),
          unselectedLabelStyle: AppTextStyle.ts14M(),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: onTabChanged,
          tabs:
              tabs.map((title) {
                return Tab(text: title.isEmpty ? 'Unknown' : title);
              }).toList(),
        ),
      ),
    );
  }
}
