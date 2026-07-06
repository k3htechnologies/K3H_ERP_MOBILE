import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
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

class ModifiedRequestsMakePaymentScreen extends StatefulWidget {
  final String uniquekey;
  final String bookingId;
  final String projectId;
  const ModifiedRequestsMakePaymentScreen({
    super.key,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
  });

  @override
  State<ModifiedRequestsMakePaymentScreen> createState() =>
      _ModifiedRequestsMakePaymentScreenState();
}

class _ModifiedRequestsMakePaymentScreenState
    extends State<ModifiedRequestsMakePaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  late TextEditingController _accountNumberC,
      _ifscCodeC,
      _accountHolderNameC,
      _customersIFSCCodeC,
      _customersAccountNumberC,
      _paymentForC,
      _refundableAmountC,
      _transactionOrChequeNumberC;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late PaymentCubit _paymentCubit;
  late ValueNotifier<List<Map<String, dynamic>>>
  _selectedProjectBankNameNotifier;
  late ValueNotifier<Map<String, dynamic>?> _selectedPaymentModeNotifier;
  late ValueNotifier<Map<String, dynamic>?> _selectedAmountTypeNotifier;

  final List<Map<String, dynamic>> _paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cash"},
    {"zAttributesId": 2, "DisplayName": "Cheque"},
    {"zAttributesId": 3, "DisplayName": "Bank Transfer"},
    {"zAttributesId": 4, "DisplayName": "UPI"},
    {"zAttributesId": 5, "DisplayName": "NEFT"},
    {"zAttributesId": 6, "DisplayName": "RTGS"},
  ];
  final List<Map<String, dynamic>> _amountTypeList = [
    {"zAttributesId": 1, "DisplayName": "Agreement Amount"},
  ];
  MultiFilePickerModel selectedChequeForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPaymentReceiptImage = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  DateTime? transactionDate;
  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedProjectBankNameNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentModeNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedAmountTypeNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _initializeControllers();
  }

  @override
  void dispose() {
    super.dispose();
    _selectedBankNotifier.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _accountHolderNameC.dispose();
    _customersIFSCCodeC.dispose();
    _customersAccountNumberC.dispose();
    _selectedPaymentModeNotifier.dispose();
    _selectedProjectBankNameNotifier.dispose();
    _paymentForC.dispose();
    _selectedAmountTypeNotifier.dispose();
    _refundableAmountC.dispose();
    _transactionOrChequeNumberC.dispose();
  }

  void _initializeControllers() {
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _accountHolderNameC = TextEditingController();
    _customersIFSCCodeC = TextEditingController();
    _customersAccountNumberC = TextEditingController();
    _paymentForC = TextEditingController();
    _refundableAmountC = TextEditingController();
    _transactionOrChequeNumberC = TextEditingController();
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _paymentCubit.refundAmountPaymentLedger(
      context: context,
      uniquekey: widget.uniquekey,
      bookingId: widget.bookingId,
      projectId: widget.projectId,
      paymentFor: _paymentForC.text.trim(),
      paymentMode:
          _selectedPaymentModeNotifier.value!["DisplayName"].toString(),
      projectBankListMasterId:
          _selectedProjectBankNameNotifier.value.isNotEmpty
              ? _selectedProjectBankNameNotifier.value.first["BankListMasterId"]
                  .toString()
              : "0",
      accountHolderName: _accountHolderNameC.text.trim(),
      bankListMasterId:
          _selectedBankNotifier.value.isNotEmpty
              ? _selectedBankNotifier.value.first["zAttributesId"].toString()
              : "0",
      accountNumber: _customersAccountNumberC.text.trim(),
      ifscCode: _customersIFSCCodeC.text.trim(),
      amountType:
          _selectedAmountTypeNotifier.value?["DisplayName"]?.toString() ?? "",
      paymentType: "Refund",
      refundedAmount: _refundableAmountC.text.trim(),
      transactionChequeDemandDraftNumber:
          _transactionOrChequeNumberC.text.trim(),
      transactionChequeDemandDraftDate:
          transactionDate?.toIso8601String().split("T").first ?? "",
      chequeFile: selectedChequeForPopUpFile,
      paymentReceiptFile: selectedPaymentReceiptImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Make Payment",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Developer’s  Bank Details",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          verticalSpacing(height: 12.0),
                          ValueListenableBuilder(
                            valueListenable: _selectedProjectBankNameNotifier,
                            builder: (context, selectedProjectBank, _) {
                              return CustomMultipleSelectPopup(
                                key: ValueKey(
                                  selectedProjectBank.isEmpty
                                      ? 'project_bank_empty'
                                      : selectedProjectBank
                                          .first['zAttributesId'],
                                ),

                                title: 'Project Bank Name',
                                hintText: "Select Project Bank Name",
                                isRequired: true,
                                isMultiSelect: false,
                                initialValue: selectedProjectBank,
                                dataList: const [],

                                onSelected: (value) {
                                  _selectedProjectBankNameNotifier.value =
                                      value;
                                  if (value.isNotEmpty) {
                                    final item = value.first;

                                    _accountNumberC.text =
                                        (item["AccountNumber"] ?? "")
                                            .toString();

                                    _ifscCodeC.text =
                                        (item["IFSCCode"] ?? "").toString();
                                  }
                                },
                                dataFetchCallBack:
                                    _paymentCubit.getProjectWithBankDropdown,

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Bank Name is required";
                                  }
                                  return null;
                                },

                                onClear: () {
                                  _selectedProjectBankNameNotifier.value = [];
                                  _accountNumberC.clear();
                                  _ifscCodeC.clear();
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _selectedProjectBankNameNotifier,
                            builder: (context, selectedProjectBank, _) {
                              if (selectedProjectBank.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextField(
                                    textController: _accountNumberC,
                                    title: "Account Number",
                                    hint: "Account Number",
                                    readOnly: true,
                                  ),
                                  CustomTextField(
                                    textController: _ifscCodeC,
                                    title: "IFSC Code",
                                    hint: "IFSC Code",
                                    readOnly: true,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Customer’s  Bank Details",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          verticalSpacing(height: 12.0),
                          CustomTextField(
                            textController: _accountHolderNameC,
                            hint: "Enter Account Holder Name",
                            title: "Account Holder Name",
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Account Holder Name is required";
                              }
                              return null;
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
                          CustomTextField(
                            textController: _customersAccountNumberC,
                            hint: "Enter Account Number",
                            title: "Account Number",
                            isRequired: true,
                            keyboardType: TextInputType.number,
                            inputFormatterList: InputValidator.digit(20),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Account Number is required";
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            textController: _customersIFSCCodeC,
                            hint: "Enter IFSC Code",
                            title: "IFSC Code",
                            isRequired: true,
                            inputFormatterList:
                                InputValidator.ifscInputFormatters(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "IFSC Code is required";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment Details",
                            style: AppTextStyle.ts14M(
                              color: AppColor.black.withValues(alpha: 0.5),
                            ),
                          ),
                          verticalSpacing(height: 12.0),
                          CustomTextField(
                            textController: _paymentForC,
                            hint: "Enter Payment For",
                            title: "Payment For",
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Payment For is required";
                              }
                              return null;
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _selectedPaymentModeNotifier,
                            builder: (context, selectedPaymentMode, _) {
                              return CustomDropDownWidget(
                                title: "Payment Mode",
                                hintText: "Select Payment Mode",
                                isRequired: true,
                                initialValue: selectedPaymentMode,
                                dataList: _paymentModeList,
                                onSelected: (value) {
                                  _selectedPaymentModeNotifier.value = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Payment Mode is required";
                                  }
                                  return null;
                                },
                                onValueClear: () {
                                  _selectedPaymentModeNotifier.value = null;
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder(
                            valueListenable: _selectedAmountTypeNotifier,
                            builder: (context, selectedAmountType, _) {
                              return CustomDropDownWidget(
                                title: "Amount Type",
                                hintText: "Select Amount Type",
                                isRequired: true,
                                initialValue: selectedAmountType,
                                dataList: _amountTypeList,
                                onSelected: (value) {
                                  _selectedAmountTypeNotifier.value = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Amount Type is required";
                                  }
                                  return null;
                                },
                                onValueClear: () {
                                  _selectedAmountTypeNotifier.value = null;
                                },
                              );
                            },
                          ),
                          CustomTextField(
                            textController: _refundableAmountC,
                            hint: "Enter Refundable Amount",
                            title: "Refundable Amount",
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Refundable Amount is required";
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            textController: _transactionOrChequeNumberC,
                            hint:
                                "Enter Transaction No. / Cheque No. / Demand Draft Number",
                            title:
                                "Transaction No. / Cheque No. / Demand Draft Number",
                            isRequired: true,
                            keyboardType: TextInputType.number,
                            inputFormatterList: InputValidator.digit(6),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Transaction No. / Cheque No. / Demand Draft Number is required";
                              }
                              return null;
                            },
                          ),
                          CustomMultiFilePicker(
                            title: "Upload Image",
                            isRequired: true,
                            filePickType: FilePickType.both,
                            initialFileList:
                                selectedChequeForPopUpFile.fileNameList,
                            onFilePickedCallback: (bytesList, fileNameList) {
                              selectedChequeForPopUpFile.fileNameList =
                                  fileNameList;
                              selectedChequeForPopUpFile.fileBytesList =
                                  bytesList;
                            },
                            onFileDeleteCallback: (
                              fileBytesList,
                              fileNameList,
                              deletedFile,
                            ) {
                              selectedChequeForPopUpFile.fileNameList =
                                  fileNameList;
                              selectedChequeForPopUpFile.fileBytesList =
                                  fileBytesList;
                              selectedChequeForPopUpFile.deletedFileList =
                                  deletedFile;
                            },
                            validator: (fileList) {
                              if (fileList == null || fileList.isEmpty) {
                                return "Image is required";
                              }
                              return null;
                            },
                          ),
                          CustomDatePicker(
                            title: "Demand Draft Date",
                            hint: "Transaction / Cheque / Demand Draft Date",
                            isRequired: true,
                            initialDate: transactionDate,
                            setValue: (value) => transactionDate = value,
                            validator: (value) {
                              if (value == null) {
                                return 'Date Of Filing is required';
                              }
                              return null;
                            },
                          ),
                          CustomMultiFilePicker(
                            title: "Upload Payment Receipt",
                            isRequired: true,
                            filePickType: FilePickType.both,
                            initialFileList:
                                selectedPaymentReceiptImage.fileNameList,
                            onFilePickedCallback: (bytesList, fileNameList) {
                              selectedPaymentReceiptImage.fileNameList =
                                  fileNameList;
                              selectedPaymentReceiptImage.fileBytesList =
                                  bytesList;
                            },
                            onFileDeleteCallback: (
                              fileBytesList,
                              fileNameList,
                              deletedFile,
                            ) {
                              selectedPaymentReceiptImage.fileNameList =
                                  fileNameList;
                              selectedPaymentReceiptImage.fileBytesList =
                                  fileBytesList;
                              selectedPaymentReceiptImage.deletedFileList =
                                  deletedFile;
                            },
                            validator: (fileList) {
                              if (fileList == null || fileList.isEmpty) {
                                return "Payment Receipt is required";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [CustomButton(text: "Save", onPressed: _submitForm)],
            ),
          ),
        ],
      ),
    );
  }
}
