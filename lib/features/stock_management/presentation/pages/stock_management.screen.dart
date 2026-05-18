import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/stock_management/presentation/cubit/stock_management_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  late StockManagementCubit _stockManagementCubit;
  late ProjectModel _selectedProject;

  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC;
  @override
  void initState() {
    super.initState();
    _stockManagementCubit = context.read<StockManagementCubit>();
    _selectedProject = getProject();
    _stockManagementCubit.getStockList(context, 1, _selectedProject.projectId);
    _searchC = TextEditingController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.stockManagement]!;
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Stock Management",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search by Stock Management",
        isFilterOn: true,
        onFilterTap: () {},
        onSearchSubmit: (value) {
          _stockManagementCubit.searchStock(
            context,
            value,
            _selectedProject.projectId,
          );
        },
        textController: _searchC,
        onExportCallback: (value) {
          _stockManagementCubit.stocksForExportPDF(
            context,
            _selectedProject.projectId,
            value,
          );
        },
        onProjectChangeCallback: (value) {
          _selectedProject = value;
          _stockManagementCubit.getStockList(
            context,
            1,
            _selectedProject.projectId,
          );
        },
      ),
      body: BlocBuilder<StockManagementCubit, StockManagementState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.stockList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              itemCount: state.stockList.length,
              itemBuilder: (context, index) {
                var stocks = state.stockList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  decoration: commonCardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                goRouter.pushNamed(
                                  AppRoutes.viewStockManagement,
                                  queryParameters: {
                                    'materialName': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        stocks.materialName,
                                      ),
                                    ),
                                    'subMaterialName': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        stocks.subMaterialName,
                                      ),
                                    ),
                                    'subMaterialMasterId': Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        stocks.subMaterialMasterId.toString(),
                                      ),
                                    ),
                                  },
                                );
                              },
                              child: Text(
                                stocks.materialName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomIconButton.add(
                                  onPressed: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.addStockManagement,
                                      queryParameters: {
                                        'stock': Uri.encodeComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(stocks.toJson()),
                                          ),
                                        ),
                                        'index': index.toString(),
                                        'isRemove': "false",
                                      },
                                    );
                                  },
                                ),
                                horizontalSpacing(),
                                CustomIconButton.remove(
                                  onPressed: () async {
                                    await goRouter.pushNamed(
                                      AppRoutes.addStockManagement,
                                      queryParameters: {
                                        'stock': Uri.encodeComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(stocks.toJson()),
                                          ),
                                        ),
                                        'index': index.toString(),
                                        'isRemove': "true",
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Sub-Material Name",
                        value: stocks.subMaterialName,
                      ),
                      buildRowTitleValue(title: "UOM", value: stocks.uomCode),
                      buildRowTitleValue(
                        title: "Total Quantity",
                        value: stocks.totalMaterialQuantityInStock.toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
