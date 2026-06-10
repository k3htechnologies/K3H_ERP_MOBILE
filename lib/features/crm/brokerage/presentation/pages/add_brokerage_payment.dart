import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../cubit/brokerage_cubit.dart';

class AddBrokeragePayment extends StatefulWidget {
  final BrokerageInvoiceModel invoiceModel;
  const AddBrokeragePayment({super.key, required this.invoiceModel});

  @override
  State<AddBrokeragePayment> createState() => _AddBrokeragePaymentState();
}

class _AddBrokeragePaymentState extends State<AddBrokeragePayment> {
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  late BrokerageCubit _brokerageCubit;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _pendingAmountC,
      _amountC,
      _tdsAmountC,
      _transactionNumberC;

  // DROPDOWNS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentTypeNotifier;

  // PAYMENT MODE LIST
  final List<Map<String, dynamic>> _paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cheque"},
    {"zAttributesId": 2, "DisplayName": "Demand Draft"},
    {"zAttributesId": 3, "DisplayName": "IMPS"},
    {"zAttributesId": 4, "DisplayName": "Online Transfer"},
    {"zAttributesId": 5, "DisplayName": "RTGS"},
    {"zAttributesId": 6, "DisplayName": "UPI"},
  ];

  // PAYMENT TYPE LIST
  final List<Map<String, dynamic>> _paymentTypeList = [
    {"zAttributesId": 1, "DisplayName": "Full"},
    {"zAttributesId": 2, "DisplayName": "Partial"},
  ];

  // FILE VARIABLES
  MultiFilePickerModel selectedTransactionOrChequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

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
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextEditingControllers() {
    _pendingAmountC = TextEditingController();
    _amountC = TextEditingController();
    _tdsAmountC = TextEditingController();
    _transactionNumberC = TextEditingController();
  }

  // FETCH BANK
  Future<Map<String, dynamic>> _fetchBanks(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getBankList(
      pageNumber: pageNumber,
      pageSize: 15,
      query: value != null && value.isNotEmpty ? {"BankName": value} : {},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<BankListMasterModel>;

        return {
          "itemList":
              banks.map((bank) {
                return {
                  "zAttributesId": bank.bankListMasterId,
                  "DisplayName": bank.bankNameWithCode,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Make Payment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Payment",
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
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
                      dataList: _paymentModeList,
                      onSelected: (value) {
                        _selectedPaymentModeNotifier.value = [value];
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Payment Mode is required";
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
                  valueListenable: _selectedBankNotifier,
                  builder: (context, selectedBank, _) {
                    return CustomMultipleSelectPopup(
                      title: 'Bank',
                      hintText: "Select Bank",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: selectedBank,
                      dataList: const [],
                      onSelected: (value) {
                        _selectedBankNotifier.value = value;
                      },
                      dataFetchCallBack: _fetchBanks,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Bank Name is required";
                        }
                        return null;
                      },
                      onClear: () {
                        _selectedBankNotifier.value = [];
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
                      dataList: _paymentTypeList,
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
                          return "Payment Type is required";
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
                      title: "Amount",
                      hint: "Enter Amount",
                      onChangeFunction: (v) {
                        final enteredAmount = double.tryParse(v) ?? 0.0;

                        final calculatedPendingAmount =
                            (widget.invoiceModel.invoiceAmount -
                                widget.invoiceModel.paymentAmount) -
                            enteredAmount;

                        _pendingAmountC.text = (calculatedPendingAmount >= 0
                                ? calculatedPendingAmount
                                : 0.0)
                            .toStringAsFixed(2);
                      },
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList: InputValidator.decimal(2),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Amount is required";
                        }
                        return null;
                      },
                    );
                  },
                ),
                CustomTextField(
                  textController: _tdsAmountC,
                  isRequired: true,
                  title: "TDS Amount",
                  hint: "Enter TDS Amount",
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatterList: InputValidator.decimal(2),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "TDS Amount is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _transactionNumberC,
                  isRequired: true,
                  title: "Transaction/Cheque Number",
                  hint: "Enter Transaction/Cheque Number",
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Transaction/Cheque Number is required";
                    }
                    return null;
                  },
                ),
                CustomMultiFilePicker(
                  title: 'Transaction/Cheque Receipt',
                  filePickType: FilePickType.both,
                  maxFiles: 1,
                  isRequired: true,
                  initialFileList: selectedTransactionOrChequeFile.fileNameList,
                  onFilePickedCallback: (bytesList, fileNameList) {
                    selectedTransactionOrChequeFile.fileNameList = fileNameList;
                    selectedTransactionOrChequeFile.fileBytesList = bytesList;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Transaction/Cheque Receipt is required";
                    }
                    return null;
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                  ) {
                    selectedTransactionOrChequeFile.fileNameList = fileNameList;
                    selectedTransactionOrChequeFile.fileBytesList =
                        fileBytesList;
                    selectedTransactionOrChequeFile.deletedFileList =
                        deletedFile;
                  },
                ),
              ],
            ),
          ),
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
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _brokerageCubit.addBrokeragePayment(
                context: context,
                bookingId: widget.invoiceModel.bookingId.toString(),
                projectId: widget.invoiceModel.projectId.toString(),
                brokerageInvoiceId:
                    widget.invoiceModel.brokerageInvoiceId.toString(),
                paymentMode:
                    _selectedPaymentModeNotifier.value.first['DisplayName'],
                bankListMasterId:
                    _selectedBankNotifier.value.first['zAttributesId']
                        .toString(),
                paymentType:
                    _selectedPaymentTypeNotifier.value.first['DisplayName'],
                amountPaid: _amountC.text,
                tDSAmount: _tdsAmountC.text,
                transactionNumber: _transactionNumberC.text,
                transactionReceiptFiles: selectedTransactionOrChequeFile,
              );
            },
          ),
        ),
      ),
    );
  }
}
