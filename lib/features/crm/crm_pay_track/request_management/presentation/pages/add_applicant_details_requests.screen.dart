import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/model/booking_applicant_modification_request.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/presentation/cubit/request_management_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddApplicantDetailsRequestsScreen extends StatefulWidget {
  final BookingApplicantModificationRequestModel? applicant;
  final int bookingId;
  final int projectId;
  final int? index;
  final bool isEdit;
  const AddApplicantDetailsRequestsScreen({
    super.key,
    required this.bookingId,
    required this.projectId,
    this.index,
    this.isEdit = false,
    this.applicant,
  });

  @override
  State<AddApplicantDetailsRequestsScreen> createState() =>
      _AddApplicantDetailsRequestsScreenState();
}

class _AddApplicantDetailsRequestsScreenState
    extends State<AddApplicantDetailsRequestsScreen> {
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<Map<String, dynamic>?> selectedApplicantType = ValueNotifier(
    null,
  );

  List<Map<String, dynamic>> get _applicantTypeOptions {
    final requestCubit = context.read<RequestManagementCubit>();

    final hasApprovedApplicant = requestCubit
        .state
        .bookingApplicantModificationRequestModel
        .any(
          (e) =>
              e.applicantType.toLowerCase() == "applicant" &&
              e.approvalStatus.toLowerCase() == "approved",
        );

    if (hasApprovedApplicant) {
      return applicantTypeList
          .where((e) => e["DisplayName"] != "Applicant")
          .toList();
    }

    return applicantTypeList;
  }

  final List<Map<String, dynamic>> applicantTypeList = const [
    {"zAttributesId": 1, "DisplayName": "Applicant"},
    {"zAttributesId": 2, "DisplayName": "Co - Applicant"},
  ];
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

  MultiFilePickerModel paymentProofURLFundFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel proofOfDocumentFile = MultiFilePickerModel(
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
    _initControllers();
    _prefillData();
  }

  void _initControllers() {
    _applicantNameC = TextEditingController();
    _mobileC = TextEditingController();
    _emailC = TextEditingController();
    _panC = TextEditingController();
    _aadharC = TextEditingController();
    _passportC = TextEditingController();
    _drivingLicenseC = TextEditingController();
    _votingIdC = TextEditingController();
    _gstC = TextEditingController();
    _accountNumberC = TextEditingController();
    _ifscCodeC = TextEditingController();
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

  void _prefillData() {
    if (widget.isEdit && widget.applicant != null) {
      final a = widget.applicant!;

      _applicantNameC.text = a.applicantName;
      _mobileC.text = a.applicantMobileNumber;
      if (a.applicantMobileNumberCountryCode.isNotEmpty) {
        selectedMobileNoCountry.value = countryList.firstWhere(
          (e) => e.code == a.applicantMobileNumberCountryCode,
          orElse: () => countryList.firstWhere((e) => e.code == "+91"),
        );
      }
      _emailC.text = a.applicantEmailId;
      _aadharC.text = a.aadharCardNumber;
      _panC.text = a.panNumber;
      _passportC.text = a.passportNumber;
      _drivingLicenseC.text = a.drivingLicenseNumber;
      _votingIdC.text = a.votingIdNumber;
      _gstC.text = a.gstNumber;

      selectedApplicantType.value = applicantTypeList.firstWhere(
        (e) => e["DisplayName"] == a.applicantType,
      );
      proofOfDocumentFile.fileNameList =
          a.proofOfDocumentUrl.isEmpty ? [] : a.proofOfDocumentUrl.split(",");
      profilePhotoFile.fileNameList =
          a.photoUrl.isEmpty ? [] : a.photoUrl.split(",");
      aadhaarFile.fileNameList =
          a.aadharCardUrl.isEmpty ? [] : a.aadharCardUrl.split(",");
      panFile.fileNameList =
          a.panCardUrl.isEmpty ? [] : a.panCardUrl.split(",");
      passportFile.fileNameList =
          a.passportUrl.isEmpty ? [] : a.passportUrl.split(",");
      drivingLicenseFile.fileNameList =
          a.drivingLicenseUrl.isEmpty ? [] : a.drivingLicenseUrl.split(",");
      votingIdFile.fileNameList =
          a.votingIdUrl.isEmpty ? [] : a.votingIdUrl.split(",");
      gstFile.fileNameList =
          a.gstNumberUrl.isEmpty ? [] : a.gstNumberUrl.split(",");
      chequeFile.fileNameList =
          a.cancelledChequeUrl.isEmpty ? [] : a.cancelledChequeUrl.split(",");
      poaFile.fileNameList = a.poaurl.isEmpty ? [] : a.poaurl.split(",");
      incomeForm16ItrFile.fileNameList =
          a.incomeForm16Itrurl.isEmpty ? [] : a.incomeForm16Itrurl.split(",");

      nreNroBankDetailsFile.fileNameList =
          a.nreNroBankDetailsUrl.isEmpty
              ? []
              : a.nreNroBankDetailsUrl.split(",");

      nomineeFormFile.fileNameList =
          a.nomineeFormUrl.isEmpty ? [] : a.nomineeFormUrl.split(",");
      statementOfSourceOfFundsFile.fileNameList =
          a.statementOfSourceOfFundsUrl.isEmpty
              ? []
              : a.statementOfSourceOfFundsUrl.split(",");

      paymentProofURLFundFile.fileNameList =
          a.paymentProofUrl.isEmpty ? [] : a.paymentProofUrl.split(",");
    }
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final latestVersion = context
        .read<RequestManagementCubit>()
        .state
        .bookingApplicantModificationRequestModel
        .map((e) => int.tryParse(e.versionNumber) ?? 0)
        .fold(0, (a, b) => a > b ? a : b);

    final applicant = BookingApplicantModificationRequestModel(
      bookingApplicantModificationRequestId: 0,
      applicantType:
          selectedApplicantType.value?["DisplayName"]?.toString() ?? "",

      applicantName: _applicantNameC.text.trim(),
      applicantMobileNumber: _mobileC.text.trim(),
      applicantEmailId: _emailC.text.trim(),

      photoUrl: profilePhotoFile.fileNameList.join(","),
      aadharCardNumber: _aadharC.text.trim(),
      aadharCardUrl: aadhaarFile.fileNameList.join(","),

      panNumber: _panC.text.trim(),
      panCardUrl: panFile.fileNameList.join(","),

      passportNumber: _passportC.text.trim(),
      passportUrl: passportFile.fileNameList.join(","),

      drivingLicenseNumber: _drivingLicenseC.text.trim(),
      drivingLicenseUrl: drivingLicenseFile.fileNameList.join(","),

      votingIdNumber: _votingIdC.text.trim(),
      votingIdUrl: votingIdFile.fileNameList.join(","),

      gstNumber: _gstC.text.trim(),
      gstNumberUrl: gstFile.fileNameList.join(","),

      isApproval: true,
      approvalStatus: "Pending",

      versionNumber: (latestVersion + 1).toString(),

      createdById: 0,
      createdBy: "",
      createdDate: DateTime.now(),

      modifiedById: 0,
      modifiedBy: "",
      modifiedDate: DateTime.now(),
      applicantMobileNumberCountryCode: selectedMobileNoCountry.value.code,
      cancelledChequeUrl: chequeFile.fileNameList.join(","),
      poaurl: poaFile.fileNameList.join(","),
      incomeForm16Itrurl: incomeForm16ItrFile.fileNameList.join(","),
      nreNroBankDetailsUrl: nreNroBankDetailsFile.fileNameList.join(","),
      nomineeFormUrl: nomineeFormFile.fileNameList.join(","),
      statementOfSourceOfFundsUrl: statementOfSourceOfFundsFile.fileNameList
          .join(","),
      paymentProofUrl: paymentProofURLFundFile.fileNameList.join(","),
      proofOfDocumentUrl: proofOfDocumentFile.fileNameList.join(","),

      proofOfDocumentFile: proofOfDocumentFile,
      aadhaarFile: aadhaarFile,
      panFile: panFile,
      photoFile: profilePhotoFile,
      drivingLicenseFile: drivingLicenseFile,
      votingIdFile: votingIdFile,
      gstFile: gstFile,
      chequeFile: chequeFile,
      poaFile: poaFile,
      incomeForm16ItrFile: incomeForm16ItrFile,
      nreNroBankDetailsFile: nreNroBankDetailsFile,
      nomineeFormFile: nomineeFormFile,
      statementOfSourceOfFundFile: statementOfSourceOfFundsFile,
      paymentProofURLFundFile: paymentProofFile,
    );

    if (context.mounted) {
      goRouter.pop({
        "isSuccess": true,
        "applicant": applicant,
        "isEdit": widget.isEdit,
        "index": widget.index,
        "proofDocumentFile": proofOfDocumentFile,
        "aadhaarFile": aadhaarFile,
        "panFile": panFile,
        "passportFile": passportFile,
        "photoFile": profilePhotoFile,
        "gstFile": gstFile,
        "votingFile": votingIdFile,
        "drivingFile": drivingLicenseFile,
        "poaFile": poaFile,
        "paymentProofFile": paymentProofURLFundFile,
        "statementFile": statementOfSourceOfFundsFile,
        "incomeFile": incomeForm16ItrFile,
        "nomineeFile": nomineeFormFile,
        "cancelledChequeFile": chequeFile,
        "nreFile": nreNroBankDetailsFile,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: widget.isEdit ? "Update Applicant" : "Add Applicant",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMultiFilePicker(
                      title: "Proof Of Document",
                      isRequired: true,
                      filePickType: FilePickType.kycDocument,
                      initialFileList: proofOfDocumentFile.fileNameList,
                      initialFileBytes: proofOfDocumentFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        proofOfDocumentFile.fileNameList = fileNameList;
                        proofOfDocumentFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        proofOfDocumentFile.fileBytesList = fileBytesList;
                        proofOfDocumentFile.fileNameList = fileNameList;
                        proofOfDocumentFile.deletedFileList = deleted;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Proof Of Document is required";
                        }
                        return null;
                      },
                    ),

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
                          onValueClear:
                              () => selectedApplicantType.value = null,
                        );
                      },
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
                          onCountryChanged: (country) async {
                            if (country == null) return;

                            selectedMobileNoCountry.value = country;
                            if (_mobileC.text.isNotEmpty &&
                                country.mobileLength == _mobileC.text.length) {}
                          },
                          onChangeFunction: (value) async {},
                          inputFormatterList: [
                            LengthLimitingTextInputFormatter(
                              value.mobileLength,
                            ),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            final mobile = value?.trim() ?? "";
                            final country = selectedMobileNoCountry.value;
                            if (value == null || value.isEmpty) {
                              return "Mobile Number is required";
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
                      isRequired: true,
                      hint: "Enter Email Id",
                      textController: _emailC,
                      inputFormatterList: InputValidator.emailInputFormatters(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email Id is required";
                        }
                        if (!InputValidator.isValidEmail(value)) {
                          return "Invalid email address";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Profile Photo",
                      isRequired: true,
                      filePickType: FilePickType.image,
                      initialFileList: profilePhotoFile.fileNameList,
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
                          return "Applicant Photo is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Aadhaar Card Number',
                      textController: _aadharC,
                      hint: "Enter Aadhaar Card Number",
                      inputFormatterList:
                          InputValidator.aadhaarNumberInputFormatter(),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Aadhaar Card is required";
                        }

                        if (!InputValidator.isValidAadharNumber(value.trim())) {
                          return "Invalid Aadhaar Card Number";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Upload Aadhaar Card",
                      isRequired: true,
                      filePickType: FilePickType.kycDocument,
                      initialFileList: aadhaarFile.fileNameList,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Aadhaar document is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'PAN Number',
                      textController: _panC,
                      hint: "Enter PAN Number",
                      isRequired: true,
                      inputFormatterList: InputValidator.panInputFormatters(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "PAN Card is required";
                        }

                        if (!InputValidator.isValidPAN(value.trim())) {
                          return "Invalid PAN Number";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "PAN Card",
                      isRequired: true,
                      filePickType: FilePickType.kycDocument,
                      initialFileList: panFile.fileNameList,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "PAN document is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Passport Number',
                      textController: _passportC,
                      hint: "Enter Passport Number",
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(20),
                      ],
                      validator: (value) {
                        if (drivingLicenseFile.fileNameList.isEmpty) {
                          return null;
                        }
                        if (value == null || value.isEmpty) {
                          return "Passport Number is required";
                        }

                        if (InputValidator.isValidPassport(value)) {
                          return "Passport Number is invalid";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Passport",
                      initialFileList: passportFile.fileNameList,
                      filePickType: FilePickType.kycDocument,
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
                    ),
                    CustomTextField(
                      title: 'Driving License Number',
                      textController: _drivingLicenseC,
                      hint: "Enter Driving License Number",
                      inputFormatterList: InputValidator.textDigit(20),
                      validator: (value) {
                        if (drivingLicenseFile.fileNameList.isEmpty) {
                          return null;
                        }
                        if (value == null || value.isEmpty) {
                          return "Driving License is required";
                        }

                        if (InputValidator.isValidDrivingLicence(value)) {
                          return "Driving License Number is invalid";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Driving License",
                      filePickType: FilePickType.kycDocument,
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
                    ),
                    CustomTextField(
                      title: 'Voting ID Number',
                      textController: _votingIdC,
                      hint: "Enter Voting ID Number",
                      inputFormatterList: InputValidator.textDigit(20),
                      validator: (value) {
                        final hasNumber = value?.trim().isNotEmpty ?? false;
                        final hasDocument =
                            votingIdFile.fileNameList.isNotEmpty;

                        if (hasDocument && !hasNumber) {
                          return "Voting ID Number is required";
                        }

                        if (hasNumber &&
                            !InputValidator.isValidVoterId(value!.trim())) {
                          return "Voting ID Number is invalid";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Voting ID",
                      filePickType: FilePickType.kycDocument,
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
                      title: "GST Document",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: gstFile.fileNameList,
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
                      initialFileList:
                          statementOfSourceOfFundsFile.fileNameList,
                      initialFileBytes:
                          statementOfSourceOfFundsFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        statementOfSourceOfFundsFile.fileNameList =
                            fileNameList;
                        statementOfSourceOfFundsFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        statementOfSourceOfFundsFile.fileBytesList =
                            fileBytesList;
                        statementOfSourceOfFundsFile.fileNameList =
                            fileNameList;
                        statementOfSourceOfFundsFile.deletedFileList = deleted;
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: widget.isEdit ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
