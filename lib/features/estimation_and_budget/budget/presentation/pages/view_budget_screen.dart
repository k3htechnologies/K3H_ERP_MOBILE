import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/model/budget.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/expansion_tile/custom_expansion_tile.dart';
import 'package:k3h_erp_app/widgets/status/budget_level_status.dart';

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

  late final TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _searchC = TextEditingController();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  bool _matches(BudgetModel b, String query) =>
      query.isEmpty || b.categoryName.toLowerCase().contains(query);

  // ───────────────────────── Screen ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final l1List = widget.budgetList.where((e) => e.levelType == 'L1').toList();

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Budget Master',
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showSiteSelectedWidget(),
            SearchWidget(
              textController: _searchC,
              onSubmit: (p0) {},
              hintText: "Search By Category Name",
            ),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
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

  // ───────────────────────── Hierarchy ─────────────────────────

  Widget _budgetHierarchy(
    BudgetModel l1,
    List<BudgetModel> budgetList,
    String query,
  ) {
    final sameL1 = budgetList.where((e) => e.levelId1 == l1.levelId1).toList();

    final l2List =
        sameL1.where((e) => e.levelType == 'L2').where((l2) {
          if (_matches(l2, query)) return true;
          // keep L2 if any of its L3 children match
          return sameL1.any(
            (e) =>
                e.levelType == 'L3' &&
                e.levelId2 == l2.levelId2 &&
                _matches(e, query),
          );
        }).toList();

    if (query.isNotEmpty && l2List.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(
            children: [
              Text(
                'L1 Categories :',
                style: AppTextStyle.ts12M(
                  color: AppColor.black.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                l1.level1Name,
                style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
              ),
            ],
          ),
        ),
        _l1SummaryCard(l1),
        ...l2List.map((l2) {
          final l3List =
              sameL1
                  .where(
                    (e) =>
                        e.levelType == 'L3' &&
                        e.levelId2 == l2.levelId2 &&
                        (_matches(l2, query) || _matches(e, query)),
                  )
                  .toList();

          return CustomExpandableCard(
            key: ValueKey('l2_${l2.levelId2}_$query'),
            initiallyExpanded: true,
            margin: EdgeInsets.only(bottom: 14.h),
            header: _cardHeader(
              level: 'L2',
              wbs: l2.wBSCode,
              title: l2.categoryName,
              amount: l2.budgetAmount,
              dark: true,
            ),
            body: Column(
              children: [
                _costBreakdown(l2),
                SizedBox(height: 12.h),
                for (final l3 in l3List) _l3Card(l3, sameL1),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ───────────────────────── L1 summary ─────────────────────────

  Widget _l1SummaryCard(BudgetModel budget) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF1EFFF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D5F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.categoryName,
                  style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _kBorder),
                ),
                child: Text(
                  'WBS ${budget.wBSCode}',
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Budget Amount',
            style: AppTextStyle.ts12M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            budget.budgetAmount.toIndianCurrency(),
            style: AppTextStyle.ts14SB(
              color: _kPurple,
            ).copyWith(fontSize: 22.sp),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _stat('Material', budget.materialCost),
              _vDivider(),
              _stat('Labour', budget.labourCost),
              _vDivider(),
              _stat('P&M', budget.pMCost),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── L3 / L4 ─────────────────────────

  Widget _l3Card(BudgetModel l3, List<BudgetModel> all) {
    final l4List =
        all
            .where((e) => e.levelType == 'L4' && e.levelId3 == l3.levelId3)
            .toList();

    return CustomExpandableCard(
      key: ValueKey('l3_${l3.budgetId}'),
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _kBorder),
      ),
      header: _cardHeader(
        level: 'L3',
        wbs: l3.wBSCode,
        title: l3.categoryName,
        subtitle: l3.uom,
        amount: l3.budgetAmount,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _costBreakdown(l3),
          if (l4List.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              spacing: 10,
              children: [
                _levelBadge("L4", dark: false),
                Text(
                  'MATERIALS (${l4List.length})',
                  style: AppTextStyle.ts12M(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),
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
    final qty = l4.quantity.toStringAsFixed(l4.quantity % 1 == 0 ? 0 : 2);
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l4.categoryName,
                            style: AppTextStyle.ts14M(
                              color: AppColor.darkBlue900,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${l4.wBSCode}  ·  ${l4.level4MaterialName}  ·  $qty ${l4.uom}',
                            style: AppTextStyle.ts12M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      l4.budgetAmount.toIndianCurrency(),
                      style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
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

  // ───────────────────────── Shared helpers ─────────────────────────

  Widget _levelBadge(String text, {bool dark = false}) {
    final config = budgetLevelConfig[text];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color:
            dark
                ? _kPurple
                : config?.backgroundColor ?? const Color(0xFFE8ECFA),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: AppTextStyle.ts12M(
          color:
              dark ? Colors.white : config?.textColor ?? AppColor.darkBlue900,
        ),
      ),
    );
  }

  Widget _stat(String label, double value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.ts12M(
            color: AppColor.black.withValues(alpha: 0.5),
          ),
        ),
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

  /// Material | Labour | P&M strip, then Total and Budget
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
              _stat('Material', b.materialCost),
              _vDivider(),
              _stat('Labour', b.labourCost),
              _vDivider(),
              _stat('P&M', b.pMCost),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: const Divider(height: 1, color: _kBorder),
          ),
          Row(
            children: [
              _stat('Total Rate', b.totalRate),
              _vDivider(),
              _stat('Budget Amount', b.budgetAmount),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact header shared by L2 and L3 cards
  Widget _cardHeader({
    required String level,
    required String wbs,
    required String title,
    String subtitle = '',
    required double amount,
    bool dark = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _levelBadge(level, dark: dark),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.ts14SB(color: AppColor.darkBlue900),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle.isEmpty ? 'WBS $wbs' : 'WBS $wbs  ·  $subtitle',
                    style: AppTextStyle.ts12M(
                      color: AppColor.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Amount',
              style: AppTextStyle.ts12M(
                color: AppColor.black.withValues(alpha: 0.5),
              ),
            ),
            Text(
              amount.toIndianCurrency(),
              style: AppTextStyle.ts14SB(color: _kPurple),
            ),
          ],
        ),
      ],
    );
  }
}
