import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/finance/document/data/model/term_sheet_documents.model.dart';
import 'package:k3h_erp_app/features/finance/document/presentation/cubit/documents_cubit.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermSheetDocumentScreen extends StatefulWidget {
  final TermSheetModel termSheetModel;
  final TermSheetDetailsView termSheetDetailsView;
  const TermSheetDocumentScreen({
    super.key,
    required this.termSheetDetailsView,
    required this.termSheetModel,
  });

  @override
  State<TermSheetDocumentScreen> createState() =>
      _TermSheetDocumentScreenState();
}

class _TermSheetDocumentScreenState extends State<TermSheetDocumentScreen> {
  late DocumentsCubit _documentsCubit;

  @override
  void initState() {
    super.initState();
    _documentsCubit = context.read<DocumentsCubit>();
    _documentsCubit.getTermSheetDocumentList(
      context,
      1,
      projectId: widget.termSheetDetailsView.projectId,
      termSheetId: widget.termSheetDetailsView.termSheetId,
      termSheetDetailsId: widget.termSheetDetailsView.termSheetDetailsId,
    );
  }

  Future<void> _showPopupToDeeleteTermSheetDocument(
    BuildContext context,
    TermSheetDocumentModel termSheetDocument,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'ou are about to delete a Term Sheet Document ?',
      'Deleting this Term Sheet Document will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _documentsCubit.deleteTermSheetDocument(
        context: context,
        termSheetDocumentId: termSheetDocument.termSheetDocumentId,
        uniquekey: termSheetDocument.uniquekey,
        termSheetId: termSheetDocument.termSheetId,
        termSheetDetailsId: termSheetDocument.termSheetDetailsId,
        projectId: termSheetDocument.projectId,
      );
    }
  }

  bool get isClosed =>
      widget.termSheetModel.approvalStatus.trim().toLowerCase() == "closed";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, state) {
        if (state.isLoading ?? false) {
          return Center(child: loader());
        }

        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.termSheetModel.projectName,
                      style: AppTextStyle.ts14M(),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          widget
                                  .termSheetModel
                                  .nameOfInstitutionBankNbfc
                                  .isEmpty
                              ? "-"
                              : widget.termSheetModel.nameOfInstitutionBankNbfc,
                      style: AppTextStyle.ts14SB(color: AppColor.primary),
                    ),
                    TextSpan(
                      text: " > ",
                      style: AppTextStyle.ts14M(
                        color: AppColor.greyTitleAndValueColor,
                      ),
                    ),
                    TextSpan(
                      text: widget.termSheetModel.approvalStatus,
                      style: AppTextStyle.ts14M(),
                    ),
                  ],
                ),
              ),
              verticalSpacing(),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomButton(
                    text: "Add",
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addDocuments,
                        extra: {
                          "isEdit": false,
                          "termSheetDetailsView": widget.termSheetDetailsView,
                          "termSheetModel": widget.termSheetModel,
                        },
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              Expanded(
                child:
                    state.termSheetDocumentList.isEmpty
                        ? Center(
                          child: noDataWidget(
                            message: "No Documents Found",
                            iconSize: 160.0,
                          ),
                        )
                        : ListView.builder(
                          itemCount: state.termSheetDocumentList.length,
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final documents =
                                state.termSheetDocumentList[index];
                            final documentCount =
                                documents.documentUrl
                                    .split(',')
                                    .where((url) => url.trim().isNotEmpty)
                                    .length;
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (documents
                                                .documentUrl
                                                .isNotEmpty) {
                                              showFilePreviewDialog(
                                                title: documents.documentName,
                                                context,
                                                documents.documentUrl.split(
                                                  ",",
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            documents.documentName,
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.primary,
                                            ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomIconButton.edit(
                                              isDisabled:
                                                  !documents
                                                      .isSubmittedOriginalDocument &&
                                                  isClosed,
                                              onPressed: () {
                                                goRouter.pushNamed(
                                                  AppRoutes.addDocuments,
                                                  extra: {
                                                    "isEdit": true,
                                                    "documentData": documents,
                                                    "termSheetDetailsView":
                                                        widget
                                                            .termSheetDetailsView,
                                                    "termSheetModel":
                                                        widget.termSheetModel,
                                                  },
                                                );
                                              },
                                            ),
                                            horizontalSpacing(),
                                            CustomIconButton.delete(
                                              isDisabled: isClosed,
                                              onPressed: () {
                                                _showPopupToDeeleteTermSheetDocument(
                                                  context,
                                                  documents,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  buildRowTitleValue(
                                    title: "Document Count",
                                    value: documentCount.toString(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Submitted Original",
                                    value:
                                        documents.isSubmittedOriginalDocument
                                            ? "Yes"
                                            : "No",
                                  ),
                                  buildRowTitleValue(
                                    title: "Collected Original",
                                    value:
                                        documents.isCollectedOriginalDocument
                                            ? "Yes"
                                            : "No",
                                  ),
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value: documents.documentRemark,
                                    singleLine: false,
                                  ),
                                  buildRowTitleValue(
                                    title: "Collected Original Date",
                                    value: formatDateTimeAsDDMMMYYYY(
                                      documents.collectedOriginalDocumentDate,
                                    ),
                                  ),
                                  buildRowTitleValue(
                                    title: "Uploaded By / Date",
                                    value:
                                        "${documents.createdBy} / ${formatDate(documents.createdDate)}",
                                    singleLine: false,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
