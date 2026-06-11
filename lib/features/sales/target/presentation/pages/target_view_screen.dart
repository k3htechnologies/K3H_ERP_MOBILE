import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_closing.model.dart';
import 'package:k3h_erp_app/features/sales/target/data/model/sales_target_sourcing.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TargetViewScreen extends StatefulWidget {
  final SalesTargetSourcingModel? sourcing;
  final SaleTargetClosingModel? closing;
  const TargetViewScreen({super.key, this.sourcing, this.closing});

  @override
  State<TargetViewScreen> createState() => _TargetViewScreenState();
}

class _TargetViewScreenState extends State<TargetViewScreen>
    with TickerProviderStateMixin {
  late TabController _sourcingTabC;
  late TabController _closingTabC;

  @override
  void initState() {
    super.initState();
    _sourcingTabC = TabController(length: (4), vsync: this);
    _closingTabC = TabController(length: (2), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _sourcingTabC.dispose();
    _closingTabC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            "${widget.sourcing != null ? 'Sourcing' : 'Closing'} Target",
        authorization: AuthorizationModel(),
      ),
      body:
          widget.sourcing != null ? _buildSourcingView() : _buildClosingView(),
    );
  }

  // SOURCING VIEW
  Widget _buildSourcingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerSection(),
        ChipStyleTabBar(
          controller: _sourcingTabC,
          tabs: ["Walkins", "Bookings", "OBM & IBM", "CP"],
        ),

        Expanded(
          child: TabBarView(
            controller: _sourcingTabC,
            children: [
              _walkinsView(),
              _bookingsView(),
              _ibmObmView(),
              _cpView(),
            ],
          ),
        ),
      ],
    );
  }

  // CLOSING VIEW
  Widget _buildClosingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerSection(),

        ChipStyleTabBar(
          controller: _closingTabC,
          tabs: ["Walkins", "Bookings"],
        ),

        Expanded(
          child: TabBarView(
            controller: _closingTabC,
            children: [_closingWalkinsView(), _closingBookingsView()],
          ),
        ),
      ],
    );
  }

  // HARDER SECTION
  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.closing?.employeeName ?? widget.sourcing?.employeeName ?? "",
            style: AppTextStyle.ts14M(),
          ),
          verticalSpacing(height: 4.0),
          Text(
            widget.closing?.designationName ??
                widget.sourcing?.designationName ??
                "",
            style: AppTextStyle.ts12R(color: AppColor.grey),
          ),
        ],
      ),
    );
  }

  Widget _walkinsView() {
    final m = widget.sourcing!;
    return _infoList([
      {
        "Walkins By CP": m.walkinsByCp.toString(),
        "Fresh Visits": m.freshVisits.toString(),
        "Revisits": m.revisits.toString(),
      },
    ]);
  }

  Widget _bookingsView() {
    final m = widget.sourcing!;
    return _infoList([
      {"Bookings": m.bookings.toString()},
    ]);
  }

  Widget _ibmObmView() {
    final m = widget.sourcing!;
    return _infoList([
      {"Total OBM": m.totalObm.toString()},
      {"Total OBM Fresh Visits": m.totalObmFreshVisits.toString()},
      {"Total OBM Revisits": m.totalObmRevisits.toString()},
      {"Total IBM": m.totalIbm.toString()},
    ]);
  }

  Widget _cpView() {
    final m = widget.sourcing!;
    return _infoList([
      {"Unique CP": m.uniqueCPs.toString()},
      {"Active CP": m.activeCp.toString()},
      {"New CP": m.newCp.toString()},
    ]);
  }

  Widget _closingWalkinsView() {
    final m = widget.closing!;
    return _infoList([
      {"Walkins CP": m.walkinsByCp.toString()},
      {"Walkins Direct": m.walkinsDirect.toString()},
      {"Fresh Visits": m.freshVisits.toString()},
      {"Revisits": m.revisits.toString()},
    ]);
  }

  Widget _closingBookingsView() {
    final m = widget.closing!;
    return _infoList([
      {"Bookings CP": m.bookingByCp.toString()},
      {"Bookings Direct": m.bookingDirect.toString()},
    ]);
  }

  Widget _infoList(List<Map<String, String>> data) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final map = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: commonCardDecoration(),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                map.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: buildRowTitleValue(
                      title: entry.key,
                      value: entry.value,
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
