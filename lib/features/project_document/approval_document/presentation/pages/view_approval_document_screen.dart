import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
    _routeAuthorizationModel = AuthorizationModel();

    _documentCubit.getProjectApprovalDocumentList(
      context: context,
      pageNumber: 1,
      approvalDocumentId: widget.documentModel.approvalDocumentId,
    );
  }

  // <---- PAGINATION ---->
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
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
                CustomButton(
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
                ),
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
  Widget _buildDocumentCard(ApprovalDocumentModel document, int index) {
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
              CustomIconButton.edit(
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
                value: document.modifiedBy,
              ),
              buildColumnTitleValue(
                title: "Last Modified Date",
                value:
                    document.modifiedDate != null
                        ? formatDateTimeAsDDMMMYYYY(document.modifiedDate!)
                        : '-',
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Remark",
                value: document.approvalDocumentRemark,
              ),
              buildColumnTitleValue(
                title: "View Document",
                value: document.approvalDocumentURL,
                customValueWidget: GestureDetector(
                  onTap: () {
                    if (document.approvalDocumentURL.isNotEmpty) {
                      showFilePreviewDialog(
                        context,
                        document.approvalDocumentURL.split(","),
                      );
                    }
                  },
                  child: Row(
                    spacing: 10,
                    children: [
                      Text(
                        "Document",
                        style: AppTextStyle.ts14M(
                          color:
                              document.approvalDocumentURL.isNotEmpty
                                  ? AppColor.primary
                                  : AppColor.grey,
                        ),
                      ),

                      CustomIconButton(
                        onPressed: () {
                          if (document.approvalDocumentURL.isNotEmpty) {
                            showFilePreviewDialog(
                              context,
                              document.approvalDocumentURL.split(","),
                            );
                          }
                        },
                        backgroundColor:
                            document.approvalDocumentURL.isNotEmpty
                                ? AppColor.lightBlue
                                : AppColor.lightGrey,
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          color:
                              document.approvalDocumentURL.isNotEmpty
                                  ? AppColor.primary
                                  : AppColor.grey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        return _statusChip(status, AppColor.lightBlue2, AppColor.primary);

      case 'doc missing':
        return _statusChip(status, AppColor.warning20, AppColor.warning);

      case 'in process':
        return _statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'issued':
        return _statusChip(
          status,
          AppColor.darkBackground.withValues(alpha: 0.29),
          AppColor.darkBackground,
        );

      case 'not applied':
      case 'not applicable':
        return _statusChip(status, AppColor.grey2, AppColor.black);

      case 'paid':
        return _statusChip(status, AppColor.green20, AppColor.darkGreen10);

      case 'payment due':
        return _statusChip(status, AppColor.purple20, AppColor.purple);

      case 'rejected':
        return _statusChip(status, AppColor.lightRed, AppColor.red);

      default:
        return _statusChip(status, Colors.white, Colors.black);
    }
  }

  Widget _statusChip(String text, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppTextStyle.ts12M(color: txt)),
    );
  }
}
