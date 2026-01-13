import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewDocumentScreen extends StatefulWidget {
  final int projectDocumentId;
  const ViewDocumentScreen({super.key, required this.projectDocumentId});

  @override
  State<ViewDocumentScreen> createState() => _ViewDocumentScreenState();
}

class _ViewDocumentScreenState extends State<ViewDocumentScreen> {
  //CUBIT
  late DocumentCubit _documentCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    super.initState();
    _documentCubit = context.read<DocumentCubit>();
    _routeAuthorizationModel = AuthorizationModel();

    _documentCubit.getProjectDocumentList(
      context: context,
      pageNumber: 1,
      projectDocumentId: widget.projectDocumentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Documents",
        authorization: _routeAuthorizationModel,
      ),
      body: Column(
        children: [
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
                    return _buildDocumentCard(state.documentList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnTitleValue({
    required String title,
    required String? value,
  }) {
    if (value == null) {
      return SizedBox.shrink();
    }
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentModel documentModel) {
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
                  documentModel.projectDocumentName,
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              CustomIconButton.edit(onPressed: () {}),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnTitleValue(
                title: "Status",
                value: documentModel.projectDocumentStatus,
              ),
              _buildColumnTitleValue(
                title: "Expiry Date",
                value:
                    documentModel.projectDocumentExpiryDate != null
                        ? formatDateTimeAsDDMMMYYYY(
                          documentModel.projectDocumentExpiryDate!,
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
                value: documentModel.modifiedBy,
              ),
              _buildColumnTitleValue(
                title: "Last Modified Date",
                value:
                    documentModel.modifiedDate != null
                        ? formatDateTimeAsDDMMMYYYY(documentModel.modifiedDate!)
                        : '-',
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnTitleValue(
                title: "Remark",
                value: documentModel.projectDocumentRemark,
              ),
              _buildColumnTitleValue(title: "View Document", value: '-'),
            ],
          ),
        ],
      ),
    );
  }
}
