import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/data/model/loan_details.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/loan_details/presentation/cubit/loan_details_cubit.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddActiveBankScreen extends StatefulWidget {
  final int bookingId;
  final int projectId;
  final BookingLoanDetailsModel? details;
  final int? index;
  const AddActiveBankScreen({
    super.key,
    this.details,
    this.index = 0,
    required this.bookingId,
    required this.projectId,
  });

  @override
  State<AddActiveBankScreen> createState() => _AddActiveBankScreenState();
}

class _AddActiveBankScreenState extends State<AddActiveBankScreen> {
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // DROPDOWN NOTIFIERS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  late TextEditingController _bankBranchNameC,
      _accountNumberC,
      _loanSanctionAmountC,
      _addressC;
  DateTime? sanctionDate;
  // EDIT MODE
  bool get _isEditMode => widget.details != null;
  late LoanDetailsCubit _loanDetailsCubit;
  @override
  void initState() {
    super.initState();
    _loanDetailsCubit = context.read<LoanDetailsCubit>();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _initializeControllers();
    if (_isEditMode) {
      _populateFormFields(widget.details!);
    }
  }

  void _initializeControllers() {
    _bankBranchNameC = TextEditingController();
    _accountNumberC = TextEditingController();
    _loanSanctionAmountC = TextEditingController();
    _addressC = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _selectedBankNotifier.dispose();
    _bankBranchNameC.dispose();
    _accountNumberC.dispose();
    _loanSanctionAmountC.dispose();
    _addressC.dispose();
  }

  void _populateFormFields(BookingLoanDetailsModel details) {
    _selectedBankNotifier.value = [
      {
        "zAttributesId": details.bankListMasterId,
        "DisplayName": details.bankName,
      },
    ];
    _bankBranchNameC.text = details.bankBranchName;
    _accountNumberC.text = details.loanAccountNumber;
    _loanSanctionAmountC.text = details.loanSanctionAmount.toString();
    sanctionDate = details.loanSanctionDate;
    _addressC.text = details.address;
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
    if (_isEditMode && widget.details != null) {
      _loanDetailsCubit.updateBankLoanDetails(
        context: context,
        bookingLoanDetailsId: widget.details!.bookingLoanDetailsId,
        uniqueKey: widget.details!.uniquekey,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        loanSanctionAmount: _loanSanctionAmountC.text,
        loanSanctionDate: sanctionDate!.toIso8601String(),
        bankListMasterId: _selectedBankNotifier.value.first['zAttributesId'],
        loanAccountNumber: _accountNumberC.text.trim(),
        bankBranchName: _bankBranchNameC.text.trim(),
        address: _addressC.text.trim(),
        index: widget.index!,
      );
    } else {
      _loanDetailsCubit.addBankLoanDetails(
        context: context,
        projectId: widget.projectId,
        bookingId: widget.bookingId,
        bankListMasterId: _selectedBankNotifier.value.first['zAttributesId'],
        loanSanctionAmount: _loanSanctionAmountC.text,
        loanSanctionDate: sanctionDate!.toIso8601String(),
        loanAccountNumber: _accountNumberC.text,
        bankBranchName: _bankBranchNameC.text,
        address: _addressC.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Bank" : "Add Bank",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bank Details",
                  style: AppTextStyle.ts14M(
                    color: AppColor.black.withValues(alpha: 0.5),
                  ),
                ),
                verticalSpacing(),
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
                  textController: _bankBranchNameC,
                  title: "Branch Name",
                  hint: "Enter Bank Branch Name",
                  isRequired: true,
                  inputFormatterList: [LengthLimitingTextInputFormatter(200)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Bank Branch Name is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _accountNumberC,
                  title: "Account Number",
                  hint: "Enter Account Number",
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
                  textController: _loanSanctionAmountC,
                  title: "Loan Sanction Amount (₹)",
                  hint: "Enter Loan Sanction Amount",
                  isRequired: true,
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatterList: InputValidator.decimal(2),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Loan Sanction Amount is required";
                    }
                    return null;
                  },
                ),
                CustomDatePicker(
                  title: "Santion Date",
                  isRequired: true,
                  initialDate: sanctionDate,
                  setValue: (value) => sanctionDate = value,
                  validator: (value) {
                    if (value == null) {
                      return 'Santion Date is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  textController: _addressC,
                  title: "Address",
                  hint: "Enter Address",
                  minLines: 3,
                  maxLines: 10,
                  isRequired: true,
                  inputFormatterList: [LengthLimitingTextInputFormatter(200)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Address is required";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
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
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
