import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTemporaryAlternateAccommodationPaymentScreen extends StatefulWidget {
  final TemporaryAlternativeAccommodationModel rentModel;
  final double totalAmount;
  final double? paidAmount;
  final String previousRoute;

  final PaymentLedgerModel? paymentLedger;
  final int? paymentLedgerIndex;
  const AddTemporaryAlternateAccommodationPaymentScreen({
    super.key,
    required this.rentModel,
    required this.totalAmount,
    required this.previousRoute,
    this.paidAmount,
    this.paymentLedger,
    this.paymentLedgerIndex,
  });
  @override
  State<AddTemporaryAlternateAccommodationPaymentScreen> createState() =>
      _AddTemporaryAlternateAccommodationPaymentScreenState();
}

class _AddTemporaryAlternateAccommodationPaymentScreenState
    extends State<AddTemporaryAlternateAccommodationPaymentScreen> {
  late TemporaryAlternateAccommodationCubit
  _temporaryAlternateAccommodationCubit;
  bool get _isEditMode => widget.paymentLedger != null;
  final GlobalKey<FormState> _formLedger = GlobalKey<FormState>();
  late TextEditingController _payAmountC,
      _transactionNumC,
      _accountNumberC,
      _projectAccountNumberC,
      _ifscCodeC,
      _projectIfscCodeC,
      _branchC,
      _projectAccountType,
      _accountHolderNameC,
      _projectNatureOfAccountC;
  DateTime? selectedDate;
  final ValueNotifier<Map<String, dynamic>?> _selectedPaymentMode =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedAmountType =
      ValueNotifier(null);
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedProjectWiseBankNotifier = ValueNotifier([]);

  MultiFilePickerModel transactionChequeDemandDraftUrl = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel paymentReceiptUrl = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
    _initializeTextControllers();
    if (_isEditMode) {
      _populateFormFields(widget.paymentLedger!);
    }
  }

  void _populateFormFields(PaymentLedgerModel p) async {
    selectedDate = p.transactionChequeDemandDraftDate;
    _payAmountC.text = p.payAmount.toStringAsFixed(2);
    _transactionNumC.text = p.transactionChequeDemandDraftNumber;
    _accountNumberC.text = p.accountNumber;
    _ifscCodeC.text = p.ifscCode;
    _branchC.text = '';
    _projectAccountType.text = '';
    _accountHolderNameC.text = p.projectBankAccountHolderName;
    _selectedPaymentMode.value = paymentModeList.firstWhere(
      (e) => (e['DisplayName'] as String?) == p.paymentMode,
      orElse: () => paymentModeList.first,
    );
    _selectedAmountType.value = tenantAmountTypeList.firstWhere(
      (e) => (e['DisplayName'] as String?) == p.amountType,
      orElse: () => tenantAmountTypeList.first,
    );

    _selectedBankNotifier.value = [
      {'zAttributesId': p.bankListMasterId, 'DisplayName': p.bankName},
    ];
    transactionChequeDemandDraftUrl.fileNameList =
        p.transactionChequeDemandDraftUrl.isNotEmpty
            ? p.transactionChequeDemandDraftUrl.split(',')
            : [];

    paymentReceiptUrl.fileNameList =
        p.paymentReceiptUrl.isNotEmpty ? p.paymentReceiptUrl.split(',') : [];
    _selectedProjectWiseBankNotifier.value =
        await _temporaryAlternateAccommodationCubit.getProjectWithBankById(
          projectWithBankDetailsId: p.projectBankListMasterId,
        );

    _accountHolderNameC.text =
        (_selectedProjectWiseBankNotifier.value.first["AccountHolderName"] ??
                "")
            .toString();
    _projectAccountNumberC.text =
        (_selectedProjectWiseBankNotifier.value.first["AccountNumber"] ?? "")
            .toString();
    _projectIfscCodeC.text =
        (_selectedProjectWiseBankNotifier.value.first["IFSCCode"] ?? "")
            .toString();
    _branchC.text =
        (_selectedProjectWiseBankNotifier.value.first["Branch"] ?? "")
            .toString();
    _projectAccountType.text =
        (_selectedProjectWiseBankNotifier.value.first["AcType"] ?? "")
            .toString();
    _projectNatureOfAccountC.text =
        (_selectedProjectWiseBankNotifier.value.first["NatureOfAccount"] ?? "")
            .toString();
  }

  @override
  void dispose() {
    super.dispose();
    _transactionNumC.dispose();
    _payAmountC.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _branchC.dispose();
    _projectAccountType.dispose();
    _accountHolderNameC.dispose();
    _projectAccountNumberC.dispose();
    _projectIfscCodeC.dispose();
    _projectNatureOfAccountC.dispose();
    _selectedPaymentMode.dispose();
    _selectedAmountType.dispose();
    _selectedBankNotifier.dispose();
    _selectedProjectWiseBankNotifier.dispose();
  }

  void _initializeTextControllers() {
    _transactionNumC = TextEditingController();
    _payAmountC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _branchC = TextEditingController();
    _projectAccountType = TextEditingController();
    _accountHolderNameC = TextEditingController();
    _projectAccountNumberC = TextEditingController();
    _projectIfscCodeC = TextEditingController();
    _projectNatureOfAccountC = TextEditingController();
  }

  void _submitForm() {
    if (!_formLedger.currentState!.validate()) return;
    final rentModel = widget.rentModel;

    if (_isEditMode && widget.paymentLedger != null) {
      _temporaryAlternateAccommodationCubit.updatePayTrackRentLedger(
        context: context,
        payTrackRentId: widget.paymentLedger!.payTrackRentId,
        uniqueKey: widget.paymentLedger!.uniquekey,
        tenantId: rentModel.tenantId,
        tenantApplicantId: rentModel.tenantApplicantId,
        buildingId: rentModel.buildingId,
        projectId: rentModel.projectId,
        projectBankListMasterId:
            _selectedProjectWiseBankNotifier.value.first["zAttributesId"]
                as int,
        accountHolderName: _accountHolderNameC.text,
        bankListMasterId:
            _selectedBankNotifier.value.first["zAttributesId"] as int,
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscCodeC.text,
        paymentMode: _selectedPaymentMode.value?["DisplayName"] as String,
        amountType: _selectedAmountType.value?["DisplayName"] as String,
        payAmount: _payAmountC.text,
        transactionChequeDemandDraftNumber: _transactionNumC.text,
        transactionChequeDemandDraftDate: selectedDate!,
        transactionChequeDemandDraftURL: transactionChequeDemandDraftUrl,
        paymentReceiptURL: paymentReceiptUrl,
        index: widget.paymentLedgerIndex ?? 0,
      );
    } else {
      _temporaryAlternateAccommodationCubit.addPayTrackRentLedger(
        context: context,
        payTrackRentId: 0,
        tenantId: rentModel.tenantId,
        tenantApplicantId: rentModel.tenantApplicantId,
        buildingId: rentModel.buildingId,
        projectId: rentModel.projectId,
        projectBankListMasterId:
            _selectedProjectWiseBankNotifier.value.first["zAttributesId"]
                as int,
        accountHolderName: _accountHolderNameC.text,
        bankListMasterId:
            _selectedBankNotifier.value.first["zAttributesId"] as int,
        accountNumber: _accountNumberC.text,
        ifscCode: _ifscCodeC.text,
        paymentMode: _selectedPaymentMode.value?["DisplayName"] as String,
        amountType: _selectedAmountType.value?["DisplayName"] as String,
        payAmount: _payAmountC.text,
        transactionChequeDemandDraftNumber: _transactionNumC.text,
        transactionChequeDemandDraftDate: selectedDate!,
        transactionChequeDemandDraftURL: transactionChequeDemandDraftUrl,
        paymentReceiptURL: paymentReceiptUrl,
        makeChargeTypeApiPull:
            widget.previousRoute == AppRoutes.rent ? true : false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Temporary Alternate\nAccommodation",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          spacing: 12,
          children: [
            infoCard([
              {"title": "Flat Number", "value": widget.rentModel.flatNumber},
              {
                "title": "Applicant Name",
                "value": widget.rentModel.applicantName,
              },
              {"title": "Tenure", "value": widget.rentModel.tenure},
              {
                "title": "Charge Type",
                "value": _temporaryAlternateAccommodationCubit.state.chargeType,
              },
              {
                "title": "Carpet Area (SqFt)",
                "value":
                    '${widget.rentModel.flatCarpetAreaSqFt.addCommas()} SqFt',
              },
              {"title": "Unit Type", "value": widget.rentModel.flatType},
              {
                "title": "Total Amount",
                "value": widget.totalAmount.toIndianCurrency(),
              },
              {
                "title": "Paid Total Amount",
                "value":
                    _isEditMode
                        ? _temporaryAlternateAccommodationCubit
                            .paidAmountForSummary
                            ?.toIndianCurrency()
                        : widget.paidAmount?.toIndianCurrency(),
              },
            ]),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formLedger,
                  child: Column(
                    spacing: 16,
                    children: [
                      _card('Payment Details (Payee)', [
                        CustomTextField(
                          title: "Account Holder Name",
                          hint: "Enter Account Holder Name",
                          textController: _accountHolderNameC,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Holder Name is required.";
                            }
                            return null;
                          },
                        ),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: _selectedBankNotifier,
                          builder: (context, selectedBankList, _) {
                            return CustomMultipleSelectPopup(
                              key: ValueKey(
                                selectedBankList.isEmpty
                                    ? 'bank_empty'
                                    : selectedBankList.first['zAttributesId'],
                              ),
                              title: "Bank",
                              hintText: "Select Bank",
                              isRequired: true,
                              isMultiSelect: false,
                              initialValue: selectedBankList,
                              dataList: const [],
                              onSelected: (value) {
                                _selectedBankNotifier.value = value;
                              },
                              dataFetchCallBack:
                                  _temporaryAlternateAccommodationCubit
                                      .getBankList,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bank is required';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          title: "Account Number",
                          hint: "Enter Account Number",
                          textController: _accountNumberC,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digit(15),
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Number is required.";
                            }
                            return null;
                          },
                        ),

                        CustomTextField(
                          title: "IFSC Code",
                          hint: "Enter IFSC Code",
                          textController: _ifscCodeC,
                          inputFormatterList:
                              InputValidator.ifscInputFormatters(),
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "IFSC Code is required.";
                            }
                            if (!InputValidator.isValidIFSC(value)) {
                              return 'Enter a valid IFSC Code';
                            }
                            return null;
                          },
                        ),
                        CustomDropDownWidget(
                          title: "Payment Mode",
                          hintText: "Select Payment Mode",
                          isRequired: true,
                          dataList: paymentModeList,
                          initialValue: _selectedPaymentMode.value,
                          onSelected: (value) {
                            _selectedPaymentMode.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Payment Mode for is required';
                            }
                            return null;
                          },
                          onValueClear: () => _selectedPaymentMode.value = null,
                        ),
                        CustomDropDownWidget(
                          title: "Amount Type",
                          hintText: "Select Amount Type",
                          isRequired: true,
                          dataList: tenantAmountTypeList,
                          initialValue: _selectedAmountType.value,
                          onSelected: (value) {
                            _selectedAmountType.value = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Amount Type is required';
                            }
                            return null;
                          },
                          onValueClear: () => _selectedAmountType.value = null,
                        ),
                        CustomTextField(
                          title: "Amount (₹)",
                          hint: "Enter Amount",
                          textController: _payAmountC,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          inputFormatterList:
                              inputFormatterListForDecimalValuesFixedToTwo(9),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Amount is required.";
                            }

                            if (double.parse(value) <= 0) {
                              return "Amount is required and must be greater than 0.";
                            }
                            final total = widget.totalAmount;
                            final alreadyPaid = widget.paidAmount ?? 0;
                            final originalPayAmount =
                                _temporaryAlternateAccommodationCubit
                                    .paidAmountForSummary ??
                                0;
                            final pay = double.parse(_payAmountC.text);
                            final effectivePaid =
                                _isEditMode
                                    ? (alreadyPaid - originalPayAmount + pay)
                                    : (alreadyPaid + pay);

                            final remaining = total - effectivePaid;

                            if (remaining < 0) {
                              return "Amount exceeds remaining balance (₹${(total - alreadyPaid).addCommas()})";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Transaction/Cheque/DD Number",
                          hint: "Enter Transaction/Cheque/DD Number",
                          textController: _transactionNumC,
                          inputFormatterList: InputValidator.textDigit(50),
                        ),
                        CustomDatePicker(
                          isRequired: true,
                          title: "Transaction / Cheque / Demand Draft Date",
                          initialDate: selectedDate,
                          setValue: (value) {
                            selectedDate = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Transaction / Cheque / Demand Draft Date is required.";
                            }
                            return null;
                          },
                        ),
                        CustomMultiFilePicker(
                          title: "Transaction / Cheque / Demand Draft",
                          initialFileList:
                              transactionChequeDemandDraftUrl.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            transactionChequeDemandDraftUrl.fileNameList =
                                fileNameList;
                            transactionChequeDemandDraftUrl.fileBytesList =
                                bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            transactionChequeDemandDraftUrl.fileNameList =
                                fileNameList;
                            transactionChequeDemandDraftUrl.fileBytesList =
                                fileBytesList;
                            transactionChequeDemandDraftUrl.deletedFileList =
                                deletedFile;
                          },
                        ),
                        CustomMultiFilePicker(
                          title: "Payment Receipt",
                          initialFileList: paymentReceiptUrl.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            paymentReceiptUrl.fileNameList = fileNameList;
                            paymentReceiptUrl.fileBytesList = bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            paymentReceiptUrl.fileNameList = fileNameList;
                            paymentReceiptUrl.fileBytesList = fileBytesList;
                            paymentReceiptUrl.deletedFileList = deletedFile;
                          },
                        ),
                      ]),
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedProjectWiseBankNotifier,
                        builder: (context, selectedProjectWiseList, _) {
                          return ValueListenableBuilder(
                            valueListenable: _selectedProjectWiseBankNotifier,
                            builder: (context, value, child) {
                              return _card('Developer Bank Details', [
                                CustomMultipleSelectPopup(
                                  key: ValueKey(
                                    selectedProjectWiseList.isEmpty
                                        ? 'projectwise_empty'
                                        : selectedProjectWiseList
                                            .first['zAttributesId'],
                                  ),
                                  title: "Project Wise Bank",
                                  isRequired: true,
                                  isMultiSelect: false,
                                  initialValue: selectedProjectWiseList,
                                  dataList: const [],
                                  onSelected: (value) {
                                    _selectedProjectWiseBankNotifier.value =
                                        value;
                                    if (value.isNotEmpty) {
                                      final item = value.first;

                                      _projectAccountNumberC.text =
                                          (item["AccountNumber"] ?? "")
                                              .toString();
                                      _projectIfscCodeC.text =
                                          (item["IFSCCode"] ?? "").toString();
                                      _branchC.text =
                                          (item["Branch"] ?? "").toString();
                                      _projectAccountType.text =
                                          (item["AcType"] ?? "").toString();
                                      _projectNatureOfAccountC.text =
                                          (item["NatureOfAccount"] ?? "")
                                              .toString();
                                    }
                                  },
                                  dataFetchCallBack:
                                      _temporaryAlternateAccommodationCubit
                                          .getProjectWithBankDropdown,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Project Wise Bank is required';
                                    }
                                    return null;
                                  },
                                ),
                                if (selectedProjectWiseList.isNotEmpty) ...[
                                  CustomTextField(
                                    title: "Account Number",
                                    textController: _projectAccountNumberC,
                                    readOnly: true,
                                    isRequired: true,
                                  ),
                                  CustomTextField(
                                    title: "IFSC Code",
                                    textController: _projectIfscCodeC,
                                    readOnly: true,
                                    isRequired: true,
                                  ),
                                  CustomTextField(
                                    title: "Branch",
                                    textController: _branchC,
                                    readOnly: true,
                                    isRequired: true,
                                  ),
                                  CustomTextField(
                                    title: "Account Type",
                                    textController: _projectAccountType,
                                    readOnly: true,
                                    isRequired: true,
                                  ),
                                  CustomTextField(
                                    title: "Nature Of Account",
                                    textController: _projectNatureOfAccountC,
                                    readOnly: true,
                                    isRequired: true,
                                  ),
                                ],
                              ]);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          ...children,
        ],
      ),
    );
  }
}
