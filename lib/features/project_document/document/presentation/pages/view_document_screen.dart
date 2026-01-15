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
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
          _documentCubit.state.documentList.length <
              _documentCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _documentCubit.getProjectDocumentList(
            context: context,
            pageNumber: _documentCubit.state.currentPage + 1,
            projectDocumentId: widget.documentModel.projectDocumentId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Documents",
        authorization: _routeAuthorizationModel,
        // onProjectChangeCallback
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
                        "index": Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(widget.index.toString()),
                          ),
                        ),
                        "isEdit": Uri.encodeQueryComponent(
                          EncryptionManager.encryptData(false.toString()),
                        ),
                      },
                    );
                  },
                ),
              ],
            ),

            Expanded(
              child: BlocBuilder<DocumentCubit, DocumentState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.documentList.length,
                    itemBuilder: (context, index) {
                      if ((state.isLoading ?? true) &&
                          state.documentList.isEmpty) {
                        return Center(child: loader());
                      }
                      if (state.documentList.isEmpty) {
                        return Center(child: noDataWidget());
                      }
                      return _buildDocumentCard(
                        state.documentList[index],
                        index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BUILD TITLE WIDGET
  Widget _buildColumnTitleValue({
    required String title,
    String? value,
    Widget? valueWidget,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          valueWidget ??
              Text(value!.isEmpty ? "-" : value, style: AppTextStyle.ts14M()),
        ],
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
                      "index": Uri.encodeQueryComponent(
                        EncryptionManager.encryptData(
                          jsonEncode(index.toString()),
                        ),
                      ),
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
              _buildColumnTitleValue(
                title: "Status",
                valueWidget: Container(
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
              _buildColumnTitleValue(
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
              _buildColumnTitleValue(
                title: "Last Modified By",
                value: document.modifiedBy,
              ),
              _buildColumnTitleValue(
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
              _buildColumnTitleValue(
                title: "Remark",
                value: document.projectDocumentRemark,
              ),
              _buildColumnTitleValue(
                title: "View Document",
                valueWidget: GestureDetector(
                  onTap: () {
                    showFilePreviewDialog(
                      context,
                      document.projectDocumentURL.split(","),
                    );
                  },
                  child: Row(
                    spacing: 10,
                    children: [
                      Text(
                        "Document",
                        style: AppTextStyle.ts14M(color: AppColor.primary),
                      ),

                      CustomIconButton(
                        onPressed: () => null,
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          color: AppColor.primary,
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
