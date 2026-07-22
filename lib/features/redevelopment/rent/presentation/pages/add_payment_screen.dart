import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/model/rent.model.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/cubit/rent_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/custom_snack_bar.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddPaymentScreen extends StatefulWidget {
  final int buildingId;
  final List<TemporaryAccommodationAlternativeDetailsModel> rentDetails;
  final RentModel rentModel;

  /// Total charge amount for this tenant (for remaining-amount validation).
  final double? totalAmount;
  final double? paidAmount;

  /// When non-null, screen is in update mode (reference: employee AddEmployeeScreen).
  final PaymentLedgerModel? paymentLedger;
  final int? paymentLedgerIndex;

  const AddPaymentScreen({
    super.key,
    required this.buildingId,
    required this.rentDetails,
    required this.rentModel,
    this.totalAmount,
    this.paidAmount,
    this.paymentLedger,
    this.paymentLedgerIndex,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  // CUBIT
  late RentCubit _rentCubit;
  late ProjectModel _project;

  /// Edit mode when opening for update (reference: employee _isEditMode).
  bool get _isEditMode => widget.paymentLedger != null;

  // FORM KEY
  final GlobalKey<FormState> _formLedger = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  late TextEditingController _payAmountC,
      _transactionNumC,
      _accountNumberC,
      _ifscCodeC,
      _branchC,
      _accountType,
      _accountHolderNameC;

  // DATE PICKER VAR
  DateTime? selectedDate;

  // DROPDOWN VARIABLES
  final ValueNotifier<Map<String, dynamic>?> selectedPaymentMode =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> selectedAmountType = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> selectedPaymentType =
      ValueNotifier(null);

  // Bank selections as list (single item when selected) for CustomMultipleSelectPopup
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedProjectWiseBankNotifier = ValueNotifier([]);

  // FILE PICKER MODELS
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

  // PAYMENT MODE LIST
  List<Map<String, dynamic>> paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cheque"},
    {"zAttributesId": 2, "DisplayName": "Demand Draft"},
    {"zAttributesId": 3, "DisplayName": "IMPS"},
    {"zAttributesId": 4, "DisplayName": "N/A"},
    {"zAttributesId": 5, "DisplayName": "NEFT"},
    {"zAttributesId": 6, "DisplayName": "RTGS"},
    {"zAttributesId": 7, "DisplayName": "UPI"},
  ];

  // AMOUNT TYPE LIST
  List<Map<String, dynamic>> amountTypeList = [
    {"zAttributesId": 1, "DisplayName": "Monthly"},
    {"zAttributesId": 2, "DisplayName": "Quarterly"},
    {"zAttributesId": 3, "DisplayName": "Yearly"},
    {"zAttributesId": 4, "DisplayName": "One Time"},
  ];

  // PAYMENT TYPE LIST
  List<Map<String, dynamic>> paymentTypeList = [
    {"zAttributesId": 1, "DisplayName": "Advance"},
    {"zAttributesId": 2, "DisplayName": "Regular"},
    {"zAttributesId": 3, "DisplayName": "Late Fee"},
    {"zAttributesId": 4, "DisplayName": "Penalty"},
  ];

  @override
  void initState() {
    super.initState();
    _rentCubit = context.read<RentCubit>();
    _project = getProject();
    _initializeTextControllers();
    if (_isEditMode && widget.paymentLedger != null) {
      _prefillFromPaymentLedger(widget.paymentLedger!);
    }
  }

  void _prefillFromPaymentLedger(PaymentLedgerModel p) {
    selectedDate = p.transactionChequeDemandDraftDate;
    _payAmountC.text = p.payAmount.toStringAsFixed(2);
    _transactionNumC.text = p.transactionChequeDemandDraftNumber;
    _accountNumberC.text = p.accountNumber;
    _ifscCodeC.text = p.ifscCode;
    _branchC.text = '';
    _accountType.text = '';
    _accountHolderNameC.text = p.projectBankAccountHolderName;

    selectedPaymentMode.value = paymentModeList.firstWhere(
      (e) => (e['DisplayName'] as String?) == p.paymentMode,
      orElse: () => paymentModeList.first,
    );
    selectedAmountType.value = amountTypeList.firstWhere(
      (e) => (e['DisplayName'] as String?) == p.amountType,
      orElse: () => amountTypeList.first,
    );
    selectedPaymentType.value = paymentTypeList.firstWhere(
      (e) => (e['DisplayName'] as String?) == p.paymentType,
      orElse: () => paymentTypeList.first,
    );

    _selectedBankNotifier.value = [
      {'zAttributesId': p.bankListMasterId, 'DisplayName': p.bankName},
    ];
    _selectedProjectWiseBankNotifier.value = [
      {
        'zAttributesId': p.projectBankListMasterId,
        'DisplayName': p.projectBankName,
        'AccountHolderName': p.projectBankAccountHolderName,
        'AccountNumber': p.accountNumber,
        'IFSCCode': p.ifscCode,
        'Branch': '',
        'AcType': '',
      },
    ];

    if (p.transactionChequeDemandDraftUrl.isNotEmpty) {
      transactionChequeDemandDraftUrl.fileNameList = [
        p.transactionChequeDemandDraftUrl,
      ];
    }
    if (p.paymentReceiptUrl.isNotEmpty) {
      paymentReceiptUrl.fileNameList = [p.paymentReceiptUrl];
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _transactionNumC.dispose();
    _payAmountC.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _branchC.dispose();
    _accountType.dispose();
    _accountHolderNameC.dispose();
  }

  void _initializeTextControllers() {
    _transactionNumC = TextEditingController();
    _payAmountC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _branchC = TextEditingController();
    _accountType = TextEditingController();
    _accountHolderNameC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Payment" : "Add Payment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formLedger,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomDropDownWidget(
                      title: "Payment Mode",
                      hintText: "Select Payment Mode",
                      isRequired: true,
                      dataList: paymentModeList,
                      initialValue: selectedPaymentMode.value,
                      onSelected: (value) {
                        selectedPaymentMode.value = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Payment Mode for is required';
                        }
                        return null;
                      },
                      onValueClear: () => selectedPaymentMode.value = null,
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
                          title: "Bank Name",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue: selectedBankList,
                          dataList: const [],
                          onSelected: (value) {
                            _selectedBankNotifier.value = value;
                          },
                          dataFetchCallBack: _rentCubit.getBankList,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bank Name is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedProjectWiseBankNotifier,
                      builder: (context, selectedProjectWiseList, _) {
                        return CustomMultipleSelectPopup(
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
                            _selectedProjectWiseBankNotifier.value = value;
                            if (value.isNotEmpty) {
                              final item = value.first;
                              _accountHolderNameC.text =
                                  (item["AccountHolderName"] ?? "").toString();
                              _accountNumberC.text =
                                  (item["AccountNumber"] ?? "").toString();
                              _ifscCodeC.text =
                                  (item["IFSCCode"] ?? "").toString();
                              _branchC.text = (item["Branch"] ?? "").toString();
                              _accountType.text =
                                  (item["AcType"] ?? "").toString();
                            }
                          },
                          dataFetchCallBack:
                              _rentCubit.getProjectWithBankDropdown,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Project Wise Bank is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Amount Type",
                      hintText: "Select Amount Type",
                      isRequired: true,
                      dataList: amountTypeList,
                      initialValue: selectedAmountType.value,
                      onSelected: (value) {
                        selectedAmountType.value = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Amount Type is required';
                        }
                        return null;
                      },
                      onValueClear: () => selectedAmountType.value = null,
                    ),
                    CustomDropDownWidget(
                      title: "Payment Type",
                      hintText: "Select Payment Type",
                      isRequired: true,
                      dataList: paymentTypeList,
                      initialValue: selectedPaymentType.value,
                      onSelected: (value) {
                        selectedPaymentType.value = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Payment Type is required';
                        }
                        return null;
                      },
                      onValueClear: () => selectedPaymentType.value = null,
                    ),
                    CustomTextField(
                      title: "Account Number",
                      textController: _accountNumberC,
                      readOnly: true,
                      isRequired: true,
                    ),
                    CustomTextField(
                      title: "IFSC Code",
                      textController: _ifscCodeC,
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
                      textController: _accountType,
                      readOnly: true,
                      isRequired: true,
                    ),
                    CustomTextField(
                      title: "Account Holder Name",
                      readOnly: true,
                      textController: _accountHolderNameC,
                    ),
                    CustomTextField(
                      title: "Pay Amount",
                      hint: "Enter Amount",
                      textController: _payAmountC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(9),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Pay Amount is required";
                        }

                        final entered = double.tryParse(value);
                        if (entered == null) {
                          return "Enter a valid amount";
                        }

                        if (entered <= 0) {
                          return "Pay Amount must be greater than zero";
                        }

                        if (_isEditMode) return null;

                        if (widget.totalAmount == null) {
                          return "Invalid payment configuration";
                        }

                        if ((widget.paidAmount ?? 0) > widget.totalAmount!) {
                          return "Invalid data: Paid amount exceeds total amount";
                        }

                        final remaining =
                            widget.totalAmount! - (widget.paidAmount ?? 0);

                        if (remaining <= 0) {
                          return "Full amount already paid. No further payment allowed.";
                        }

                        if (entered > remaining) {
                          return "Maximum payable amount is ₹${remaining.toStringAsFixed(2)}";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Transaction/Cheque/DD No.",
                      hint: "Enter Transaction/Cheque/DD No.",
                      isRequired: true,
                      textController: _transactionNumC,
                      inputFormatterList: InputValidator.textDigit(50),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Field is required";
                        }
                        if (value.length < 6) {
                          return "Minimum 6 characters required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Transaction/Cheque/DD Image",
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
                    CustomDatePicker(
                      isRequired: true,
                      title: "Cheque/DD/IMPS/NEFT/RTGS Date",
                      initialDate: selectedDate,
                      setValue: (value) {
                        setState(() {
                          selectedDate = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Date is required";
                        }
                        return null;
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: _isEditMode ? "Update Payment" : "Add Payment",
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            onPressed: () {
              if (!_formLedger.currentState!.validate()) return;
              if (_selectedBankNotifier.value.isEmpty) {
                CustomSnackBar.showTopSnackBar(
                  context,
                  title: "Please select Bank Name",
                  isError: true,
                );
                return;
              }
              if (_selectedProjectWiseBankNotifier.value.isEmpty) {
                CustomSnackBar.showTopSnackBar(
                  context,
                  title: "Please select Project Wise Bank",
                  isError: true,
                );
                return;
              }
              if (selectedDate == null) {
                CustomSnackBar.showTopSnackBar(
                  context,
                  title: "Please select Date",
                  isError: true,
                );
                return;
              }

              final rentModel = widget.rentModel;
              final tenure =
                  widget.rentDetails.isNotEmpty
                      ? widget.rentDetails.first.tenure
                      : rentModel.tenure;

              if (_isEditMode && widget.paymentLedger != null) {
                _rentCubit.updatePayTrackRent(
                  context: context,
                  payTrackRentId: widget.paymentLedger!.payTrackRentId,
                  uniqueKey: widget.paymentLedger!.uniquekey,
                  tenantId: rentModel.tenantId,
                  tenantApplicantId: rentModel.tenantApplicantId,
                  buildingId: rentModel.buildingId,
                  projectId: rentModel.projectId,
                  projectBankListMasterId:
                      _selectedProjectWiseBankNotifier
                              .value
                              .first["zAttributesId"]
                          as int,
                  accountHolderName: _accountHolderNameC.text,
                  bankListMasterId:
                      _selectedBankNotifier.value.first["zAttributesId"] as int,
                  accountNumber: _accountNumberC.text,
                  ifscCode: _ifscCodeC.text,
                  paymentMode:
                      selectedPaymentMode.value?["DisplayName"] as String,
                  amountType:
                      selectedAmountType.value?["DisplayName"] as String,
                  paymentType:
                      selectedPaymentType.value?["DisplayName"] as String,
                  payAmount: _payAmountC.text,
                  transactionChequeDemandDraftNumber: _transactionNumC.text,
                  transactionChequeDemandDraftDate: selectedDate!,
                  transactionChequeDemandDraftURL:
                      transactionChequeDemandDraftUrl,
                  paymentReceiptURL: paymentReceiptUrl,
                  tenure: tenure,
                  chargeType: widget.paymentLedger?.chargeType ?? "RENT",
                  index: widget.paymentLedgerIndex ?? 0,
                );
              } else {
                _rentCubit
                    .addPayTrackRent(
                      context: context,
                      payTrackRentId: 0,
                      tenantId: rentModel.tenantId,
                      tenantApplicantId: rentModel.tenantApplicantId,
                      buildingId: rentModel.buildingId,
                      projectId: rentModel.projectId,
                      projectBankListMasterId:
                          _selectedProjectWiseBankNotifier
                                  .value
                                  .first["zAttributesId"]
                              as int,
                      accountHolderName: _accountHolderNameC.text,
                      bankListMasterId:
                          _selectedBankNotifier.value.first["zAttributesId"]
                              as int,
                      accountNumber: _accountNumberC.text,
                      ifscCode: _ifscCodeC.text,
                      paymentMode:
                          selectedPaymentMode.value?["DisplayName"] as String,
                      amountType:
                          selectedAmountType.value?["DisplayName"] as String,
                      paymentType:
                          selectedPaymentType.value?["DisplayName"] as String,
                      payAmount: _payAmountC.text,
                      transactionChequeDemandDraftNumber: _transactionNumC.text,
                      transactionChequeDemandDraftDate: selectedDate!,
                      transactionChequeDemandDraftURL:
                          transactionChequeDemandDraftUrl,
                      paymentReceiptURL: paymentReceiptUrl,
                      tenure: tenure,
                      chargeType: "RENT",
                    )
                    .then((_) {
                      if (context.mounted) {
                        _rentCubit.pullChargesDetails(
                          context: context,
                          pageNumber: 1,
                          projectId: _project.projectId,
                          buildingId: widget.buildingId,
                          chargeName: "RENT",
                          tenure: tenure,
                        );
                      }
                    });
              }
            },
          ),
        ),
      ),
    );
  }
}
