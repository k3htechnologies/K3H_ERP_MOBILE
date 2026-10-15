import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/presentation/cubit/baseline_cost_plan_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewBaselineCostPlanScreen extends StatefulWidget {
  final int index;
  final BaselineCostPlanDocumentModel baselineCostPlanDocumentModel;
  const ViewBaselineCostPlanScreen({
    super.key,
    required this.index,
    required this.baselineCostPlanDocumentModel,
  });

  @override
  State<ViewBaselineCostPlanScreen> createState() =>
      _ViewBaselineCostPlanScreenState();
}

class _ViewBaselineCostPlanScreenState
    extends State<ViewBaselineCostPlanScreen> {
  //CUBIT
  late BaselineCostPlanCubit _baselineCostPlanCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _baselineCostPlanCubit = context.read<BaselineCostPlanCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.baselineCostPlan]!;

    _baselineCostPlanCubit.getBaselineCostPlanDocumentList(
      context: context,
      pageNumber: 1,
      baselineCostPlanDocumentId:
          widget.baselineCostPlanDocumentModel.baselineCostPlanDocumentId,
      baselineCostPlanDocumentCategory:
          widget.baselineCostPlanDocumentModel.baselineCostPlanDocumentCategory,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_baselineCostPlanCubit.state.isLoading! &&
          _baselineCostPlanCubit.state.subBaselineCostPlanDocumentList.length <
              _baselineCostPlanCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _baselineCostPlanCubit.getBaselineCostPlanDocumentList(
            context: context,
            pageNumber: _baselineCostPlanCubit.state.currentPageOfSubDoc + 1,
            baselineCostPlanDocumentId:
                widget.baselineCostPlanDocumentModel.baselineCostPlanDocumentId,
          );
        });
      }
    });
  }

  // DELETE SUB DOCUMENT
  Future<void> _showPopupToDeleteSubDocument(
    BuildContext context,
    BaselineCostPlanDocumentModel obj,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _baselineCostPlanCubit.deleteBaseplanCostPlanDocument(
        obj,
        context,
        index,
        isSubDoc: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Drawing Document",
        authorization: _routeAuthorizationModel,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showSiteSelectedWidget(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: Text(
                    widget
                        .baselineCostPlanDocumentModel
                        .baselineCostPlanDocumentName,
                    style: AppTextStyle.ts16SB(),
                  ),
                ),
                _routeAuthorizationModel.isAction
                    ? CustomButton(
                      leading: Icon(Icons.add, color: AppColor.white, size: 16),
                      text: "Add",
                      onPressed: () {
                        goRouter.pushNamed(
                          AppRoutes.addBaselineCostPlan,
                          queryParameters: {
                            "document": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(
                                  widget.baselineCostPlanDocumentModel.toJson(),
                                ),
                              ),
                            ),
                            "index": widget.index.toString(),

                            "isEdit": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(false.toString()),
                            ),
                          },
                        );
                      },
                    )
                    : SizedBox.shrink(),
              ],
            ),

            BlocBuilder<BaselineCostPlanCubit, BaselineCostPlanState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.subBaselineCostPlanDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.subBaselineCostPlanDocumentList.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: noDataWidget(message: "No Document Found"),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.subBaselineCostPlanDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index ==
                          state.subBaselineCostPlanDocumentList.length) {
                        return state.subBaselineCostPlanDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }

                      return _buildDocumentCard(
                        state.subBaselineCostPlanDocumentList[index],
                        index,
                        context,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //DOCUMENT CARD
  Widget _buildDocumentCard(
    BaselineCostPlanDocumentModel document,
    int index,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: commonCardDecoration(),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Expanded(
                child: Text(
                  document.baselineCostPlanDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              CustomIconButton.edit(
                isDisabled: (!_routeAuthorizationModel.isAction),
                onPressed: () {
                  goRouter.pushNamed(
                    AppRoutes.addBaselineCostPlan,
                    queryParameters: {
                      "document": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          jsonEncode(document.toJson()),
                        ),
                      ),
                      "index": index.toString(),

                      "isEdit": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(true.toString()),
                      ),
                    },
                  );
                },
              ),
              CustomIconButton.delete(
                isDisabled: (!_routeAuthorizationModel.isAction),
                onPressed: () {
                  _showPopupToDeleteSubDocument(context, document, index);
                },
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Baseline Cost Plan Value",
                value: document.baselineCostPlanValue.toIndianCurrency(),
              ),
              buildColumnTitleValue(
                title: "Remark",
                value: document.baselineCostPlanDocumentRemark,
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Last Modified By",
                value:
                    document.modifiedBy.isEmpty
                        ? document.createdBy
                        : document.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Last Modified Date",
                value: formatDateTimeAsDDMMMYYYY(
                  document.modifiedDate ?? document.createdDate,
                ),
              ),
            ],
          ),
          Row(
            children: [
              buildColumnTitleValue(
                title: "Document (.PDF)",
                value: document.baselineCostPlanDocumentUrl,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.baselineCostPlanDocumentUrl.isEmpty,
                      onPressed: () {
                        showFilePreviewDialog(
                          context,
                          title: document.baselineCostPlanDocumentName,
                          document.baselineCostPlanDocumentUrl.split(","),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildColumnTitleValue(
            title: "Remark",
            value: document.baselineCostPlanDocumentRemark,
            removeExpanded: true,
          ),
        ],
      ),
    );
  }
}
