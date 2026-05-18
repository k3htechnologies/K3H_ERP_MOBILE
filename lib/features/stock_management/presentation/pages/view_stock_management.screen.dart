import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/stock_management/data/model/stock_management_history.model.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _stockManagementCubit = context.read<StockManagementCubit>();
    _selectedProject = getProject();
    _stockManagementCubit.getStockHistoryList(
      context,
      1,
      _selectedProject.projectId,
      widget.subMaterialMasterId,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _stockManagementCubit.changeHistoryTab(_tabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Stock Management",
        authorization: AuthorizationModel(),
      ),
      body: Column(
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
            tabs: const ["History", "Material In", "Material Out"],
          ),

          Expanded(
            child: BlocBuilder<StockManagementCubit, StockManagementState>(
              builder: (context, state) {
                if ((state.isLoading ?? false)) {
                  return const Center(child: CircularProgressIndicator());
                }

                final historyList = state.stockHistoryList;

                List<StockManagementHistoryModel> filteredList = historyList;

                /// MATERIAL IN
                if (state.selectedHistoryTab == 1) {
                  filteredList =
                      historyList
                          .where(
                            (e) =>
                                e.inwardOutwardType.toUpperCase() == "INWARD",
                          )
                          .toList();
                }

                /// MATERIAL OUT
                if (state.selectedHistoryTab == 2) {
                  filteredList =
                      historyList
                          .where(
                            (e) =>
                                e.inwardOutwardType.toUpperCase() == "OUTWARD",
                          )
                          .toList();
                }

                if (filteredList.isEmpty) {
                  return Center(child: noDataWidget());
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final stock = filteredList[index];

                    final isInward =
                        stock.inwardOutwardType.toUpperCase() == "INWARD";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRowTitleValue(
                            title: isInward ? "Material In" : "Material Out",

                            value:
                                "${isInward ? '+' : '-'} "
                                "${stock.materialQuantityInwardOutward} "
                                "${stock.uomCode}",
                            valueTextStyle: AppTextStyle.ts14M(
                              color:
                                  isInward
                                      ? AppColor.green
                                      : AppColor.missingInformationRed,
                            ),
                          ),
                          if (isInward)
                            buildRowTitleValue(
                              title: "PO No.",
                              value: stock.systemGeneratedCode,
                            ),

                          buildRowTitleValue(
                            title: "Created By",
                            value: stock.createdBy,
                          ),
                          buildRowTitleValue(
                            title: "Created Date",
                            value: formatDateTimeAsDDMMMYYYY(stock.createdDate),
                          ),
                          buildRowTitleValue(
                            title: "Remark",
                            value: stock.reason,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
