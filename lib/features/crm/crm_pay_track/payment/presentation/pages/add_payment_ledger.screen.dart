// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/data/model/pay_track_payment_ledger_summary.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/model/project_with_bank_details.model.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/sales/sales_master/other_charges/data/model/other_charges.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
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

class AddPaymentLedgerScreen extends StatefulWidget {
  final List<PayTrackPaymentLedgerModel> paymentLedger;
  final PayTrackPaymentLedgerSummaryModel? editPaymentLedger;
  final List<OtherChargeModel> bookingOtherChargesList;
  const AddPaymentLedgerScreen({
    super.key,
    required this.paymentLedger,
    required this.bookingOtherChargesList,
    this.editPaymentLedger,
  });

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
  late ValueNotifier<Map<String, dynamic>?> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<Map<String, dynamic>?>
  _selectedPaymentreceivedFromNotifier;
  late ValueNotifier<double> totalAmountVN;
  late ValueNotifier<double> paidAmountVN;
  late ValueNotifier<double> pendingAmountVN;
  late ValueNotifier<List<Map<String, dynamic>>>
  _selectedProjectBankNameNotifier;
  late ValueNotifier<Map<String, dynamic>?> selectedOtherCharge;
  // late ValueNotifier<Map<String, dynamic>?> selectedOtherChargeWithGST;

  late TextEditingController _receivedAmountC,
      _transactionOrChequeNumberC,
      _accountNumberC,
      _ifscCodeC,
      _branchC,
      _accountTypeC,
      _natureOfAccountC;

  MultiFilePickerModel selectedChequeForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  DateTime? transactionDate;

  //EDIT MODE
  bool get _isEditMode => widget.editPaymentLedger != null;

  List<Map<String, dynamic>> _projectBankList = [];

  // PROJECT MASTER REPO
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

  bool get _isDeveloperBankRequired {
    final paymentFor =
        selectedPaymentFor.value?["DisplayName"]
            ?.toString()
            .trim()
            .toLowerCase() ??
        "";

    return ![
      "stamp duty",
      "registration fees",
      "agreement value tds",
    ].contains(paymentFor);
  }

  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    selectedPaymentFor = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedPaymentModeNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentreceivedFromNotifier = ValueNotifier<Map<String, dynamic>?>(
      null,
    );
    totalAmountVN = ValueNotifier(0);
    paidAmountVN = ValueNotifier(0);
    pendingAmountVN = ValueNotifier(0);
    _selectedProjectBankNameNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    selectedOtherCharge = ValueNotifier(null);
    // selectedOtherChargeWithGST = ValueNotifier(null);
    _initializeControllers();

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await getProjectWithBankDropdown(1);

        _prefillPaymentLedger(widget.editPaymentLedger!);

        if (context.mounted) {
          _paymentCubit.getPaymentLedgerSummaryList(
            context,
            widget.editPaymentLedger!.bookingId,
            widget.editPaymentLedger!.projectId,
            widget.editPaymentLedger!.paymentFor,
          );
        }
      });
    }
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
    _natureOfAccountC.dispose();
    selectedOtherCharge.dispose();
    // selectedOtherChargeWithGST.dispose();
  }

  void _initializeControllers() {
    _receivedAmountC = TextEditingController();
    _transactionOrChequeNumberC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _branchC = TextEditingController();
    _accountTypeC = TextEditingController();
    _natureOfAccountC = TextEditingController();
  }

  void _prefillPaymentLedger(PayTrackPaymentLedgerSummaryModel list) {
    if (!_isEditMode) return;
    final item = list;
    final matchedLedger = widget.paymentLedger.firstWhereOrNull(
      (e) =>
          e.paymentFor.trim().toLowerCase() ==
          item.paymentFor.trim().toLowerCase(),
    );

    final paymentFor = paymentForList.firstWhereOrNull(
      (e) =>
          (e['DisplayName']?.toString().trim().toLowerCase()) ==
          item.paymentFor.trim().toLowerCase(),
    );

    selectedPaymentFor.value = paymentFor;
    final paymentForName = item.paymentFor.trim().toLowerCase();
    if (paymentForName == "other charges value" ||
        paymentForName == "other charges gst") {
      final otherCharge = widget.bookingOtherChargesList.firstWhereOrNull(
        (e) => e.bookingOtherChargesId == item.bookingOtherChargesId,
      );

      if (otherCharge != null) {
        totalAmountVN.value =
            paymentForName == "other charges gst"
                ? otherCharge.gstValue
                : otherCharge.value;

        paidAmountVN.value = 0;
        pendingAmountVN.value = totalAmountVN.value;
      }
    } else if (matchedLedger != null) {
      totalAmountVN.value = matchedLedger.totalAmount;
      paidAmountVN.value = matchedLedger.receivedAmount;
      pendingAmountVN.value =
          matchedLedger.totalAmount - matchedLedger.receivedAmount;
    }
    // if (paymentForName == "other charges value" ||
    //     paymentForName == "other charges gst") {
    //   final otherCharge = widget.bookingOtherChargesList.firstWhereOrNull(
    //     (e) => e.bookingOtherChargesId == item.bookingOtherChargesId,
    //   );

    //   if (otherCharge != null) {
    //     selectedOtherCharge.value = {
    //       "zAttributesId": otherCharge.bookingOtherChargesId,
    //       "DisplayName": otherCharge.chargeName,
    //       "Value": otherCharge.value,
    //     };
    //   }
    // }
    // if (matchedLedger != null) {
    //   totalAmountVN.value = matchedLedger.totalAmount;
    //   paidAmountVN.value = matchedLedger.receivedAmount;
    //   pendingAmountVN.value =
    //       matchedLedger.totalAmount - matchedLedger.receivedAmount;
    // }
    if (item.bankListMasterId != 0) {
      _selectedBankNotifier.value = [
        {"zAttributesId": item.bankListMasterId, "DisplayName": item.bankName},
      ];
    } else {
      _selectedBankNotifier.value = [];
    }
    _selectedProjectBankNameNotifier.value = [
      {
        "zAttributesId": item.projectBankListMasterId,
        "DisplayName": item.projectBankName,
      },
    ];

    final paymentReceivedFrom = paymentReceivedFormList.firstWhere(
      (e) => e['DisplayName'] == item.paymentReceivedFrom,
      orElse: () => paymentReceivedFormList.first,
    );

    _selectedPaymentreceivedFromNotifier.value = paymentReceivedFrom;
    _receivedAmountC.text = item.receivedAmount.toString();

    _transactionOrChequeNumberC.text = item.transactionChequeDemandDraftNumber;

    transactionDate = item.transactionChequeDemandDraftDate;

    _selectedPaymentModeNotifier.value = paymentModeList.firstWhereOrNull(
      (e) => (e['DisplayName']) == item.paymentMode,
    );
    selectedChequeForPopUpFile.fileNameList =
        item.paymentReceiptUrl.isEmpty ? [] : item.paymentReceiptUrl.split(",");

    _selectedProjectBankNameNotifier.value = [
      {
        "zAttributesId": item.projectBankListMasterId,
        "ProjectWithBankDetailsId": item.projectBankListMasterId,
        "BankListMasterId": item.bankListMasterId,
        "DisplayName":
            "${item.projectBankName} - ${item.projectNatureOfAccount}",
        "AccountNumber": item.projectAccountNumber,
        "IFSCCode": item.projectIfscCode,
        "AcType": item.projectAcType,
        "NatureOfAccount": item.projectNatureOfAccount,
      },
    ];

    final matchedProjectBank = _projectBankList.firstWhereOrNull(
      (e) => e["ProjectWithBankDetailsId"] == item.projectBankListMasterId,
    );

    if (matchedProjectBank != null) {
      _accountNumberC.text =
          matchedProjectBank["AccountNumber"]?.toString() ?? "";
      _ifscCodeC.text = matchedProjectBank["IFSCCode"]?.toString() ?? "";
      _accountTypeC.text = matchedProjectBank["AcType"]?.toString() ?? "";
      _natureOfAccountC.text =
          matchedProjectBank["NatureOfAccount"]?.toString() ?? "";
      _branchC.text = matchedProjectBank["Branch"]?.toString() ?? "";
    }

    if (matchedProjectBank != null) {
      _accountNumberC.text =
          matchedProjectBank["AccountNumber"]?.toString() ?? "";
      _ifscCodeC.text = matchedProjectBank["IFSCCode"]?.toString() ?? "";
      _accountTypeC.text = matchedProjectBank["AcType"]?.toString() ?? "";
      _natureOfAccountC.text =
          matchedProjectBank["NatureOfAccount"]?.toString() ?? "";
      _branchC.text = matchedProjectBank["Branch"]?.toString() ?? "";
    }
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

  // PROJECT WISE BANK DROPDOWN
  Future<Map<String, dynamic>> getProjectWithBankDropdown(
    int pageNumber, {
    String? value,
  }) async {
    ProjectModel project = getProject();

    final result = await _projectMasterRepository.getProjectWithBankDetails(
      projectId: project.projectId,
      queryParams: {"BankName": value ?? "", "IsCheckPermission": false},
    );

    return result.fold(
      (failure) {
        _projectBankList = [];
        return {"itemList": <Map<String, dynamic>>[], "totalNumberOfRecord": 0};
      },
      (response) {
        final data = response["data"] as List<ProjectWithBankDetailsModel>;

        List<Map<String, dynamic>> items =
            data.map((e) {
              return {
                "zAttributesId": e.projectWithBankDetailsId,
                "ProjectWithBankDetailsId": e.projectWithBankDetailsId,
                "BankListMasterId": e.bankListMasterId,
                "DisplayName": "${e.bankName} - ${e.natureOfAccount}",
                "AccountHolderName": e.beneficiaryAccountHolderName,
                "AccountNumber": e.accountNumber,
                "Branch": e.branch,
                "IFSCCode": e.ifscCode,
                "AcType": e.acType,
                "NatureOfAccount": e.natureOfAccount,
              };
            }).toList();
        if (value != null && value.trim().isNotEmpty) {
          items =
              items.where((e) {
                return e["DisplayName"].toString().toLowerCase().contains(
                  value.toLowerCase(),
                );
              }).toList();
        }
        _projectBankList = items;

        return {"itemList": items, "totalNumberOfRecord": items.length};
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditMode) {
      _paymentCubit.updatePaymentLedgerMaster(
        context: context,
        payTrackPaymentLedgerId:
            widget.editPaymentLedger!.payTrackPaymentLedgerId.toString(),

        bookingId: widget.paymentLedger.first.bookingId,

        projectId: widget.paymentLedger.first.projectId,

        bookingOtherChargesId:
            selectedOtherCharge.value?["zAttributesId"].toString() ?? "0",
        paymentFor: selectedPaymentFor.value?["DisplayName"]?.toString() ?? "",

        paymentMode:
            _selectedPaymentModeNotifier.value!["DisplayName"].toString(),

        paymentReceivedFrom:
            _selectedPaymentreceivedFromNotifier.value!["DisplayName"]
                .toString(),

        bankListMasterId:
            _selectedBankNotifier.value.isNotEmpty
                ? _selectedBankNotifier.value.first["zAttributesId"].toString()
                : "0",

        projectBankListMasterId:
            _selectedProjectBankNameNotifier.value.isNotEmpty
                ? _selectedProjectBankNameNotifier.value.first["zAttributesId"]
                    .toString()
                : "0",
        receivedAmount: _receivedAmountC.text.trim(),

        transactionChequeDemandDraftNumber:
            _transactionOrChequeNumberC.text.trim(),

        transactionChequeDemandDraftDate:
            transactionDate?.toIso8601String().split("T").first ?? "",

        selectedChequeUrl: selectedChequeForPopUpFile,
        uniquekey: widget.editPaymentLedger!.uniquekey.toString(),
      );
    } else {
      _paymentCubit.addPaymentLedgerMaster(
        context: context,

        bookingId: widget.paymentLedger.first.bookingId,

        projectId: widget.paymentLedger.first.projectId,

        bookingOtherChargesId:
            selectedOtherCharge.value?["zAttributesId"]?.toString() ?? "0",

        paymentFor: selectedPaymentFor.value?["DisplayName"]?.toString() ?? "",

        paymentMode:
            _selectedPaymentModeNotifier.value!["DisplayName"].toString(),

        paymentReceivedFrom:
            _selectedPaymentreceivedFromNotifier.value!["DisplayName"]
                .toString(),

        bankListMasterId:
            _selectedBankNotifier.value.isNotEmpty
                ? _selectedBankNotifier.value.first["zAttributesId"].toString()
                : "0",

        projectBankListMasterId:
            _selectedProjectBankNameNotifier.value.isNotEmpty
                ? _selectedProjectBankNameNotifier.value.first["zAttributesId"]
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            _isEditMode ? "Update Payment Ledger" : "Add Payment Ledger",
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
                      _isEditMode
                          ? "Update Payment Ledger"
                          : "Add Payment Ledger",
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
                          hintText: "Select Payment For",
                          dataList: paymentForList,
                          initialValue: selectedPaymentFor.value,
                          onSelected: (value) {
                            selectedPaymentFor.value = value;

                            final paymentFor = value["DisplayName"].toString();

                            if (paymentFor == "Other Charges Value" ||
                                paymentFor == "Other Charges GST") {
                              // Reset until an Other Charge is selected
                              selectedOtherCharge.value = null;

                              totalAmountVN.value = 0;
                              paidAmountVN.value = 0;
                              pendingAmountVN.value = 0;
                            } else {
                              final matchedLedger = widget.paymentLedger
                                  .firstWhere(
                                    (e) => e.paymentFor == paymentFor,
                                    orElse:
                                        () => PayTrackPaymentLedgerModel(
                                          bookingId: 0,
                                          projectId: 0,
                                          paymentFor: "",
                                          totalAmount: 0,
                                          receivedAmount: 0,
                                          uploadedPaymentLedgerCount: 0,
                                          approvalPendingPaymentLedgerCount: 0,
                                        ),
                                  );

                              totalAmountVN.value = matchedLedger.totalAmount;
                              paidAmountVN.value = matchedLedger.receivedAmount;
                              pendingAmountVN.value =
                                  matchedLedger.totalAmount -
                                  matchedLedger.receivedAmount;
                            }
                          },
                          // onSelected: (value) {
                          //   selectedPaymentFor.value = value;

                          //   final selectedName = value["DisplayName"];

                          //   final matchedLedger = widget.paymentLedger
                          //       .firstWhere(
                          //         (e) => e.paymentFor == selectedName,
                          //         orElse:
                          //             () => PayTrackPaymentLedgerModel(
                          //               bookingId: 0,
                          //               projectId: 0,
                          //               paymentFor: '',
                          //               totalAmount: 0,
                          //               receivedAmount: 0,
                          //               uploadedPaymentLedgerCount: 0,
                          //               approvalPendingPaymentLedgerCount: 0,
                          //             ),
                          //       );

                          //   totalAmountVN.value = matchedLedger.totalAmount;
                          //   paidAmountVN.value = matchedLedger.receivedAmount;
                          //   pendingAmountVN.value =
                          //       matchedLedger.totalAmount -
                          //       matchedLedger.receivedAmount;
                          // },
                          onValueClear: () {
                            selectedPaymentFor.value = null;

                            totalAmountVN.value = 0;
                            paidAmountVN.value = 0;
                            pendingAmountVN.value = 0;
                            selectedOtherCharge.value = null;
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
                                              value:
                                                  totalAmount
                                                      .toIndianCurrency(),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Paid Amount",
                                              value:
                                                  paidAmount.toIndianCurrency(),
                                            ),
                                          ),
                                          horizontalSpacing(),
                                          Expanded(
                                            child: buildColumnTitleValueNormal(
                                              title: "Pending Amount",
                                              value:
                                                  pendingAmount
                                                      .toIndianCurrency(),
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
                      valueListenable: selectedPaymentFor,
                      builder: (_, value, __) {
                        if (value?["DisplayName"] != "Other Charges Value") {
                          return const SizedBox.shrink();
                        }

                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Other Charges",
                          hintText: "Select Other Charge",
                          initialValue: selectedOtherCharge.value,
                          dataList:
                              widget.bookingOtherChargesList.map((e) {
                                return {
                                  "zAttributesId": e.bookingOtherChargesId,
                                  "DisplayName": e.chargeName,
                                  "Value": e.value,
                                };
                              }).toList(),
                          onSelected: (value) {
                            selectedOtherCharge.value = value;

                            final model = widget.bookingOtherChargesList
                                .firstWhere(
                                  (e) =>
                                      e.bookingOtherChargesId ==
                                      value["zAttributesId"],
                                );

                            if (selectedPaymentFor.value?["DisplayName"] ==
                                "Other Charges GST") {
                              totalAmountVN.value = model.gstValue;
                            } else {
                              totalAmountVN.value = model.value;
                            }

                            paidAmountVN.value = 0;
                            pendingAmountVN.value = totalAmountVN.value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Other Charge is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedOtherCharge.value = null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedPaymentFor,
                      builder: (_, value, __) {
                        if (value?["DisplayName"] != "Other Charges GST") {
                          return const SizedBox.shrink();
                        }

                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Other Charges",
                          hintText: "Select Other Charge",
                          initialValue: selectedOtherCharge.value,
                          dataList:
                              widget.bookingOtherChargesList.map((e) {
                                return {
                                  "zAttributesId": e.bookingOtherChargesId,
                                  "DisplayName": e.chargeName,
                                  "Value": e.value,
                                };
                              }).toList(),
                          onSelected: (value) {
                            selectedOtherCharge.value = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Other Charge is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedOtherCharge.value = null;
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
                              paymentModeList.contains(selectedPaymentMode)
                                  ? selectedPaymentMode
                                  : null,
                          dataList: paymentModeList,

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
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _selectedBankNotifier,
                      builder: (context, selectedBank, _) {
                        return CustomMultipleSelectPopup(
                          title: 'Bank Name',
                          hintText: "Select Bank Name",
                          isRequired: true,
                          isMultiSelect: false,
                          initialValue:
                              selectedBank.isNotEmpty ? selectedBank : null,
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
                          initialValue: selectPayement,
                          onSelected: (value) {
                            _selectedPaymentreceivedFromNotifier.value = value;
                          },
                          onValueClear: () {
                            _selectedPaymentreceivedFromNotifier.value = null;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Payment Received From is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      textController: _receivedAmountC,
                      hint: "Enter Received Amount",
                      title: "Received Amount (₹)",
                      isRequired: true,
                      keyboardType: TextInputType.numberWithOptions(),
                      inputFormatterList: InputValidator.decimal(2),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Received Amount is required";
                        }

                        final receivedAmount = double.tryParse(value) ?? 0;
                        final remainingAmount = pendingAmountVN.value;
                        if (receivedAmount <= 0) {
                          return "Received Amount cannot be zero or negative";
                        }
                        if (receivedAmount > remainingAmount) {
                          return "Amount cannot exceed remaining ${remainingAmount.toIndianCurrency()}";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _transactionOrChequeNumberC,
                      hint: "Enter Transaction / Cheque / Demand Draft No. ",
                      title: "Transaction / Cheque / Demand Draft No.",
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(25),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Transaction / Cheque / Demand Draft No. is required";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Transaction / Cheque / Demand Draft Image",
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
                          return "Transaction / Cheque / Demand Draft Image is required";
                        }

                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Transaction / Cheque / Demand Draft Date",
                      hint: "Transaction / Cheque / Demand Draft Date",
                      isRequired: true,
                      initialDate: transactionDate,
                      setValue: (value) => transactionDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Transaction / Cheque / Demand Draft Date is required';
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
                      "Developer Bank Details",
                      style: AppTextStyle.ts14M(
                        color: AppColor.black.withValues(alpha: 0.5),
                      ),
                    ),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: selectedPaymentFor,
                      builder: (_, __, ___) {
                        return ValueListenableBuilder(
                          valueListenable: _selectedProjectBankNameNotifier,
                          builder: (context, selectedProjectBank, _) {
                            return CustomMultipleSelectPopup(
                              title: 'Project Bank Name',
                              hintText: "Select Project Bank Name",
                              isRequired: _isDeveloperBankRequired,
                              isMultiSelect: false,
                              initialValue:
                                  selectedProjectBank.isNotEmpty
                                      ? selectedProjectBank
                                      : null,
                              dataList: const [],

                              onSelected: (value) {
                                _selectedProjectBankNameNotifier.value = value;

                                if (value.isNotEmpty) {
                                  final item = value.first;

                                  _accountNumberC.text =
                                      (item["AccountNumber"] ?? "").toString();

                                  _ifscCodeC.text =
                                      (item["IFSCCode"] ?? "").toString();

                                  _branchC.text =
                                      (item["Branch"] ?? "").toString();

                                  _accountTypeC.text =
                                      (item["AcType"] ?? "").toString();

                                  _natureOfAccountC.text =
                                      (item["NatureOfAccount"] ?? "")
                                          .toString();
                                }
                              },

                              dataFetchCallBack: getProjectWithBankDropdown,

                              validator: (value) {
                                if (_isDeveloperBankRequired &&
                                    (value == null || value.isEmpty)) {
                                  return "Project Bank Name is required";
                                }
                                return null;
                              },

                              onClear: () {
                                _selectedProjectBankNameNotifier.value = [];
                                _accountNumberC.clear();
                                _ifscCodeC.clear();
                                _branchC.clear();
                                _accountTypeC.clear();
                                _natureOfAccountC.clear();
                              },
                            );
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
                              verticalSpacing(),

                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      textController: _natureOfAccountC,
                                      title: "Nature Of Account",
                                      hint: "Nature Of Account",
                                      readOnly: true,
                                    ),
                                  ),
                                  horizontalSpacing(),
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
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
