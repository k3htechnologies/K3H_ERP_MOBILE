import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/data/model/pay_track.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/payment/presentation/cubit/payment_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/refund_amount_payment_ledger.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/pages/widgets/document_preview.screen.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ModifiedRequestsMakePaymentScreen extends StatefulWidget {
  final String uniquekey;
  final int bookingId;
  final int projectId;
  final RefundedAmountLedgerModel? refundData;
  const ModifiedRequestsMakePaymentScreen({
    super.key,
    required this.uniquekey,
    required this.bookingId,
    required this.projectId,
    this.refundData,
  });

  @override
  State<ModifiedRequestsMakePaymentScreen> createState() =>
      _ModifiedRequestsMakePaymentScreenState();
}

class _ModifiedRequestsMakePaymentScreenState
    extends State<ModifiedRequestsMakePaymentScreen> {
  late RequestManagementCubit _requestManagementCubit;
  late PayTrackCubit _payTrackCubit;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  late TextEditingController _accountNumberC,
      _ifscCodeC,
      _developerBankBranchNameC,
      _accountTypeC,
      _natureOfAccC,
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

  MultiFilePickerModel selectedChequeForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  DateTime? transactionDate;
  bool get isEdit => widget.refundData != null;
  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    _payTrackCubit = context.read<PayTrackCubit>();
    _requestManagementCubit = context.read<RequestManagementCubit>();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedProjectBankNameNotifier =
        ValueNotifier<List<Map<String, dynamic>>>([]);
    _selectedPaymentModeNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _selectedAmountTypeNotifier = ValueNotifier<Map<String, dynamic>?>(null);
    _initializeControllers();
    _requestManagementCubit.getBookingById(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
    _payTrackCubit.getPayTrackListByBookingId(
      context,
      1,
      widget.projectId,
      widget.bookingId,
    );
    if (isEdit) {
      final data = widget.refundData!;
      _selectedProjectBankNameNotifier.value = [
        {
          "zAttributesId": data.projectBankListMasterId,
          "ProjectWithBankDetailsId": data.projectBankListMasterId,
          "DisplayName": data.projectBankName,
          "AccountNumber": data.projectAccountNumber,
          "IFSCCode": data.projectIfscCode,
          "Branch": "",
          "AcType": data.projectAcType,
          "NatureOfAccount": data.projectNatureOfAccount,
        },
      ];
      _selectedBankNotifier.value = [
        {"zAttributesId": data.bankListMasterId, "DisplayName": data.bankName},
      ];
      _selectedPaymentModeNotifier.value = paymentModeList.firstWhere(
        (e) => e["DisplayName"] == data.paymentMode,
        orElse: () => {},
      );
      _accountHolderNameC.text = data.accountHolderName;
      _customersAccountNumberC.text = data.accountNumber;
      _customersIFSCCodeC.text = data.ifscCode;
      _refundableAmountC.text = data.refundedAmount.toString();
      _transactionOrChequeNumberC.text =
          data.transactionChequeDemandDraftNumber;

      transactionDate = data.transactionChequeDemandDraftDate;

      selectedChequeForPopUpFile.fileNameList = [
        data.transactionChequeDemandDraftUrl,
      ];
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedBankNotifier.dispose();
    _developerBankBranchNameC.dispose();
    _accountTypeC.dispose();
    _natureOfAccC.dispose();
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
    _developerBankBranchNameC = TextEditingController();
    _accountTypeC = TextEditingController();
    _natureOfAccC = TextEditingController();
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
    debugPrint(_selectedProjectBankNameNotifier.value.toString());
    _requestManagementCubit.refundAmountPaymentLedger(
      context: context,
      refundedAmountLedgerId: widget.refundData?.refundedAmountLedgerId ?? 0,
      uniquekey: widget.uniquekey,
      bookingId: widget.bookingId,
      projectId: widget.projectId,
      paymentMode:
          _selectedPaymentModeNotifier.value!["DisplayName"].toString(),
      projectBankListMasterId:
          _selectedProjectBankNameNotifier.value.isNotEmpty
              ? _selectedProjectBankNameNotifier
                  .value
                  .first["ProjectWithBankDetailsId"]
                  .toString()
              : "0",
      accountHolderName: _accountHolderNameC.text.trim(),
      bankListMasterId:
          _selectedBankNotifier.value.isNotEmpty
              ? _selectedBankNotifier.value.first["zAttributesId"].toString()
              : "0",
      accountNumber: _customersAccountNumberC.text.trim(),
      ifscCode: _customersIFSCCodeC.text.trim(),
      refundedAmount: _refundableAmountC.text.trim(),
      transactionChequeDemandDraftNumber:
          _transactionOrChequeNumberC.text.trim(),
      transactionChequeDemandDraftDate:
          transactionDate?.toIso8601String().split("T").first ?? "",
      chequeFile: selectedChequeForPopUpFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: isEdit ? "Edit Payment" : "Make Payment",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<RequestManagementCubit, RequestManagementState>(
        builder: (context, state) {
          if (state.isLoading ?? false) {
            return Center(child: loader());
          }
          final payTrack =
              context.watch<PayTrackCubit>().state.payTrackOverview;

          if (payTrack == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final maxRefundableAmount =
              state.bookingData?.totalAmountReceivedAgainstBooking ?? 0.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildUnitDetailsCard(state.bookingData!),
                          verticalSpacing(),
                          buildApplicantAndCoApplicantDetailsCard(
                            state.bookingData!,
                          ),
                          verticalSpacing(),
                          buildWarningRefundAmountCard(state.bookingData!),
                          buildReceivedAmountCard(payTrack),
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
                                  "Developers Bank Details",
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                verticalSpacing(height: 12.0),
                                ValueListenableBuilder(
                                  valueListenable:
                                      _selectedProjectBankNameNotifier,
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
                                              (item["IFSCCode"] ?? "")
                                                  .toString();
                                          _developerBankBranchNameC.text =
                                              (item["Branch"] ?? "").toString();
                                          _accountTypeC.text =
                                              (item["AcType"] ?? "").toString();
                                          _natureOfAccC.text =
                                              (item["NatureOfAccount"] ?? "")
                                                  .toString();
                                        }
                                      },
                                      dataFetchCallBack:
                                          _paymentCubit
                                              .getProjectWithBankDropdown,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Project Bank Name is required";
                                        }
                                        return null;
                                      },

                                      onClear: () {
                                        _selectedProjectBankNameNotifier.value =
                                            [];
                                        _accountNumberC.clear();
                                        _ifscCodeC.clear();
                                        _developerBankBranchNameC.clear();
                                        _accountTypeC.clear();
                                        _natureOfAccC.clear();
                                      },
                                    );
                                  },
                                ),
                                ValueListenableBuilder(
                                  valueListenable:
                                      _selectedProjectBankNameNotifier,
                                  builder: (context, selectedProjectBank, _) {
                                    if (selectedProjectBank.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                textController: _accountNumberC,
                                                title: "Account Number",
                                                hint: "Account Number",
                                                readOnly: true,
                                              ),
                                            ),
                                            horizontalSpacing(width: 20.0),
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
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                textController:
                                                    _developerBankBranchNameC,
                                                title: "Branch",
                                                hint: "Branch",
                                                readOnly: true,
                                              ),
                                            ),
                                            horizontalSpacing(width: 20.0),
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
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: CustomTextField(
                                                textController: _natureOfAccC,
                                                title: "Nature Of Account",
                                                hint: "Nature Of Account",
                                                readOnly: true,
                                              ),
                                            ),
                                          ],
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
                                  "Customers Bank Details",
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
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
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                verticalSpacing(height: 12.0),

                                ValueListenableBuilder(
                                  valueListenable: _selectedPaymentModeNotifier,
                                  builder: (context, selectedPaymentMode, _) {
                                    return CustomDropDownWidget(
                                      title: "Payment Mode",
                                      hintText: "Select Payment Mode",
                                      isRequired: true,
                                      initialValue: selectedPaymentMode,
                                      dataList: paymentModeList,
                                      onSelected: (value) {
                                        _selectedPaymentModeNotifier.value =
                                            value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Payment Mode is required";
                                        }
                                        return null;
                                      },
                                      onValueClear: () {
                                        _selectedPaymentModeNotifier.value =
                                            null;
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

                                    final enteredAmount =
                                        double.tryParse(value.trim()) ?? 0.0;

                                    final maxRefundableAmount =
                                        context
                                            .read<PayTrackCubit>()
                                            .state
                                            .payTrackOverview
                                            ?.totalAmountRefundedAgainstBooking ??
                                        0.0;

                                    if (enteredAmount > maxRefundableAmount) {
                                      return "Refundable Amount cannot be greater than ${maxRefundableAmount.toIndianCurrency()}.";
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
                                  title:
                                      "Transaction / Cheque / Demand Draft Image",
                                  isRequired: true,
                                  filePickType: FilePickType.both,
                                  initialFileList:
                                      selectedChequeForPopUpFile.fileNameList,
                                  onFilePickedCallback: (
                                    bytesList,
                                    fileNameList,
                                  ) {
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
                                      return "ITransaction / Cheque / Demand Draft Image is required";
                                    }
                                    return null;
                                  },
                                ),
                                CustomDatePicker(
                                  title:
                                      "Transaction / Cheque / Demand Draft Date",
                                  hint:
                                      "Transaction / Cheque / Demand Draft Date",
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Save", onPressed: _submitForm),
        ),
      ),
    );
  }

  Widget buildWarningRefundAmountCard(BookingModel data) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Note: This is the refund amount finalized for this booking. Please consider this amount while initiating any further refund process.",
            style: AppTextStyle.ts12B(),
          ),
          buildColumnTitleValueNormal(
            title: "Amount",
            value: data.totalAmountRefundedAgainstBooking.toIndianCurrency(),
          ),
        ],
      ),
    );
  }

  Widget buildReceivedAmountCard(PayTrackModel data) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColor.lightBlue,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Received Amount",
            style: AppTextStyle.ts14M(
              color: AppColor.black.withValues(alpha: 0.5),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Stamp Duty",
                  value: data.receivedStampDutyAmount.toIndianCurrency(),
                ),
              ),
              horizontalSpacing(width: 20.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Registration Fees",
                  value: data.receivedRegistrationFees.toIndianCurrency(),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Agreememt Value (Without TDS)",
                  value: data.receivedAgreementValue.toIndianCurrency(),
                ),
              ),
              horizontalSpacing(width: 20.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Agreememt Value GST",
                  value:
                      data.receivedAgreementValueGstAmount.toIndianCurrency(),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Agreememt Value TDS",
                  value: data.receivedAgreementValueTds.toIndianCurrency(),
                ),
              ),
              horizontalSpacing(width: 20.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Other Charges",
                  value: data.receivedOtherChargesAmount.toIndianCurrency(),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Other Charges GST",
                  value: data.otherChargesGstAmount.toIndianCurrency(),
                ),
              ),
              horizontalSpacing(width: 20.0),
              Expanded(
                child: buildColumnTitleValueNormal(
                  title: "Total Received",
                  value:
                      data.totalAmountReceivedAgainstBooking.toIndianCurrency(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildUnitDetailsCard(BookingModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF2F6FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              "Unit Details",
              style: AppTextStyle.ts14M(color: AppColor.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Project Name",
                        value: data.projectName,
                      ),
                    ),
                    horizontalSpacing(width: 20.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Wing",
                        value: data.wing,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Floor",
                        value: data.floor,
                      ),
                    ),
                    horizontalSpacing(width: 20.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Unit Number",
                        value: data.flat,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Configuration",
                        value: data.flatConfiguration,
                      ),
                    ),
                    horizontalSpacing(width: 20.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "RERA Carpet Area (SqFt)",
                        value: data.reraCarpetAreaSqFt.toString(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Agreement Value (With TDS)",
                        value: data.agreementValue.toIndianCurrency(),
                      ),
                    ),
                    horizontalSpacing(width: 20.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Number Of Parking",
                        value: data.numberOfParking.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildApplicantAndCoApplicantDetailsCard(BookingModel data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xfffff6eb),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Text(
              "Applicant & Co - Applicant Details",
              style: AppTextStyle.ts14M(color: Color(0xffc2410c)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              spacing: 10.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 6.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: AppColor.lightBlue,
                      ),
                      child: Text(
                        data.bookingApplicantData.first.applicantType,
                        style: AppTextStyle.ts14M(color: AppColor.primary),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Applicant Name",
                        value: data.bookingApplicantData.first.applicantName,

                        customValueWidget: DocumentPreviewText(
                          title: "Profile Photo",
                          text: data.bookingApplicantData.first.applicantName,
                          fileUrl: data.bookingApplicantData.first.photoURL,
                        ),
                      ),
                    ),
                    horizontalSpacing(width: 20.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Mobile Number",
                        value:
                            data
                                .bookingApplicantData
                                .first
                                .applicantMobileNumber,

                        customValueWidget: CustomClickToContactText(
                          countryCode:
                              data
                                  .bookingApplicantData
                                  .first
                                  .applicantMobileNumberCountryCode,
                          value:
                              data
                                  .bookingApplicantData
                                  .first
                                  .applicantMobileNumber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
