import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SalesFilterWidget extends StatelessWidget {
  const SalesFilterWidget({
    super.key,
    required this.selectedTab,
    required this.onTap,
    required this.onDateChanged,
    this.initialFromDate,
    this.initialToDate,
  });

  final String selectedTab;
  final ValueChanged<String> onTap;

  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  final void Function(DateTime? fromDate, DateTime? toDate) onDateChanged;

  static const List<String> tabs = [
    "Today",
    "Weekly",
    "Monthly",
    "Datewise",
    "Overall",
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = tabs.indexOf(selectedTab).clamp(0, tabs.length - 1);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / tabs.length;

            return Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffECECF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    left: itemWidth * selectedIndex,
                    top: 4,
                    bottom: 4,
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children:
                        tabs.map((tab) {
                          final selected = tab == selectedTab;

                          return Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                if (!selected) {
                                  onTap(tab);
                                }
                              },
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style:
                                      selected
                                          ? AppTextStyle.ts12SB(
                                            color: AppColor.white,
                                          )
                                          : AppTextStyle.ts12R(
                                            color: AppColor.grey,
                                          ),
                                  child: Text(tab),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        if (selectedTab == 'Datewise') ...[
          verticalSpacing(),
          CustomFromToDatePicker(
            initialFromDate: initialFromDate,
            initialToDate: initialToDate,
            onToDateChanged: onDateChanged,
          ),
        ],
      ],
    );
  }
}
