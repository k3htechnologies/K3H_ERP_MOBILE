import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/building_summary.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area.model.dart';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';

class WingSection extends StatefulWidget {
  final WingGroup wing;
  final bool initiallyExpanded;
  const WingSection({
    super.key,
    required this.wing,
    this.initiallyExpanded = false,
  });

  @override
  State<WingSection> createState() => _WingSectionState();
}

class _WingSectionState extends State<WingSection> {
  late final ValueNotifier<bool> _expanded = ValueNotifier(
    widget.initiallyExpanded,
  );

  @override
  void dispose() {
    _expanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wing = widget.wing;

    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      color: AppColor.lightBluebg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _expanded.value = !_expanded.value,
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Row(
                children: [
                  Expanded(child: _label("WING", wing.wing)),
                  Expanded(child: _label("UNIT", wing.flats.length.toString())),
                  ValueListenableBuilder<bool>(
                    valueListenable: _expanded,
                    builder:
                        (_, open, __) => Icon(
                          open
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20.sp,
                          color: AppColor.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1.sp, color: AppColor.dividerColor),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Expanded(
                  child: _info(
                    "FTF Height (Mt)",
                    _fmt(wing.ftfHeight, zero: "0"),
                  ),
                ),
                Expanded(
                  child: _info(
                    "Cumulative Height (Mt)",
                    _fmt(wing.cumulativeHeight, zero: "0"),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _expanded,
            builder: (_, open, __) {
              if (!open) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.fromLTRB(12.sp, 0, 12.sp, 12.sp),
                child: Column(
                  children: [
                    for (int i = 0; i < wing.flats.length; i++)
                      _UnitCard(index: i + 1, flat: wing.flats[i]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyle.ts12M(color: AppColor.primary)),
      Text(value, style: AppTextStyle.ts14M()),
    ],
  );
}

class _UnitCard extends StatelessWidget {
  final int index;
  final ConstructionAreaModel flat;
  const _UnitCard({required this.index, required this.flat});

  @override
  Widget build(BuildContext context) {
    final modifiedBy =
        flat.modifiedBy.isNotEmpty ? flat.modifiedBy : flat.createdBy;
    final modifiedDate = flat.modifiedDate ?? flat.createdDate;

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: AppColor.grey10),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "UNIT ${index.toString().padLeft(2, '0')}",
                        style: AppTextStyle.ts12M(color: AppColor.primary),
                      ),
                      Text(flat.flat, style: AppTextStyle.ts14SB()),
                    ],
                  ),
                ),
                CustomIconButton.edit(onPressed: () {}),
              ],
            ),
          ),
          _divider(),
          _row(
            _info("Unit Type", flat.flatType),
            _info("Configuration", flat.flatConfiguration, chip: true),
          ),
          _divider(),
          _row(
            _info("Area by PL Line (SqMt)", _fmt(flat.areaByPlLineSqMt)),
            _info("Multiplier (%)", _fmt(flat.multiplierForAreaPercentage)),
          ),
          _divider(),
          _row(
            _info("Total Area (SqMt)", _fmt(flat.totalAreaSqMt)),
            _info("Total Area (SqFt)", _fmt(flat.totalAreaSqFt)),
          ),
          _divider(),
          _row(_info("Remarks", flat.remark.isEmpty ? "—" : flat.remark), null),
          _divider(),
          _row(
            _info("Last Modified By", modifiedBy.isEmpty ? "—" : modifiedBy),
            _info(
              "Last Modified Date",
              DateFormat('dd MMM yy').format(modifiedDate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Widget left, Widget? right) => Padding(
    padding: EdgeInsets.all(12.sp),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        Expanded(child: right ?? const SizedBox.shrink()),
      ],
    ),
  );

  Widget _divider() =>
      Divider(height: 1, thickness: 1.sp, color: AppColor.dividerColor);
}

Widget _info(String title, String value, {bool chip = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
      SizedBox(height: 4.sp),
      chip && value.isNotEmpty
          ? Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 2.sp),
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(20.sp),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              value,
              style: AppTextStyle.ts12M(color: AppColor.primary),
            ),
          )
          : Text(value.isEmpty ? "—" : value, style: AppTextStyle.ts14M()),
    ],
  );
}

String _fmt(double v, {String zero = "—"}) =>
    v == 0
        ? zero
        : (v == v.truncateToDouble() ? v.toInt().toString() : v.toString());
