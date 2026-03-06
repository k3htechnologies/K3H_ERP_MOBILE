import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class ChipStyleTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsets margin;

  const ChipStyleTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin = const EdgeInsets.only(left: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: margin,
        height: 40,
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
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 6),
          dividerColor: Colors.transparent,
          labelStyle: AppTextStyle.ts14M(),
          unselectedLabelStyle: AppTextStyle.ts14M(),
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          tabs: tabs.map((title) {
            return Tab(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.grey.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(title),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}