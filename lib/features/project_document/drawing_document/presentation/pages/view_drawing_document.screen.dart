import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/cubit/drawing_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/pages/widget/expandable_text.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDrawingDocumentScreen extends StatefulWidget {
  final int index;
  final DrawingDocumentModel drawingDocumentModel;
  const ViewDrawingDocumentScreen({
    super.key,
    required this.index,
    required this.drawingDocumentModel,
  });

  @override
  State<ViewDrawingDocumentScreen> createState() =>
      _ViewDrawingDocumentScreenState();
}

class _ViewDrawingDocumentScreenState extends State<ViewDrawingDocumentScreen> {
  //CUBIT
  late UtilsCubit _utilsCubit;
  late DrawingDocumentCubit _drawingDocumentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _drawingDocumentCubit = context.read<DrawingDocumentCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.drawingDocument]!;

    _drawingDocumentCubit.getDrawingDocumentList(
      context: context,
      pageNumber: 1,
      drawingDocumentId: widget.drawingDocumentModel.drawingDocumentId,
      drawingDocumentCategory:
          widget.drawingDocumentModel.drawingDocumentCategory,
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
          !_drawingDocumentCubit.state.isLoading! &&
          _drawingDocumentCubit.state.subDrawingDocumentList.length <
              _drawingDocumentCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _drawingDocumentCubit.getDrawingDocumentList(
            context: context,
            pageNumber: _drawingDocumentCubit.state.currentPageOfSubDoc + 1,
            drawingDocumentId: widget.drawingDocumentModel.drawingDocumentId,
          );
        });
      }
    });
  }

  // DELETE SUB DOCUMENT
  Future<void> _showPopupToDeleteSubDocument(
    BuildContext context,
    DrawingDocumentModel obj,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _drawingDocumentCubit.deleteDrawingDocument(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyle.ts16SB(),
                      children: [
                        TextSpan(
                          text:
                              widget
                                  .drawingDocumentModel
                                  .drawingDocumentCategory,
                        ),
                        TextSpan(
                          text: " > ",
                          style: AppTextStyle.ts16M(color: AppColor.grey),
                        ),
                        TextSpan(
                          text: widget.drawingDocumentModel.drawingDocumentName,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _routeAuthorizationModel.isAction
                        ? CustomButton(
                          leading: Icon(
                            Icons.add,
                            color: AppColor.white,
                            size: 16,
                          ),
                          text: "Add",
                          onPressed: () {
                            goRouter.pushNamed(
                              AppRoutes.addDrawingDocument,
                              queryParameters: {
                                "document": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(
                                      widget.drawingDocumentModel.toJson(),
                                    ),
                                  ),
                                ),
                                "index": widget.index.toString(),

                                "isEdit": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    false.toString(),
                                  ),
                                ),
                              },
                            );
                          },
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),

            BlocBuilder<DrawingDocumentCubit, DrawingDocumentState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.subDrawingDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.subDrawingDocumentList.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: noDataWidget(message: "No Document Found"),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.subDrawingDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.subDrawingDocumentList.length) {
                        return state.subDrawingDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }

                      return _buildDocumentCard(
                        state.subDrawingDocumentList[index],
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
    DrawingDocumentModel document,
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
                  document.drawingDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              CustomIconButton.edit(
                isDisabled:
                    (!_routeAuthorizationModel.isAction ||
                        !document.approvalStatus.toLowerCase().contains(
                          'pending',
                        )),
                onPressed: () {
                  goRouter.pushNamed(
                    AppRoutes.addDrawingDocument,
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
                isDisabled:
                    (!_routeAuthorizationModel.isAction ||
                        !document.approvalStatus.toLowerCase().contains(
                          'pending',
                        )),
                onPressed: () {
                  _showPopupToDeleteSubDocument(context, document, index);
                },
              ),
            ],
          ),
          buildRowTitleValue(
            title: "Revision Date",
            value:
                document.drawingDocumentRevisionDate != null
                    ? formatDateTimeAsDDMMMYYYY(
                      document.drawingDocumentRevisionDate!,
                    )
                    : '-',
          ),
          buildRowTitleValue(
            title: "Status",
            value: document.drawingDocumentStatus,
            customValueWidget: drawingDocumentStatusWidget(
              document.drawingDocumentStatus,
            ),
          ),
          ExpandableFloorRow(title: "Floor", floor: document.floor),
          buildRowTitleValue(
            title: "Last Modified By",
            value:
                document.modifiedBy.isEmpty
                    ? document.createdBy
                    : document.modifiedBy,
          ),
          buildRowTitleValue(
            title: "Last Modified Date",
            value: formatDateTimeAsDDMMMYYYY(
              document.modifiedDate ?? document.createdDate,
            ),
          ),
          buildRowTitleValue(
            title: "PDF",
            value: document.drawingDocumentUrl,
            customValueWidget: Row(
              children: [
                CustomButton.documentOutline(
                  isDisable: document.drawingDocumentUrl.isEmpty,
                  onPressed: () {
                    showFilePreviewDialog(
                      context,
                      title: document.drawingDocumentName,
                      document.drawingDocumentUrl.split(","),
                    );
                  },
                ),
              ],
            ),
          ),
          buildRowTitleValue(
            title: "DWG",
            value: document.drawingDocumentDwgurl,
            customValueWidget: Row(
              children: [
                CustomButton.documentOutline(
                  isDisable: document.drawingDocumentDwgurl.isEmpty,
                  onPressed: () {
                    showFilePreviewDialog(
                      context,
                      title: document.drawingDocumentName,
                      document.drawingDocumentDwgurl.split(","),
                    );
                  },
                ),
              ],
            ),
          ),
          buildRowTitleValue(
            title: "Remark",
            value: document.drawingDocumentRemark,
            singleLine: false,
          ),
          ApproveRejectWidget(
            showApproval: document.isApproval,
            actionTitle:
                document.approvalStatus.isEmpty
                    ? "Pending"
                    : document.approvalStatus,
            isActionAlreadyPerformed: !isActionAllowed,
            popupTitle:
                "${document.drawingDocumentCategory} > ${document.drawingDocumentName}",
            onApprove: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'DRAWING DOCUMENT APPROVAL',
                id: document.drawingDocumentId,
                projectId: document.projectId,
                isApproved: true,
                remark: val.trim(),
              );
              if (context.mounted) {
                _drawingDocumentCubit.getDrawingDocumentList(
                  context: context,
                  pageNumber: 1,
                  drawingDocumentId:
                      widget.drawingDocumentModel.drawingDocumentId,
                  drawingDocumentCategory:
                      widget.drawingDocumentModel.drawingDocumentCategory,
                );
              }
            },
            onReject: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'DRAWING DOCUMENT APPROVAL',
                id: document.drawingDocumentId,
                projectId: document.projectId,
                isApproved: false,
                remark: val.trim(),
              );
              if (context.mounted) {
                _drawingDocumentCubit.getDrawingDocumentList(
                  context: context,
                  pageNumber: 1,
                  drawingDocumentId:
                      widget.drawingDocumentModel.drawingDocumentId,
                );
              }
            },
            onThirdTap: () async {
              final approvalLogHistoryList = await _utilsCubit
                  .getApprovalLogHistory(
                    context: context,
                    projectId: document.projectId,
                    id: document.drawingDocumentId,
                    moduleName: "DRAWING DOCUMENT APPROVAL",
                  );

              if (context.mounted) {
                goRouter.pushNamed(
                  AppRoutes.approvalLogHistory,
                  queryParameters: {
                    "subTitle": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "${widget.drawingDocumentModel.drawingDocumentCategory} > ${document.drawingDocumentName}",
                      ),
                    ),
                    "title": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "Drawing Document Log History",
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
}
