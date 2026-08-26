import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/document/data/model/term_sheet_documents.model.dart';
import 'package:k3h_erp_app/features/finance/document/presentation/cubit/documents_cubit.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDocumentsScreen extends StatefulWidget {
  final bool isEdit;
  final TermSheetModel? termSheetModel;
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetDocumentModel? termSheetDocumentModel;
  const AddDocumentsScreen({
    super.key,
    required this.isEdit,
    this.termSheetDocumentModel,
    this.termSheetDetailsView,
    this.termSheetModel,
  });

  @override
  State<AddDocumentsScreen> createState() => _AddDocumentsScreenState();
}

class _AddDocumentsScreenState extends State<AddDocumentsScreen> {
  late DocumentsCubit _documentsCubit;
  late TextEditingController _remarkC;
  DateTime? collectedOriginalDocumentDate;

  late ValueNotifier<bool> submittedOriginalNotifier;
  late ValueNotifier<bool> collectedOriginalNotifier;

  late ValueNotifier<DateTime?> collectedOriginalDateNotifier;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<Map<String, dynamic>?> selectedSupport = ValueNotifier(
    null,
  );

  final MultiFilePickerModel files = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    _documentsCubit = context.read<DocumentsCubit>();
    _remarkC = TextEditingController();
    submittedOriginalNotifier = ValueNotifier(false);
    collectedOriginalNotifier = ValueNotifier(false);
    collectedOriginalDateNotifier = ValueNotifier(null);

    if (widget.isEdit && widget.termSheetDocumentModel != null) {
      prefillTermSheetDocument();
    }
    super.initState();
  }

  void prefillTermSheetDocument() {
    final document = widget.termSheetDocumentModel!;

    _remarkC.text = document.documentRemark;

    submittedOriginalNotifier.value = document.isSubmittedOriginalDocument;

    collectedOriginalNotifier.value = document.isCollectedOriginalDocument;

    if (document.collectedOriginalDocumentDate != null) {
      collectedOriginalDateNotifier.value =
          document.collectedOriginalDocumentDate;
    }

    final selectedDocument = termSheetDocumentList.firstWhere(
      (item) => item['DisplayName'] == document.documentName,
      orElse: () => termSheetDocumentList.first,
    );

    if (selectedDocument.isNotEmpty) {
      selectedSupport.value = selectedDocument;
    }
    files.fileNameList =
        widget.termSheetDocumentModel!.documentUrl.isEmpty
            ? []
            : widget.termSheetDocumentModel!.documentUrl.split(",");
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bool submittedOriginal = submittedOriginalNotifier.value;
    final bool collectedOriginal = collectedOriginalNotifier.value;

    debugPrint("Submitted Original: $submittedOriginal");
    debugPrint("Collected Original: $collectedOriginal");
    final termSheetDetails = widget.termSheetDetailsView;

    if (termSheetDetails == null) {
      return;
    }
    if (widget.isEdit) {
      final termSheetDocument = widget.termSheetDocumentModel;

      if (termSheetDocument == null) return;
      _documentsCubit.updateTermSheetDocument(
        context: context,
        termSheetDocumentId: termSheetDocument.termSheetDocumentId,
        uniquekey: termSheetDocument.uniquekey,
        termSheetId: termSheetDetails.termSheetId,
        termSheetDetailsId: termSheetDetails.termSheetDetailsId,
        projectId: termSheetDetails.projectId,
        remark: _remarkC.text.trim(),
        file: files,
        documentName: selectedSupport.value?["DisplayName"],
        isSubmittedOriginalDocument: submittedOriginalNotifier.value,
        isCollectedOriginalDocument: collectedOriginalNotifier.value,
        collectedOriginalDate: collectedOriginalDateNotifier.value,
      );
    } else {
      _documentsCubit.addTermSheetDocument(
        context: context,
        termSheetId: termSheetDetails.termSheetId,
        termSheetDetailsId: termSheetDetails.termSheetDetailsId,
        projectId: termSheetDetails.projectId,
        remark: _remarkC.text.trim(),
        file: files,
        documentName: selectedSupport.value?["DisplayName"],
        isSubmittedOriginalDocument: submittedOriginalNotifier.value,
        isCollectedOriginalDocument: collectedOriginalNotifier.value,
      );
    }
  }

  @override
  void dispose() {
    _remarkC.dispose();
    submittedOriginalNotifier.dispose();
    collectedOriginalNotifier.dispose();
    collectedOriginalDateNotifier.dispose();
    super.dispose();
  }

  bool get isClosed =>
      widget.termSheetModel?.approvalStatus.trim().toLowerCase() == "closed";

  bool get isClosedEdit => widget.isEdit && isClosed;

  bool get canEditCollectedOriginal =>
      isClosedEdit && submittedOriginalNotifier.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Term Sheet Document",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit
                  ? "Update Term Sheet Document"
                  : "Add Term Sheet Document",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: selectedSupport,
                      builder: (context, selectedValue, child) {
                        return CustomDropDownWidget(
                          title: "Document Name",
                          hintText: "Select Document Name",
                          dataList: termSheetDocumentList,
                          initialValue: selectedValue,
                          isDisabled: widget.isEdit && isClosed,
                          onSelected: (value) {
                            selectedSupport.value = value;
                          },
                          onValueClear: () {
                            selectedSupport.value = null;
                          },
                          isRequired: true,
                          validator: (value) {
                            if (value == null) {
                              return 'Document Name is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomMultiFilePicker(
                      readOnly: widget.isEdit && isClosed,
                      title: "File",
                      isRequired: true,
                      filePickType: FilePickType.both,
                      initialFileList: files.fileNameList,

                      onFilePickedCallback: (bytesList, fileNameList) {
                        files.fileNameList = fileNameList;
                        files.fileBytesList = bytesList;
                      },

                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        files.fileNameList = fileNameList;
                        files.fileBytesList = fileBytesList;
                        files.deletedFileList = deletedFile;
                      },

                      validator: (fileList) {
                        if (fileList == null || fileList.isEmpty) {
                          return "File is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      readOnly: widget.isEdit && isClosed,
                      title: "Remark",
                      hint: "Enter Remark",
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 10,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: submittedOriginalNotifier,
                      builder: (context, isSubmittedOriginal, child) {
                        return CustomCheckBox(
                          title: "Submitted Original?",
                          isDisabled: isClosed,
                          isSelected: isSubmittedOriginal,
                          onChanged: (value) {
                            if (!isClosed) {
                              submittedOriginalNotifier.value = value;
                            }
                          },
                        );
                      },
                    ),

                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: collectedOriginalNotifier,
                      builder: (context, isCollectedOriginal, child) {
                        final bool canEditCollectedOriginal =
                            isClosed && widget.isEdit;

                        return CustomCheckBox(
                          title: "Collected Original?",

                          isDisabled: !canEditCollectedOriginal,

                          isSelected: isCollectedOriginal,

                          onChanged: (value) {
                            if (canEditCollectedOriginal) {
                              collectedOriginalNotifier.value = value;

                              if (!value) {
                                collectedOriginalDateNotifier.value = null;
                              }
                            }
                          },
                        );
                      },
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder<bool>(
                      valueListenable: collectedOriginalNotifier,
                      builder: (context, isCollectedOriginal, child) {
                        final bool shouldShowDatePicker =
                            isClosed && widget.isEdit && isCollectedOriginal;

                        if (!shouldShowDatePicker) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            verticalSpacing(),
                            ValueListenableBuilder<DateTime?>(
                              valueListenable: collectedOriginalDateNotifier,
                              builder: (context, selectedDate, child) {
                                return CustomDatePicker(
                                  title: "Collected Original Document Date",
                                  hint: "DD-MM-YYYY",
                                  initialDate: selectedDate,
                                  setValue: (value) {
                                    collectedOriginalDateNotifier.value = value;
                                  },
                                  isRequired: true,
                                  validator: (value) {
                                    if (value == null) {
                                      return "Collected Original Document Date is required";
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: widget.isEdit ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
