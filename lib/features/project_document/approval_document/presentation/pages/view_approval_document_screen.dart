import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewApprovalDocumentScreen extends StatefulWidget {
  final int index;
  final ApprovalDocumentModel documentModel;

  const ViewApprovalDocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
  });

  @override
  State<ViewApprovalDocumentScreen> createState() =>
      _ViewApprovalDocumentScreenState();
}

class _ViewApprovalDocumentScreenState
    extends State<ViewApprovalDocumentScreen> {
  //CUBIT
  late ApprovalDocumentCubit _documentCubit;
  late UtilsCubit _utilsCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _documentCubit = context.read<ApprovalDocumentCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.approvalDocument]!;
    _documentCubit.getProjectApprovalDocumentList(
      context: context,
      pageNumber: 1,
      approvalDocumentId: widget.documentModel.approvalDocumentId,
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
          !_documentCubit.state.isLoading! &&
          _documentCubit.state.subApprovalDocumentList.length <
              _documentCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _documentCubit.getProjectApprovalDocumentList(
            context: context,
            pageNumber: _documentCubit.state.currentPageOfSubDoc + 1,
            approvalDocumentId: widget.documentModel.approvalDocumentId,
          );
        });
      }
    });
  }

  // DELETE SUB DOCUMENT
  Future<void> _showPopupToDeleteSubDocument(
    BuildContext context,
    ApprovalDocumentModel obj,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _documentCubit.deleteApprovalDocument(
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
        screenTitle: "Approval Documents",
        authorization: _routeAuthorizationModel,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
        child: Column(
          spacing: 15,
          children: [
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.documentModel.approvalDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
                _routeAuthorizationModel.isAction
                    ? CustomButton(
                      leading: Icon(Icons.add, color: AppColor.white, size: 16),
                      text: "Add",
                      onPressed: () {
                        goRouter.pushNamed(
                          AppRoutes.addApprovalDocument,
                          queryParameters: {
                            "approvalDocument": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(widget.documentModel.toJson()),
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

            BlocBuilder<ApprovalDocumentCubit, ApprovalDocumentState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.subApprovalDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.subApprovalDocumentList.isEmpty) {
                  return Expanded(child: Center(child: noDataWidget()));
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.subApprovalDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.subApprovalDocumentList.length) {
                        return state.subApprovalDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      return _buildDocumentCard(
                        state.subApprovalDocumentList[index],
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
    ApprovalDocumentModel document,
    int index,
    BuildContext context,
  ) {
    // IF DOCUMENT IS NOT APPROVED OR USER HAS NO ACTION PERMISSION,
    // THEN ACTIONS ARE CONSIDERED ALREADY PERFORMED -> SHOW HISTORY AND DISABLE ACTIONS
    final bool isActionAllowed = document.isApproval;

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
                  document.approvalDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              if (_routeAuthorizationModel.isAction) ...[
                CustomIconButton.edit(
                  isDisabled:
                      !document.approvalDocumentApprovalStatus
                          .toLowerCase()
                          .contains('pending'),
                  onPressed: () {
                    goRouter.pushNamed(
                      AppRoutes.addApprovalDocument,
                      queryParameters: {
                        "approvalDocument": Uri.encodeQueryComponent(
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
                  isDisabled:
                      !document.approvalDocumentApprovalStatus
                          .toLowerCase()
                          .contains('pending'),
                  onPressed: () {
                    _showPopupToDeleteSubDocument(context, document, index);
                  },
                ),
              ],
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Status",
                customValueWidget: statusWidget(
                  document.approvalDocumentStatus,
                ),
                value: document.approvalDocumentStatus,
              ),
              buildColumnTitleValue(
                title: "Expiry Date",
                value:
                    document.approvalDocumentExpiryDate != null
                        ? formatDateTimeAsDDMMMYYYY(
                          document.approvalDocumentExpiryDate!,
                        )
                        : '-',
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
                value:
                    document.modifiedDate != null
                        ? formatDate(document.modifiedDate!)
                        : formatDate(document.createdDate),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Approval Status",
                value: document.approvalDocumentApprovalStatus,
                customValueWidget: approvalStatusWidget(
                  document.approvalDocumentApprovalStatus,
                ),
              ),
              buildColumnTitleValue(
                title: "View Document",
                value: document.approvalDocumentURL,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.approvalDocumentURL.isEmpty,
                      onPressed: () {
                        final url = document.approvalDocumentURL;
                        if (url.isNotEmpty) {
                          showFilePreviewDialog(
                            title: document.approvalDocumentName,
                            context,
                            url.split(","),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildColumnTitleValue(
                title: "Remark",
                value: document.approvalDocumentRemark,
              ),
            ],
          ),
          ApproveRejectWidget(
            actionTitle: isActionAllowed ? "Actions" : "History",
            isActionAlreadyPerformed: !isActionAllowed,
            popupTitle:
                "${widget.documentModel.approvalDocumentCategory} > ${document.approvalDocumentName}",
            onApprove: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'APPROVAL DOCUMENT APPROVAL',
                id: document.approvalDocumentId,
                projectId: document.projectId,
                isApproved: true,
                remark: val.trim(),
              );
              if (context.mounted) {
                _documentCubit.getProjectApprovalDocumentList(
                  context: context,
                  pageNumber: 1,
                  approvalDocumentId: widget.documentModel.approvalDocumentId,
                );
              }
            },
            onReject: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'APPROVAL DOCUMENT APPROVAL',
                id: document.approvalDocumentId,
                projectId: document.projectId,
                isApproved: false,
                remark: val.trim(),
              );
              if (context.mounted) {
                _documentCubit.getProjectApprovalDocumentList(
                  context: context,
                  pageNumber: 1,
                  approvalDocumentId: widget.documentModel.approvalDocumentId,
                );
              }
            },
            onThirdTap: () async {
              final approvalLogHistoryList = await _utilsCubit
                  .getApprovalLogHistory(
                    context: context,
                    projectId: document.projectId,
                    id: document.approvalDocumentId,
                    moduleName: "APPROVAL DOCUMENT APPROVAL",
                  );

              if (context.mounted) {
                goRouter.pushNamed(
                  AppRoutes.approvalLogHistory,
                  queryParameters: {
                    "subTitle": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "${widget.documentModel.approvalDocumentCategory} > ${document.approvalDocumentName}",
                      ),
                    ),
                    "title": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "Approval Document Log History",
                      ),
                    ),
                    "approvalList": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        jsonEncode(
                          approvalLogHistoryList
                              .map((e) => e.toJson())
                              .toList(),
                        ),
                      ),
                    ),
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper Widget
  Widget statusWidget(String status) {
    final s = status.toLowerCase();

    switch (s) {
      case 'applied':
        return statusChip(status, AppColor.lightBlue2, AppColor.primary);

      case 'doc missing':
        return statusChip(status, AppColor.warning20, AppColor.warning);

      case 'in process':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'issued':
        return statusChip(
          status,
          AppColor.darkBackground.withValues(alpha: 0.29),
          AppColor.darkBackground,
        );

      case 'not applied':
      case 'not applicable':
        return statusChip(status, AppColor.grey2, AppColor.black);

      case 'paid':
        return statusChip(status, AppColor.green20, AppColor.darkGreen10);

      case 'payment due':
        return statusChip(status, AppColor.purple20, AppColor.purple);

      case 'rejected':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      default:
        return statusChip(status, Colors.white, Colors.black);
    }
  }
}
