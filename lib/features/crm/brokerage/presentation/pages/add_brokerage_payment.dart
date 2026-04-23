import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/paid_brokerage_booking.model.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBrokeragePayment extends StatefulWidget {
  final PaidBrokerageBookingModel? paidBrokerageBookingModel;
  final int? index;
  const AddBrokeragePayment({super.key, this.paidBrokerageBookingModel,this.index});

  @override
  State<AddBrokeragePayment> createState() => _AddBrokeragePaymentState();
}

class _AddBrokeragePaymentState extends State<AddBrokeragePayment> {
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _amountC, _tdsAmountC, _transactionNumberC;

  // DROPDOWNS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentModeNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedPaymentTypeNotifier;

  // PAYMENT MODE LIST
  final List<Map<String, dynamic>> _paymentModeList = [
    {"zAttributesId": 1, "DisplayName": "Cash"},
    {"zAttributesId": 2, "DisplayName": "Cheque"},
    {"zAttributesId": 3, "DisplayName": "Bank Transfer"},
    {"zAttributesId": 4, "DisplayName": "UPI"},
    {"zAttributesId": 5, "DisplayName": "NEFT"},
    {"zAttributesId": 6, "DisplayName": "RTGS"},
  ];

  // PAYMENT TYPE LIST
  final List<Map<String, dynamic>> _paymentTypeList = [
    {"zAttributesId": 1, "DisplayName": "Full Payment"},
    {"zAttributesId": 2, "DisplayName": "Partial Payment"},
    {"zAttributesId": 3, "DisplayName": "Advance Payment"},
  ];

  // FILE VARIABLES
  MultiFilePickerModel selectedTransactionOrChequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // EDIT MODE
  bool get _isEditMode => widget.paidBrokerageBookingModel != null;

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? "Update Payment" : "Add Payment",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              ValueListenableBuilder(
                valueListenable: _selectedPaymentModeNotifier,
                builder: (context, selectedPaymentMode, _) {
                  return CustomDropDownWidget(
                    title: "Payment Mode",
                    hintText: "Select Payment Mode",
                    isRequired: true,
                    initialValue: selectedPaymentMode.isNotEmpty
                        ? selectedPaymentMode.first
                        : null,
                    dataList: _paymentModeList,
                    onSelected: (value) {
                      _selectedPaymentModeNotifier.value = [value];
                    },
                    validator: (value){
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
                    initialValue: selectedPaymentType.isNotEmpty
                        ? selectedPaymentType.first
                        : null,
                    dataList: _paymentTypeList,
                    onSelected: (value) {
                      _selectedPaymentTypeNotifier.value = [value];
                    },
                    validator: (value){
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
                textController: _amountC,
                isRequired: true,
                title: "Amount",
                hint: "Enter Amount",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Amount is required";
                  }
                  return null;
                },
              ),
              CustomTextField(
                textController: _tdsAmountC,
                isRequired: true,
                title: "TDS Amount",
                hint: "Enter TDS Amount",
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
                onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
                  selectedTransactionOrChequeFile.fileNameList = fileNameList;
                  selectedTransactionOrChequeFile.fileBytesList = fileBytesList;
                  selectedTransactionOrChequeFile.deletedFileList = deletedFile;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColor.white,
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 16,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () {
              if (_formKey.currentState!.validate()) {

              }
            },
          ),
        ),
      ),
    );
  }
}
