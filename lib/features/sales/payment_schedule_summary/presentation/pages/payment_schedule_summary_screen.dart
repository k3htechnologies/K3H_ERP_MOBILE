import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/data/model/payment_schedule_master_report.model.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_cubit.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PaymentScheduleSummaryScreen extends StatefulWidget {
  const PaymentScheduleSummaryScreen({super.key});

  @override
  State<PaymentScheduleSummaryScreen> createState() =>
      _PaymentScheduleSummaryScreenState();
}

class _PaymentScheduleSummaryScreenState
    extends State<PaymentScheduleSummaryScreen>
    with TickerProviderStateMixin {
  //TAB CONTROLLERS
  late TabController _mainTabController;
  TabController? _flatConfigurationTabController;
  //CUBIT
  late PaymentScheduleSummaryCubit _paymentScheduleSummaryCubit;
  // TEXTEDITING CONTROLLER
  late TextEditingController _ratePerSqFt;

  @override
  void initState() {
    super.initState();
    _paymentScheduleSummaryCubit = context.read<PaymentScheduleSummaryCubit>();
    _onScroll();
    _ratePerSqFt = TextEditingController();
    _paymentScheduleSummaryCubit.getProjectInventoryStructure(
      context,
      1,
      getProject().projectId,
    );
  }

  // <---- PAGINATION  ---->
  void _onScroll() {
    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);
  }

  // <---- FLAT CONFIGURATION TAB CHANGE HANDLER ---->
  void _handleFlatConfigurationTabChange() {
    if (!_flatConfigurationTabController!.indexIsChanging) {
      final selectedConfig =
          _paymentScheduleSummaryCubit
              .state
              .flatConfigurationList[_flatConfigurationTabController!.index];
      _paymentScheduleSummaryCubit.clearCostSheetList();
      _paymentScheduleSummaryCubit.onFlatConfigurationChanged(
        selectedConfig,
        context,
        _ratePerSqFt,
      );
    }
  }

  // <---- INITIALIZE FLATCONFIGURATION ---->
  void _initFlatConfigTabController(List<String> flatList) {
    _flatConfigurationTabController?.removeListener(
      _handleFlatConfigurationTabChange,
    );
    _flatConfigurationTabController?.dispose();

    _flatConfigurationTabController = TabController(
      length: flatList.length,
      vsync: this,
    );

    _flatConfigurationTabController!.addListener(
      _handleFlatConfigurationTabChange,
    );
  }

  // <---- MAIN TAB HANDLER FOR COST SHEET AND PAYMENT SUMMARY REPORT ---->
  void _handleMainTabChange() {
    if (_mainTabController.indexIsChanging) return;

    final state = _paymentScheduleSummaryCubit.state;
    // IF BUILDING OR WING IS NOT SELECTED, DO NOT FETCH DATA
    if (state.selectedBuilding == null || state.selectedWing == null) return;

    final rate = int.tryParse(_ratePerSqFt.text.trim()) ?? 0;

    Map<String, dynamic> queryParams = {
      "Wing": state.selectedWing,
      "BuildingId": state.selectedBuilding?.buildingId,
      "Rate": rate,
      "PaymentScheduleMasterId": 0,
      "FlatConfiguration": state.selectedFlatConfiguration,
    };
    if (_mainTabController.index == 1) {
      _paymentScheduleSummaryCubit.getPaymentScheduleMasterReport(
        context,
        1,
        getProject().projectId,
        queryParams,
      );
    } else {
      _paymentScheduleSummaryCubit.getCostSheetReport(
        context,
        1,
        getProject().projectId,
        queryParams,
      );
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _flatConfigurationTabController?.dispose();
    _ratePerSqFt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        isMenuButton: true,
        screenTitle: "Payment Schedule Summary",
        authorization: AuthorizationModel(),
        onProjectChangeCallback: (val) {
          final state = _paymentScheduleSummaryCubit.state;
          // IF BUILDING OR WING IS NOT SELECTED, DO NOT FETCH DATA
          if (state.selectedBuilding == null || state.selectedWing == null) {
            return;
          }
          final rate = int.tryParse(_ratePerSqFt.text.trim()) ?? 0;

          Map<String, dynamic> queryParams = {
            "Wing": state.selectedWing,
            "BuildingId": state.selectedBuilding?.buildingId,
            "Rate": rate,
            "PaymentScheduleMasterId": 0,
            "FlatConfiguration": state.selectedFlatConfiguration,
          };
          _paymentScheduleSummaryCubit.fetchData(context, 1, queryParams);
        },
      ),
      body: BlocListener<
        PaymentScheduleSummaryCubit,
        PaymentScheduleSummaryState
      >(
        listenWhen:
            (previous, current) =>
                previous.flatConfigurationList != current.flatConfigurationList,
        listener: (context, state) {
          if (state.flatConfigurationList.isNotEmpty) {
            _initFlatConfigTabController(state.flatConfigurationList);
          }
        },

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// MAIN TAB (COST SHEET / PAYMENT SCHEDULE)
              _buildMainTab(),
              verticalSpacing(),

              /// MAIN TAB VIEW
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _mainTabController,
                  children: [
                    /// ---------------- COST SHEET VIEW ----------------
                    _buildCostSheetView(),

                    /// ---------------- PAYMENT SCHEDULE VIEW ----------------
                    _buildPaymentScheduleView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- MAIN TAB ----------------
  Widget _buildMainTab() {
    final tabs = const ['Cost Sheet', 'Payment Schedule'];

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _mainTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }

  /// ---------------- COST SHEET VIEW ----------------
  Widget _buildCostSheetView() {
    return Column(
      children: [
        /// DROPDOWNS + RATE
        _buildFilters(),
        verticalSpacing(),

        /// FLAT CONFIGURATION TAB + COST SHEET LIST
        BlocBuilder<PaymentScheduleSummaryCubit, PaymentScheduleSummaryState>(
          builder: (context, state) {
            if (state.flatConfigurationList.isEmpty ||
                _flatConfigurationTabController == null) {
              return const SizedBox();
            }

            return Expanded(
              child: Column(
                children: [
                  // FLAT TAB
                  _buildFlatConfigurationTabBar(state),
                  verticalSpacing(),
                  // COST SHEET LIST
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),

                      controller: _flatConfigurationTabController,
                      children:
                          state.flatConfigurationList
                              .map((e) => _buildCostSheetReportList())
                              .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// ---------------- COST SHEET REPORT LIST ----------------
  Widget _buildCostSheetReportList() {
    return BlocBuilder<
      PaymentScheduleSummaryCubit,
      PaymentScheduleSummaryState
    >(
      builder: (context, state) {
        if (state.selectedWing == null) {
          return const Center(child: Text("Please Select Wing"));
        }
        if (state.isLoading! && state.costSheetReportList.isEmpty) {
          return Center(child: loader());
        }
        if (state.costSheetReportList.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.costSheetReportList.length,
          itemBuilder: (context, index) {
            final item = state.costSheetReportList[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              margin: EdgeInsets.only(bottom: 10),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Carpet Area (In Sq. ft )",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      Text(
                        item.carpetArea.toString(),
                        style: AppTextStyle.ts14M(),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Value (In ₹)",
                        style: AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                      Text(
                        item.totalValue.toString(),
                        style: AppTextStyle.ts14M(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ---------------- PAYMENT SCHEDULE VIEW ----------------
  Widget _buildPaymentScheduleView() {
    return BlocBuilder<
      PaymentScheduleSummaryCubit,
      PaymentScheduleSummaryState
    >(
      builder: (context, state) {
        if (state.selectedWing == null) {
          return const Center(child: Text("Please Select Wing"));
        }
        if (state.isLoading! && state.costSheetReportList.isEmpty) {
          return Center(child: loader());
        }

        if (state.paymentScheduleReportList.isEmpty) {
          return Center(child: noDataWidget());
        }

        final Map<int, FlatPaymentSchedule> grouped = {};

        for (var slab in state.paymentScheduleReportList) {
          if (grouped.containsKey(slab.inventoryFlatId)) {
            grouped[slab.inventoryFlatId]!.slabs.add(slab);
          } else {
            grouped[slab.inventoryFlatId] = FlatPaymentSchedule(
              inventoryFlatId: slab.inventoryFlatId,
              carpetArea: slab.carpetArea,
              slabs: [slab],
            );
          }
        }

        final flats = grouped.values.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: flats.length,
          itemBuilder: (context, index) {
            final flat = flats[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentRow(
                    "Carpet Area (In Sq. ft)",
                    flat.carpetArea,
                    null,
                  ),

                  const SizedBox(height: 12),

                  ...flat.slabs.map((slab) {
                    return _buildPaymentRow(
                      slab.name,
                      slab.totalValue,
                      slab.paymentSchedulePercentage,
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ---------------- FILTERS ----------------
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              // ---------------- BUILDING DROPDOWN ----------------
              Expanded(
                child: BlocBuilder<
                  PaymentScheduleSummaryCubit,
                  PaymentScheduleSummaryState
                >(
                  buildWhen:
                      (previous, current) =>
                          previous.buildingList != current.buildingList ||
                          previous.selectedBuilding != current.selectedBuilding,
                  builder: (context, state) {
                    final buildingListMap =
                        state.buildingList
                            .map(
                              (e) => {
                                "zAttributesId": e.buildingId,
                                "DisplayName": e.buildingNumber,
                              },
                            )
                            .toList();

                    final selectedBuildingMap = buildingListMap
                        .firstWhereOrNull(
                          (e) =>
                              e["zAttributesId"] ==
                              state.selectedBuilding?.buildingId,
                        );

                    return CustomDropDownWidget(
                      title: "Building",
                      isRequired: true,
                      dataList: buildingListMap,
                      initialValue: selectedBuildingMap,
                      onSelected: (value) {
                        final selectedId = value["zAttributesId"];

                        if (selectedId != state.selectedBuilding?.buildingId) {
                          context
                              .read<PaymentScheduleSummaryCubit>()
                              .onBuildingChanged(selectedId);
                        }
                      },
                      validator:
                          (value) =>
                              value == null ? "Building is required" : null,
                    );
                  },
                ),
              ),

              horizontalSpacing(),

              // ---------------- WING DROPDOWN ----------------
              Expanded(
                child: BlocBuilder<
                  PaymentScheduleSummaryCubit,
                  PaymentScheduleSummaryState
                >(
                  buildWhen:
                      (previous, current) =>
                          previous.wingList != current.wingList ||
                          previous.selectedWing != current.selectedWing,
                  builder: (context, state) {
                    final wingListMap =
                        state.wingList
                            .map(
                              (e) => {
                                "zAttributesId": e.hashCode,
                                "DisplayName": e,
                              },
                            )
                            .toList();

                    final selectedWingMap = wingListMap.firstWhereOrNull(
                      (e) => e["DisplayName"] == state.selectedWing,
                    );

                    return CustomDropDownWidget(
                      title: "Wing",
                      isRequired: true,
                      dataList: wingListMap,
                      initialValue: selectedWingMap,
                      onSelected: (value) {
                        final selected = value["DisplayName"];

                        if (selected != state.selectedWing) {
                          _paymentScheduleSummaryCubit.onWingChanged(
                            selected,
                            context,
                            _ratePerSqFt,
                          );
                        }
                      },
                      validator:
                          (value) => value == null ? "Wing is required" : null,
                    );
                  },
                ),
              ),
            ],
          ),

          verticalSpacing(),
          CustomTextField(
            title: "Rate Per Sq.ft",
            hint: 'Enter Rate',
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.decimal(10),
            textController: _ratePerSqFt,
            isRequired: true,
            onSubmitFunction: (val) {
              _paymentScheduleSummaryCubit.onRateChanged(val, context);
            },
          ),
        ],
      ),
    );
  }

  /// ---------------- FLAT CONFIGURATION TAB ----------------
  Widget _buildFlatConfigurationTabBar(PaymentScheduleSummaryState state) {
    if (_flatConfigurationTabController == null ||
        state.flatConfigurationList.isEmpty) {
      return const SizedBox();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _flatConfigurationTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent, // just in case
            tabs: state.flatConfigurationList.map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
    );
  }

  // HELPER WIDGET FOR PAYMENT SCHEDULE CARD
  Widget _buildPaymentRow(String label, double value, double? percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + PERCENTAGE
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    label,
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ),
                if (percentage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: AppTextStyle.ts14M(),
                  ),
                ],
              ],
            ),
          ),
          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),
          // VALUE
          Text(value.toStringAsFixed(0), style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }
}
