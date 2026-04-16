import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/model/brokerage_invoice.model.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBrokerageInvoiceScreen extends StatefulWidget {
  final BrokerageInvoiceModel? brokerageInvoiceModel;
  const AddBrokerageInvoiceScreen({super.key, this.brokerageInvoiceModel});

  @override
  State<AddBrokerageInvoiceScreen> createState() =>
      _AddBrokerageInvoiceScreenState();
}

class _AddBrokerageInvoiceScreenState extends State<AddBrokerageInvoiceScreen> {
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _invoiceNumberC,
      _accountNameC,
      _accountNumberC,
      _ifscCodeC,
      _invoiceAmountC,
      _remarkC;

  // INVOICE DATE
  DateTime? invoiceDate;
  DateTime? dueDate;

  // DROPDOWN NOTIFIERS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;

  // EDIT MODE
  bool get _isEditMode => widget.brokerageInvoiceModel != null;

  @override
  void initState() {
    super.initState();
    _initializeTextEditingControllers();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
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

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextEditingControllers() {
    _invoiceNumberC = TextEditingController();
    _accountNameC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _invoiceAmountC = TextEditingController();
    _remarkC = TextEditingController();
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
        screenTitle: "Brokerage Invoice",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              _isEditMode
                  ? "Update Brokerage Invoice"
                  : "Add Brokerage Invoice",
              style: AppTextStyle.ts16SB(),
            ),
            verticalSpacing(),
            CustomTextField(
              title: "Invoice Number",
              hint: "Enter Invoice Number",
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invoice Number is required";
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
                  return 'Invoice Date is required';
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
                  onClear: (){
                    _selectedBankNotifier.value = [];
                  },
                );
              },
            ),
            CustomTextField(
              title: "Account Name",
              hint: "Enter Account Name",
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Account Name is required";
                }
                return null;
              },
              textController: _accountNameC,
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
            CustomTextField(
              title: "Invoice Amount",
              hint: "Enter Invoice Amount",
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Invoice Amount is required";
                }
                return null;
              },
              textController: _invoiceAmountC,
            ),
            CustomDatePicker(
              title: 'Due Date',
              isRequired: true,
              initialDate: dueDate,
              setValue: (value) => dueDate = value,
              validator: (value) {
                if (value == null) {
                  return 'Due Date is required';
                }
                return null;
              },
            ),
            CustomTextField(
              title: "Remark",
              hint: "Enter Remark",
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Remark is required";
                }
                return null;
              },
              textController: _remarkC,
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
            text: _isEditMode ? "Update Invoice" : "Add Invoice",
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
