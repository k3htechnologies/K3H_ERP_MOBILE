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
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late TabController _mainTabController; // Cost Sheet / Payment Schedule
  TabController? _flatTabController; // Office / Shop / 1BHK...
  late PaymentScheduleSummaryCubit _paymentScheduleSummarycubit;
  late TextEditingController _ratePerSqFt;
  late ScrollController _costSheetScrollController;
  late ScrollController _paymentScheduleScrollController;

  @override
  void initState() {
    super.initState();
    _paymentScheduleSummarycubit = context.read<PaymentScheduleSummaryCubit>();

    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);

    _ratePerSqFt = TextEditingController();

    // ✅ Initialize scroll controllers
    _costSheetScrollController = ScrollController();
    _paymentScheduleScrollController = ScrollController();

    // ✅ Attach scroll listeners if you want infinite scroll
    _costSheetScrollController.addListener(_onCostSheetScroll);
    _paymentScheduleScrollController.addListener(_onPaymentScheduleScroll);

    _paymentScheduleSummarycubit.getProjectInventoryStructure(
      context,
      1,
      getProject().projectId,
    );
  }

  // ✅ Infinite scroll for Cost Sheet
  void _onCostSheetScroll() {
    if (_costSheetScrollController.position.pixels >=
        _costSheetScrollController.position.maxScrollExtent - 50) {
      // Near bottom, load next page
      final state = _paymentScheduleSummarycubit.state;
      final nextPage = (state.costSheetCurrentPage ?? 1) + 1;

      final rate = int.tryParse(_ratePerSqFt.text.trim()) ?? 0;

      Map<String, dynamic> queryParams = {
        "Wing": state.selectedWing,
        "BuildingId": state.selectedBuilding?.buildingId,
        if (rate != 0) "Rate": rate,
        "PaymentScheduleMasterId": 0,
        "FlatConfiguration": state.selectedFlatConfiguration,
      };

      _paymentScheduleSummarycubit.getCostSheetReport(
        context,
        nextPage,
        getProject().projectId,
        queryParams,
      );
    }
  }

  // ✅ Infinite scroll for Payment Schedule
  void _onPaymentScheduleScroll() {
    if (_paymentScheduleScrollController.position.pixels >=
        _paymentScheduleScrollController.position.maxScrollExtent - 50) {
      final state = _paymentScheduleSummarycubit.state;
      final nextPage = (state.paymentScheduleCurrentPage ?? 1) + 1;

      final rate = int.tryParse(_ratePerSqFt.text.trim()) ?? 0;

      Map<String, dynamic> queryParams = {
        "Wing": state.selectedWing,
        "BuildingId": state.selectedBuilding?.buildingId,
        if (rate != 0) "Rate": rate,
        "PaymentScheduleMasterId": 0,
        "FlatConfiguration": state.selectedFlatConfiguration,
      };

      _paymentScheduleSummarycubit.getPaymentScheduleMasterReport(
        context,
        nextPage,
        getProject().projectId,
        queryParams,
      );
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _flatTabController?.dispose();
    _ratePerSqFt.dispose();
    _costSheetScrollController.dispose();
    _paymentScheduleScrollController.dispose();
    super.dispose();
  }

  void _handleFlatTabChange() {
    if (!_flatTabController!.indexIsChanging) {
      final selectedConfig =
          _paymentScheduleSummarycubit
              .state
              .flatConfigurationList[_flatTabController!.index];
      _paymentScheduleSummarycubit.clearCostSheetList();
      _paymentScheduleSummarycubit.onFlatConfigurationChanged(
        selectedConfig,
        context,
        _ratePerSqFt,
      );
    }
  }

  void _initFlatTabController(List<String> flatList) {
    _flatTabController?.removeListener(_handleFlatTabChange);
    _flatTabController?.dispose();

    _flatTabController = TabController(length: flatList.length, vsync: this);

    _flatTabController!.addListener(_handleFlatTabChange);
  }

  void _handleMainTabChange() {
    if (!_mainTabController.indexIsChanging) {
      final rate = int.tryParse(_ratePerSqFt.text.trim()) ?? 0;

      Map<String, dynamic> queryParams = {
        "Wing": _paymentScheduleSummarycubit.state.selectedWing,
        "BuildingId":
            _paymentScheduleSummarycubit.state.selectedBuilding?.buildingId,
        if (rate != 0) "Rate": rate,
        "PaymentScheduleMasterId": 0,

        "FlatConfiguration":
            _paymentScheduleSummarycubit.state.selectedFlatConfiguration,
      };

      if (_mainTabController.index == 1) {
        _paymentScheduleSummarycubit.getPaymentScheduleMasterReport(
          context,
          1,
          getProject().projectId,
          queryParams,
        );
      } else {
        _paymentScheduleSummarycubit.getCostSheetReport(
          context,
          1,
          getProject().projectId,
          queryParams,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        isMenuButton: true,
        screenTitle: "Payment Schedule Summary",
        authorization: AuthorizationModel(),
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
            _initFlatTabController(state.flatConfigurationList);
          }
        },

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// MAIN TAB (Cost Sheet / Payment Schedule)
              _buildMainTab(),
              verticalSpacing(),

              /// MAIN TAB VIEW
              Expanded(
                child: TabBarView(
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
            dividerColor: Colors.transparent, // remove divider
            // optional: set indicatorColor to transparent to be safe
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
                _flatTabController == null) {
              return const SizedBox();
            }

            return Expanded(
              // ✅ Expanded instead of SingleChildScrollView
              child: Column(
                children: [
                  // Flat tabs (Office / Shop / 1BHK etc.)
                  _buildFlatTabBar(state),
                  verticalSpacing(),

                  Expanded(
                    // ✅ Expanded gives TabBarView bounded height
                    child: TabBarView(
                      controller: _flatTabController,
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

  /// ---------------- PAYMENT SCHEDULE VIEW ----------------
  Widget _buildPaymentScheduleView() {
    return BlocBuilder<
      PaymentScheduleSummaryCubit,
      PaymentScheduleSummaryState
    >(
      builder: (context, state) {
        if (state.selectedWing == null) {
          return Center(child: Text("Please Select Wing"));
        }

        if (state.flatPaymentSchedules.isEmpty) {
          return Center(child: noDataWidget());
        }

        return ListView.builder(
          controller: _paymentScheduleScrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.flatPaymentSchedules.length + 1, // ✅ +1 for loader
          itemBuilder: (context, index) {
            // ✅ Pagination loader at bottom
            if (index == state.flatPaymentSchedules.length) {
              return state.flatPaymentSchedules.length <
                      state
                          .paymentScheduleTotalRecords // use your total count field
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
            final flat = state.flatPaymentSchedules[index];

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
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Show Carpet Area only once per flat
                  _buildPaymentRow(
                    "Carpet Area (In Sq. ft)",
                    flat.carpetArea.toString(),
                  ),

                  SizedBox(height: 12),

                  // ✅ Show all slabs for this flat
                  ...flat.slabs.map((slab) {
                    return _buildPaymentRowWithPercentage(
                      slab.name,
                      slab.totalValue,
                      slab.paymentSchedulePercentage,
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Simple row with label and value
  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Row with value and percentage
  Widget _buildPaymentRowWithPercentage(
    String label,
    double value,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          "${percentage.toStringAsFixed(0)}%",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  /// ---------------- FILTERS ----------------
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          /// Building & Wing Dropdowns
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
                                "DisplayName": e.buildingNumber ?? '',
                              },
                            )
                            .toList();

                    /// ✅ Only set initial value if it exists
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
                          context
                              .read<PaymentScheduleSummaryCubit>()
                              .onWingChanged(selected, context, _ratePerSqFt);
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

          /// Rate Per Sq.ft
          CustomTextField(
            title: "Rate Per Sq.ft",
            hint: 'Enter Rate',
            keyboardType: TextInputType.number,
            inputFormatterList: InputValidator.decimal(10),
            textController: _ratePerSqFt,
          ),
        ],
      ),
    );
  }

  /// ---------------- FLAT TAB ----------------
  Widget _buildFlatTabBar(PaymentScheduleSummaryState state) {
    if (_flatTabController == null || state.flatConfigurationList.isEmpty) {
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
            controller: _flatTabController,
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
          controller: _costSheetScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.costSheetReportList.length + 1, // ✅ +1 for loader
          itemBuilder: (context, index) {
            // ✅ Pagination loader at bottom
            if (index == state.costSheetReportList.length) {
              return (state.isLoading! &&
                      state.costSheetReportList.length <
                          state.costSheetTotalRecords)
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }
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
}
