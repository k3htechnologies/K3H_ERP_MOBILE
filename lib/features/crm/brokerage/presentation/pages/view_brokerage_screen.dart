import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ViewBrokerageScreen extends StatefulWidget {
  final BrokerageModel brokerageModel;
  const ViewBrokerageScreen({super.key, required this.brokerageModel});

  @override
  State<ViewBrokerageScreen> createState() => _ViewBrokerageScreenState();
}

class _ViewBrokerageScreenState extends State<ViewBrokerageScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late BrokerageCubit _brokerageCubit;
  late TextEditingController _searchC;
  final List<ValueNotifier<bool>> _invoiceExpandList = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchC = TextEditingController();
    _brokerageCubit = context.read<BrokerageCubit>();
    _brokerageCubit.getBrokerageInvoiceList(
      context,
      1,
      widget.brokerageModel.projectId,
      widget.brokerageModel.bookingId,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      _brokerageCubit.getBrokerageInvoiceList(
        context,
        1,
        widget.brokerageModel.projectId,
        widget.brokerageModel.bookingId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Brokerage",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          spacing: 10,
          children: [
            ChipStyleTabBar(
              margin: EdgeInsets.zero,
              controller: _tabController,
              tabs: ["Invoice", "Payment"],
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: SearchWidget(
                    onSubmit: (val) {},
                    textController: _searchC,
                  ),
                ),
                CustomIconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 16, color: AppColor.primary),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildInvoiceView(), _buildPaymentView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceView() {
    return BlocBuilder<BrokerageCubit, BrokerageState>(
      builder: (context, state) {
        if (_invoiceExpandList.length != state.brokerageInvoiceList.length) {
          _invoiceExpandList.clear();
          _invoiceExpandList.addAll(
            List.generate(
              state.brokerageInvoiceList.length,
              (_) => ValueNotifier(false),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.brokerageInvoiceList.length,
          itemBuilder: (context, index) {
            final invoice = state.brokerageInvoiceList[index];
            final notifier = _invoiceExpandList[index];

            return ValueListenableBuilder<bool>(
              valueListenable: notifier,
              builder: (context, isExpanded, _) {
                return Container(
                  decoration: commonCardDecoration(),
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      buildRowTitleValue(
                        title: "Invoice No.",
                        fixesWidth: 100.w,
                        value: invoice.invoiceNumber,
                        customValueWidget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              style: AppTextStyle.ts14M(),
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                CustomIconButton.edit(onPressed: () {}),
                                CustomIconButton.delete(onPressed: () {}),
                                GestureDetector(
                                  onTap: () => notifier.value = !isExpanded,
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Invoice Date",
                        value: formatDateTimeAsDDMMMYYYY(invoice.invoiceDate),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Invoice Amount",
                        value: addCommasToInteger(invoice.invoiceAmount),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Paid Amount",
                        value: addCommasToInteger(invoice.invoiceAmount),
                      ),
                      buildRowTitleValue(
                        fixesWidth: 100.w,
                        title: "Outstanding Amount",
                        value: addCommasToInteger(invoice.invoiceAmount),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            isExpanded
                                ? _invoiceDetailCard(invoice)
                                : ApproveRejectWidget(
                                  actionTitle: "Approval",
                                  onApprove: (remark) {},
                                  onReject: (remark) {},
                                  onThirdTap: () {},
                                  popupTitle: "Invoice Approval",
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _invoiceDetailCard(BrokerageInvoiceModel invoice) {
    return Container(
      key: ValueKey(true),
      decoration: BoxDecoration(
        color: AppColor.grey10.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.grey10),
      ),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "Invoice Details",
            style: AppTextStyle.ts14M(color: AppColor.black),
          ),
          buildRowTitleValue(
            title: "Amount",
            value: addCommasToInteger(invoice.invoiceAmount),
          ),
          buildRowTitleValue(title: "Payment Mode", value: "Cheque"),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Bank Name",
                value: invoice.bankName,
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Account Name",
                value: invoice.accountName,
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Account Number",
                value: invoice.accountNumber,
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "IFSC Code",
                value: invoice.ifscCode,
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Due Date",
                value: formatDateTimeAsDDMMMYYYY(invoice.dueDate),
              ),
            ],
          ),
          Divider(height: 1, color: AppColor.grey50),
          Text("Action Details", style: AppTextStyle.ts14M()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Created By",
                value: invoice.createdBy,
              ),
              buildColumnTitleValue(
                title: "Created Date",
                value: formatDate(invoice.createdDate),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Modified By",
                value: invoice.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Modified Date",
                value:
                    (invoice.modifiedDate == null)
                        ? "-"
                        : formatDate(invoice.modifiedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentView() {
    return Container();
  }
}
