import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/local_term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLocalTermSheet extends StatefulWidget {
  final bool isEdit;
  final TermSheetModel? termSheetModel;
  const AddLocalTermSheet({
    super.key,
    this.termSheetModel,
    required this.isEdit,
  });

  @override
  State<AddLocalTermSheet> createState() => _AddLocalTermSheetState();
}

class _AddLocalTermSheetState extends State<AddLocalTermSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _loanTakenByC,
      _nameOfInstitutionBankNBFC,
      _facilityAmountC,
      _rateOfInterestC,
      _processingFeesC,
      _legalAndDocumentationFeesC,
      _monotoriumPeriodC,
      _loanTenureC,
      _minimumSellingPriceC,
      _emiAmountC,
      _termsIfAnyC,
      _remarkC;

  // NOTIFIERS

  ValueNotifier<Map<String, dynamic>?> selectedType = ValueNotifier(null);
  final ValueNotifier<DateTime?> _sanctionFromDateNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _sanctionToDateNotifier =
      ValueNotifier<DateTime?>(null);

  // DATE PICKERS
  DateTime? termSheetDate, sanctionDate;

  // FILE PICKER
  final MultiFilePickerModel _termSheetDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    initialiseControllers();
    if (widget.termSheetModel != null) {
      _prefillTermSheet(widget.termSheetModel!);
    }
  }

  void initialiseControllers() {
    _loanTakenByC = TextEditingController();
    _nameOfInstitutionBankNBFC = TextEditingController();
    _facilityAmountC = TextEditingController();
    _rateOfInterestC = TextEditingController();
    _processingFeesC = TextEditingController();
    _legalAndDocumentationFeesC = TextEditingController();
    _monotoriumPeriodC = TextEditingController();
    _loanTenureC = TextEditingController();
    _minimumSellingPriceC = TextEditingController();
    _emiAmountC = TextEditingController();
    _termsIfAnyC = TextEditingController();
    _remarkC = TextEditingController();
  }

  @override
  void dispose() {
    _loanTakenByC.dispose();
    _nameOfInstitutionBankNBFC.dispose();
    selectedType.dispose();
    _facilityAmountC.dispose();
    _rateOfInterestC.dispose();
    _processingFeesC.dispose();
    _legalAndDocumentationFeesC.dispose();
    _monotoriumPeriodC.dispose();
    _loanTenureC.dispose();
    _minimumSellingPriceC.dispose();
    _emiAmountC.dispose();
    _termsIfAnyC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  void _sumbit() {
    if (!_formKey.currentState!.validate()) return;

    final termSheet = LocalTermSheetModel(
      nameOfInstitutionBankNBFC: _nameOfInstitutionBankNBFC.text.trim(),
      loanTakenBy: _loanTakenByC.text.trim(),
      loanStartDate: _sanctionFromDateNotifier.value?.toIso8601String() ?? "",
      loanEndDate: _sanctionToDateNotifier.value?.toIso8601String() ?? "",
      loanTenureInMonth: _loanTenureC.text.trim(),
      rateOfInterestInPercentage: _rateOfInterestC.text.trim(),
      remark: _remarkC.text.trim(),
      termSheetDate: termSheetDate?.toIso8601String() ?? "",
      sanctionDate: sanctionDate?.toIso8601String() ?? "",
      minimumSellingPrice: _minimumSellingPriceC.text.trim(),
      legalAndDocumentationFees: _legalAndDocumentationFeesC.text.trim(),
      monotoriumPeriodInMonth: _monotoriumPeriodC.text.trim(),
      emiAmount: _emiAmountC.text.trim(),
      otherImportantTermsIfAny: _termsIfAnyC.text.trim(),
      type: selectedType.value?["DisplayName"].toString() ?? "",
      facilityAmount: _facilityAmountC.text.trim(),
      processingFeesInPercentage: _processingFeesC.text.trim(),
      termSheetURL: [],
      termSheetFiles: _termSheetDocument,
    );

    goRouter.pop(termSheet);
  }

  void _prefillTermSheet(TermSheetModel termSheetModel) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Term Sheet",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit ? "Update Term Sheet" : "Add Term Sheet",
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
                    CustomTextField(
                      title: "Loan Taken By",
                      hint: "Enter Loan Taken By",
                      textController: _loanTakenByC,
                    ),
                    CustomTextField(
                      title: "Name Of Institution / Bank / NBFC",
                      hint: "Enter Name Of Institution / Bank / NBFC",
                      textController: _nameOfInstitutionBankNBFC,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name Of Institution / Bank / NBFC is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Type",
                          hintText: "Select Type",
                          dataList: typeList,
                          onSelected: (value) {
                            selectedType.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Type is required';
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedType.value = null;
                          },
                        );
                      },
                    ),
                    CustomDatePicker(
                      title: 'Term Sheet Date',
                      isRequired: true,
                      initialDate: termSheetDate,
                      setValue: (value) => termSheetDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Term Sheet Date is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Faciltiy Amount (₹)",
                      hint: "Enter Facilty Amount (₹)",
                      textController: _facilityAmountC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Faciltiy Amount is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Rate Of Interest (%)",
                      hint: "Enter Rate Of Interest",
                      textController: _rateOfInterestC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Rate Of Interest (%) is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Processing Fees (%)",
                      hint: "Enter Processing Fees",
                      textController: _processingFeesC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Processing Fees (%) is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Legal & Documentation Fees (₹)",
                      hint: "Enter Legal & Documentation Fees",
                      textController: _legalAndDocumentationFeesC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Legal & Documentation Fees (₹) is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Monotorium Period (In Month)",
                      hint: "Enter Monotorium Period",
                      textController: _monotoriumPeriodC,
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Loan Tenure (In Month)",
                      hint: "Enter Loan Tenure",
                      textController: _loanTenureC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Loan Tenure (In Month) is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Minimum Selling Price (₹)",
                      hint: "Enter Minimum Selling Price",
                      textController: _minimumSellingPriceC,
                    ),
                    CustomMultiFilePicker(
                      title: "Term Sheet",
                      isRequired: true,
                      filePickType: FilePickType.document,
                      initialFileList: _termSheetDocument.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        _termSheetDocument.fileNameList = fileNameList;
                        _termSheetDocument.fileBytesList = bytesList;
                      },

                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        _termSheetDocument.fileNameList = fileNameList;
                        _termSheetDocument.fileBytesList = fileBytesList;
                        _termSheetDocument.deletedFileList = deletedFile;
                      },
                      validator: (fileList) {
                        if (fileList == null || fileList.isEmpty) {
                          return "Term Sheet is required";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: 'Sanction Date',
                      initialDate: sanctionDate,
                      setValue: (value) => sanctionDate = value,
                    ),
                    CustomTextField(
                      title: "EMI Amount (₹)",
                      hint: "Enter EMI Amount",
                      textController: _emiAmountC,
                    ),
                    CustomFromToDatePicker(
                      fromDateTitle: "Loan Start Date",
                      toDateTitle: "Loan End Date",
                      removeBottomMargin: false,
                      initialFromDate: _sanctionFromDateNotifier.value,
                      initialToDate: _sanctionToDateNotifier.value,
                      onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                        _sanctionFromDateNotifier.value = fromDate;
                        _sanctionToDateNotifier.value = toDate;
                      },
                    ),
                    CustomTextField(
                      title: "Other Important Terms If Any",
                      hint: "Enter Terms If Any",
                      textController: _termsIfAnyC,
                      minLines: 3,
                      maxLines: 10,
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 10,
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
            onPressed: _sumbit,
          ),
        ),
      ),
    );
  }
}
