import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddPaymentLedgerScreen extends StatefulWidget {
  final List<PayTrackPaymentLedgerModel> paymentLedgerList;
  const AddPaymentLedgerScreen({super.key, required this.paymentLedgerList});

  @override
  State<AddPaymentLedgerScreen> createState() => _AddPaymentLedgerScreenState();
}

class _AddPaymentLedgerScreenState extends State<AddPaymentLedgerScreen> {
  late PaymentCubit _paymentCubit;
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ValueNotifier<Map<String, dynamic>?> selectedPaymentFor;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<List<Map<String, dynamic>>>
  _selectedPaymentreceivedFromNotifier;
  late ValueNotifier<double> totalAmountVN;
  late ValueNotifier<double> paidAmountVN;
  late ValueNotifier<double> pendingAmountVN;
  late ValueNotifier<List<Map<String, dynamic>>>
  _selectedProjectBankNameNotifier;

  late TextEditingController _receivedAmountC,
      _transactionOrChequeNumberC,
      _accountNumberC,
      _ifscCodeC,
      _branchC,
      _accountTypeC;
  List<Map<String, dynamic>> paymentForList = [
    {"zAttributesId": 1, "DisplayName": "Agreement Value"},
    {"zAttributesId": 2, "DisplayName": "Agreement Value GST"},
    {"zAttributesId": 3, "DisplayName": "Agreement Value TDS"},
    {"zAttributesId": 4, "DisplayName": "Other Charges Value"},
    {"zAttributesId": 5, "DisplayName": "Other Charges GST"},
    {"zAttributesId": 6, "DisplayName": "Registration Fees"},
    {"zAttributesId": 7, "DisplayName": "Stamp Duty"},
  ];
  final List<Map<String, dynamic>> _paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cash"},
    {"zAttributesId": 2, "DisplayName": "Cheque"},
    {"zAttributesId": 3, "DisplayName": "Bank Transfer"},
    {"zAttributesId": 4, "DisplayName": "UPI"},
    {"zAttributesId": 5, "DisplayName": "NEFT"},
    {"zAttributesId": 6, "DisplayName": "RTGS"},
  ];
  List<Map<String, dynamic>> paymentReceivedFormList = [
    {"zAttributesId": 1, "DisplayName": "Bank"},
    {"zAttributesId": 2, "DisplayName": "Owner"},
  ];
  MultiFilePickerModel selectedChequeForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  DateTime? transactionDate;
  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    selectedPaymentFor = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedPaymentModeNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      [],
    );
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentreceivedFromNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    totalAmountVN = ValueNotifier(0);
    paidAmountVN = ValueNotifier(0);
    pendingAmountVN = ValueNotifier(0);
    _selectedProjectBankNameNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    _initializeControllers();
  }

  @override
  void dispose() {
    super.dispose();
    selectedPaymentFor.dispose();
    totalAmountVN.dispose();
    paidAmountVN.dispose();
    pendingAmountVN.dispose();
    _selectedPaymentModeNotifier.dispose();
    _selectedBankNotifier.dispose();
    _selectedPaymentreceivedFromNotifier.dispose();
    _receivedAmountC.dispose();
    _selectedProjectBankNameNotifier.dispose();
    _transactionOrChequeNumberC.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _branchC.dispose();
    _accountTypeC.dispose();
  }

  void _initializeControllers() {
    _receivedAmountC = TextEditingController();
    _transactionOrChequeNumberC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _branchC = TextEditingController();
    _accountTypeC = TextEditingController();
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
    debugPrint(
      "Selected Project Bank => ${_selectedProjectBankNameNotifier.value}",
    );
    _paymentCubit.addPaymentLedgerMaster(
      context: context,

      bookingId: widget.paymentLedgerList.first.bookingId.toString(),

      projectId: widget.paymentLedgerList.first.projectId.toString(),

      bookingOtherChargesId: "0",

      paymentFor: selectedPaymentFor.value?["DisplayName"]?.toString() ?? "",

      paymentMode:
          _selectedPaymentModeNotifier.value.isNotEmpty
              ? _selectedPaymentModeNotifier.value.first["DisplayName"]
                  .toString()
              : "",

      paymentReceivedFrom:
          _selectedPaymentreceivedFromNotifier.value.isNotEmpty
              ? _selectedPaymentreceivedFromNotifier.value.first["DisplayName"]
                  .toString()
              : "",

      bankListMasterId:
          _selectedBankNotifier.value.isNotEmpty
              ? _selectedBankNotifier.value.first["zAttributesId"].toString()
              : "0",

      projectBankListMasterId:
          _selectedProjectBankNameNotifier.value.isNotEmpty
              ? _selectedProjectBankNameNotifier.value.first["BankListMasterId"]
                  .toString()
              : "0",

      receivedAmount: _receivedAmountC.text.trim(),

      transactionChequeDemandDraftNumber:
          _transactionOrChequeNumberC.text.trim(),

      transactionChequeDemandDraftDate:
          transactionDate?.toIso8601String().split("T").first ?? "",

      selectedChequeUrl: selectedChequeForPopUpFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Add Payment Ledger",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Payment Ledger",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: selectedPaymentFor,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          title: "Payment For",
                          hintText: "Select Payment",
                          dataList: paymentForList,
                          initialValue: selectedPaymentFor.value,
                          onSelected: (value) {
                            selectedPaymentFor.value = value;

                            final selectedName = value["DisplayName"];

                            final matchedLedger = widget.paymentLedgerList
                                .firstWhere(
                                  (e) => e.paymentFor == selectedName,
                                  orElse:
                                      () => PayTrackPaymentLedgerModel(
                                        bookingId: 0,
                                        projectId: 0,
                                        paymentFor: "",
                                        receivedAmount: 0,
                                        totalAmount: 0,
                                        uploadedPaymentLedgerCount: 0,
                                        approvalPendingPaymentLedgerCount: 0,
                                      ),
                                );

                            totalAmountVN.value = matchedLedger.receivedAmount;
                            paidAmountVN.value = matchedLedger.receivedAmount;
                            pendingAmountVN.value =
                                matchedLedger.receivedAmount -
                                matchedLedger.receivedAmount;
                          },
                          onValueClear: () {
                            selectedPaymentFor.value = null;

                            totalAmountVN.value = 0;
                            paidAmountVN.value = 0;
                            pendingAmountVN.value = 0;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Payment For is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedPaymentFor,
                      builder: (context, selectedValue, _) {
                        if (selectedValue == null) {
                          return const SizedBox.shrink();
                        }

                        return ValueListenableBuilder(
                          valueListenable: totalAmountVN,
                          builder: (_, totalAmount, __) {
                            return ValueListenableBuilder(
                              valueListenable: paidAmountVN,
                              builder: (_, paidAmount, __) {
                                return ValueListenableBuilder(
                                  valueListenable: pendingAmountVN,
                                  builder: (_, pendingAmount, __) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 10.0),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColor.lightBlue,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Total Amount",
                                              value: addCommasToInteger(
                                                totalAmount,
                                              ),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Paid Amount",
                                              value: addCommasToInteger(
                                                paidAmount,
                                              ),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Pending Amount",
                                              value: addCommasToInteger(
                                                pendingAmount,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
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
                          title: 'Bank Name',
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
                      valueListenable: _selectedPaymentreceivedFromNotifier,
                      builder: (context, selectPayement, _) {
                        return CustomDropDownWidget(
                          title: "Payment Received From",
                          hintText: "Select Payment Received From",
                          dataList: paymentReceivedFormList,
                          isRequired: true,
                          initialValue:
                              selectPayement.isNotEmpty
                                  ? selectPayement.first
                                  : null,
                          onSelected: (value) {
                            _selectedPaymentreceivedFromNotifier.value = [
                              value,
                            ];
                          },
                          onValueClear: () {
                            _selectedPaymentreceivedFromNotifier.value = [];
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Payment Received is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _receivedAmountC,
                      hint: "Received Amount",
                      title: "Received Amount (₹)",
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList: InputValidator.decimal(2),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Received Amount is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _transactionOrChequeNumberC,
                      hint: "Enter Transaction / Cheque / Demand Draft No.",
                      title: "Transaction / Cheque / Demand Draft No.",
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(6),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Transaction / Cheque / Demand Draft No. is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Upload Cheque",
                      isRequired: true,
                      filePickType: FilePickType.both,
                      initialFileList: selectedChequeForPopUpFile.fileNameList,

                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedChequeForPopUpFile.fileNameList = fileNameList;
                        selectedChequeForPopUpFile.fileBytesList = bytesList;
                      },

                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedChequeForPopUpFile.fileNameList = fileNameList;
                        selectedChequeForPopUpFile.fileBytesList =
                            fileBytesList;
                        selectedChequeForPopUpFile.deletedFileList =
                            deletedFile;
                      },

                      validator: (fileList) {
                        if (fileList == null || fileList.isEmpty) {
                          return "Cheque is required";
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Our Bank Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: _selectedProjectBankNameNotifier,
                      builder: (context, selectedProjectBank, _) {
                        return CustomMultipleSelectPopup(
                          key: ValueKey(
                            selectedProjectBank.isEmpty
                                ? 'project_bank_empty'
                                : selectedProjectBank.first['zAttributesId'],
                          ),

                          title: 'Project Bank Name',
                          hintText: "Select Project Bank Name",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedProjectBank,
                          dataList: const [],

                          onSelected: (value) {
                            debugPrint("PROJECT BANK VALUE => $value");

                            _selectedProjectBankNameNotifier.value = value;

                            if (value.isNotEmpty) {
                              final item = value.first;

                              _accountNumberC.text =
                                  (item["AccountNumber"] ?? "").toString();

                              _ifscCodeC.text =
                                  (item["IFSCCode"] ?? "").toString();

                              _branchC.text = (item["Branch"] ?? "").toString();

                              _accountTypeC.text =
                                  (item["AcType"] ?? "").toString();
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
                            _branchC.clear();
                            _accountTypeC.clear();
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

                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      textController: _accountNumberC,
                                      title: "Account Number",
                                      hint: "Account Number",
                                      readOnly: true,
                                    ),
                                  ),

                                  horizontalSpacing(),

                                  Expanded(
                                    child: CustomTextField(
                                      textController: _ifscCodeC,
                                      title: "IFSC Code",
                                      hint: "IFSC Code",
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),

                              verticalSpacing(),

                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      textController: _branchC,
                                      title: "Branch",
                                      hint: "Branch",
                                      readOnly: true,
                                    ),
                                  ),

                                  horizontalSpacing(),

                                  Expanded(
                                    child: CustomTextField(
                                      textController: _accountTypeC,
                                      title: "Account Type",
                                      hint: "Account Type",
                                      readOnly: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(Icons.add, size: 18, color: AppColor.white),
            text: "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
