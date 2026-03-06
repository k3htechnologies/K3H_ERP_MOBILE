import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
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
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Applicant"},
    {"zAttributesId": 2, "DisplayName": "Co-Applicant"},
  ];

  // SELECTED APPLICANT TYPE
  late Map<String, dynamic> selectedApplicantType;

  // METHODS TO CHECK IF APPLICANT TYPE IS PRIMARY
  bool _isApplicantType(String type) =>
      type.toLowerCase().trim() == 'applicant';

  // CHECK IF APPLICANT IS EDITING
  bool get _isEditingApplicantType =>
      widget.applicant != null &&
      _isApplicantType(widget.applicant!.applicantType);

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

  @override
  void initState() {
    super.initState();
    selectedApplicantType = applicantTypeList.first;
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
    selectedApplicantType = applicantTypeList.firstWhere(
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
        target.fileBytesList = [];
      }
    }

    setFileLists(profilePhotoFile, applicant.photoURL);
    setFileLists(aadhaarFile, applicant.aadharCardURL);
    setFileLists(panFile, applicant.panCardURL);
    setFileLists(passportFile, applicant.passportURL);
    setFileLists(drivingLicenseFile, applicant.drivingLicenseURL);
    setFileLists(votingIdFile, applicant.votingIdURL);
    setFileLists(gstFile, applicant.gstNumberURL);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Prevent duplicate primary applicant
    if (selectedApplicantType['DisplayName'] == "Applicant" &&
        widget.hasPrimaryApplicant &&
        !_isEditingApplicantType) {
      showErrorMessage(context, "", "Primary Applicant already exists");
      return;
    }

    final applicant = BookingApplicantData(
      bookingApplicantId: widget.applicant?.bookingApplicantId ?? 0,
      applicantType: selectedApplicantType['DisplayName'],
      applicantName: _applicantNameC.text.trim(),
      applicantMobileNumber: _mobileC.text.trim(),
      applicantEmailId: _emailC.text.trim(),

      photoURL: widget.applicant?.photoURL ?? '',
      aadharCardNumber: _aadharC.text.trim(),
      aadharCardURL: widget.applicant?.aadharCardURL ?? '',
      panNumber: _panC.text.trim(),
      panCardURL: widget.applicant?.panCardURL ?? '',
      passportNumber: _passportC.text.trim(),
      passportURL: widget.applicant?.passportURL ?? '',
      drivingLicenseNumber: _drivingLicenseC.text.trim(),
      drivingLicenseURL: widget.applicant?.drivingLicenseURL ?? '',
      votingIdNumber: _votingIdC.text.trim(),
      votingIdURL: widget.applicant?.votingIdURL ?? '',
      gstNumber: _gstC.text.trim(),
      gstNumberURL: widget.applicant?.gstNumberURL ?? '',

      createdById: widget.applicant?.createdById ?? -1,
      createdBy: widget.applicant?.createdBy ?? '',
      createdDate: widget.applicant?.createdDate ?? DateTime.now(),
      modifiedById: widget.applicant?.modifiedById ?? -1,
      modifiedBy: widget.applicant?.modifiedBy ?? '',
      modifiedDate: DateTime.now(),
    );

    // 🔥 Attach file picker models
    applicant.profilePhotoImage = profilePhotoFile;
    applicant.aadhaarImage = aadhaarFile;
    applicant.panImage = panFile;
    applicant.passportImage = passportFile;
    applicant.drivingLicenseImage = drivingLicenseFile;
    applicant.votingIdImage = votingIdFile;
    applicant.gstImage = gstFile;

    Navigator.pop(context, {"applicant": applicant, "index": widget.index});
  }

  @override
  Widget build(BuildContext context) {
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
                  CustomDropDownWidget(
                    title: "Applicant Type",
                    isRequired: true,
                    initialValue: selectedApplicantType,
                    dataList: _applicantTypeOptions,
                    onSelected: (value) => selectedApplicantType = value,
                    validator: (value) {
                      if (value == null || value['zAttributesId'] == -1) {
                        return "Applicant Type is required";
                      }
                      return null;
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
                  CustomTextField(
                    title: 'Mobile Number',
                    isRequired: true,
                    hint: "Enter Mobile Number",
                    textController: _mobileC,
                    keyboardType: TextInputType.phone,
                    inputFormatterList: InputValidator.digit(10),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Mobile Number is required";
                      }
                      if (!InputValidator.isValidMobileNumber(value)) {
                        return "Invalid mobile number";
                      }
                      return null;
                    },
                    prefixWidget: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          SizedBox(width: 10),
                          Text("+91"),
                          VerticalDivider(
                            color: AppColor.black,
                            thickness: 0.5,
                            width: 15,
                            indent: 5,
                            endIndent: 5,
                          ),
                        ],
                      ),
                    ),
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
                    filePickType: FilePickType.image,
                    isRequired: true,
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
                        return "Profile Photo is required";
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
                        return "Aadhaar is required";
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
                    textController: _panC,
                    inputFormatterList: InputValidator.panInputFormatters(),
                    validator: (value) {
                      if (panFile.fileNameList.isNotEmpty) {
                        if (value == null || value.isEmpty) {
                          return "PAN Number is required";
                        }
                        if (!InputValidator.isValidPAN(value)) {
                          return "PAN Number is invalid";
                        }
                      } else {
                        if (value != null &&
                            value.isNotEmpty &&
                            !InputValidator.isValidPAN(value)) {
                          return "PAN Number is invalid";
                        }
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "PAN Card",
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
                    validator: (fileList) {
                      if (_panC.text.isNotEmpty &&
                          InputValidator.isValidPAN(_panC.text.trim()) &&
                          (fileList == null || fileList.isEmpty)) {
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
                          !InputValidator.isValidPassport(
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
                          !InputValidator.isValidGST(_gstC.text.trim()) &&
                          (fileList == null || fileList.isEmpty)) {
                        return "GST Certificate document is required";
                      }
                      return null;
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
          child: CustomButton(text: "Save", onPressed: _save),
        ),
      ),
    );
  }
}
