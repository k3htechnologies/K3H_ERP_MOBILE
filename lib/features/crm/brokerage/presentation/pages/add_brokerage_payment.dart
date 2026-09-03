import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/model/project_with_bank_details.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../cubit/brokerage_cubit.dart';

class AddBrokeragePayment extends StatefulWidget {
  final BrokerageInvoiceModel invoiceModel;
  final double brokerageAmount;
  const AddBrokeragePayment({
    super.key,
    required this.invoiceModel,
    required this.brokerageAmount,
  });

  @override
  State<AddBrokeragePayment> createState() => _AddBrokeragePaymentState();
}

class _AddBrokeragePaymentState extends State<AddBrokeragePayment> {
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  late BrokerageCubit _brokerageCubit;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _pendingAmountC,
      _amountC,
      _tdsAmountC,
      _transactionNumberC,
      _projectAccountNumberC,
      _projectIfscCodeC,
      _projectBranchC,
      _projectAccountType,
      _projectNatureOfAccountC;

  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentTypeNotifier;

  MultiFilePickerModel selectedTransactionOrChequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  DateTime? selectedTransactionDate;

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _brokerageCubit = context.read<BrokerageCubit>();
    _selectedPaymentModeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentTypeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _amountC.dispose();
    _tdsAmountC.dispose();
    _transactionNumberC.dispose();
    _selectedBankNotifier.dispose();
    _selectedPaymentModeNotifier.dispose();
    _selectedPaymentTypeNotifier.dispose();
    _projectAccountNumberC.dispose();
    _projectIfscCodeC.dispose();
    _projectBranchC.dispose();
    _projectAccountType.dispose();
    _projectNatureOfAccountC.dispose();
  }

  void _initializeTextEditingControllers() {
    _pendingAmountC = TextEditingController();
    _amountC = TextEditingController();
    _tdsAmountC = TextEditingController();
    _transactionNumberC = TextEditingController();
    _projectAccountNumberC = TextEditingController();
    _projectIfscCodeC = TextEditingController();
    _projectBranchC = TextEditingController();
    _projectAccountType = TextEditingController();
    _projectNatureOfAccountC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchProjectBanksForDropdown(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: widget.invoiceModel.projectId,
      queryParams: value != null && value.isNotEmpty ? {"BankName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<ProjectWithBankDetailsModel>;

        return {
          "itemList":
              banks.map((bank) {
                return {
                  "zAttributesId": bank.projectWithBankDetailsId,
                  "DisplayName": bank.bankName,
                  "AccountHolderName": bank.beneficiaryAccountHolderName,
                  "AccountNumber": bank.accountNumber,
                  "Branch": bank.branch,
                  "IFSCCode": bank.ifscCode,
                  "AcType": bank.acType,
                  "NatureOfAccount": bank.natureOfAccount,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    _brokerageCubit.addBrokeragePayment(
      context: context,
      bookingId: widget.invoiceModel.bookingId.toString(),
      projectId: widget.invoiceModel.projectId.toString(),
      brokerageInvoiceId: widget.invoiceModel.brokerageInvoiceId.toString(),
      paymentMode: _selectedPaymentModeNotifier.value.first['DisplayName'],
      bankListMasterId:
          _selectedBankNotifier.value.first['zAttributesId'].toString(),
      paymentType: _selectedPaymentTypeNotifier.value.first['DisplayName'],
      amountPaid: _amountC.text,
      tDSAmount: _tdsAmountC.text,
      transactionNumber: _transactionNumberC.text,
      transactionReceiptFiles: selectedTransactionOrChequeFile,
      transactionChequeDemandDraftDate: selectedTransactionDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Brokerage",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<BrokerageCubit, BrokerageState>(
              builder: (context, state) {
                final invoiceAmount = state.brokerageInvoiceList.fold(
                  0.0,
                  (a, b) => a + b.invoiceAmount,
                );
                final paymentPaidAmount = state.brokerageInvoiceList.fold(
                  0.0,
                  (a, b) => a + b.paymentAmount,
                );
                final pendingAmount =
                    (widget.brokerageAmount -
                        state.brokerageInvoiceList.fold(
                          0.0,
                          (a, b) => a + b.paymentAmount,
                        ));
                return infoCard([
                  {
                    "title": "Invoice Number",
                    "value": widget.invoiceModel.invoiceNumber,
                  },
                  {
                    "title": "Invoice Date",
                    "value": formatDateTimeAsDDMMMYYYY(
                      widget.invoiceModel.invoiceDate,
                    ),
                  },
                  {
                    "title": "Invoice Amount",
                    "value": invoiceAmount.toIndianCurrency(),
                  },
                  {
                    "title": "Paid invoice Amount",
                    "value": paymentPaidAmount.toIndianCurrency(),
                  },
                  {
                    "title": "Pending Amount",
                    "value": pendingAmount.toIndianCurrency(),
                  },
                ]);
              },
            ),
            verticalSpacing(),
            Text(
              "Add Payment Details",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: 16,
                    children: [
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: _selectedBankNotifier,
                        builder: (context, selectedProjectWiseList, _) {
                          return ValueListenableBuilder(
                            valueListenable: _selectedBankNotifier,
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
                                    _selectedBankNotifier.value = value;
                                    if (value.isNotEmpty) {
                                      final item = value.first;

                                      _projectAccountNumberC.text =
                                          (item["AccountNumber"] ?? "")
                                              .toString();
                                      _projectIfscCodeC.text =
                                          (item["IFSCCode"] ?? "").toString();
                                      _projectBranchC.text =
                                          (item["Branch"] ?? "").toString();
                                      _projectAccountType.text =
                                          (item["AcType"] ?? "").toString();
                                      _projectNatureOfAccountC.text =
                                          (item["NatureOfAccount"] ?? "")
                                              .toString();
                                    }
                                  },
                                  dataFetchCallBack:
                                      _fetchProjectBanksForDropdown,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Project Wise Bank is required.';
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
                                    textController: _projectBranchC,
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

                      _card('Make Payment', [
                        ValueListenableBuilder(
                          valueListenable: _selectedPaymentModeNotifier,
                          builder: (context, selectedPaymentMode, _) {
                            return CustomDropDownWidget(
                              title: "Payment Mode",
                              hintText: "Select Payment Mode",
                              isRequired: true,
                              initialValue:
                                  selectedPaymentMode.isNotEmpty
                                      ? selectedPaymentMode.first
                                      : null,
                              dataList: paymentModeList,
                              onSelected: (value) {
                                _selectedPaymentModeNotifier.value = [value];
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Payment Mode is required.";
                                }
                                return null;
                              },
                              onValueClear: () {
                                _selectedPaymentModeNotifier.value = [];
                              },
                            );
                          },
                        ),

                        ValueListenableBuilder(
                          valueListenable: _selectedPaymentTypeNotifier,
                          builder: (context, selectedPaymentType, _) {
                            return CustomDropDownWidget(
                              title: "Payment Type",
                              hintText: "Select Payment Type",
                              isRequired: true,
                              initialValue:
                                  selectedPaymentType.isNotEmpty
                                      ? selectedPaymentType.first
                                      : null,
                              dataList: paymentTypeList,
                              onSelected: (value) {
                                _selectedPaymentTypeNotifier.value = [value];
                                if (value['DisplayName'] == 'Full') {
                                  _amountC.text =
                                      (widget.invoiceModel.invoiceAmount -
                                              widget.invoiceModel.paymentAmount)
                                          .toString();
                                  _tdsAmountC.clear();
                                } else {
                                  _pendingAmountC.text =
                                      (widget.invoiceModel.invoiceAmount -
                                              widget.invoiceModel.paymentAmount)
                                          .toString();
                                  _amountC.clear();
                                  _tdsAmountC.clear();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Payment Type is required.";
                                }
                                return null;
                              },
                              onValueClear: () {
                                _selectedPaymentTypeNotifier.value = [];
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          textController: _pendingAmountC,
                          readOnly: true,
                          title: "Pending Amount",
                          hint: "0",
                          prefixType: CustomTextFieldPrefix.rupees,
                          keyboardType: TextInputType.numberWithOptions(),
                          inputFormatterList: InputValidator.decimal(2),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectedPaymentTypeNotifier,
                          builder: (context, value, child) {
                            return CustomTextField(
                              textController: _amountC,
                              isRequired: true,
                              readOnly:
                                  value.isEmpty
                                      ? false
                                      : value.first['DisplayName'] == 'Full',
                              title: "Brokerage Amount",
                              hint: "Enter Brokerage Amount",
                              prefixType: CustomTextFieldPrefix.rupees,
                              onChangeFunction: (v) {
                                final enteredAmount = double.tryParse(v) ?? 0.0;

                                final calculatedPendingAmount =
                                    (widget.invoiceModel.invoiceAmount -
                                        widget.invoiceModel.paymentAmount) -
                                    enteredAmount;

                                _pendingAmountC
                                    .text = (calculatedPendingAmount >= 0
                                        ? calculatedPendingAmount
                                        : 0.0)
                                    .toStringAsFixed(2);
                              },
                              keyboardType: TextInputType.numberWithOptions(),
                              inputFormatterList: InputValidator.decimal(2),

                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Brokerage Amount is required.";
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          textController: _tdsAmountC,
                          title: "TDS Amount",
                          hint: "Enter TDS Amount",
                          prefixType: CustomTextFieldPrefix.rupees,
                          keyboardType: TextInputType.numberWithOptions(),
                          inputFormatterList: InputValidator.decimal(2),
                        ),
                        CustomTextField(
                          textController: _transactionNumberC,
                          isRequired: true,
                          inputFormatterList: [
                            LengthLimitingTextInputFormatter(25),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                          ],
                          title: "Transaction/Cheque/Demand Draft No.",
                          hint: "Enter Transaction/Cheque/Demand Draft No.",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Transaction/Cheque/Demand Draft No.is required.";
                            }
                            return null;
                          },
                        ),
                        CustomMultiFilePicker(
                          title: 'Transaction/Cheque/Demand Draft Image',
                          filePickType: FilePickType.both,
                          maxFiles: 1,
                          isRequired: true,
                          initialFileList:
                              selectedTransactionOrChequeFile.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedTransactionOrChequeFile.fileNameList =
                                fileNameList;
                            selectedTransactionOrChequeFile.fileBytesList =
                                bytesList;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Transaction/Cheque/Demand Draft Image is required.";
                            }
                            return null;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedTransactionOrChequeFile.fileNameList =
                                fileNameList;
                            selectedTransactionOrChequeFile.fileBytesList =
                                fileBytesList;
                            selectedTransactionOrChequeFile.deletedFileList =
                                deletedFile;
                          },
                        ),
                        CustomDatePicker(
                          isRequired: true,
                          title: "Transaction / Cheque / Demand Draft Date",
                          initialDate: selectedTransactionDate,
                          setValue: (value) {
                            selectedTransactionDate = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Transaction / Cheque / Demand Draft Date is required.";
                            }
                            return null;
                          },
                        ),
                      ]),
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
          color: AppColor.white,
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(Icons.add, size: 16, color: AppColor.white),
            text: "Add",
            onPressed: _saveForm,
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
