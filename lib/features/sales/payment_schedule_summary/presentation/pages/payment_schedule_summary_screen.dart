import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/payment_schedule_summary/presentation/cubit/payment_schedule_summary_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
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
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late PaymentScheduleSummaryCubit _paymentScheduleSummaryCubit;

  // TEXT EDITING CONTROLLER
  late TextEditingController _ratePerSqFt;

  @override
  void initState() {
    super.initState();
    _paymentScheduleSummaryCubit = context.read<PaymentScheduleSummaryCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _ratePerSqFt = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _paymentScheduleSummaryCubit.onTabChanged(_tabController.index, context);
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Cost Sheet'),
                      Tab(text: 'Payment Schedule'),
                    ],
                  ),
                ),
              ),
            ),
            verticalSpacing(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: Text("Wings dropdown")),
                  Expanded(
                    child: CustomTextField(
                      title: "Rate Per Sq.ft",
                      hint: 'Enter Rate Per Sq.ft',
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.decimal(10),
                      textController: _ratePerSqFt,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildCostSheet(), _buildPaymentSchedule()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD COST SHEET
  Widget _buildCostSheet() {
    return Container();
  }

  // BUILD PAYMENT SCHEDULE
  Widget _buildPaymentSchedule() {
    return Container();
  }
}
