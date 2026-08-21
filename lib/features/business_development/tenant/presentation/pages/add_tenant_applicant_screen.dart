import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/bank_list_master/data/model/bank_list_master.model.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
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
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTenantApplicantScreen extends StatefulWidget {
  final TenantApplicantData? applicant;
  final int? index;
  final bool hasPrimaryApplicant;
  const AddTenantApplicantScreen({
    super.key,
    this.applicant,
    this.index,
    this.hasPrimaryApplicant = false,
  });
  @override
  State<AddTenantApplicantScreen> createState() =>
      _AddTenantApplicantScreenState();
}

class _AddTenantApplicantScreenState extends State<AddTenantApplicantScreen> {
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<CountryCode> selectedMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  late TextEditingController _applicantNameC,
      _mobileC,
      _emailC,
      _panC,
      _aadharC,
      _passportC,
      _drivingLicenseC,
      _votingIdC,
      _gstC,
      _accountNumberC,
      _ifscCodeC;
  ValueNotifier<Map<String, dynamic>?> selectedApplicantType = ValueNotifier(
    null,
  );
  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';
  // CHECK IF APPLICANT IS EDITING
  bool get _isEditingApplicantType =>
      widget.applicant != null &&
      _isApplicantType(widget.applicant!.applicantType);
  // APPLICANT TYPE OPTIONS
  List<Map<String, dynamic>> get _applicantTypeOptions => applicantTypeList;
  // SELECTED BANK
  final ValueNotifier<List<Map<String, dynamic>>> _selectedBank = ValueNotifier(
    [],
  );
  // FILE PICKERS
  MultiFilePickerModel profilePhotoFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel aadhaarFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel panFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel passportFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel drivingLicenseFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel votingIdFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel gstFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel chequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel statementOfSourceOfFundsFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel paymentProofFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  @override
  void initState() {
    super.initState();
    _initControllers(widget.applicant);
    _prefill(widget.applicant);
  }

  @override
  void dispose() {
    _applicantNameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _aadharC.dispose();
    _panC.dispose();
    _passportC.dispose();
    _drivingLicenseC.dispose();
    _votingIdC.dispose();
    _gstC.dispose();
    _accountNumberC.dispose();
    _ifscCodeC.dispose();
    super.dispose();
  }

  void _initControllers(TenantApplicantData? applicant) {
    _applicantNameC = TextEditingController(text: applicant?.applicantName);
    _mobileC = TextEditingController(text: applicant?.applicantMobileNumber);
    _emailC = TextEditingController(text: applicant?.applicantEmailId);
    _aadharC = TextEditingController(text: applicant?.aadharCardNumber);
    _panC = TextEditingController(text: applicant?.panNumber);
    _passportC = TextEditingController(text: applicant?.passportNumber);
    _drivingLicenseC = TextEditingController(
      text: applicant?.drivingLicenseNumber,
    );
    _votingIdC = TextEditingController(text: applicant?.votingIdNumber);
    _gstC = TextEditingController(text: applicant?.gstNumber);
    _accountNumberC = TextEditingController(text: applicant?.accountNumber);
    _ifscCodeC = TextEditingController(text: applicant?.ifscCode);
  }

  void _prefill(TenantApplicantData? applicant) {
    if (applicant == null) return;
    selectedApplicantType.value = applicantTypeList.firstWhere(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          applicant.applicantType.toLowerCase(),
      orElse: () => applicantTypeList.first,
    );
    void setFileLists(MultiFilePickerModel target, String url) {
      if (url.isEmpty) {
        target.fileNameList = [];
        target.fileBytesList = [];
      } else {
        target.fileNameList = url.split(",");
      }
    }

    setFileLists(profilePhotoFile, applicant.photoURL);
    setFileLists(aadhaarFile, applicant.aadharCardURL);
    setFileLists(panFile, applicant.panCardURL);
    setFileLists(passportFile, applicant.passportURL);
    setFileLists(drivingLicenseFile, applicant.drivingLicenseURL);
    setFileLists(votingIdFile, applicant.votingIdURL);
    setFileLists(gstFile, applicant.gstNumberURL);
    setFileLists(chequeFile, applicant.chequeURL);
    if (applicant.bankListMasterId != 0 || applicant.bankName.isNotEmpty) {
      _selectedBank.value = [
        {
          "zAttributesId": applicant.bankListMasterId,
          "DisplayName": applicant.bankName,
        },
      ];
    }
  }

  Future<Map<String, dynamic>> _fetchBank(
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final selectedType = selectedApplicantType.value!['DisplayName'].toString();
    if (widget.hasPrimaryApplicant &&
        !_isEditingApplicantType &&
        _isApplicantType(selectedType)) {
      showErrorMessage(context, "", "Primary Applicant already exists");
      return;
    }
    final int bankListMasterId =
        _selectedBank.value.isNotEmpty
            ? _selectedBank.value.first['zAttributesId'] as int
            : 0;
    final String bankName =
        _selectedBank.value.isNotEmpty
            ? _selectedBank.value.first['DisplayName'].toString()
            : '';
    final applicant = TenantApplicantData(
      tenantApplicantId: widget.applicant?.tenantApplicantId ?? 0,
      tenantId: widget.applicant?.tenantId ?? 0,
      buildingId: widget.applicant?.buildingId ?? 0,
      projectId: widget.applicant?.projectId ?? 0,
      applicantType: selectedApplicantType.value!['DisplayName'],
      applicantName: _applicantNameC.text.trim(),
      applicantMobileNumber: _mobileC.text,
      applicantMobileNumberCountryCode: selectedMobileNoCountry.value.code,
      applicantEmailId: _emailC.text.trim(),
      photoURL:
          profilePhotoFile.fileNameList.isNotEmpty
              ? profilePhotoFile.fileNameList.join(",")
              : '',
      aadharCardURL:
          aadhaarFile.fileNameList.isNotEmpty
              ? aadhaarFile.fileNameList.join(",")
              : '',
      aadharCardNumber: _aadharC.text.trim(),
      panNumber: _panC.text.trim(),
      panCardURL:
          panFile.fileNameList.isNotEmpty ? panFile.fileNameList.join(",") : '',
      passportNumber: _passportC.text.trim(),
      passportURL:
          passportFile.fileNameList.isNotEmpty
              ? passportFile.fileNameList.join(",")
              : '',
      drivingLicenseNumber: _drivingLicenseC.text.trim(),
      drivingLicenseURL:
          drivingLicenseFile.fileNameList.isNotEmpty
              ? drivingLicenseFile.fileNameList.join(",")
              : '',
      votingIdNumber: _votingIdC.text.trim(),
      votingIdURL:
          votingIdFile.fileNameList.isNotEmpty
              ? votingIdFile.fileNameList.join(",")
              : '',
      gstNumber: _gstC.text.trim(),
      gstNumberURL:
          gstFile.fileNameList.isNotEmpty ? gstFile.fileNameList.join(",") : '',
      chequeURL:
          chequeFile.fileNameList.isNotEmpty
              ? chequeFile.fileNameList.join(",")
              : '',
      bankListMasterId: bankListMasterId,
      bankName: bankName,
      accountNumber: _accountNumberC.text.trim(),
      ifscCode: _ifscCodeC.text.trim(),
      createdById: widget.applicant?.createdById ?? -1,
      createdBy: widget.applicant?.createdBy ?? '',
      createdDate: widget.applicant?.createdDate ?? DateTime.now(),
      modifiedById: widget.applicant?.modifiedById ?? -1,
      modifiedBy: widget.applicant?.modifiedBy ?? '',
      modifiedDate: DateTime.now(),
      lastModifiedBy: '',
      lastModifiedDate: null,
    );
    applicant.profilePhotoImage = profilePhotoFile;
    applicant.aadhaarImage = aadhaarFile;
    applicant.panImage = panFile;
    applicant.passportImage = passportFile;
    applicant.drivingLicenseImage = drivingLicenseFile;
    applicant.votingIdImage = votingIdFile;
    applicant.gstImage = gstFile;
    applicant.chequeImage = chequeFile;
    goRouter.pop({"applicant": applicant, "index": widget.index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.applicant == null
                        ? "Add Applicant"
                        : "Update Applicant",
                    style: AppTextStyle.ts16SB(color: AppColor.black),
                  ),
                  verticalSpacing(),
                  ValueListenableBuilder(
                    valueListenable: selectedApplicantType,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: "Applicant Type",
                        hintText: "Select Applicant Type",
                        isRequired: true,
                        initialValue: selectedApplicantType.value,
                        dataList: _applicantTypeOptions,
                        onSelected:
                            (value) => selectedApplicantType.value = value,
                        validator: (value) {
                          if (value == null || value['zAttributesId'] == -1) {
                            return "Applicant Type is required";
                          }
                          return null;
                        },
                        onValueClear: () => selectedApplicantType.value = null,
                      );
                    },
                  ),
                  if (widget.hasPrimaryApplicant && !_isEditingApplicantType)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        "Applicant already added. Use another type or edit the existing Applicant.",
                        style: AppTextStyle.ts12R(color: AppColor.grey),
                      ),
                    ),
                  CustomTextField(
                    title: 'Applicant Name',
                    isRequired: true,
                    hint: "Enter Applicant Name",
                    textController: _applicantNameC,
                    inputFormatterList: InputValidator.textOnly(100),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Applicant Name is required";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: selectedMobileNoCountry,
                    builder: (context, value, child) {
                      return CustomTextField(
                        title: "Mobile Number",
                        textController: _mobileC,
                        hint: "Enter Mobile Number",
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        showCountryDropdown: true,
                        selectedCountry: value,
                        onCountryChanged: (country) {
                          if (country == null) return;
                          selectedMobileNoCountry.value = country;
                        },
                        inputFormatterList: [
                          LengthLimitingTextInputFormatter(value.mobileLength),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          final mobile = value?.trim() ?? "";
                          final country = selectedMobileNoCountry.value;
                          if (value == null || value.isEmpty) {
                            return "Mobile Number is required";
                          }
                          if (mobile.isNotEmpty) {
                            if ((mobile.length != country.mobileLength) ||
                                country.regex != null &&
                                    !country.regex!.hasMatch(mobile)) {
                              return "Invalid Mobile Number";
                            }
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  CustomTextField(
                    title: 'Email Id',
                    hint: "Enter Email Id",
                    textController: _emailC,
                    inputFormatterList: InputValidator.emailInputFormatters(),
                  ),
                  CustomMultiFilePicker(
                    title: "Profile Photo",
                    filePickType: FilePickType.image,
                    initialFileList: profilePhotoFile.fileNameList,
                    initialFileBytes: profilePhotoFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      profilePhotoFile.fileNameList = fileNameList;
                      profilePhotoFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      profilePhotoFile.fileBytesList = fileBytesList;
                      profilePhotoFile.fileNameList = fileNameList;
                      profilePhotoFile.deletedFileList = deleted;
                    },
                  ),
                  CustomTextField(
                    title: 'Aadhaar Card Number',
                    hint: "Enter Aadhaar Card Number",
                    isRequired: true,
                    textController: _aadharC,
                    keyboardType: TextInputType.number,
                    inputFormatterList:
                        InputValidator.aadhaarNumberInputFormatter(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Aadhaar Card Number is required";
                      }
                      if (value.trim().isNotEmpty &&
                          !InputValidator.isValidAadharNumber(value.trim())) {
                        return "Invalid Aadhaar Card Number";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Aadhaar Card",
                    filePickType: FilePickType.kycDocument,
                    isRequired: true,
                    initialFileList: aadhaarFile.fileNameList,
                    initialFileBytes: aadhaarFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      aadhaarFile.fileNameList = fileNameList;
                      aadhaarFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      aadhaarFile.fileBytesList = fileBytesList;
                      aadhaarFile.fileNameList = fileNameList;
                      aadhaarFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (fileList == null || fileList.isEmpty) {
                        return "Aadhaar Card document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'PAN Number',
                    hint: "Enter PAN Number",
                    isRequired: true,
                    textController: _panC,
                    inputFormatterList: InputValidator.panInputFormatters(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "PAN Number is required";
                      }
                      if (!InputValidator.isValidPAN(value)) {
                        return "PAN Number is invalid";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "PAN Card",
                    isRequired: true,
                    filePickType: FilePickType.kycDocument,
                    initialFileList: panFile.fileNameList,
                    initialFileBytes: panFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      panFile.fileNameList = fileNameList;
                      panFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      panFile.fileBytesList = fileBytesList;
                      panFile.fileNameList = fileNameList;
                      panFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (fileList == null || fileList.isEmpty) {
                        return "PAN Card document is required";
                      }
                      if (_panC.text.isNotEmpty &&
                          InputValidator.isValidPAN(_panC.text.trim()) &&
                          (fileList.isEmpty)) {
                        return "PAN Card document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Passport Number',
                    hint: "Enter Passport Number",
                    textController: _passportC,
                    inputFormatterList:
                        InputValidator.passportInputFormatters(),
                    validator: (value) {
                      if (passportFile.fileNameList.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return "Passport Number is required";
                        }
                        if (!InputValidator.isValidPassport(value)) {
                          return "Passport Number is invalid";
                        }
                      } else {
                        if (value != null &&
                            value.isNotEmpty &&
                            !InputValidator.isValidPassport(value)) {
                          return "Passport Number is invalid";
                        }
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Passport Document",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: passportFile.fileNameList,
                    initialFileBytes: passportFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      passportFile.fileNameList = fileNameList;
                      passportFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      passportFile.fileBytesList = fileBytesList;
                      passportFile.fileNameList = fileNameList;
                      passportFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (_passportC.text.isNotEmpty &&
                          InputValidator.isValidPassport(
                            _passportC.text.trim(),
                          ) &&
                          (fileList == null || fileList.isEmpty)) {
                        return "Passport document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Driving License Number',
                    hint: "Enter Driving License Number",
                    textController: _drivingLicenseC,
                    inputFormatterList:
                        InputValidator.drivingLicenceInputFormatters(),
                    validator: (value) {
                      if (drivingLicenseFile.fileNameList.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return "Driving License Number is required";
                        }
                        if (!InputValidator.isValidDrivingLicence(value)) {
                          return "Driving License Number invalid";
                        }
                      } else {
                        if (value != null &&
                            value.isNotEmpty &&
                            !InputValidator.isValidDrivingLicence(value)) {
                          return "Driving License Number is invalid";
                        }
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Driving License Document",
                    filePickType: FilePickType.kycDocument,
                    initialFileBytes: drivingLicenseFile.fileBytesList,
                    initialFileList: drivingLicenseFile.fileNameList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      drivingLicenseFile.fileNameList = fileNameList;
                      drivingLicenseFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      drivingLicenseFile.fileBytesList = fileBytesList;
                      drivingLicenseFile.fileNameList = fileNameList;
                      drivingLicenseFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (_drivingLicenseC.text.isNotEmpty &&
                          InputValidator.isValidDrivingLicence(
                            _drivingLicenseC.text.trim(),
                          ) &&
                          (fileList == null || fileList.isEmpty)) {
                        return "Driving License document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Voting ID Number',
                    textController: _votingIdC,
                    hint: "Enter Voting ID Number",
                    inputFormatterList: InputValidator.voterIdInputFormatters(),
                    validator: (value) {
                      if (votingIdFile.fileNameList.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return "Voting Id is required";
                        }
                        if (!InputValidator.isValidVoterId(value)) {
                          return "Voting Id is invalid";
                        }
                      } else {
                        if (value != null &&
                            value.isNotEmpty &&
                            !InputValidator.isValidVoterId(value)) {
                          return "Voting Id is invalid";
                        }
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Voting ID Document",
                    filePickType: FilePickType.kycDocument,
                    initialFileBytes: votingIdFile.fileBytesList,
                    initialFileList: votingIdFile.fileNameList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      votingIdFile.fileNameList = fileNameList;
                      votingIdFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      votingIdFile.fileBytesList = fileBytesList;
                      votingIdFile.fileNameList = fileNameList;
                      votingIdFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (_votingIdC.text.isNotEmpty &&
                          InputValidator.isValidVoterId(
                            _votingIdC.text.trim(),
                          ) &&
                          (fileList == null || fileList.isEmpty)) {
                        return "Voting Id document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'GST Number',
                    textController: _gstC,
                    hint: "Enter GST Number",
                    inputFormatterList: InputValidator.gstInputFormatters(),
                    validator: (value) {
                      if (gstFile.fileNameList.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return "GST Number is required";
                        }
                        if (!InputValidator.isValidGST(value)) {
                          return "GST Number is invalid";
                        }
                      } else {
                        if (value != null &&
                            value.isNotEmpty &&
                            !InputValidator.isValidGST(value)) {
                          return "GST Number is invalid";
                        }
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "GST Certificate",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: gstFile.fileNameList,
                    initialFileBytes: gstFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      gstFile.fileNameList = fileNameList;
                      gstFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      gstFile.fileBytesList = fileBytesList;
                      gstFile.fileNameList = fileNameList;
                      gstFile.deletedFileList = deleted;
                    },
                    validator: (fileList) {
                      if (_gstC.text.isNotEmpty &&
                          InputValidator.isValidGST(_gstC.text.trim()) &&
                          (fileList == null || fileList.isEmpty)) {
                        return "GST Certificate document is required";
                      }
                      return null;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedBank,
                    builder: (context, bank, child) {
                      return CustomMultipleSelectPopup(
                        title: 'Bank',
                        hintText: "Select Bank",
                        isMultiSelect: false,
                        initialValue: bank,
                        dataList: const [],
                        onSelected: (value) {
                          _selectedBank.value = value;
                        },
                        dataFetchCallBack: _fetchBank,
                      );
                    },
                  ),
                  CustomTextField(
                    title: 'Account Number',
                    hint: "Enter account number",
                    textController: _accountNumberC,
                    inputFormatterList: InputValidator.digit(19),
                  ),
                  CustomTextField(
                    title: 'IFSC Code',
                    hint: "Enter IFSC Code",
                    textController: _ifscCodeC,
                    inputFormatterList: InputValidator.ifscInputFormatters(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (!InputValidator.isValidIFSC(value)) {
                        return 'Enter a valid IFSC Code';
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Cancelled Cheque",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: chequeFile.fileNameList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      chequeFile.fileNameList = fileNameList;
                      chequeFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      chequeFile.fileBytesList = fileBytesList;
                      chequeFile.fileNameList = fileNameList;
                      chequeFile.deletedFileList = deleted;
                    },
                  ),
                  verticalSpacing(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              _isEditingApplicantType ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditingApplicantType ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
