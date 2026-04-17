import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class MaterialRequisitonScreen extends StatefulWidget {
  const MaterialRequisitonScreen({super.key});

  @override
  State<MaterialRequisitonScreen> createState() =>
      _MaterialRequisitonScreenState();
}

class _MaterialRequisitonScreenState extends State<MaterialRequisitonScreen> {
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  // SELECTION OF PROJECT
  late ProjectModel _project;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _project = getProject();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.materialRequisition]!;
    _materialRequisitionCubit.getMaterialRequisitionList(
      context,
      1,
      _project.projectId,
    );
    _onScroll();
    _initializeTextEditingController();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_materialRequisitionCubit.state.isLoading! &&
          _materialRequisitionCubit.state.materialRequisitionList.length <
              _materialRequisitionCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _materialRequisitionCubit.getMaterialRequisitionList(
            context,
            _materialRequisitionCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Material Requisition",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {},
        onAddCallback: () {},
        onProjectChangeCallback: (value) {
          _project = value;
          _materialRequisitionCubit.getMaterialRequisitionList(
            context,
            1,
            _project.projectId,
          );
        },
        onExportCallback: (value) {
          if (_project.projectId == 0) {
            showErrorMessage(context, "Error", "Please Select a project");
            return;
          }
          if (_materialRequisitionCubit.state.materialRequisitionList.isEmpty) {
            showErrorMessage(context, "", "No Data Found");
            return;
          }
          _materialRequisitionCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchC.clear();
          // _materialRequisitionCubit.(context, "", _project.projectId);
        },
        child: BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) &&
                state.materialRequisitionList.isEmpty) {
              return Center(child: loader());
            }
            if (state.materialRequisitionList.isEmpty) {
              return Center(
                child: noDataWidget(message: "No Material Data Found"),
              );
            }
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount:
                  _materialRequisitionCubit
                      .state
                      .materialRequisitionList
                      .length +
                  1,
              itemBuilder: (context, index) {
                if (index == state.materialRequisitionList.length) {
                  return state.materialRequisitionList.length <
                          state.totalNumberOfRecord
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : const SizedBox.shrink();
                }
                var material = state.materialRequisitionList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(12),
                  decoration: commonCardDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {},
                              child: Text(
                                material.systemGeneratedCode,
                                style: AppTextStyle.ts14M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),

                          horizontalSpacing(),
                          if (_routeAuthorizationModel.isAction) ...[
                            CustomIconButton.edit(
                              onPressed: () async {
                                copy(
                                  context: context,
                                  text: material.systemGeneratedCode,
                                );
                              },
                            ),
                            horizontalSpacing(),
                          ],
                          CustomIconButton.delete(onPressed: () {}),
                        ],
                      ),
                      buildRowTitleValue(
                        title: "Vendor's Name",
                        fixesWidth: 150,
                        value: material.finalVendor,
                      ),
                      buildRowTitleValue(
                        title: "Stage",
                        fixesWidth: 150,
                        value: material.materialRequisitionStage,
                      ),
                      buildRowTitleValue(
                        title: "Total PO Amount",
                        fixesWidth: 150,
                        value: "₹ ${material.totalPoAmount}",
                      ),
                      buildRowTitleValue(
                        title: "Invoice Amount",
                        fixesWidth: 150,
                        value: "₹ ${material.totalInvoice}",
                      ),

                      buildRowTitleValue(
                        title: "Status",
                        fixesWidth: 150,
                        value: material.materialRequisitionStatus,
                        customValueWidget: statusWidget(
                          material.materialRequisitionStatus,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget statusWidget(String status) {
    final trimmed = status.trim();

    // If empty → show dash
    if (trimmed.isEmpty) {
      return statusChip("-", AppColor.lightGreyBackground, AppColor.black);
    }

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'booking done':
        return statusChip(
          status,
          AppColor.green20.withValues(alpha: 0.1),
          AppColor.green,
        );

      case 'blocked':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'cancelled':
        return statusChip(status, AppColor.black10, AppColor.darkGrey);

      case 'negotiation':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'lost':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'retention':
        return statusChip(status, AppColor.lightBlue2, AppColor.info);

      case 're - visit scheduled':
        return statusChip(status, AppColor.lightGreenBg, AppColor.darkGreen);

      case 're - visit proposed':
        return statusChip(status, AppColor.lightOrangenBg, AppColor.orange);

      case 'site visit':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      case 'unit selection / blocked':
        return statusChip(
          status,
          AppColor.lightRed,
          AppColor.priorityHighColor,
        );

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }
}
