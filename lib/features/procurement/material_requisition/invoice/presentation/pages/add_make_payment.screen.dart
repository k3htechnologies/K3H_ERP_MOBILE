import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/presentation/cubit/invoice_cubit.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMakePaymentScreen extends StatefulWidget {
  final String systemgeneratedCode;
  const AddMakePaymentScreen({super.key, required this.systemgeneratedCode});

  @override
  State<AddMakePaymentScreen> createState() => _AddMakePaymentScreenState();
}

class _AddMakePaymentScreenState extends State<AddMakePaymentScreen> {
  late InvoiceCubit _invoiceCubit;
  late ProjectModel _selectedProject;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  // TEXT EDITING CONTROLLERS
  late TextEditingController _accountNumberC,
      _ifscCodeC,
      _pendingAmountC,
      _amountPaidC,
      _tdsAmountC,
      _transactionOrChequeNumberC;
  // DROPDOWNS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentTypeNotifier;
  late ValueNotifier<bool> _isFullPaymentNotifier;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // PAYMENT MODE LIST
  final List<Map<String, dynamic>> _paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cheque"},
    {"zAttributesId": 2, "DisplayName": "Bank Transfer"},
    {"zAttributesId": 3, "DisplayName": "UPI"},
    {"zAttributesId": 4, "DisplayName": "NEFT"},
    {"zAttributesId": 5, "DisplayName": "RTGS"},
  ];

  // FILE VARIABLES
  MultiFilePickerModel selectedTransactionOrChequeNumberFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );

  @override
  void initState() {
    super.initState();
    _invoiceCubit = context.read<InvoiceCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _selectedProject = getProject();
    _initializeTextControllers();
    _selectedPaymentModeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentTypeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
    _isFullPaymentNotifier = ValueNotifier(false);
  }

  void _initializeTextControllers() {
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _pendingAmountC = TextEditingController();
    _amountPaidC = TextEditingController();
    _tdsAmountC = TextEditingController();
    _transactionOrChequeNumberC = TextEditingController();
  }

  @override
  void dispose() {
    _selectedPaymentModeNotifier.dispose();
    _selectedBankNotifier.dispose();
    _selectedPaymentTypeNotifier.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _pendingAmountC.dispose();
    _amountPaidC.dispose();
    _tdsAmountC.dispose();
    _transactionOrChequeNumberC.dispose();
    _isFullPaymentNotifier.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> getPaymentTypeList() {
    final invoice = _invoiceCubit.state.invoiceList.first;

    final paidTillDate = invoice.invoiceAmountPaidTillDate;

    // FIRST PAYMENT
    if (paidTillDate == 0) {
      return [
        {"zAttributesId": 1, "DisplayName": "Partial"},
        {"zAttributesId": 2, "DisplayName": "Full"},
      ];
    }

    // PARTIAL PAYMENT ALREADY DONE
    return [
      {"zAttributesId": 1, "DisplayName": "Partial"},
    ];
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final materialOverview =
        _materialRequisitionCubit.state.materialRequisitionOverview;

    if (materialOverview == null) {
      showErrorMessage(
        context,
        "Error",
        "Material requisition details not found",
      );
      return;
    }
    if (_selectedPaymentModeNotifier.value.isEmpty ||
        _selectedBankNotifier.value.isEmpty ||
        _selectedPaymentTypeNotifier.value.isEmpty) {
      showErrorMessage(context, "Error", "Please select all dropdown values");
      return;
    }

    _invoiceCubit.addPayment(
      context: context,
      projectId: _selectedProject.projectId,
      materialRequisitionId: materialOverview.materialRequisitionId,
      uniqueKey: materialOverview.uniquekey,
      materialRequisitionInvoiceId:
          _invoiceCubit.state.invoiceList.first.materialRequisitionInvoiceId,
      selectPaymentMode: _selectedPaymentModeNotifier.value.first,
      selectedBank: _selectedBankNotifier.value.first,
      accountNumber: _accountNumberC.text,
      ifscCode: _ifscCodeC.text,
      selectPaymentType: _selectedPaymentTypeNotifier.value.first,
      amountPaid: _amountPaidC.text,
      tdsAmount: _tdsAmountC.text,
      transactionNumber: _transactionOrChequeNumberC.text,
      isAdvance: false,
      transactionReceiptPhoto: selectedTransactionOrChequeNumberFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Payment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.systemgeneratedCode,
              style: AppTextStyle.ts16M(color: AppColor.primary),
            ),
            verticalSpacing(),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.all(12.0),
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
                          onValueClear: () {
                            _selectedPaymentModeNotifier.value = [];
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Payment Mode is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedBankNotifier,
                      builder: (context, selectedBank, _) {
                        return CustomMultipleSelectPopup(
                          title: "Bank Name",
                          hintText: "Select Bank Name",
                          isRequired: true,
                          initialValue: selectedBank,
                          dataList: const [],
                          dataFetchCallBack: _fetchBanks,
                          onSelected: (value) {
                            _selectedBankNotifier.value = value;
                          },
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
                      title: "Account Number",
                      hint: "Enter Account Number",
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Account Number is required";
                        }
                        return null;
                      },
                      textController: _accountNumberC,
                    ),
                    CustomTextField(
                      title: "IFSC Code",
                      hint: "Enter IFSC Code",
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "IFSC Code is required";
                        }
                        return null;
                      },
                      textController: _ifscCodeC,
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
                          dataList: getPaymentTypeList(),
                          onSelected: (value) {
                            final wasFull = _isFullPaymentNotifier.value;

                            _selectedPaymentTypeNotifier.value = [value];

                            final isFull =
                                value["DisplayName"]
                                    .toString()
                                    .trim()
                                    .toLowerCase() ==
                                "full";

                            _isFullPaymentNotifier.value = isFull;

                            final invoice =
                                _invoiceCubit.state.invoiceList.first;
                            final invoiceAmount =
                                invoice.invoiceAmount -
                                invoice.invoiceAmountPaidTillDate;

                            _pendingAmountC.text = invoiceAmount
                                .toStringAsFixed(2);

                            if (isFull) {
                              _amountPaidC.text = invoiceAmount.toStringAsFixed(
                                2,
                              );
                            } else if (wasFull) {
                              _amountPaidC.clear();
                            }
                          },
                          onValueClear: () {
                            _selectedPaymentTypeNotifier.value = [];
                            _isFullPaymentNotifier.value = false;
                            _pendingAmountC.clear();
                            _amountPaidC.clear();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Payment Type is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Pending Amount",
                      hint: "Pending Amount",
                      isRequired: true,
                      readOnly: true,
                      textController: _pendingAmountC,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _isFullPaymentNotifier,
                      builder: (context, isFullPayment, _) {
                        final pendingAmount =
                            double.tryParse(_pendingAmountC.text) ?? 0;

                        return CustomTextField(
                          title: "Amount Paid",
                          hint: "Enter Amount Paid",
                          isRequired: true,
                          readOnly: isFullPayment,
                          textController: _amountPaidC,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Amount Paid is required";
                            }

                            final enteredAmount = double.tryParse(value) ?? 0;

                            if (enteredAmount <= 0) {
                              return "Enter valid amount";
                            }

                            // cannot exceed pending
                            if (enteredAmount > pendingAmount) {
                              return "Amount cannot exceed ${pendingAmount.toIndianCurrency()}";
                            }

                            final selectedType =
                                _selectedPaymentTypeNotifier.value.firstOrNull;

                            final paymentType =
                                selectedType?["DisplayName"]
                                    ?.toString()
                                    .trim()
                                    .toLowerCase();

                            // partial payment validation
                            if (paymentType == "partial" &&
                                enteredAmount == pendingAmount &&
                                getPaymentTypeList().length > 1) {
                              return "Select Full payment type";
                            }

                            // full payment validation
                            if (paymentType == "full" &&
                                enteredAmount != pendingAmount) {
                              return "Full payment must equal pending amount";
                            }

                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "TDS Amount",
                      hint: "Enter TDS Amount",
                      textController: _tdsAmountC,
                    ),
                    CustomTextField(
                      title: "Transaction/Cheque Number",
                      hint: "Enter Transaction/Cheque Number",
                      textController: _transactionOrChequeNumberC,
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 5,
                      title: "Transaction/Cheque Receipt",
                      initialFileList:
                          selectedTransactionOrChequeNumberFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedTransactionOrChequeNumberFile.fileNameList =
                            fileNameList;
                        selectedTransactionOrChequeNumberFile.fileBytesList =
                            bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedTransactionOrChequeNumberFile.fileNameList =
                            fileNameList;
                        selectedTransactionOrChequeNumberFile.fileBytesList =
                            fileBytesList;
                        selectedTransactionOrChequeNumberFile.deletedFileList =
                            deletedFile;
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 70,
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: CustomButton(text: "Save", onPressed: _submitForm),
            ),
          ],
        ),
      ),
    );
  }
}
