import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBrokerageInvoiceScreen extends StatefulWidget {
  final int bookingId;
  final int projectId;
  final BrokerageModel brokerageModel;
  final BrokerageInvoiceModel? brokerageInvoiceModel;
  final int? index;
  const AddBrokerageInvoiceScreen({
    super.key,
    required this.brokerageModel,
    this.brokerageInvoiceModel,
    this.index,
    required this.bookingId,
    required this.projectId,
  });
  @override
  State<AddBrokerageInvoiceScreen> createState() =>
      _AddBrokerageInvoiceScreenState();
}

class _AddBrokerageInvoiceScreenState extends State<AddBrokerageInvoiceScreen> {
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberC,
      _accountNameC,
      _accountNumberC,
      _ifscCodeC,
      _invoiceAmountC,
      _remarkC;
  DateTime? invoiceDate;
  DateTime? dueDate;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late double _availableBrokerageAmount;
  final MultiFilePickerModel _invoiceDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late BrokerageCubit _brokerageCubit;
  bool get _isEditMode => widget.brokerageInvoiceModel != null;
  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _brokerageCubit = context.read<BrokerageCubit>();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _prefill();
  }

  @override
  void dispose() {
    super.dispose();
    _invoiceNumberC.dispose();
    _accountNameC.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    _invoiceAmountC.dispose();
    _remarkC.dispose();
    _selectedBankNotifier.dispose();
  }

  void _initializeTextEditingControllers() {
    _invoiceNumberC = TextEditingController();
    _accountNameC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _invoiceAmountC = TextEditingController();
    _remarkC = TextEditingController();
  }

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

  void _prefill() {
    if (!_isEditMode) return;
    final brokerage = widget.brokerageInvoiceModel!;
    _invoiceNumberC.text = brokerage.invoiceNumber;
    invoiceDate = brokerage.invoiceDate;
    _invoiceDocument.fileNameList = brokerage.uploadInvoiceURL.split(",");
    _selectedBankNotifier.value = [
      {
        "zAttributesId": brokerage.bankListMasterId,
        "DisplayName": brokerage.bankName,
      },
    ];
    _accountNumberC.text = brokerage.accountNumber;
    _accountNameC.text = brokerage.accountName;
    _ifscCodeC.text = brokerage.ifscCode;
    _invoiceAmountC.text = brokerage.invoiceAmount.toString();
    dueDate = brokerage.dueDate;
    _remarkC.text = brokerage.remark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Brokerage Invoice",
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
                _availableBrokerageAmount =
                    widget.brokerageModel.brokerageAmount - invoiceAmount;
                final paymentPaidAmount = state.brokerageInvoiceList.fold(
                  0.0,
                  (a, b) => a + b.paymentAmount,
                );
                final pendingAmount =
                    (widget.brokerageModel.brokerageAmount -
                        state.brokerageInvoiceList.fold(
                          0.0,
                          (a, b) => a + b.paymentAmount,
                        ));
                return infoCard([
                  {
                    "title": "CP Name",
                    "value": widget.brokerageModel.channelPartnerName,
                  },
                  {
                    "title": "CP Company",
                    "value": widget.brokerageModel.channelPartnerCompany,
                  },
                  {
                    "title": "CP Mobile Number",
                    "value": widget.brokerageModel.channelPartnerMobileNumber,
                    "widget": CustomClickToContactText(
                      countryCode:
                          widget
                              .brokerageModel
                              .channelPartnerMobileNumberCountryCode,
                      value: widget.brokerageModel.channelPartnerMobileNumber,
                    ),
                  },
                  {
                    "title": "Agreement Value",
                    "value":
                        widget.brokerageModel.agreementValue.toIndianCurrency(),
                  },
                  {
                    "title": "Brokerage Amount",
                    "value":
                        widget.brokerageModel.brokerageAmount
                            .toIndianCurrency(),
                  },
                  {
                    "title": "Generated Invoice Amount",
                    "value": invoiceAmount.toIndianCurrency(),
                  },
                  {
                    "title": "Paid Invoice Amount",
                    "value": paymentPaidAmount.toIndianCurrency(),
                  },
                  {
                    "title": "Outstanding Amount",
                    "value": pendingAmount.toIndianCurrency(),
                  },
                ]);
              },
            ),
            verticalSpacing(),
            Text(
              _isEditMode ? "Update Invoice" : "Add Invoice",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          title: "Invoice Number",
                          hint: "Enter Invoice Number",
                          isRequired: true,
                          inputFormatterList:
                              InputValidator.digitAndCharacterOnly(15),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Invoice Number is required.";
                            }
                            if (value.trim().isNotEmpty &&
                                !InputValidator.isValidInvoiceNumber(
                                  value.trim(),
                                )) {
                              return "Invoice Number cannot be zero.";
                            }
                            return null;
                          },
                          textController: _invoiceNumberC,
                        ),
                        CustomDatePicker(
                          title: 'Invoice Date',
                          isRequired: true,
                          initialDate: invoiceDate,
                          setValue: (value) => invoiceDate = value,
                          validator: (value) {
                            if (value == null) {
                              return 'Invoice Date is required.';
                            }
                            return null;
                          },
                        ),
                        CustomMultiFilePicker(
                          title: "Invoice Document",
                          isRequired: true,
                          filePickType: FilePickType.kycDocument,
                          initialFileList: _invoiceDocument.fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            _invoiceDocument.fileNameList = fileNameList;
                            _invoiceDocument.fileBytesList = bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            _invoiceDocument.fileNameList = fileNameList;
                            _invoiceDocument.fileBytesList = fileBytesList;
                            _invoiceDocument.deletedFileList = deletedFile;
                          },
                          validator: (fileList) {
                            if (fileList == null || fileList.isEmpty) {
                              return "Invoice Document is required.";
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
                                  return "Bank Name is required.";
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
                          title: "Account Holder Name",
                          hint: "Enter Account Holder Name",
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Holder Name is required.";
                            }
                            return null;
                          },
                          textController: _accountNameC,
                        ),
                        CustomTextField(
                          title: "Account Number",
                          hint: "Enter Account Number",
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digit(18),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Account Number is required.";
                            }
                            return null;
                          },
                          textController: _accountNumberC,
                        ),
                        CustomTextField(
                          title: "IFSC Code",
                          hint: "Enter IFSC Code",
                          isRequired: true,
                          inputFormatterList:
                              InputValidator.ifscInputFormatters(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'IFSC Code is required.';
                            }
                            if (!InputValidator.isValidIFSC(value)) {
                              return 'Enter a valid IFSC Code.';
                            }
                            return null;
                          },
                          textController: _ifscCodeC,
                        ),
                        CustomTextField(
                          title: "Invoice Amount",
                          hint: "Enter Invoice Amount",
                          keyboardType: TextInputType.numberWithOptions(),
                          inputFormatterList: InputValidator.decimal(2),
                          isRequired: true,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                double.parse(value) == 0) {
                              return "Invoice Amount is required.";
                            }
                            if ((double.tryParse(value) ?? 0) >
                                widget.brokerageModel.brokerageAmount) {
                              return "Invoice amount exceeds the brokerage amount ${_availableBrokerageAmount == 0 ? '' : _availableBrokerageAmount.toIndianCurrency()}.";
                            }
                            return null;
                          },
                          textController: _invoiceAmountC,
                        ),
                        CustomDatePicker(
                          title: 'Due Date',
                          initialDate: dueDate,
                          startDate: DateTime.now(),
                          isRequired: true,
                          setValue: (value) => dueDate = value,
                          validator: (value) {
                            if (value == null) {
                              return 'Due Date is required.';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Remark",
                          hint: "Enter Remark",
                          isRequired: true,
                          minLines: 3,
                          maxLines: 3,
                          textController: _remarkC,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Remark is required.'
                                      : null,
                        ),
                      ],
                    ),
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
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_isEditMode) {
                _brokerageCubit.updateBrokerageInvoice(
                  context: context,
                  brokerageInvoiceId:
                      widget.brokerageInvoiceModel!.brokerageInvoiceId
                          .toString(),
                  uniquekey: widget.brokerageInvoiceModel!.uniqueKey,
                  bookingId: widget.brokerageInvoiceModel!.bookingId.toString(),
                  projectId: widget.brokerageInvoiceModel!.projectId.toString(),
                  invoiceNumber: _invoiceNumberC.text.trim(),
                  invoiceDate: invoiceDate!.toIso8601String(),
                  bankListMasterId:
                      _selectedBankNotifier.value.first['zAttributesId']
                          .toString(),
                  accountName: _accountNameC.text.trim(),
                  accountNumber: _accountNumberC.text.trim(),
                  iFSCCode: _ifscCodeC.text.trim(),
                  invoiceAmount: _invoiceAmountC.text.trim(),
                  dueDate: dueDate?.toIso8601String() ?? "",
                  remark: _remarkC.text.trim(),
                  invoiceFiles: _invoiceDocument,
                  index: widget.index!,
                );
              } else {
                _brokerageCubit.addBrokerageInvoice(
                  context: context,
                  bookingId: widget.bookingId.toString(),
                  projectId: widget.projectId.toString(),
                  invoiceNumber: _invoiceNumberC.text.trim(),
                  invoiceDate: invoiceDate!.toIso8601String(),
                  bankListMasterId:
                      _selectedBankNotifier.value.first['zAttributesId']
                          .toString(),
                  accountName: _accountNameC.text.trim(),
                  accountNumber: _accountNumberC.text.trim(),
                  iFSCCode: _ifscCodeC.text.trim(),
                  invoiceAmount: _invoiceAmountC.text.trim(),
                  dueDate: dueDate?.toIso8601String() ?? "",
                  remark: _remarkC.text.trim(),
                  invoiceFiles: _invoiceDocument,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
