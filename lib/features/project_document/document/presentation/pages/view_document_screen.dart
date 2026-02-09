import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDocumentScreen extends StatefulWidget {
  final int index;
  final DocumentModel documentModel;

  const ViewDocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
  });

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  //CUBIT
  late DocumentCubit _documentCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _onScroll();
    _documentCubit = context.read<DocumentCubit>();
    _routeAuthorizationModel = AuthorizationModel();

    _documentCubit.getProjectDocumentList(
      context: context,
      pageNumber: 1,
      projectDocumentId: widget.documentModel.projectDocumentId,
    );
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_documentCubit.state.isLoading! &&
          _documentCubit.state.subDocumentList.length <
              _documentCubit.state.totalNumberOfRecordOfSubDoc) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _documentCubit.getProjectDocumentList(
            context: context,
            pageNumber: _documentCubit.state.currentPageOfSubDoc + 1,
            projectDocumentId: widget.documentModel.projectDocumentId,
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
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Documents",
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
                  widget.documentModel.projectDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
                CustomButton(
                  leading: Icon(Icons.add, color: AppColor.white, size: 16),
                  text: "Add",
                  onPressed: () {
                    goRouter.pushNamed(
                      AppRoutes.addDocument,
                      queryParameters: {
                        "document": Uri.encodeQueryComponent(
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

            BlocBuilder<DocumentCubit, DocumentState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.subDocumentList.isEmpty) {
                  return Expanded(child: Center(child: loader()));
                }

                if (state.subDocumentList.isEmpty) {
                  return Expanded(child: Center(child: noDataWidget()));
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: state.subDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.subDocumentList.length) {
                        return state.subDocumentList.length <
                                state.totalNumberOfRecordOfSubDoc
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      return _buildDocumentCard(
                        state.subDocumentList[index],
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
  Widget _buildDocumentCard(DocumentModel document, int index) {
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
                  document.projectDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              CustomIconButton.edit(
                onPressed: () {
                  goRouter.pushNamed(
                    AppRoutes.addDocument,
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
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumnTitleValue(
                title: "Status",
                value: document.projectDocumentApprovalStatus,
                customValueWidget: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  decoration: BoxDecoration(
                    color: getBgColorByStatus(document.projectDocumentStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    document.projectDocumentStatus,
                    style: AppTextStyle.ts12M(
                      color: getTxtColorByStatus(
                        document.projectDocumentStatus,
                      ),
                    ),
                  ),
                ),
              ),
              buildColumnTitleValue(
                title: "Expiry Date",
                value:
                    document.projectDocumentExpiryDate != null
                        ? formatDateTimeAsDDMMMYYYY(
                          document.projectDocumentExpiryDate!,
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
                value: document.projectDocumentRemark,
              ),
              buildColumnTitleValue(
                title: "View Document",
                value: document.projectDocumentURL,
                customValueWidget: Row(
                  children: [
                    CustomButton.documentOutline(
                      isDisable: document.projectDocumentURL.isEmpty,
                      onPressed: () {
                        showFilePreviewDialog(
                          context,
                          document.projectDocumentURL.split(","),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //COLOR GETTER FOR STATUS BACKGROUND COLOR AS PER STATUS
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

  //COLOR GETTER FOR STATUS TEXT COLOR AS PER STATUS
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
