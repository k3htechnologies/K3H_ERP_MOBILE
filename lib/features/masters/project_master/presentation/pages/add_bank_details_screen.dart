import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/bank_details.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/project_master/presentation/cubit/project_master_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_paginated_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBankDetailsScreen extends StatefulWidget {
  final BankDetailsModel? bankDetailsModel;
  final ProjectModel project;
  const AddBankDetailsScreen({
    super.key,
    this.bankDetailsModel,
    required this.project,
  });

  @override
  State<AddBankDetailsScreen> createState() => _AddBankDetailsScreenState();
}

class _AddBankDetailsScreenState extends State<AddBankDetailsScreen> {
  late ProjectMasterCubit _projectMasterCubit;
  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  late TextEditingController _beneficiaryAccountHolderNameC;
  late TextEditingController _accountNumberC;
  late TextEditingController _branchC;
  late TextEditingController _ifscCodeC;

  // DROPDOWN VARIABLES
  Map<String, dynamic>? selectedBank;
  Map<String, dynamic>? selectedAccountType;

  // ACCOUNT TYPE LIST
  final List<Map<String, dynamic>> accountTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Current"},
    {"zAttributesId": 2, "DisplayName": "DEMAT"},
    {"zAttributesId": 3, "DisplayName": "Fixed"},
    {"zAttributesId": 4, "DisplayName": "Salary"},
    {"zAttributesId": 5, "DisplayName": "Savings"},
  ];

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _initializeDropdowns();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _projectMasterCubit = context.read<ProjectMasterCubit>();
  }

  @override
  void dispose() {
    _beneficiaryAccountHolderNameC.dispose();
    _accountNumberC.dispose();
    _branchC.dispose();
    _ifscCodeC.dispose();
    super.dispose();
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextControllers() {
    _beneficiaryAccountHolderNameC = TextEditingController(
      text: widget.bankDetailsModel?.beneficiaryAccountHolderName ?? '',
    );
    _accountNumberC = TextEditingController(
      text: widget.bankDetailsModel?.accountNumber ?? '',
    );
    _branchC = TextEditingController(
      text: widget.bankDetailsModel?.branch ?? '',
    );
    _ifscCodeC = TextEditingController(
      text: widget.bankDetailsModel?.ifscCode ?? '',
    );
  }

  // INITIALISING DROPDOWN
  void _initializeDropdowns() {
    if (widget.bankDetailsModel != null) {
      selectedBank = {
        'zAttributesId': widget.bankDetailsModel!.bankListMasterId,
        'DisplayName': widget.bankDetailsModel!.bankName,
      };

      final acType = widget.bankDetailsModel!.acType.toLowerCase();
      if (acType.contains('current')) {
        selectedAccountType = accountTypeList[1]; // Current
      } else if (acType.contains('demat')) {
        selectedAccountType = accountTypeList[2]; // DEMAT
      } else if (acType.contains('fixed')) {
        selectedAccountType = accountTypeList[3]; // Fixed
      } else if (acType.contains('salary')) {
        selectedAccountType = accountTypeList[4]; // Salary
      } else if (acType.contains('savings')) {
        selectedAccountType = accountTypeList[5]; // Savings
      } else {
        selectedAccountType = accountTypeList[0]; // Select
      }
    } else {
      selectedBank = null;
      selectedAccountType = accountTypeList[0];
    }
  }

  // HANDLE SUBMIT
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedBank == null || selectedBank!['zAttributesId'] == -1) {
      showErrorMessage(context, "Error", "Please select a bank");
      return;
    }

    if (selectedAccountType == null ||
        selectedAccountType!['zAttributesId'] == -1) {
      showErrorMessage(context, "Error", "Please select an account type");
      return;
    }

    Map<String, dynamic> bankRequestBody = {
      "ProjectWithBankDetailsId":
          widget.bankDetailsModel?.projectWithBankDetailsId ?? 0,
      if (widget.bankDetailsModel?.uniquekey != null)
        "Uniquekey": widget.bankDetailsModel?.uniquekey,
      "ProjectId": widget.project.projectId,
      "BeneficiaryAccountHolderName":
          _beneficiaryAccountHolderNameC.text.trim(),
      "BankListMasterId": selectedBank!['zAttributesId'],
      "AccountNumber": _accountNumberC.text.trim(),
      "Branch": _branchC.text.trim(),
      "IFSCCode": _ifscCodeC.text.trim(),
      "AcType": selectedAccountType!['DisplayName'],
    };

    await _projectMasterCubit.addUpdateProjectWithBankDetails(
      bankRequestBody: bankRequestBody,
      projectId: widget.project.projectId.toString(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            widget.bankDetailsModel == null
                ? "Add Bank Details"
                : "Update Bank Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Beneficiary Account Holder Name",
                  textController: _beneficiaryAccountHolderNameC,
                  hint: "Enter Account Holder Name",
                  isRequired: true,
                  inputFormatterList: InputValidator.textOnly(100),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Account Holder Name is required";
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomPaginationDropDownWidget(
                  title: "Bank Name",
                  isRequired: true,
                  initialValue: selectedBank,
                  dataFetchCallBack: (int pageNumber, {String? value}) async {
                    return await _projectMasterCubit.getBankList(
                      pageNumber,
                      value: value,
                    );
                  },
                  onSelected: (value) {
                    setState(() {
                      selectedBank = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return 'Bank Name is required';
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomDropDownWidget(
                  title: "Account Type",
                  isRequired: true,
                  initialValue: selectedAccountType,
                  dataList: accountTypeList,
                  onSelected: (value) {
                    setState(() {
                      selectedAccountType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return 'Account Type is required';
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Account Number",
                  textController: _accountNumberC,
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
                verticalSpacing(),
                CustomTextField(
                  title: "Branch Name",
                  textController: _branchC,
                  hint: "Enter Branch Name",
                  isRequired: true,
                  inputFormatterList: InputValidator.textOnly(100),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Branch is required";
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "IFSC Code",
                  textController: _ifscCodeC,
                  hint: "Enter IFSC Code",
                  isRequired: true,
                  inputFormatterList: [
                    LengthLimitingTextInputFormatter(11),
                    UpperCaseTextFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "IFSC Code is required";
                    }
                    if (value.trim().length != 11) {
                      return "IFSC Code must be 11 characters";
                    }
                    return null;
                  },
                ),
                verticalSpacing(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: widget.bankDetailsModel == null ? "Add" : "Update",
            onPressed: _handleSubmit,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }
}

// Custom text formatter for uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
