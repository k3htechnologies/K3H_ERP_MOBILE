import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class ChipStyleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsets margin;
  final bool isSecondaryStyle;
  final Function(int index)? onTabChanged;

  const ChipStyleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin = const EdgeInsets.only(left: 10),
    this.onTabChanged,
    this.isSecondaryStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: margin,
        height: 50.h,
        child:
            isSecondaryStyle
                ? TabBar(
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  controller: controller,
                  isScrollable: true,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: AppColor.grey,
                  labelStyle: AppTextStyle.ts14SB(),
                  unselectedLabelStyle: AppTextStyle.ts14M(),
                  tabAlignment: TabAlignment.start,
                  dividerColor: AppColor.lightBlue,
                  indicator: UnderlineTabIndicator(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(width: 2, color: AppColor.primary),
                  ),
                  tabs:
                      tabs
                          .map(
                            (title) =>
                                Tab(text: title.isEmpty ? 'Unknown' : title),
                          )
                          .toList(),
                )
                : TabBar(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                ),
      ),
    );
  }
}
