import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBookingApplicantScreen extends StatefulWidget {
  final BookingApplicantData? applicant;
  final int? index;
  final bool hasPrimaryApplicant;
  const AddBookingApplicantScreen({
    super.key,
    this.applicant,
    this.index,
    this.hasPrimaryApplicant = false,
  });

  @override
  State<AddBookingApplicantScreen> createState() =>
      _AddBookingApplicantScreenState();
}

class _AddBookingApplicantScreenState extends State<AddBookingApplicantScreen> {
  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  late TextEditingController _applicantNameC,
      _mobileC,
      _emailC,
      _panC,
      _aadharC,
      _passportC,
      _drivingLicenseC,
      _votingIdC,
      _gstC;

  // APPLICANT TYPE LIST
  final List<Map<String, dynamic>> applicantTypeList = const [
    {"zAttributesId": 1, "DisplayName": "Applicant"},
    {"zAttributesId": 2, "DisplayName": "Co-Applicant"},
  ];

  // SELECTED APPLICANT TYPE
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
  bool get isEditMode => widget.applicant != null;
  // APPLICANT TYPE OPTIONS
  List<Map<String, dynamic>> get _applicantTypeOptions => applicantTypeList;

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

  MultiFilePickerModel cancelledChequeFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel poaFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel incomeForm16ItrFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel nreNroBankDetailsFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel nomineeFormFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel statementOfSourceOfFundFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel paymentProofURLFundFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  ValueNotifier<CountryCode> selectedMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
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
    super.dispose();
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initControllers(BookingApplicantData? applicant) {
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
  }

  // PREFILL APPLICANT DETAILS
  void _prefill(BookingApplicantData? applicant) {
    if (applicant == null) return;
    selectedApplicantType.value = applicantTypeList.firstWhere(
      (e) =>
          e['DisplayName'].toString().toLowerCase() ==
          applicant.applicantType.toLowerCase(),
      orElse: () => applicantTypeList.first,
    );
    if (applicant.applicantMobileNumberCountryCode.isNotEmpty) {
      selectedMobileNoCountry.value = countryList.firstWhere(
        (e) => e.code == applicant.applicantMobileNumberCountryCode,
        orElse:
            () => CountryCode(
              name: "India",
              code: "+91",
              countryCode: "IN",
              mobileLength: 10,
              regex: RegExp(r'^[6-9]\d{9}$'),
            ),
      );
    }

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
    setFileLists(cancelledChequeFile, applicant.cancelledChequeUrl);
    setFileLists(poaFile, applicant.poaurl);
    setFileLists(incomeForm16ItrFile, applicant.incomeForm16Itrurl);
    setFileLists(nreNroBankDetailsFile, applicant.nreNroBankDetailsUrl);
    setFileLists(nomineeFormFile, applicant.nomineeFormUrl);
    setFileLists(
      statementOfSourceOfFundFile,
      applicant.statementOfSourceOfFundsURL,
    );
    setFileLists(paymentProofURLFundFile, applicant.paymentProofURL);
  }

  void _saveForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // PREVENT DUPLICATE PRIMARY APPLICANT
    if (selectedApplicantType.value!['DisplayName'] == "Applicant" &&
        widget.hasPrimaryApplicant &&
        !_isEditingApplicantType) {
      showErrorMessage(context, "", "Primary Applicant already exists");
      return;
    }

    final applicant = BookingApplicantData(
      bookingApplicantId: widget.applicant?.bookingApplicantId ?? 0,
      applicantType: selectedApplicantType.value!['DisplayName'],
      applicantName: _applicantNameC.text.trim(),
      applicantMobileNumber: _mobileC.text.trim(),
      applicantEmailId: _emailC.text.trim(),
      applicantMobileNumberCountryCode: selectedMobileNoCountry.value.code,
      photoURL:
          profilePhotoFile.fileNameList.isNotEmpty
              ? profilePhotoFile.fileNameList.join(",")
              : widget.applicant?.photoURL ?? '',
      aadharCardURL:
          aadhaarFile.fileNameList.isNotEmpty
              ? aadhaarFile.fileNameList.join(",")
              : widget.applicant?.aadharCardURL ?? '',
      panCardURL:
          panFile.fileNameList.isNotEmpty
              ? panFile.fileNameList.join(",")
              : widget.applicant?.panCardURL ?? '',
      passportURL:
          passportFile.fileNameList.isNotEmpty
              ? passportFile.fileNameList.join(",")
              : widget.applicant?.passportURL ?? '',
      drivingLicenseURL:
          drivingLicenseFile.fileNameList.isNotEmpty
              ? drivingLicenseFile.fileNameList.join(",")
              : widget.applicant?.drivingLicenseURL ?? '',
      votingIdURL:
          votingIdFile.fileNameList.isNotEmpty
              ? votingIdFile.fileNameList.join(",")
              : widget.applicant?.votingIdURL ?? '',
      gstNumberURL:
          gstFile.fileNameList.isNotEmpty
              ? gstFile.fileNameList.join(",")
              : widget.applicant?.gstNumberURL ?? '',
      cancelledChequeUrl:
          cancelledChequeFile.fileNameList.isNotEmpty
              ? cancelledChequeFile.fileNameList.join(",")
              : widget.applicant?.cancelledChequeUrl ?? '',
      poaurl:
          poaFile.fileNameList.isNotEmpty
              ? poaFile.fileNameList.join(",")
              : widget.applicant?.poaurl ?? '',
      incomeForm16Itrurl:
          incomeForm16ItrFile.fileNameList.isNotEmpty
              ? incomeForm16ItrFile.fileNameList.join(",")
              : widget.applicant?.incomeForm16Itrurl ?? '',
      nreNroBankDetailsUrl:
          nreNroBankDetailsFile.fileNameList.isNotEmpty
              ? nreNroBankDetailsFile.fileNameList.join(",")
              : widget.applicant?.nreNroBankDetailsUrl ?? '',
      nomineeFormUrl:
          nomineeFormFile.fileNameList.isNotEmpty
              ? nomineeFormFile.fileNameList.join(",")
              : widget.applicant?.nomineeFormUrl ?? '',
      statementOfSourceOfFundsURL:
          statementOfSourceOfFundFile.fileNameList.isNotEmpty
              ? statementOfSourceOfFundFile.fileNameList.join(",")
              : widget.applicant?.statementOfSourceOfFundsURL ?? '',
      paymentProofURL:
          paymentProofURLFundFile.fileNameList.isNotEmpty
              ? paymentProofURLFundFile.fileNameList.join(",")
              : widget.applicant?.paymentProofURL ?? '',
      aadharCardNumber: _aadharC.text.trim(),
      panNumber: _panC.text.trim(),
      passportNumber: _passportC.text.trim(),
      drivingLicenseNumber: _drivingLicenseC.text.trim(),
      votingIdNumber: _votingIdC.text.trim(),
      gstNumber: _gstC.text.trim(),

      createdById: widget.applicant?.createdById ?? -1,
      createdBy: widget.applicant?.createdBy ?? '',
      createdDate: widget.applicant?.createdDate ?? DateTime.now(),
      modifiedById: widget.applicant?.modifiedById ?? -1,
      modifiedBy: widget.applicant?.modifiedBy ?? '',
      modifiedDate: DateTime.now(),
    );

    applicant.profilePhotoImage = profilePhotoFile;
    applicant.aadhaarImage = aadhaarFile;
    applicant.panImage = panFile;
    applicant.passportImage = passportFile;
    applicant.drivingLicenseImage = drivingLicenseFile;
    applicant.votingIdImage = votingIdFile;
    applicant.gstImage = gstFile;
    applicant.cancelledChequeImage = cancelledChequeFile;
    applicant.poaImage = poaFile;
    applicant.incomeForm16ItrImage = incomeForm16ItrFile;
    applicant.nreNroBankDetailsImage = nreNroBankDetailsFile;
    applicant.nomineeFormImage = nomineeFormFile;
    applicant.statementOfSourceOfFundImage = statementOfSourceOfFundFile;
    applicant.paymentProofImage = paymentProofURLFundFile;

    Navigator.pop(context, {"applicant": applicant, "index": widget.index});
  }

  @override
  Widget build(BuildContext context) {
    final disableMobileNo =
        widget.applicant != null && widget.applicant!.bookingApplicantId != 0;
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Booking Form",
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
                          if (value == null) {
                            return "Applicant Type is required.";
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
                        return "Applicant Name is required.";
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
                        readOnly: disableMobileNo,
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
                            return "Mobile Number is required.";
                          }
                          if (mobile.isNotEmpty) {
                            // LENGTH AND REGEX VALIDATION
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
                    isRequired: true,
                    textController: _emailC,
                    inputFormatterList: InputValidator.emailInputFormatters(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email Id is required.";
                      }
                      if (!InputValidator.isValidEmail(value)) {
                        return "Invalid Email Id";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Profile Photo",
                    filePickType: FilePickType.image,
                    isRequired: true,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Profile Photo is required.";
                      }
                      return null;
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
                        return "Aadhaar Card Number is required.";
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
                        return "Aadhaar Card document is required.";
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
                        return "PAN Number is required.";
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
                        return "PAN Card document is required.";
                      }
                      if (_panC.text.isNotEmpty &&
                          InputValidator.isValidPAN(_panC.text.trim()) &&
                          (fileList.isEmpty)) {
                        return "PAN Card document is required.";
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
                          return "Passport Number is required.";
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
                        return "Passport document is required.";
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
                          return "Driving License Number is required.";
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
                        return "Driving License document is required.";
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
                          return "Voting Id is required.";
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
                        return "Voting Id document is required.";
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
                          return "GST Number is required.";
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
                        return "GST Certificate document is required.";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Cancelled Cheque",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: cancelledChequeFile.fileNameList,
                    initialFileBytes: cancelledChequeFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      cancelledChequeFile.fileNameList = fileNameList;
                      cancelledChequeFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      cancelledChequeFile.fileBytesList = fileBytesList;
                      cancelledChequeFile.fileNameList = fileNameList;
                      cancelledChequeFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "POA (if NRI Execution)",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: poaFile.fileNameList,
                    initialFileBytes: poaFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      poaFile.fileNameList = fileNameList;
                      poaFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      poaFile.fileBytesList = fileBytesList;
                      poaFile.fileNameList = fileNameList;
                      poaFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Income Docs (Form 16 / ITR)",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: incomeForm16ItrFile.fileNameList,
                    initialFileBytes: incomeForm16ItrFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      incomeForm16ItrFile.fileNameList = fileNameList;
                      incomeForm16ItrFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      incomeForm16ItrFile.fileBytesList = fileBytesList;
                      incomeForm16ItrFile.fileNameList = fileNameList;
                      incomeForm16ItrFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "NRE / NRO Bank Details",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: nreNroBankDetailsFile.fileNameList,
                    initialFileBytes: nreNroBankDetailsFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      nreNroBankDetailsFile.fileNameList = fileNameList;
                      nreNroBankDetailsFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      nreNroBankDetailsFile.fileBytesList = fileBytesList;
                      nreNroBankDetailsFile.fileNameList = fileNameList;
                      nreNroBankDetailsFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Nominee Form",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: nomineeFormFile.fileNameList,
                    initialFileBytes: nomineeFormFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      nomineeFormFile.fileNameList = fileNameList;
                      nomineeFormFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      nomineeFormFile.fileBytesList = fileBytesList;
                      nomineeFormFile.fileNameList = fileNameList;
                      nomineeFormFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Statement of Source of Funds",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: statementOfSourceOfFundFile.fileNameList,
                    initialFileBytes: statementOfSourceOfFundFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      statementOfSourceOfFundFile.fileNameList = fileNameList;
                      statementOfSourceOfFundFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      statementOfSourceOfFundFile.fileBytesList = fileBytesList;
                      statementOfSourceOfFundFile.fileNameList = fileNameList;
                      statementOfSourceOfFundFile.deletedFileList = deleted;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Payment Proof",
                    filePickType: FilePickType.kycDocument,
                    initialFileList: paymentProofURLFundFile.fileNameList,
                    initialFileBytes: paymentProofURLFundFile.fileBytesList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      paymentProofURLFundFile.fileNameList = fileNameList;
                      paymentProofURLFundFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      paymentProofURLFundFile.fileBytesList = fileBytesList;
                      paymentProofURLFundFile.fileNameList = fileNameList;
                      paymentProofURLFundFile.deletedFileList = deleted;
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
            text: isEditMode ? "Update Applicant" : "Add Applicant",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
