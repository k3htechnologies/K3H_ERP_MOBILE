import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewRERADocumentScreen extends StatefulWidget {
  final int index;
  final RERADocumentModel documentModel;

  const ViewRERADocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
  });

  @override
  State<ViewRERADocumentScreen> createState() => _ViewRERADocumentScreenState();
}

class _ViewRERADocumentScreenState extends State<ViewRERADocumentScreen> {
  //CUBIT
  late RERADocumentCubit _documentCubit;
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
    _documentCubit = context.read<RERADocumentCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.rera]!;

    _documentCubit.getRERADocumentList(
      context: context,
      pageNumber: 1,
      projectRERADocumentId: widget.documentModel.projectRERADocumentId,
    );
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_documentCubit.state.isLoading! &&
          _documentCubit.state.reraSubDocumentList.length <
              _documentCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _documentCubit.getRERADocumentList(
            context: context,
            pageNumber: _documentCubit.state.currentPageOfSubDoc + 1,
            projectRERADocumentId: widget.documentModel.projectRERADocumentId,
          );
        });
      }
    });
  }

  // DELETE RERA DOCUMENT
  Future<void> _showPopupToDeleteRERASubDocument(
    BuildContext context,
    RERADocumentModel obj,

    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to RERA delete a document?',
      'Deleting this RERA document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _documentCubit.deleteDocument(
        obj,
        obj.projectRERADocumentCategoryId,
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
        screenTitle: "RERA Documents",
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
                  widget.documentModel.projectRERADocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
                if (_routeAuthorizationModel.isAction)
                  CustomButton(
                    leading: Icon(Icons.add, color: AppColor.white, size: 16),
                    text: "Add",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addReraDocument,
                        queryParameters: {
                          "reraDocument": Uri.encodeQueryComponent(
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
                  ),
              ],
            ),

            BlocBuilder<RERADocumentCubit, RERADocumentState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.reraSubDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.reraSubDocumentList.isEmpty) {
                  return Expanded(child: Center(child: noDataWidget()));
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.reraSubDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.reraSubDocumentList.length) {
                        return state.reraSubDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      return _buildDocumentCard(
                        state.reraSubDocumentList[index],
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

  // DOCUMENT CARD
  Widget _buildDocumentCard(
    RERADocumentModel document,
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
                  document.projectRERADocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              if (_routeAuthorizationModel.isAction) ...[
                CustomIconButton.edit(
                  isDisabled:
                      !document.projectRERADocumentApprovalStatus
                          .toLowerCase()
                          .contains('pending'),
                  onPressed: () {
                    goRouter.pushNamed(
                      AppRoutes.addReraDocument,
                      queryParameters: {
                        "reraDocument": Uri.encodeQueryComponent(
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
                      !document.projectRERADocumentApprovalStatus
                          .toLowerCase()
                          .contains('pending'),
                  onPressed: () {
                    _showPopupToDeleteRERASubDocument(context, document, index);
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
                value: document.projectRERADocumentStatus,
                customValueWidget: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  decoration: BoxDecoration(
                    color: getBgColorByStatus(
                      document.projectRERADocumentStatus,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    document.projectRERADocumentStatus,
                    style: AppTextStyle.ts12M(
                      color: getTxtColorByStatus(
                        document.projectRERADocumentStatus,
                      ),
                    ),
                  ),
                ),
              ),
              buildColumnTitleValue(
                title: "Approval Status",
                value: document.projectRERADocumentApprovalStatus,
                customValueWidget: approvalStatusWidget(
                  document.projectRERADocumentApprovalStatus,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Last Modified By",
                value: document.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Last Modified Date",
                value:
                    document.modifiedDate != null
                        ? formatDate(document.modifiedDate!)
                        : '-',
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "View Screenshot",
                value: document.reraPortalScreenShotURL!,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.reraPortalScreenShotURL!.isEmpty,
                      onPressed: () {
                        showFilePreviewDialog(
                          context,
                          document.reraPortalScreenShotURL!.split(","),
                        );
                      },
                    ),
                  ],
                ),
              ),
              buildColumnTitleValue(
                title: "View Document",
                value: document.projectRERADocumentURL,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.projectRERADocumentURL.isEmpty,
                      onPressed: () {
                        showFilePreviewDialog(
                          context,
                          document.projectRERADocumentURL.split(","),
                        );
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
                value: document.projectRERADocumentRemark,
              ),
            ],
          ),
          ApproveRejectWidget(
            actionTitle: isActionAllowed ? "Actions" : "History",
            isActionAlreadyPerformed: !isActionAllowed,
            popupTitle:
                "${widget.documentModel.projectRERADocumentCategory} > ${document.projectRERADocumentName}",
            onApprove: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'RERA DOCUMENT APPROVAL',
                id: document.projectRERADocumentId,
                projectId: document.projectId,
                isApproved: true,
                remark: val.trim(),
              );
              if (context.mounted) {
                _documentCubit.getRERADocumentList(
                  context: context,
                  pageNumber: 1,
                  projectRERADocumentId:
                      widget.documentModel.projectRERADocumentId,
                );
              }
            },
            onReject: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'RERA DOCUMENT APPROVAL',
                id: document.projectRERADocumentId,
                projectId: document.projectId,
                isApproved: false,
                remark: val.trim(),
              );
              if (context.mounted) {
                _documentCubit.getRERADocumentList(
                  context: context,
                  pageNumber: 1,
                  projectRERADocumentId:
                      widget.documentModel.projectRERADocumentId,
                );
              }
            },
            onThirdTap: () async {
              final approvalLogHistoryList = await _utilsCubit
                  .getApprovalLogHistory(
                    context: context,
                    projectId: document.projectId,
                    id: document.projectRERADocumentId,
                    moduleName: "RERA DOCUMENT APPROVAL",
                  );

              if (context.mounted) {
                goRouter.pushNamed(
                  AppRoutes.approvalLogHistory,
                  queryParameters: {
                    "subTitle": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "${widget.documentModel.projectRERADocumentCategory} > ${document.projectRERADocumentName}",
                      ),
                    ),
                    "title": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "RERA Document Log History",
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

  // COLOR GETTER FOR STATUS BACKGROUND COLOR AS PER STATUS
  static Color getBgColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return AppColor.lightBlue2;
      case 'doc missing':
        return AppColor.warning20;

      case 'in process':
        return AppColor.lightYellow;
      case 'issued':
        return AppColor.darkBackground.withValues(alpha: 0.29);

      case 'not applied':
        return AppColor.grey2;
      case 'not applicable':
        return AppColor.grey2;
      case "paid":
        return AppColor.green20;
      case "payment due":
        return AppColor.purple20;
      case "rejected":
        return AppColor.lightRed;
      default:
        return Colors.white;
    }
  }

  // COLOR GETTER FOR STATUS TEXT COLOR AS PER STATUS
  static Color getTxtColorByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return AppColor.primary;
      case 'doc missing':
        return AppColor.warning;

      case 'in process':
        return AppColor.brown;
      case 'issued':
        return AppColor.darkBackground;

      case 'not applied':
        return AppColor.black;
      case 'not applicable':
        return AppColor.black;
      case "paid":
        return AppColor.darkGreen10;
      case "payment due":
        return AppColor.purple;
      case "rejected":
        return AppColor.red;
      default:
        return Colors.black;
    }
  }
}
