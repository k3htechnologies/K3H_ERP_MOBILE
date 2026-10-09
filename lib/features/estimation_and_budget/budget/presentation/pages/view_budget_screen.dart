import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/budget_level_status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewBudgetMasterScreen extends StatefulWidget {
  final List<BudgetModel> budgetList;
  const ViewBudgetMasterScreen({super.key, required this.budgetList});
  @override
  State<ViewBudgetMasterScreen> createState() => _ViewBudgetMasterScreenState();
}

class _ViewBudgetMasterScreenState extends State<ViewBudgetMasterScreen> {
  static const _kPurple = Color(0xFF3B2F9E);
  static const _kBorder = Color(0xFFE3E6F0);
  static const _kSoft = Color(0xFFF9F8FF);
  static const _kSummaryStart = Color(0xFFF1EFFF);
  static const _kSummaryBorder = Color(0xFFD9D5F5);
  late TextEditingController _searchC;
  @override
  void initState() {
    _searchC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  TextStyle get _mutedStyle =>
      AppTextStyle.ts12M(color: AppColor.black.withValues(alpha: 0.5));
  bool _matches(BudgetModel b, String query) =>
      query.isEmpty || b.categoryName.toLowerCase().contains(query);

  /// True if any L4 under this L3 matches.
  bool _anyL4Matches(BudgetModel l3, List<BudgetModel> all, String query) =>
      all.any(
        (e) =>
            e.levelType == 'L4' &&
            e.levelId3 == l3.levelId3 &&
            _matches(e, query),
      );

  /// An L3 is visible when its parent L2 matches, it matches itself,
  /// or any of its L4 children match.
  bool _l3Visible(
    BudgetModel l2,
    BudgetModel l3,
    List<BudgetModel> all,
    String query,
  ) =>
      _matches(l2, query) ||
      _matches(l3, query) ||
      _anyL4Matches(l3, all, query);
  void showDialog(
    BuildContext context, {
    required String title,
    required String note,
  }) {
    final ScrollController controller = ScrollController();
    //FOR FLATS LISTING IN VIEW
    final List<String> items =
        note
            .split(',')
            .map((e) => e.replaceAll(RegExp(r'\s+'), ' ').trim())
            .where((e) => e.isNotEmpty)
            .toList();

    DialogHelper.showCustomDialogue(
      context,
      title: title == 'Flats' ? "$title (${items.length})" : title,
      childContent: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: RawScrollbar(
          controller: controller,
          thumbVisibility: true,
          thumbColor: AppColor.lightBlue,
          radius: const Radius.circular(8),
          child: ListView.builder(
            controller: controller,
            shrinkWrap: true,
            padding: const EdgeInsets.only(right: 8),
            itemCount: items.length,
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title == 'Flats')
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 8),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title == 'Flats' ? items[index] : note,
                          style: AppTextStyle.ts14R(),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l1List = widget.budgetList.where((e) => e.levelType == 'L1').toList();
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Budget',
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showSiteSelectedWidget(),
            SizedBox(height: 8.h),
            SearchWidget(
              textController: _searchC,
              onSubmit: (_) {},
              hintText: 'Search By Category Name',
            ),
            SizedBox(height: 8.h),
            if (l1List.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  children: [
                    Text(
                      'L1 Category :',
                      style: AppTextStyle.ts12M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      l1List.first.level1Name,
                      style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
                    ),
                  ],
                ),
              ),
            Expanded(
              child:
                  l1List.isEmpty
                      ? Center(
                        child: noDataWidget(message: 'No Budget Data Found'),
                      )
                      : ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchC,
                        builder: (context, value, _) {
                          final query = value.text.trim().toLowerCase();
                          return ListView.builder(
                            itemCount: l1List.length,
                            itemBuilder:
                                (_, i) => _budgetHierarchy(
                                  l1List[i],
                                  widget.budgetList,
                                  query,
                                ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetHierarchy(
    BudgetModel l1,
    List<BudgetModel> budgetList,
    String query,
  ) {
    final sameL1 = budgetList.where((e) => e.levelId1 == l1.levelId1).toList();
    final l2List =
        sameL1
            .where(
              (l2) =>
                  l2.levelType == 'L2' &&
                  (_matches(l2, query) ||
                      sameL1.any(
                        (l3) =>
                            l3.levelType == 'L3' &&
                            l3.levelId2 == l2.levelId2 &&
                            _l3Visible(l2, l3, sameL1, query),
                      )),
            )
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _l1SummaryCard(l1),
        if (query.isNotEmpty && l2List.isEmpty)
          SizedBox(
            width: double.infinity,
            height: 0.4.sh,
            child: Center(child: noDataWidget()),
          ),
        ...l2List.map((l2) {
          final l3List =
              sameL1
                  .where(
                    (e) =>
                        e.levelType == 'L3' &&
                        e.levelId2 == l2.levelId2 &&
                        _l3Visible(l2, e, sameL1, query),
                  )
                  .toList();
          return CustomExpandableCard(
            key: ValueKey('l2_${l2.levelId2}_$query'),
            margin: EdgeInsets.only(bottom: 14.h),
            initiallyExpanded: query.isNotEmpty,
            header: _cardHeader(
              level: 'L2',
              wbs: l2.wBSCode,
              title: l2.categoryName,
              amount: l2.budgetAmount,
            ),
            body: Column(
              children: [
                _costBreakdown(l2),
                SizedBox(height: 12.h),
                for (final l3 in l3List) _l3Card(l2, l3, sameL1, query),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _l1SummaryCard(BudgetModel budget) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kSummaryStart, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _kSummaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            amount: budget.budgetAmount,
            level: budget.levelType,
            title: budget.level1Name,
            wbs: budget.wBSCode,
          ),
          SizedBox(height: 14.h),
          _costBreakdown(budget),
        ],
      ),
    );
  }

  Widget _l3Card(
    BudgetModel l2,
    BudgetModel l3,
    List<BudgetModel> all,
    String query,
  ) {
    final showAllL4 = _matches(l2, query) || _matches(l3, query);
    final l4List =
        all
            .where(
              (e) =>
                  e.levelType == 'L4' &&
                  e.levelId3 == l3.levelId3 &&
                  (showAllL4 || _matches(e, query)),
            )
            .toList();
    return CustomExpandableCard(
      key: ValueKey('l3_${l3.budgetId}_$query'),
      initiallyExpanded: _searchC.text.trim().isNotEmpty ? true : false,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _kBorder),
      ),
      header: _cardHeader(
        level: 'L3',
        wbs: l3.wBSCode,
        title: l3.categoryName,
        subtitle: 'Quantity: ${l3.quantity.addCommas()} ${l3.uom}',
        amount: l3.budgetAmount,
        remark: l3.remark,
        flat: l3.flat,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _costBreakdown(l3),
          if (l4List.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                _levelBadge('L4'),
                SizedBox(width: 10.w),
                Text('MATERIALS (${l4List.length})', style: _mutedStyle),
              ],
            ),
            SizedBox(height: 8.h),
            ...l4List.map(_l4Tile),
          ],
        ],
      ),
    );
  }

  Widget _l4Tile(BudgetModel l4) {
    final totalQty = (l4.l3Quantity * l4.quantity).addCommas();
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: _kSoft,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 3.w,
              decoration: BoxDecoration(
                color: _kPurple,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(8.r),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l4.categoryName,
                            style: AppTextStyle.ts14M(
                              color: AppColor.darkBlue900,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        _wbsChip(l4.wBSCode),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Expanded(
                      child: Text(
                        '· Quantity: $totalQty ${l4.uom}\n'
                        '· Order QTY: ${l4.orderQuantity.addCommas()} ${l4.uom}\n'
                        '· Received QTY: ${l4.receivedQuantity.addCommas()} ${l4.uom}',
                        style: _mutedStyle,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    budgetAmountRemarkSection(
                      amount: l4.budgetAmount,
                      level: l4.levelType,
                      remark: l4.remark,
                      flat: l4.flat,
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

  Widget _levelBadge(String text) {
    final config = budgetLevelConfig[text];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: config?.backgroundColor ?? AppColor.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: AppTextStyle.ts12M(color: config?.textColor ?? AppColor.white),
      ),
    );
  }

  Widget _wbsChip(String wbs) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: AppColor.white,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: _kBorder),
    ),
    child: Text(
      'WBS $wbs',
      style: AppTextStyle.ts12M(color: AppColor.black.withValues(alpha: 0.7)),
    ),
  );
  Widget _stat(String label, double value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _mutedStyle),
        SizedBox(height: 2.h),
        Text(
          value.toIndianCurrency(),
          style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
        ),
      ],
    ),
  );
  Widget _vDivider() => Container(
    width: 1,
    height: 28.h,
    margin: EdgeInsets.symmetric(horizontal: 10.w),
    color: _kBorder,
  );
  Widget _costBreakdown(BudgetModel b) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kSoft,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _stat('Material Rate', b.materialCost),
              _vDivider(),
              _stat('Labour Rate', b.labourCost),
            ],
          ),
          Divider(height: 21.h, color: _kBorder),
          Row(
            children: [
              _stat('P&M Rate', b.pMCost),
              _vDivider(),
              _stat('Total Rate', b.totalRate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardHeader({
    required String level,
    required String wbs,
    required String title,
    String subtitle = '',
    String remark = '',
    String flat = '',
    required double amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _levelBadge(level),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyle.ts14SB(
                            color: AppColor.darkBlue900,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      _wbsChip(wbs),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text('·  $subtitle', style: _mutedStyle),
                  ],
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        budgetAmountRemarkSection(
          amount: amount,
          level: level,
          remark: remark,
          flat: flat,
        ),
      ],
    );
  }

  Widget budgetAmountRemarkSection({
    required double amount,
    required String remark,
    required String level,
    String flat = '',
  }) {
    final formattedAmount = amount.toIndianCurrency();
    // IF ABOVE 10 CRORE MOVE TO NEXT LINE
    return (formattedAmount.length < 22)
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: level == 'L4' ? 0 : 10,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text("Budget Amount", style: _mutedStyle),
                ),
                SizedBox(
                  width: 10,
                  child: Text(
                    ":",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.grey),
                  ),
                ),
                Flexible(
                  child: Text(
                    formattedAmount.isNotEmpty ? formattedAmount : "-",
                    maxLines: null,
                    style: AppTextStyle.ts14SB(color: _kPurple),
                  ),
                ),
              ],
            ),
            if (level == 'L3' || level == 'L4') ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 120, child: Text("Flat", style: _mutedStyle)),
                  SizedBox(
                    width: 10,
                    child: Text(
                      ":",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.grey),
                    ),
                  ),
                  flat.trim().isEmpty
                      ? Text("--", style: _mutedStyle)
                      : InkWell(
                        onTap: () {
                          showDialog(context, title: "Flats", note: flat);
                        },
                        child: Text(
                          "View Flats",
                          style: AppTextStyle.ts12M(
                            color: AppColor.primary,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColor.primary,
                          ),
                        ),
                        //  Padding(
                        //   padding: EdgeInsets.only(right: 10.w),
                        //   child: Icon(
                        //     Icons.info_outline,
                        //     size: 18,
                        //     color: AppColor.primary,
                        //   ),
                        // ),
                      ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text("Remark", style: _mutedStyle),
                  ),
                  SizedBox(
                    width: 10,
                    child: Text(
                      ":",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.grey),
                    ),
                  ),
                  remark.trim().isEmpty
                      ? Text("--", style: _mutedStyle)
                      : InkWell(
                        onTap: () {
                          showDialog(context, title: "Remark", note: remark);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ],
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget Amount: ', style: _mutedStyle),
                const SizedBox(height: 5),
                Text(
                  formattedAmount,
                  softWrap: true,
                  style: AppTextStyle.ts14SB(color: _kPurple),
                ),
              ],
            ),
            if (level == 'L3' || level == 'L4')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (flat.trim().isNotEmpty) ...[
                    Text("Flat: ", style: _mutedStyle),
                    remark.trim().isEmpty
                        ? Text("--", style: _mutedStyle)
                        : InkWell(
                          onTap: () {
                            showDialog(context, title: "Flats", note: flat);
                          },
                          child: Text(
                            "View Flats",
                            style: AppTextStyle.ts12M(
                              color: AppColor.primary,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                          ),
                        ),
                  ],
                  Text("Remark: ", style: _mutedStyle),
                  remark.trim().isEmpty
                      ? Text("--", style: _mutedStyle)
                      : InkWell(
                        onTap: () {
                          showDialog(context, title: "Remark", note: remark);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                ],
              ),
          ],
        );
  }
}
