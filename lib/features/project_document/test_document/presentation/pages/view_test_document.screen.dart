import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/model/test_document.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document/presentation/cubit/test_document_cubit.dart';
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
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewTestDocumentScreen extends StatefulWidget {
  final int index;
  final TestDocumentModel testDocumentModel;
  const ViewTestDocumentScreen({
    super.key,
    required this.index,
    required this.testDocumentModel,
  });

  @override
  State<ViewTestDocumentScreen> createState() => _ViewTestDocumentScreenState();
}

class _ViewTestDocumentScreenState extends State<ViewTestDocumentScreen> {
  //CUBIT
  late UtilsCubit _utilsCubit;
  late TestDocumentCubit _testDocumentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _testDocumentCubit = context.read<TestDocumentCubit>();
    _utilsCubit = context.read<UtilsCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.testDocument]!;

    _testDocumentCubit.getTestDocumentList(
      context: context,
      pageNumber: 1,
      testDocumentId: widget.testDocumentModel.testDocumentId,
      testDocumentCategory: widget.testDocumentModel.testDocumentCategory,
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
          !_testDocumentCubit.state.isLoading! &&
          _testDocumentCubit.state.subTestDocumentList.length <
              _testDocumentCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _testDocumentCubit.getTestDocumentList(
            context: context,
            pageNumber: _testDocumentCubit.state.currentPageOfSubDoc + 1,
            testDocumentId: widget.testDocumentModel.testDocumentId,
          );
        });
      }
    });
  }

  // DELETE SUB DOCUMENT
  Future<void> _showPopupToDeleteSubDocument(
    BuildContext context,
    TestDocumentModel obj,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _testDocumentCubit.deleteDocument(obj, context, index, isSubDoc: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Test Document",
        authorization: _routeAuthorizationModel,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16),
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: Text(
                    widget.testDocumentModel.testDocumentName,
                    style: AppTextStyle.ts16SB(),
                  ),
                ),
                _routeAuthorizationModel.isAction
                    ? CustomButton(
                      leading: Icon(Icons.add, color: AppColor.white, size: 16),
                      text: "Add",
                      onPressed: () {
                        goRouter.pushNamed(
                          AppRoutes.addTestDocument,
                          queryParameters: {
                            "document": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(widget.testDocumentModel.toJson()),
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

            BlocBuilder<TestDocumentCubit, TestDocumentState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.subTestDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.subTestDocumentList.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: noDataWidget(message: "No Document Found"),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.subTestDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.subTestDocumentList.length) {
                        return state.subTestDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }

                      return _buildDocumentCard(
                        state.subTestDocumentList[index],
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
    TestDocumentModel document,
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
                  document.testDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              if (_routeAuthorizationModel.isAction) ...[
                CustomIconButton.edit(
                  isDisabled:
                      !document.approvalStatus.toLowerCase().contains(
                        'pending',
                      ),
                  onPressed: () {
                    goRouter.pushNamed(
                      AppRoutes.addTestDocument,
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
                      !document.approvalStatus.toLowerCase().contains(
                        'pending',
                      ),
                  onPressed: () {
                    _showPopupToDeleteSubDocument(context, document, index);
                  },
                ),
              ],
            ],
          ),
          buildColumnTitleValue(
            title: "Expiry Date",
            removeExpanded: true,
            value:
                document.testDocumentExpiryDate != null
                    ? formatDateTimeAsDDMMMYYYY(
                      document.testDocumentExpiryDate!,
                    )
                    : '-',
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
                title: "View Document",
                value: document.testDocumentUrl,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.testDocumentUrl.isEmpty,
                      onPressed: () {
                        showFilePreviewDialog(
                          context,
                          title: document.testDocumentName,
                          document.testDocumentUrl.split(","),
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
            value: document.testDocumentRemark,
            removeExpanded: true,
          ),
          ApproveRejectWidget(
            showApproval: document.isApproval,
            actionTitle:
                document.approvalStatus.isEmpty
                    ? "Pending"
                    : document.approvalStatus,
            isActionAlreadyPerformed: !isActionAllowed,
            popupTitle:
                "${document.testDocumentCategory} > ${document.testDocumentName}",
            onApprove: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'TEST DOCUMENT APPROVAL',
                id: document.testDocumentId,
                projectId: document.projectId,
                isApproved: true,
                remark: val.trim(),
              );
              if (context.mounted) {
                _testDocumentCubit.getTestDocumentList(
                  context: context,
                  pageNumber: 1,
                  testDocumentId: widget.testDocumentModel.testDocumentId,
                  testDocumentCategory:
                      widget.testDocumentModel.testDocumentCategory,
                );
              }
            },
            onReject: (val) async {
              await _utilsCubit.updateModulesWorkflowApproval(
                context: context,
                moduleName: 'TEST DOCUMENT APPROVAL',
                id: document.testDocumentId,
                projectId: document.projectId,
                isApproved: false,
                remark: val.trim(),
              );
              if (context.mounted) {
                _testDocumentCubit.getTestDocumentList(
                  context: context,
                  pageNumber: 1,
                  testDocumentId: widget.testDocumentModel.testDocumentId,
                );
              }
            },
            onThirdTap: () async {
              final approvalLogHistoryList = await _utilsCubit
                  .getApprovalLogHistory(
                    context: context,
                    projectId: document.projectId,
                    id: document.testDocumentId,
                    moduleName: "TEST DOCUMENT APPROVAL",
                  );

              if (context.mounted) {
                goRouter.pushNamed(
                  AppRoutes.approvalLogHistory,
                  queryParameters: {
                    "subTitle": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "${widget.testDocumentModel.testDocumentCategory} > ${document.testDocumentName}",
                      ),
                    ),
                    "title": Uri.encodeComponent(
                      EncryptionManager.encryptData(
                        "Project Document Log History",
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
