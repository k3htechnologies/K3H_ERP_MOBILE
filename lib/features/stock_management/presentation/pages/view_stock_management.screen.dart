import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management_history.model.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewStockManagementScreen extends StatefulWidget {
  final String materialName;
  final String subMaterialName;
  final int subMaterialMasterId;
  const ViewStockManagementScreen({
    super.key,
    required this.materialName,
    required this.subMaterialName,
    required this.subMaterialMasterId,
  });

  @override
  State<ViewStockManagementScreen> createState() =>
      _ViewStockManagementScreenState();
}

class _ViewStockManagementScreenState extends State<ViewStockManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late StockManagementCubit _stockManagementCubit;
  late ProjectModel _selectedProject;
  late ScrollController scrollController;
  Timer? _debounce;
  late TextEditingController _unusedQuantityC;
  final GlobalKey<FormState> _statusFormKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _stockManagementCubit = context.read<StockManagementCubit>();
    _selectedProject = getProject();
    _stockManagementCubit.getStockSummaryList(
      context,
      1,
      _selectedProject.projectId,
      widget.subMaterialMasterId,
    );
    _tabController.addListener(_handleTabChange);
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _unusedQuantityC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _unusedQuantityC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
  }

  Future<void> _handleTabChange() async {
    if (_tabController.indexIsChanging) return;

    switch (_tabController.index) {
      case 0:
        await _stockManagementCubit.getStockSummaryList(
          context,
          1,
          _selectedProject.projectId,
          widget.subMaterialMasterId,
        );
        break;
      case 1:
        await _stockManagementCubit.getStockHistoryList(
          context,
          1,
          _selectedProject.projectId,
          widget.subMaterialMasterId,
        );
        break;
      case 2:
        await _stockManagementCubit.getStockHistoryList(
          context,
          1,
          _selectedProject.projectId,
          widget.subMaterialMasterId,
          type: "INWARD",
        );
        break;
      case 3:
        await _stockManagementCubit.getStockHistoryList(
          context,
          1,
          _selectedProject.projectId,
          widget.subMaterialMasterId,
          type: "OUTWARD",
        );
        break;
    }
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_stockManagementCubit.state.isLoading! &&
          _stockManagementCubit.state.stockHistoryList.length <
              _stockManagementCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _stockManagementCubit.getStockHistoryList(
            context,
            _stockManagementCubit.state.currentPage + 1,
            _selectedProject.projectId,
            widget.subMaterialMasterId,
          );
        });
      }
    });
  }

  Future<void> _showAddUpdateMaterialUsageBottomSheet(
    BuildContext context, {
    StockManagementHistoryModel? historyModel,
    int? index,
  }) async {
    if (historyModel != null) {
      _unusedQuantityC.text = historyModel.unUsedMaterial.toString();
    }

    final totalQuantity = historyModel?.materialQuantityInwardOutward ?? 0;

    await DialogHelper.showCustomBottomSheet(
      context,
      "Material Usage",
      contentWidget: StatefulBuilder(
        builder: (context, innerBottomsheetState) {
          final unusedQty = double.tryParse(_unusedQuantityC.text) ?? 0;

          final usedQty = totalQuantity - unusedQty;

          return Form(
            key: _statusFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(),
                CustomTextField(
                  title: "Total Quantity",
                  hint: "$totalQuantity ${historyModel?.uomCode ?? ''}",
                  textController: TextEditingController(
                    text: "$totalQuantity ${historyModel?.uomCode ?? ''}",
                  ),
                  readOnly: true,
                ),
                CustomTextField(
                  title: "Unused Quantity",
                  hint: "Enter Quantity",
                  textController: _unusedQuantityC,
                  isRequired: true,
                  keyboardType: TextInputType.number,

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter unused quantity";
                    }

                    final unused = double.tryParse(value);

                    if (unused == null) {
                      return "Invalid quantity";
                    }

                    if (unused > totalQuantity) {
                      return "Unused quantity cannot exceed total quantity";
                    }

                    return null;
                  },

                  onChangeFunction: (value) {
                    innerBottomsheetState(() {});
                  },
                ),
                CustomTextField(
                  title: "Used Quantity",
                  hint:
                      "${usedQty.toStringAsFixed(2)} ${historyModel?.uomCode ?? ''}",
                  textController: TextEditingController(
                    text:
                        "${usedQty.toStringAsFixed(2)} ${historyModel?.uomCode ?? ''}",
                  ),
                  readOnly: true,
                ),
              ],
            ),
          );
        },
      ),
      bottomActions: StatefulBuilder(
        builder: (context, innerBottomsheetState) {
          final unusedQty = double.tryParse(_unusedQuantityC.text) ?? 0;

          final usedQty = totalQuantity - unusedQty;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomButton(
                  text: "Cancel",
                  backgroundColor: AppColor.white,
                  titleTextStyle: AppTextStyle.ts14M(),
                  borderColor: AppColor.grey.withValues(alpha: 0.25),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              horizontalSpacing(),

              Expanded(
                child: CustomButton(
                  text: "Save",
                  onPressed: () {
                    if (!_statusFormKey.currentState!.validate()) {
                      return;
                    }

                    _stockManagementCubit.addUpdateUsedUnusedStock(
                      context,
                      projectId: _selectedProject.projectId,
                      materialRequisitionGRNStockId:
                          historyModel!.materialRequisitionGrnStockId,
                      usedQuantity: usedQty,
                      unusedQuantity: unusedQty,
                      subMaterialMasterId: widget.subMaterialMasterId,
                    );

                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    _clearStatusSheet();
  }

  void _clearStatusSheet() {
    _unusedQuantityC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Stock Management",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<StockManagementCubit, StockManagementState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "${widget.materialName} > ${widget.subMaterialName}",
                  style: AppTextStyle.ts14M(),
                ),
              ),

              ChipStyleTabBar(
                isSecondaryStyle: false,
                controller: _tabController,
                tabs: const [
                  "Summary",
                  "History",
                  "Material In",
                  "Material Issued",
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _summaryWidget(context, state),
                    _historyTabWidget(context, state),
                    _materialInWidget(context, state),
                    _materialOutWidget(context, state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryWidget(BuildContext context, StockManagementState state) {
    return ListView.builder(
      itemCount: state.stockSummaryList.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      itemBuilder: (context, index) {
        final summary = state.stockSummaryList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.all(12.0),
          decoration: commonCardDecoration(),
          child: Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRowTitleValue(
                title: "Material Name",
                value: summary.materialName,
                singleLine: false,
              ),
              buildRowTitleValue(
                title: "Sub Material Name",
                value: summary.subMaterialName,
                singleLine: false,
              ),
              buildRowTitleValue(title: "UOM", value: summary.uomCode),
              buildRowTitleValue(
                title: "PO No.",
                value: summary.systemGeneratedCode,
                singleLine: false,
              ),
              buildRowTitleValue(
                title: "Total Material Quantity in Stock",
                value: summary.totalMaterialQuantityInStock.toString(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _historyTabWidget(BuildContext context, StockManagementState state) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.stockHistoryList.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      itemBuilder: (context, index) {
        if (index == state.stockHistoryList.length) {
          return state.stockHistoryList.length < state.totalNumberOfRecord
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
              : const SizedBox.shrink();
        }
        final history = state.stockHistoryList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.all(12.0),
          decoration: commonCardDecoration(),
          child: Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRowTitleValue(
                title: "Material In/Out",
                value:
                    "${history.materialQuantityInwardOutward.toString()} ${history.uomCode}",
                valueTextStyle: AppTextStyle.ts14M(
                  color:
                      history.inwardOutwardType.toLowerCase() == 'outward'
                          ? AppColor.missingInformationRed
                          : AppColor.green,
                ),
              ),
              buildRowTitleValue(title: "Remark", value: history.reason),
              buildRowTitleValue(title: "Created By", value: history.createdBy),
              buildRowTitleValue(
                title: "Created Date",
                value: formatDateTimeAsDDMMMYYYY(history.createdDate),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _materialInWidget(BuildContext context, StockManagementState state) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.stockHistoryList.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      itemBuilder: (context, index) {
        if (index == state.stockHistoryList.length) {
          return state.stockHistoryList.length < state.totalNumberOfRecord
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
              : const SizedBox.shrink();
        }
        final history = state.stockHistoryList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.all(12.0),
          decoration: commonCardDecoration(),
          child: Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRowTitleValue(
                title: "Material In/Out",
                value:
                    "${history.materialQuantityInwardOutward.toString()} ${history.uomCode}",
                valueTextStyle: AppTextStyle.ts14M(
                  color:
                      history.inwardOutwardType.toLowerCase() == 'outward'
                          ? AppColor.missingInformationRed
                          : AppColor.green,
                ),
              ),
              buildRowTitleValue(title: "Remark", value: history.reason),
              buildRowTitleValue(title: "Created By", value: history.createdBy),
              buildRowTitleValue(
                title: "Created Date",
                value: formatDateTimeAsDDMMMYYYY(history.createdDate),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _materialOutWidget(BuildContext context, StockManagementState state) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.stockHistoryList.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      itemBuilder: (context, index) {
        if (index == state.stockHistoryList.length) {
          return state.stockHistoryList.length < state.totalNumberOfRecord
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
              : const SizedBox.shrink();
        }
        final history = state.stockHistoryList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.all(12.0),
          decoration: commonCardDecoration(),
          child: Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildRowTitleValue(
                title: "Material In/Out",
                value:
                    "${history.materialQuantityInwardOutward.toString()} ${history.uomCode}",
                valueTextStyle: AppTextStyle.ts14M(
                  color:
                      history.inwardOutwardType.toLowerCase() == 'outward'
                          ? AppColor.missingInformationRed
                          : AppColor.green,
                ),
              ),
              buildRowTitleValue(
                title: "Used Material",
                value: history.usedMaterial.toString(),
              ),
              buildRowTitleValue(
                title: "Unused Material",
                value: history.unUsedMaterial.toString(),
              ),
              buildRowTitleValue(title: "Remark", value: history.reason),
              buildRowTitleValue(title: "Created By", value: history.createdBy),
              buildRowTitleValue(
                title: "Created Date",
                value: formatDateTimeAsDDMMMYYYY(history.createdDate),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    isDisable:
                        history.materialQuantityInwardOutward ==
                        history.usedMaterial,
                    text: "Material Usage",
                    onPressed: () {
                      _showAddUpdateMaterialUsageBottomSheet(
                        context,
                        historyModel: history,
                        index: index,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
