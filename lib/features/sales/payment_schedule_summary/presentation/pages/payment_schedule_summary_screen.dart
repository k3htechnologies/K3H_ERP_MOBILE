import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_cubit.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_state.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
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
  late TabController _mainTabController; // Cost Sheet / Payment Schedule
  TabController? _flatTabController; // Office / Shop / 1BHK...
  late PaymentScheduleSummaryCubit _cubit;
  late TextEditingController _ratePerSqFt;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PaymentScheduleSummaryCubit>();

    _mainTabController = TabController(length: 2, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);

    _ratePerSqFt = TextEditingController();

    _cubit.getProjectInventoryStructure(context, 1, getProject().projectId);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _flatTabController?.dispose();
    _ratePerSqFt.dispose();
    super.dispose();
  }

  void _handleFlatTabChange() {
    if (!_flatTabController!.indexIsChanging) {
      _cubit.onTabChanged(_flatTabController!.index, context);
    }
  }

  void _initFlatTabController(List<String> flatList) {
    _flatTabController?.removeListener(_handleFlatTabChange);
    _flatTabController?.dispose();

    _flatTabController = TabController(length: flatList.length, vsync: this);

    _flatTabController!.addListener(_handleFlatTabChange);
  }

  void _handleMainTabChange() {
    // Only react when tab has actually changed
    if (!_mainTabController.indexIsChanging) {
      // If user switches to Payment Schedule tab (index 1)
      if (_mainTabController.index == 1) {
        Map<String, dynamic> queryParams = {
          "Wing": "A", // replace with selected wing if dynamic
        };

        _cubit.getPaymentScheduleMasterReport(
          context,
          1, // page number
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
                    BlocBuilder<
                      PaymentScheduleSummaryCubit,
                      PaymentScheduleSummaryState
                    >(
                      builder: (context, state) {
                        if (state.paymentScheduleMasterReportList.isEmpty) {
                          return const Center(
                            child: Text("No Payment Schedule Available"),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount:
                              state.paymentScheduleMasterReportList.length,
                          itemBuilder: (context, index) {
                            final item =
                                state.paymentScheduleMasterReportList[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColor.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Carpet Area (In Sq. ft )"),
                                      Text(item.name.toString()),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Value (In ₹)"),
                                      Text(item.carpetArea.toString()),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          /// DROPDOWNS + RATE
          _buildFilters(),
          verticalSpacing(),

          /// FLAT CONFIGURATION TAB + PAYMENT SCHEDULE LIST
          BlocBuilder<PaymentScheduleSummaryCubit, PaymentScheduleSummaryState>(
            builder: (context, state) {
              if (state.flatConfigurationList.isEmpty ||
                  _flatTabController == null) {
                return const SizedBox();
              }

              return Column(
                children: [
                  // Flat tabs (Office / Shop / 1BHK etc.)
                  _buildFlatTabBar(state),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _flatTabController,
                      children:
                          state.flatConfigurationList
                              .map((e) => _buildPaymentScheduleList())
                              .toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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

                    // Safe initial value: must exist in list
                    final initialBuilding =
                        state.selectedBuilding != null
                            ? buildingListMap.firstWhereOrNull(
                                  (e) =>
                                      e["zAttributesId"] ==
                                      state.selectedBuilding!.buildingId,
                                ) ??
                                buildingListMap.first
                            : buildingListMap.isNotEmpty
                            ? buildingListMap.first
                            : null;

                    return CustomDropDownWidget(
                      title: "Building",
                      isRequired: true,
                      dataList: buildingListMap,
                      initialValue: initialBuilding,
                      onSelected: (value) {
                        _cubit.onBuildingChanged(
                          value["zAttributesId"],
                          context,
                        );
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

                    // Safe initial value: must exist in list
                    final initialWing =
                        state.selectedWing != null
                            ? wingListMap.firstWhereOrNull(
                                  (e) => e["DisplayName"] == state.selectedWing,
                                ) ??
                                wingListMap.first
                            : wingListMap.isNotEmpty
                            ? wingListMap.first
                            : null;

                    return CustomDropDownWidget(
                      title: "Wing",
                      isRequired: true,
                      dataList: wingListMap,
                      initialValue: initialWing,
                      onSelected: (value) {
                        _cubit.onWingChanged(value["DisplayName"], context);
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

  /// ---------------- PAYMENT SCHEDULE LIST ----------------
  Widget _buildPaymentScheduleList() {
    return BlocBuilder<
      PaymentScheduleSummaryCubit,
      PaymentScheduleSummaryState
    >(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.paymentScheduleMasterReportList.length,
          itemBuilder: (context, index) {
            final item = state.paymentScheduleMasterReportList[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Carpet Area (In Sq. ft )"),
                      Text(item.name.toString()),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Value (In ₹)"),
                      Text(item.carpetArea.toString()),
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
