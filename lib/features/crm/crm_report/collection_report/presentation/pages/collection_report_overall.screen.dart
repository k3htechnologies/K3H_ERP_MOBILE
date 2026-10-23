import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/model/collection_report_project_wise.model.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/pages/widgets/collection_report_card.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CollectionReportOverallScreen extends StatefulWidget {
  final List<CollectionReportProjectWiseModel>?
  collectionReportProjectWiseModel;
  final int totalUnits;
  final int residentialUnits;
  final int commercialUnits;
  const CollectionReportOverallScreen({
    super.key,
    this.collectionReportProjectWiseModel,
    required this.totalUnits,
    required this.residentialUnits,
    required this.commercialUnits,
  });

  @override
  State<CollectionReportOverallScreen> createState() =>
      _CollectionReportOverallScreenState();
}

class _CollectionReportOverallScreenState
    extends State<CollectionReportOverallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Collection Report Overview",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        widget
                            .collectionReportProjectWiseModel!
                            .first
                            .projectName,
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  TextSpan(text: " > "),
                  TextSpan(
                    text:
                        "Wing ${widget.collectionReportProjectWiseModel!.first.wing}",
                    style: AppTextStyle.ts14M(),
                  ),
                ],
                style: AppTextStyle.ts14M(),
              ),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.all(12.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.sp),
                color: AppColor.lightBluebg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.layers,
                    weight: 18.sp,
                    color: AppColor.primary,
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: Text(
                      "Total Units: ${widget.totalUnits} (Residential: ${widget.residentialUnits} | Commercial: ${widget.commercialUnits})",
                      style: AppTextStyle.ts12M(color: AppColor.primary),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUnitTypeCard(
                      unitType: "Residential",
                      dotColor: AppColor.yellow,
                    ),
                    verticalSpacing(height: 12.sp),
                    _buildUnitTypeCard(
                      unitType: "Commercial",
                      dotColor: Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitTypeCard({
    required String unitType,
    required Color dotColor,
  }) {
    final rows =
        (widget.collectionReportProjectWiseModel ?? [])
            .where((e) => e.unitType == unitType)
            .toList();

    if (rows.isEmpty) return const SizedBox.shrink();

    final total = rows.where((e) => e.type == 'Total').firstOrNull;
    final allotted =
        rows.where((e) => e.type == 'Allotted / Member').firstOrNull;
    final booked = rows.where((e) => e.type == 'Booked / Sale').firstOrNull;

    return CollectionReportCard(
      title: "$unitType Units",
      dotColor: dotColor,
      bodyColor: Color(0xffEEF5FB),
      subTitle:
          "${total?.totalUnit ?? 0} Units (Allotted: ${allotted?.totalUnit ?? 0} | Booked: ${booked?.totalUnit ?? 0})",
      body: Column(
        children: [
          _buildSectionTile(
            "Total",
            rows.where((e) => e.type == "Total").toList(),
          ),
          verticalSpacing(height: 10.sp),
          _buildSectionTile(
            "Allotted / Member",
            rows.where((e) => e.type == "Allotted / Member").toList(),
          ),
          verticalSpacing(height: 10.sp),
          _buildSectionTile(
            "Booked / Sale",
            rows.where((e) => e.type == "Booked / Sale").toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTile(
    String title,
    List<CollectionReportProjectWiseModel> items,
  ) {
    return CollapsibleBox(
      title: title,
      initiallyExpanded: title == "Total",
      child:
          items.isEmpty
              ? Padding(padding: EdgeInsets.all(16), child: noDataWidget())
              : Column(
                children:
                    items
                        .map(
                          (e) => CollectionSectinCard(
                            item: e,
                            formatCurrency: (v) => v.toIndianCurrency(),
                          ),
                        )
                        .toList(),
              ),
    );
  }
}

class CollapsibleBox extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final Color expandedHeaderColor;
  final Color collapsedHeaderColor;
  final Color expandedTitleColor;
  final Color collapsedTitleColor;
  final Color iconColor;
  final Color bodyColor;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry headerPadding;

  const CollapsibleBox({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expandedHeaderColor = AppColor.lightBlue,
    this.collapsedHeaderColor = Colors.white,
    this.expandedTitleColor = AppColor.primary,
    this.collapsedTitleColor = const Color(0xFF111827),
    this.iconColor = AppColor.grey,
    this.bodyColor = Colors.white,
    this.borderColor = AppColor.dividerColor,
    this.radius = 14,
    this.headerPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  });

  @override
  State<CollapsibleBox> createState() => _CollapsibleBoxState();
}

class _CollapsibleBoxState extends State<CollapsibleBox> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.bodyColor,
        borderRadius: BorderRadius.circular(widget.radius),
        border:
            widget.borderColor == null
                ? null
                : Border.all(color: widget.borderColor!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              color:
                  _expanded
                      ? widget.expandedHeaderColor
                      : widget.collapsedHeaderColor,
              padding: widget.headerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyle.ts14SB(
                        color:
                            _expanded
                                ? widget.expandedTitleColor
                                : widget.collapsedTitleColor,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: widget.iconColor,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child:
                _expanded
                    ? widget.child
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class DetailBlock extends StatelessWidget {
  final String title;
  final Color color;
  final Widget left;
  final Widget right;
  final bool showDivider;

  const DetailBlock({
    super.key,
    required this.title,
    required this.color,
    required this.left,
    required this.right,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts14M(color: color)),
        verticalSpacing(height: 8.sp),
        Row(children: [Expanded(child: left), Expanded(child: right)]),
        if (showDivider) ...[
          verticalSpacing(height: 14.sp),
          const Divider(height: 1, color: AppColor.dividerColor),
          verticalSpacing(height: 14.sp),
        ],
      ],
    );
  }
}

class AmountRow {
  final String label;
  final double value;
  final Color color;
  const AmountRow(this.label, this.value, this.color);
}

class AmountGroup extends StatelessWidget {
  final String title;
  final List<AmountRow> rows;
  final bool initiallyExpanded;
  final String Function(double) format;

  const AmountGroup({
    super.key,
    required this.title,
    required this.rows,
    required this.format,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return CollapsibleBox(
      title: title,
      initiallyExpanded: initiallyExpanded,
      radius: 6.sp,
      borderColor: null,
      bodyColor: AppColor.lightGreen100,
      expandedHeaderColor: AppColor.lightGreen100,
      collapsedHeaderColor: AppColor.lightGreen100,
      expandedTitleColor: AppColor.darkGreen50,
      collapsedTitleColor: AppColor.darkGreen50,
      iconColor: AppColor.grey,
      headerPadding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: buildRowTitleValue(
                  title: rows[i].label,
                  value: format(rows[i].value),
                  valueTextStyle: AppTextStyle.ts14SB(color: rows[i].color),
                  singleLine: false,
                ),
              ),
              if (i != rows.length - 1)
                const Divider(height: 1, color: AppColor.dividerColor),
            ],
          ],
        ),
      ),
    );
  }
}

class CollectionSectinCard extends StatelessWidget {
  final CollectionReportProjectWiseModel item;
  final String Function(double) formatCurrency;

  const CollectionSectinCard({
    super.key,
    required this.item,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailBlock(
            title: 'Total Unit Details',
            color: AppColor.primary,
            left: buildColumnTitleValue(
              title: "Units",
              value: item.totalUnit.toString(),
              removeExpanded: true,
            ),

            right: buildColumnTitleValue(
              title: "RERA Carpet Area (SqFt)",
              value: item.totalUnit.toString(),
              removeExpanded: true,
            ),
          ),
          DetailBlock(
            title: "Registration Details",
            color: AppColor.orangeColor,
            left: buildColumnTitleValue(
              title: "Completed",
              value: item.registrationCompleted.toString(),
              removeExpanded: true,
            ),
            right: buildColumnTitleValue(
              title: "Pending",
              value: item.registrationPending.toString(),
              customValueWidget: Text(
                item.registrationPending.toString(),
                style: AppTextStyle.ts14SB(color: AppColor.orangeColor),
              ),
              removeExpanded: true,
            ),
          ),
          DetailBlock(
            title: "Alloted / Booked Details",
            color: AppColor.purple,
            left: buildColumnTitleValue(
              title: "Count",
              value: item.totalUnit.toString(),
              removeExpanded: true,
            ),
            right: buildColumnTitleValue(
              title: "RERA Carpet Area (SqFt)",
              value: item.totalReraCarpetAreaSqFt.toString(),
              removeExpanded: true,
            ),
          ),
          Text(
            'Amount Details',
            style: AppTextStyle.ts14M(color: AppColor.green),
          ),
          verticalSpacing(),
          AmountGroup(
            title: "Agreement Amount Details",
            initiallyExpanded: true,
            format: formatCurrency,
            rows: [
              AmountRow("Agreement", item.totalAgreementValue, AppColor.black),
              AmountRow("Due", item.dueAmount, AppColor.orangeColor),
              AmountRow('Received', item.receivedAmount, AppColor.darkGreen50),
              AmountRow(
                'Outstanding',
                item.balanceAmount,
                AppColor.missingInformationRed,
              ),
            ],
          ),
          verticalSpacing(),
          AmountGroup(
            title: "GST Amount Details",
            format: formatCurrency,
            rows: [
              AmountRow("GST", item.totalGstValue, AppColor.black),
              AmountRow(
                "Received",
                item.gstReceivedAmount,
                AppColor.darkGreen50,
              ),
              AmountRow(
                "Outstanding",
                item.gstBalanceAmount,
                AppColor.missingInformationRed,
              ),
            ],
          ),
          verticalSpacing(),
          AmountGroup(
            title: "TDS Amount Details",
            format: formatCurrency,
            rows: [
              AmountRow("TDS", item.totalTdsValue, AppColor.black),
              AmountRow(
                "Received",
                item.tdsReceivedAmount,
                AppColor.darkGreen50,
              ),
              AmountRow(
                "Outstanding",
                item.tdsBalanceAmount,
                AppColor.missingInformationRed,
              ),
            ],
          ),
          verticalSpacing(),
          AmountGroup(
            title: "Stamp Duty Amount Details",
            format: formatCurrency,
            rows: [
              AmountRow('Stamp Duty', item.totalStampDutyValue, AppColor.black),
              AmountRow(
                'Received',
                item.stampDutyReceivedAmount,
                AppColor.darkGreen50,
              ),
              AmountRow(
                'Outstanding',
                item.stampDutyBalanceAmount,
                AppColor.missingInformationRed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
