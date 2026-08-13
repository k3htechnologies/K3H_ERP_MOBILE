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
  final MultiFilePickerModel? aadhaarFile;
  final MultiFilePickerModel? panFile;
  final MultiFilePickerModel? passportFile;
  final MultiFilePickerModel? photoFile;
  final MultiFilePickerModel? gstFile;
  final MultiFilePickerModel? votingFile;
  final MultiFilePickerModel? drivingFile;
  final MultiFilePickerModel? poaFile;
  final MultiFilePickerModel? paymentProofFile;
  final MultiFilePickerModel? proofDocumentFile;
  final MultiFilePickerModel? statementFile;
  final MultiFilePickerModel? incomeFile;
  final MultiFilePickerModel? nomineeFile;
  final MultiFilePickerModel? cancelledChequeFile;
  final MultiFilePickerModel? nreFile;
  const AddApplicantDetailsRequestsScreen({
    super.key,
    required this.bookingId,
    required this.projectId,
    this.index,
    this.isEdit = false,
    this.applicant,
    this.aadhaarFile,
    this.panFile,
    this.passportFile,
    this.photoFile,
    this.gstFile,
    this.votingFile,
    this.drivingFile,
    this.poaFile,
    this.paymentProofFile,
    this.proofDocumentFile,
    this.statementFile,
    this.incomeFile,
    this.nomineeFile,
    this.cancelledChequeFile,
    this.nreFile,
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

    if (widget.isEdit && widget.index != null) {
      _loadApplicantFromCubit();
    }

    _prefillData();
  }

  void _loadApplicantFromCubit() {
    final cubit = context.read<RequestManagementCubit>();

    final applicants = cubit.state.bookingApplicantModificationRequestModel;

    final index = widget.index!;

    final applicant = applicants[index];

    profilePhotoFile = _copyFileModel(applicant.photoFile);
    aadhaarFile = _copyFileModel(applicant.aadhaarFile);
    panFile = _copyFileModel(applicant.panFile);
    passportFile = _copyFileModel(applicant.passportFile);
    drivingLicenseFile = _copyFileModel(applicant.drivingLicenseFile);
    votingIdFile = _copyFileModel(applicant.votingIdFile);
    gstFile = _copyFileModel(applicant.gstFile);
    chequeFile = _copyFileModel(applicant.chequeFile);
    poaFile = _copyFileModel(applicant.poaFile);
    paymentProofURLFundFile = _copyFileModel(applicant.paymentProofURLFundFile);
    proofOfDocumentFile = _copyFileModel(applicant.proofOfDocumentFile);
    statementOfSourceOfFundsFile = _copyFileModel(
      applicant.statementOfSourceOfFundFile,
    );
    incomeForm16ItrFile = _copyFileModel(applicant.incomeForm16ItrFile);
    nomineeFormFile = _copyFileModel(applicant.nomineeFormFile);
    nreNroBankDetailsFile = _copyFileModel(applicant.nreNroBankDetailsFile);
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
    if (!widget.isEdit || widget.index == null) {
      return;
    }

    final cubit = context.read<RequestManagementCubit>();

    final applicants = cubit.state.bookingApplicantModificationRequestModel;

    final index = widget.index!;

    if (index < 0 || index >= applicants.length) {
      return;
    }

    final a = applicants[index];

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
    if (proofOfDocumentFile.fileNameList.isEmpty) {
      proofOfDocumentFile.fileNameList =
          a.proofOfDocumentUrl.isEmpty ? [] : a.proofOfDocumentUrl.split(",");
    }
    if (profilePhotoFile.fileNameList.isEmpty) {
      profilePhotoFile.fileNameList =
          a.photoUrl.isEmpty ? [] : a.photoUrl.split(",");
    }
    if (aadhaarFile.fileNameList.isEmpty) {
      aadhaarFile.fileNameList =
          a.aadharCardUrl.isEmpty ? [] : a.aadharCardUrl.split(",");
    }
    if (panFile.fileNameList.isEmpty) {
      panFile.fileNameList =
          a.panCardUrl.isEmpty ? [] : a.panCardUrl.split(",");
    }

    if (passportFile.fileNameList.isEmpty) {
      passportFile.fileNameList =
          a.passportUrl.isEmpty ? [] : a.passportUrl.split(",");
    }
    if (drivingLicenseFile.fileNameList.isEmpty) {
      drivingLicenseFile.fileNameList =
          a.drivingLicenseUrl.isEmpty ? [] : a.drivingLicenseUrl.split(",");
    }
    if (votingIdFile.fileNameList.isEmpty) {
      votingIdFile.fileNameList =
          a.votingIdUrl.isEmpty ? [] : a.votingIdUrl.split(",");
    }
    if (gstFile.fileNameList.isEmpty) {
      gstFile.fileNameList =
          a.gstNumberUrl.isEmpty ? [] : a.gstNumberUrl.split(",");
    }
    if (chequeFile.fileNameList.isEmpty) {
      chequeFile.fileNameList =
          a.cancelledChequeUrl.isEmpty ? [] : a.cancelledChequeUrl.split(",");
    }
    if (poaFile.fileNameList.isEmpty) {
      poaFile.fileNameList = a.poaurl.isEmpty ? [] : a.poaurl.split(",");
    }
    if (incomeForm16ItrFile.fileNameList.isEmpty) {
      incomeForm16ItrFile.fileNameList =
          a.incomeForm16Itrurl.isEmpty ? [] : a.incomeForm16Itrurl.split(",");
    }
    if (nreNroBankDetailsFile.fileNameList.isEmpty) {
      nreNroBankDetailsFile.fileNameList =
          a.nreNroBankDetailsUrl.isEmpty
              ? []
              : a.nreNroBankDetailsUrl.split(",");
    }
    if (nomineeFormFile.fileNameList.isEmpty) {
      nomineeFormFile.fileNameList =
          a.nomineeFormUrl.isEmpty ? [] : a.nomineeFormUrl.split(",");
    }
    if (statementOfSourceOfFundsFile.fileNameList.isEmpty) {
      statementOfSourceOfFundsFile.fileNameList =
          a.statementOfSourceOfFundsUrl.isEmpty
              ? []
              : a.statementOfSourceOfFundsUrl.split(",");
    }
    if (paymentProofURLFundFile.fileNameList.isEmpty) {
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
      bookingApplicantModificationRequestId:
          widget.isEdit
              ? widget.applicant?.bookingApplicantModificationRequestId ?? 0
              : 0,
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
    );
    applicant.proofOfDocumentFile = proofOfDocumentFile;
    applicant.aadhaarFile = aadhaarFile;
    applicant.panFile = panFile;
    applicant.photoFile = profilePhotoFile;
    applicant.drivingLicenseFile = drivingLicenseFile;
    applicant.chequeFile = chequeFile;
    applicant.votingIdFile = votingIdFile;
    applicant.gstFile = gstFile;
    applicant.passportFile = passportFile;
    applicant.poaFile = poaFile;
    applicant.incomeForm16ItrFile = incomeForm16ItrFile;
    applicant.nreNroBankDetailsFile = nreNroBankDetailsFile;
    applicant.nomineeFormFile = nomineeFormFile;
    applicant.statementOfSourceOfFundFile = statementOfSourceOfFundsFile;
    applicant.paymentProofURLFundFile = paymentProofURLFundFile;

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

  MultiFilePickerModel _copyFileModel(MultiFilePickerModel? source) {
    if (source == null) {
      return MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
    }

    return MultiFilePickerModel(
      fileBytesList: List<Uint8List>.from(source.fileBytesList),
      fileNameList: List<String>.from(source.fileNameList),
      deletedFileList: source.deletedFileList,
    );
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
                        proofOfDocumentFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        proofOfDocumentFile
                            .fileBytesList = List<Uint8List>.from(bytesList);
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
                      initialFileBytes: profilePhotoFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        profilePhotoFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        profilePhotoFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                      initialFileBytes: aadhaarFile.fileBytesList,

                      onFilePickedCallback: (bytesList, fileNameList) {
                        aadhaarFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        aadhaarFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                      initialFileBytes: panFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        panFile.fileNameList = List<String>.from(fileNameList);
                        panFile.fileBytesList = List<Uint8List>.from(bytesList);
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
                      inputFormatterList:
                          InputValidator.passportInputFormatters(),
                      validator: (value) {
                        if (passportFile.fileNameList.isNotEmpty) {
                          if (value == null || value.isEmpty) {
                            return "Passport Number is required";
                          }
                          if (!InputValidator.isValidPassport(value)) {
                            return "Enter a valid Passport Number";
                          }
                        } else {
                          if (value != null &&
                              value.isNotEmpty &&
                              !InputValidator.isValidPassport(value)) {
                            return "Enter a valid Passport Number";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Passport",
                      initialFileList: passportFile.fileNameList,
                      initialFileBytes: passportFile.fileBytesList,
                      filePickType: FilePickType.kycDocument,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        passportFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        passportFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                      validator: (value) {
                        if (_passportC.text.trim().isNotEmpty &&
                            passportFile.fileNameList.isEmpty) {
                          return "Passport document is required";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Driving License Number',
                      textController: _drivingLicenseC,
                      hint: "Enter Driving License Number",
                      inputFormatterList:
                          InputValidator.drivingLicenceInputFormatters(),
                      validator: (value) {
                        if (drivingLicenseFile.fileNameList.isNotEmpty) {
                          if (value == null || value.isEmpty) {
                            return "Driving License Number is required";
                          }
                          if (!InputValidator.isValidDrivingLicence(value)) {
                            return "Enter a valid Driving License Number";
                          }
                        } else {
                          if (value != null &&
                              value.isNotEmpty &&
                              !InputValidator.isValidDrivingLicence(value)) {
                            return "Enter a valid Driving License Number";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Driving License",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: drivingLicenseFile.fileNameList,
                      initialFileBytes: drivingLicenseFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        drivingLicenseFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        drivingLicenseFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                      validator: (value) {
                        if (_drivingLicenseC.text.trim().isNotEmpty &&
                            drivingLicenseFile.fileNameList.isEmpty) {
                          return "Driving License document is required";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Voting ID Number',
                      textController: _votingIdC,
                      hint: "Enter Voting ID Number",
                      inputFormatterList:
                          InputValidator.voterIdInputFormatters(),
                      validator: (value) {
                        if (votingIdFile.fileNameList.isNotEmpty) {
                          if (value == null || value.isEmpty) {
                            return "Voting ID Number is required";
                          }
                          if (!InputValidator.isValidVoterId(value)) {
                            return "Enter a valid Voting Id Number";
                          }
                        } else {
                          if (value != null &&
                              value.isNotEmpty &&
                              !InputValidator.isValidGST(value)) {
                            return "Enter a valid Voting Id Number";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Voting ID",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: votingIdFile.fileNameList,
                      initialFileBytes: votingIdFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        votingIdFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        votingIdFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                      validator: (value) {
                        if (_votingIdC.text.trim().isNotEmpty &&
                            votingIdFile.fileNameList.isEmpty) {
                          return "Voting ID document is required";
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
                            return "Enter a valid GST Number";
                          }
                        } else {
                          if (value != null &&
                              value.isNotEmpty &&
                              !InputValidator.isValidGST(value)) {
                            return "Enter a valid GST Number";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "GST Document",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: gstFile.fileNameList,
                      initialFileBytes: gstFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        gstFile.fileNameList = List<String>.from(fileNameList);
                        gstFile.fileBytesList = List<Uint8List>.from(bytesList);
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
                      validator: (value) {
                        if (_gstC.text.trim().isNotEmpty &&
                            gstFile.fileNameList.isEmpty) {
                          return "GST document is required";
                        }

                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Cancelled Cheque",
                      filePickType: FilePickType.kycDocument,
                      initialFileList: chequeFile.fileNameList,
                      initialFileBytes: chequeFile.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        chequeFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        chequeFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                        poaFile.fileNameList = List<String>.from(fileNameList);
                        poaFile.fileBytesList = List<Uint8List>.from(bytesList);
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
                        incomeForm16ItrFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        incomeForm16ItrFile
                            .fileBytesList = List<Uint8List>.from(bytesList);
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
                        nreNroBankDetailsFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        nreNroBankDetailsFile
                            .fileBytesList = List<Uint8List>.from(bytesList);
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
                        nomineeFormFile.fileNameList = List<String>.from(
                          fileNameList,
                        );
                        nomineeFormFile.fileBytesList = List<Uint8List>.from(
                          bytesList,
                        );
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
                        statementOfSourceOfFundsFile
                            .fileNameList = List<String>.from(fileNameList);
                        statementOfSourceOfFundsFile
                            .fileBytesList = List<Uint8List>.from(bytesList);
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
                        paymentProofURLFundFile
                            .fileNameList = List<String>.from(fileNameList);
                        paymentProofURLFundFile
                            .fileBytesList = List<Uint8List>.from(bytesList);
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
