import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/model/company_bank.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddCompanyBankDetailsScreen extends StatefulWidget {
  final CompanyBankModel? bankDetailsModel;
  final int? index;
  const AddCompanyBankDetailsScreen({
    super.key,
    this.bankDetailsModel,
    this.index,
  });

  @override
  State<AddCompanyBankDetailsScreen> createState() =>
      _AddCompanyBankDetailsScreenState();
}

class _AddCompanyBankDetailsScreenState
    extends State<AddCompanyBankDetailsScreen> {
  late CompanyMasterCubit _companyMasterCubit;
  final _formKey = GlobalKey<FormState>();

  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  // TEXT CONTROLLERS
  late TextEditingController _beneficiaryAccountHolderNameC,
      _accountNumberC,
      _branchC,
      _ifscCodeC,
      _micrCodeC;

  // DROPDOWN VARIABLES
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedBankNotifier;
  ValueNotifier<Map<String, dynamic>?> selectedAccountType = ValueNotifier(
    null,
  );
  ValueNotifier<Map<String, dynamic>?> selectedNatureOfAccount = ValueNotifier(
    null,
  );
  ValueNotifier<Map<String, dynamic>?> selectedStatus = ValueNotifier(null);
  bool get _isEditMode => widget.bankDetailsModel != null;
  MultiFilePickerModel cancelChequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();
    _companyMasterCubit = context.read<CompanyMasterCubit>();
    _selectedBankNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _initializeTextControllers();
    if (_isEditMode) {
      _populateFormFields(widget.bankDetailsModel!);
    }
    _initializeDropdowns();
  }

  @override
  void dispose() {
    _beneficiaryAccountHolderNameC.dispose();
    _selectedBankNotifier.dispose();
    _accountNumberC.dispose();
    _branchC.dispose();
    _ifscCodeC.dispose();
    _micrCodeC.dispose();
    super.dispose();
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextControllers() {
    _beneficiaryAccountHolderNameC = TextEditingController();
    _accountNumberC = TextEditingController();
    _branchC = TextEditingController();
    _ifscCodeC = TextEditingController();
    _micrCodeC = TextEditingController();
  }

  void _populateFormFields(CompanyBankModel bankDetails) {
    _beneficiaryAccountHolderNameC.text =
        bankDetails.beneficiaryAccountHolderName;
    _accountNumberC.text = bankDetails.accountNumber;
    _branchC.text = bankDetails.branch;
    _ifscCodeC.text = bankDetails.ifscCode;
    _selectedBankNotifier.value = [
      {
        'zAttributesId': bankDetails.bankListMasterId,
        'DisplayName': bankDetails.bankName,
      },
    ];

    final acType = bankDetails.acType.toLowerCase();
    selectedAccountType.value = accountTypeList.firstWhere(
      (acT) =>
          acT['DisplayName'].toString().toLowerCase() == acType.toLowerCase(),
      orElse: () => accountTypeList[0],
    );
    if (bankDetails.natureOfAccount != "") {
      selectedNatureOfAccount.value = natureOfAccountList.firstWhere(
        (nature) =>
            nature['DisplayName'].toString().toLowerCase() ==
            bankDetails.natureOfAccount.toLowerCase(),
        orElse: () => natureOfAccountList[0],
      );
    }
    _micrCodeC.text = bankDetails.mICRCode;
    if (bankDetails.status != "") {
      selectedStatus.value = statusList.firstWhere(
        (status) =>
            status['DisplayName'].toString().toLowerCase() ==
            bankDetails.status.toLowerCase(),
        orElse: () => statusList[0],
      );
    }
    cancelChequeFile.fileNameList =
        bankDetails.cancelChequeURL.isEmpty
            ? []
            : bankDetails.cancelChequeURL.split(',');
  }

  // INITIALISING DROPDOWN
  void _initializeDropdowns() {
    if (widget.bankDetailsModel != null) {
      _selectedBankNotifier.value = [
        {
          'zAttributesId': widget.bankDetailsModel!.bankListMasterId,
          'DisplayName': widget.bankDetailsModel!.bankName,
        },
      ];

      final acType = widget.bankDetailsModel!.acType.toLowerCase();
      selectedAccountType.value = accountTypeList.firstWhere(
        (acT) =>
            acT['DisplayName'].toString().toLowerCase() == acType.toLowerCase(),
        orElse: () => accountTypeList[0],
      );
      if (widget.bankDetailsModel?.natureOfAccount != "") {
        selectedNatureOfAccount.value = natureOfAccountList.firstWhere(
          (nature) =>
              nature['DisplayName'].toString().toLowerCase() ==
              widget.bankDetailsModel?.natureOfAccount.toLowerCase(),
          orElse: () => natureOfAccountList[0],
        );
      }
    } else {
      _selectedBankNotifier.value.isNotEmpty;
    }
  }

  // HANDLE SUBMIT
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankNotifier.value.isEmpty) {
      showErrorMessage(context, "Error", "Please select a bank");
      return;
    }

    if (selectedAccountType.value == null ||
        selectedAccountType.value!['zAttributesId'] == -1) {
      showErrorMessage(context, "Error", "Please select an account type");
      return;
    }

    await _companyMasterCubit.addUpdateCompanyWithBankDetails(
      companyWithBankDetailsId:
          widget.bankDetailsModel?.companyWithBankDetailsId ?? 0,
      companyId: _companyMasterCubit.state.companyOverview!.companyId,
      index: widget.index,
      uniqueKey: widget.bankDetailsModel?.uniquekey,
      beneficiaryAccountHolderName: _beneficiaryAccountHolderNameC.text,
      bankListMasterId: _selectedBankNotifier.value.first['zAttributesId'],
      accountNumber: _accountNumberC.text,
      branch: _branchC.text,
      ifscCode: _ifscCodeC.text,
      natureOfAccount: selectedNatureOfAccount.value!['DisplayName'],
      accountType: selectedAccountType.value!['DisplayName'],
      context: context,
      cancelChequeFile: cancelChequeFile,
      micrCode: _micrCodeC.text,
      status: selectedStatus.value!['DisplayName'],
    );
  }

  // FETCH BANKS
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
        screenTitle: "Bank Details",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  _isEditMode ? "Update Bank Details" : "Add Bank Details",
                  style: AppTextStyle.ts14M(),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
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
                            return "Beneficiary Account Holder Name is required.";
                          }
                          return null;
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedBankNotifier,
                        builder: (context, selectedEmployee, _) {
                          return CustomMultipleSelectPopup(
                            title: 'Bank',
                            hintText: "Select Bank",
                            isRequired: true,
                            isMultiSelect: false,
                            initialValue: selectedEmployee,
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
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: selectedAccountType,
                        builder: (context, selectedAccountT, child) {
                          return CustomDropDownWidget(
                            title: "Account Type",
                            hintText: "Select Account Type",
                            isRequired: true,
                            initialValue: selectedAccountT,
                            dataList: accountTypeList,
                            onSelected: (value) {
                              selectedAccountType.value = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value['zAttributesId'] == -1) {
                                return 'Account Type is required.';
                              }
                              return null;
                            },
                            onValueClear: () {
                              selectedAccountType.value = null;
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: selectedNatureOfAccount,
                        builder: (context, selectedAccountT, child) {
                          return CustomDropDownWidget(
                            title: "Nature of Account",
                            hintText: "Select Nature of Account",
                            isRequired: true,
                            initialValue: selectedAccountT,
                            dataList: natureOfAccountList,
                            onSelected: (value) {
                              selectedNatureOfAccount.value = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value['zAttributesId'] == -1) {
                                return 'Nature of Account is required.';
                              }
                              return null;
                            },
                            onValueClear: () {
                              selectedNatureOfAccount.value = null;
                            },
                          );
                        },
                      ),

                      CustomTextField(
                        title: "Account Number",
                        textController: _accountNumberC,
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
                      ),
                      CustomTextField(
                        title: "Branch Name",
                        textController: _branchC,
                        hint: "Enter Branch Name",
                        isRequired: true,
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Bank Branch Name is required.";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: "IFSC Code",
                        textController: _ifscCodeC,
                        hint: "Enter IFSC Code",
                        isRequired: true,
                        inputFormatterList:
                            InputValidator.ifscInputFormatters(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "IFSC Code is required.";
                          }
                          if (value.trim().length != 11) {
                            return "IFSC Code must be 11 characters";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: "MICR Code",
                        textController: _micrCodeC,
                        hint: "Enter MICR Code",
                        isRequired: true,
                        inputFormatterList: InputValidator.digit(10),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "MICR Code is required.";
                          }
                          if (value.trim().length != 10) {
                            return "MICR Code must be at most 10 Digit";
                          }
                          return null;
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: selectedStatus,
                        builder: (context, selectedStatusT, child) {
                          return CustomDropDownWidget(
                            title: "Status",
                            hintText: "Select Status",
                            isRequired: true,
                            initialValue: selectedStatusT,
                            dataList: statusList,
                            onSelected: (value) {
                              selectedStatus.value = value;
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Status is required.';
                              }
                              return null;
                            },
                            onValueClear: () {
                              selectedStatus.value = null;
                            },
                          );
                        },
                      ),
                      CustomMultiFilePicker(
                        // readOnly: !_routeAuthorizationModel.isAction,
                        initialFileList: cancelChequeFile.fileNameList,
                        title: "Cancel Cheque",
                        isRequired: true,
                        filePickType: FilePickType.kycDocument,
                        onFilePickedCallback: (fileByteList, fileNameList) {
                          cancelChequeFile.fileBytesList = fileByteList;
                          cancelChequeFile.fileNameList = fileNameList;
                        },
                        onFileDeleteCallback: (
                          fileBytesList,
                          fileNameList,
                          deletedUrl,
                        ) {
                          cancelChequeFile.fileBytesList = fileBytesList;
                          cancelChequeFile.fileNameList = fileNameList;
                          cancelChequeFile.deletedFileList = deletedUrl;
                        },
                        validator: (value) {
                          if ((value == null || value.isEmpty)) {
                            return "Cancel Cheque is required.";
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
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text:
                widget.bankDetailsModel == null
                    ? "Save Bank Details"
                    : "Update Bank Details",
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
