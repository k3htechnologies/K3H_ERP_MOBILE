import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/local_term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet.model.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
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
  final LocalTermSheetModel? termSheetModel;
  final TermSheetModel? termSheet;
  final TermSheetDetailsView? termSheetDetailsView;
  const AddLocalTermSheet({
    super.key,
    this.termSheetModel,
    this.termSheet,
    this.termSheetDetailsView,
  });

  @override
  State<AddLocalTermSheet> createState() => _AddLocalTermSheetState();
}

class _AddLocalTermSheetState extends State<AddLocalTermSheet> {
  // EDIT MODE
  bool get _isEditMode => widget.termSheetModel != null;
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
  final ValueNotifier<DateTime?> _loanFromDateNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _loanToDateNotifier = ValueNotifier<DateTime?>(
    null,
  );

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
    if (_isEditMode) {
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
      loanStartDate: _loanFromDateNotifier.value,
      loanEndDate: _loanToDateNotifier.value,
      loanTenureInMonth: _loanTenureC.text.trim(),
      rateOfInterestInPercentage: _rateOfInterestC.text.trim(),
      remark: _remarkC.text.trim(),
      termSheetDate: termSheetDate,
      sanctionDate: sanctionDate,
      minimumSellingPrice: _minimumSellingPriceC.text.trim(),
      legalAndDocumentationFees: _legalAndDocumentationFeesC.text.trim(),
      monotoriumPeriodInMonth: _monotoriumPeriodC.text.trim(),
      emiAmount: _emiAmountC.text.trim(),
      otherImportantTermsIfAny: _termsIfAnyC.text.trim(),
      type: selectedType.value?["DisplayName"].toString() ?? "",
      facilityAmount: double.tryParse(_facilityAmountC.text.trim()) ?? 0.0,
      processingFeesInPercentage: _processingFeesC.text.trim(),
      termSheetURL: [],
      termSheetFiles: _termSheetDocument,
      termSheetDetailsId: 0,
      uniquekey: '',
    );

    goRouter.pop(termSheet);
  }

  void _prefillTermSheet(LocalTermSheetModel termSheet) {
    _loanTakenByC.text = termSheet.loanTakenBy;

    _nameOfInstitutionBankNBFC.text = termSheet.nameOfInstitutionBankNBFC;

    _facilityAmountC.text = termSheet.facilityAmount.toString();

    _rateOfInterestC.text = termSheet.rateOfInterestInPercentage;

    _processingFeesC.text = termSheet.processingFeesInPercentage;

    _legalAndDocumentationFeesC.text = termSheet.legalAndDocumentationFees;

    _monotoriumPeriodC.text = termSheet.monotoriumPeriodInMonth;

    _loanTenureC.text = termSheet.loanTenureInMonth;

    _minimumSellingPriceC.text = termSheet.minimumSellingPrice;

    _emiAmountC.text = termSheet.emiAmount;

    _termsIfAnyC.text = termSheet.otherImportantTermsIfAny;

    _remarkC.text = termSheet.remark;

    termSheetDate = termSheet.termSheetDate;

    sanctionDate = termSheet.sanctionDate;

    _loanFromDateNotifier.value = termSheet.loanStartDate;

    _loanToDateNotifier.value = termSheet.loanEndDate;

    selectedType.value = typeList.firstWhere(
      (e) => e["DisplayName"] == termSheet.type,
      orElse: () => typeList.first,
    );

    _termSheetDocument.fileNameList = List<String>.from(
      termSheet.termSheetFiles.fileNameList,
    );

    _termSheetDocument.fileBytesList = List.from(
      termSheet.termSheetFiles.fileBytesList,
    );

    _termSheetDocument.deletedFileList =
        termSheet.termSheetFiles.deletedFileList;
  }

  String? validateSanctionDate() {
    final loanStartDate = _loanFromDateNotifier.value;
    final loanEndDate = _loanToDateNotifier.value;
    final isLoanDateEntered = loanStartDate != null || loanEndDate != null;
    if (isLoanDateEntered && sanctionDate == null) {
      return "Sanction Date is required when Loan Start Date is entered";
    }
    if (sanctionDate == null) {
      return null;
    }
    if (termSheetDate != null && sanctionDate!.isBefore(termSheetDate!)) {
      return "Sanction Date must be greater than or equal to Term Sheet Date";
    }

    return null;
  }

  bool get isBothApproved {
    final termSheetStatus =
        widget.termSheet?.approvalStatus.trim().toLowerCase();

    final detailsStatus =
        widget.termSheetDetailsView?.approvalStatus.trim().toLowerCase();

    return termSheetStatus == "approved" && detailsStatus == "approved";
  }

  bool get shouldLockApprovedFields {
    return _isEditMode && isBothApproved;
  }

  bool get lockFields => shouldLockApprovedFields;

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
              _isEditMode ? "Update Term Sheet" : "Add Term Sheet",
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
                      readOnly: lockFields,
                    ),
                    CustomTextField(
                      title: "Name Of Institution / Bank / NBFC",
                      hint: "Enter Name Of Institution / Bank / NBFC",
                      textController: _nameOfInstitutionBankNBFC,
                      readOnly: lockFields,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name Of Institution / Bank / NBFC is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedType,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Type",
                          hintText: "Select Type",
                          isDisabled: lockFields,
                          initialValue: value,
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
                      readOnly: lockFields,
                      validator: (value) {
                        if (value == null) {
                          return 'Term Sheet Date is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Faciltiy Amount",
                      hint: "Enter Facilty Amount",
                      textController: _facilityAmountC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      readOnly: lockFields,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Faciltiy Amount is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Rate Of Interest",
                      hint: "Enter Rate Of Interest",
                      textController: _rateOfInterestC,
                      prefixType: CustomTextFieldPrefix.percentage,
                      keyboardType: TextInputType.number,
                      readOnly: lockFields,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(2),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Rate Of Interest is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Processing Fees",
                      hint: "Enter Processing Fees",
                      readOnly: lockFields,
                      prefixType: CustomTextFieldPrefix.percentage,
                      textController: _processingFeesC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(2),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Processing Fees is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Legal & Documentation Fees",
                      hint: "Enter Legal & Documentation Fees",
                      textController: _legalAndDocumentationFeesC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      readOnly: lockFields,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Legal & Documentation Fees is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Monotorium Period (In Month)",
                      hint: "Enter Monotorium Period",
                      textController: _monotoriumPeriodC,
                      readOnly: lockFields,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(4),
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Loan Tenure (In Month)",
                      hint: "Enter Loan Tenure",
                      textController: _loanTenureC,
                      readOnly: lockFields,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(4),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Loan Tenure (In Month) is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Minimum Selling Price",
                      hint: "Enter Minimum Selling Price",
                      textController: _minimumSellingPriceC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      readOnly: lockFields,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                    ),
                    CustomMultiFilePicker(
                      title: "Term Sheet",
                      isRequired: true,
                      readOnly: !lockFields,
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
                      setValue: (value) {
                        sanctionDate = value;
                        // REVALIDATE THE FORM
                        _formKey.currentState?.validate();
                      },
                      validator: (value) {
                        return validateSanctionDate();
                      },
                    ),
                    CustomTextField(
                      title: "EMI Amount",
                      hint: "Enter EMI Amount",
                      textController: _emiAmountC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                    ),
                    CustomFromToDatePicker(
                      fromDateTitle: "Loan Start Date",
                      toDateTitle: "Loan End Date",
                      removeBottomMargin: false,
                      initialFromDate: _loanFromDateNotifier.value,
                      initialToDate: _loanToDateNotifier.value,
                      onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                        _loanFromDateNotifier.value = fromDate;
                        _loanToDateNotifier.value = toDate;
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
            text: _isEditMode ? "Update" : "Add",
            onPressed: _sumbit,
          ),
        ),
      ),
    );
  }
}
