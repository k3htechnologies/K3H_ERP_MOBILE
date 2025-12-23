import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddCompanyMasterScreen extends StatefulWidget {
  final CompanyModel? company;
  const AddCompanyMasterScreen({super.key, this.company});

  @override
  State<AddCompanyMasterScreen> createState() =>
      _AddCompanyMasterMobileScreenState();
}

class _AddCompanyMasterMobileScreenState extends State<AddCompanyMasterScreen> {
  // CUBIT
  late CompanyMasterAddCubit _companyMasterAddCubit;

  late TextEditingController
      // COMPANY TEXT CONTROLLER
      _companyNameC,
      _contactPersonC,
      _mobileNumberC,
      _emailIdC,
      _landLineNumberC,
      _gstNumberC,
      _panNumberC,
      _cinNumberC,
      _reraNumberC,
      _addressC,
      // COMPANY PARTNER TEXT CONTROLLER
      _companyPartnerFirstNameC,
      _companyPartnerMiddleNameC,
      _companyPartnerLastNameC,
      _companyPartnerMobileNumberC,
      _companyPartnerEmailC,
      _companyPartnerPercentageC,
      _companyPartnerPanNumberC,
      _companyPartnerAadharNumberC;

  // COMPANY TYPE DROPDOWN
  List<Map<String, dynamic>> companyTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "LLP"},
    {"zAttributesId": 2, "DisplayName": "Private Limited Company"},
    {"zAttributesId": 3, "DisplayName": "Proprietorship"},
  ];

  // GENDER LIST
  final List<Map<String, dynamic>> genderList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];

  // FORM KEYS (one per section)
  final _formKeys = [
    GlobalKey<FormState>(), // Basic details
    GlobalKey<FormState>(), // Government identifiers
    GlobalKey<FormState>(), // Address
    GlobalKey<FormState>(), // Company verification documents
  ];
  final _companyPartnerFormKey = GlobalKey<FormState>();

  // INITIAL STATE/DISTRICT/CITY ID
  int stateMasterId = -1;
  int districtMasterId = -1;
  int cityMasterId = -1;

  // DROPDOWN VARIABLES
  late Map<String, dynamic> selectedCompanyType;
  late Map<String, dynamic> selectedGender;

  // DATE PICKER FOR DOB
  DateTime? dateOfBirth;

  // FILE VARIABLES
  MultiFilePickerModel gstCertificateFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPANCardFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel cinPhotoFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedCompanyLetterHeadHeaderFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedCompanyLetterHeadFooterFile =
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      );
  MultiFilePickerModel selectedPANForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedAadharForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedPhotoForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _companyMasterAddCubit = BlocProvider.of<CompanyMasterAddCubit>(context);
    _initializeTextEditingControllers(widget.company);
    _prefillCompanyDetails(widget.company);
  }

  @override
  void dispose() {
    super.dispose();
    _disposeTextEditingControllers();
    _companyMasterAddCubit.resetCompanyPartner();
  }

  // INITIALISING TEXT CONTROLLERS
  void _initializeTextEditingControllers(CompanyModel? company) {
    // BASIC COMPANY DETAILS
    _companyNameC = TextEditingController(text: company?.companyName);
    selectedCompanyType = companyTypeList[0];
    _contactPersonC = TextEditingController(text: company?.contactPerson);
    _mobileNumberC = TextEditingController(text: company?.mobileNumber);
    _emailIdC = TextEditingController(text: company?.emailId);
    _landLineNumberC = TextEditingController(text: company?.landLineNumber);
    // GOVERNMENT IDENTIFIERS
    _gstNumberC = TextEditingController(text: company?.gstNumber);
    _cinNumberC = TextEditingController(text: company?.cinNumber);
    _panNumberC = TextEditingController(text: company?.panNumber);
    _reraNumberC = TextEditingController(text: company?.reraNumber);
    _addressC = TextEditingController(text: "");
    // COMPANY PARTNER DETAILS
    _companyPartnerFirstNameC = TextEditingController();
    _companyPartnerMiddleNameC = TextEditingController();
    _companyPartnerLastNameC = TextEditingController();
    _companyPartnerMobileNumberC = TextEditingController();
    _companyPartnerEmailC = TextEditingController();
    _companyPartnerPercentageC = TextEditingController();
    _companyPartnerPanNumberC = TextEditingController();
    _companyPartnerAadharNumberC = TextEditingController();
  }

  // DISPOSE METHOD TO DISPOSE ALL TEXT CONTROLLERS
  void _disposeTextEditingControllers() {
    // BASIC COMPANY DETAILS
    _companyNameC.dispose();
    _contactPersonC.dispose();
    _mobileNumberC.dispose();
    _emailIdC.dispose();
    _landLineNumberC.dispose();
    // GOVERNMENT IDENTIFIERS
    _gstNumberC.dispose();
    _cinNumberC.dispose();
    _panNumberC.dispose();
    _reraNumberC.dispose();
    _addressC.dispose();
    // COMPANY PARTNER DETAILS
    _companyPartnerFirstNameC.dispose();
    _companyPartnerMiddleNameC.dispose();
    _companyPartnerLastNameC.dispose();
    _companyPartnerMobileNumberC.dispose();
    _companyPartnerEmailC.dispose();
    _companyPartnerPercentageC.dispose();
    _companyPartnerPanNumberC.dispose();
    _companyPartnerAadharNumberC.dispose();
  }

  // PREFILL COMPANY DETAILS
  Future<void> _prefillCompanyDetails(CompanyModel? company) async {
    // DROPDOWN INITIALIZATION
    selectedGender = genderList.first;
    stateMasterId = widget.company?.stateMasterId ?? -1;
    districtMasterId = widget.company?.districtMasterId ?? -1;
    cityMasterId = widget.company?.cityMasterId ?? -1;
    _companyMasterAddCubit.resetCompanyPartner(
      companyPartner: company?.companyPartnerData,
    );
    selectedCompanyType = companyTypeList.firstWhere(
      (element) => element['DisplayName'] == widget.company?.companyType,
      orElse: () => companyTypeList.first,
    );
    // FILES
    gstCertificateFile.fileNameList =
        company?.gstCertificateURL == null || company?.gstCertificateURL == ""
            ? []
            : company!.gstCertificateURL.split(",");
    gstCertificateFile.fileBytesList = List.generate(
      gstCertificateFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    selectedPANCardFile.fileNameList =
        company?.panCardURL == null || company?.panCardURL == ""
            ? []
            : company!.panCardURL.split(",");

    selectedPANCardFile.fileBytesList = List.generate(
      selectedPANCardFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    cinPhotoFile.fileNameList =
        company?.cinURL == null || company?.cinURL == ""
            ? []
            : company!.cinURL.split(",");

    cinPhotoFile.fileBytesList = List.generate(
      cinPhotoFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    selectedCompanyLetterHeadHeaderFile.fileNameList =
        company?.companyLetterheadHeaderURL == null ||
                company?.companyLetterheadHeaderURL == ""
            ? []
            : company!.companyLetterheadHeaderURL.split(",");

    selectedCompanyLetterHeadHeaderFile.fileBytesList = List.generate(
      selectedCompanyLetterHeadHeaderFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    selectedCompanyLetterHeadFooterFile.fileNameList =
        company?.companyLetterheadFooterURL == null ||
                company?.companyLetterheadFooterURL == ""
            ? []
            : company!.companyLetterheadFooterURL.split(",");

    selectedCompanyLetterHeadFooterFile.fileBytesList = List.generate(
      selectedCompanyLetterHeadFooterFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    if (company != null) {
      for (var value in company.companyPartnerData) {
        value.panCardFile = MultiFilePickerModel(
          fileBytesList: [],
          fileNameList:
              value.panCardURL == "" ? [] : value.panCardURL.split(","),
          deletedFileList: '',
        );

        value.panCardFile!.fileBytesList = List.generate(
          value.panCardFile!.fileNameList.length,
          (_) => Uint8List(0),
        );

        value.aadharCardFile = MultiFilePickerModel(
          fileBytesList: [],
          fileNameList:
              value.aadharCardURL == "" ? [] : value.aadharCardURL.split(","),
          deletedFileList: '',
        );

        value.aadharCardFile!.fileBytesList = List.generate(
          value.aadharCardFile!.fileNameList.length,
          (_) => Uint8List(0),
        );

        value.photoFile = MultiFilePickerModel(
          fileBytesList: [],
          fileNameList: value.photoURL == "" ? [] : value.photoURL.split(","),
          deletedFileList: '',
        );

        value.photoFile!.fileBytesList = List.generate(
          value.photoFile!.fileNameList.length,
          (_) => Uint8List(0),
        );
      }
    }
  }

  // PREFILL COMPANY PARTNER DETAILS
  void _prefillCompanyPartnerData(CompanyPartnerModel companyPartner) {
    _companyPartnerFirstNameC.text = companyPartner.firstName;
    _companyPartnerLastNameC.text = companyPartner.lastName;
    _companyPartnerMiddleNameC.text = companyPartner.middleName;
    _companyPartnerEmailC.text = companyPartner.emailId;
    _companyPartnerMobileNumberC.text = companyPartner.mobileNumber;
    _companyPartnerPercentageC.text =
        companyPartner.partnerPercentage.toString();
    _companyPartnerPanNumberC.text = companyPartner.panNumber;
    _companyPartnerAadharNumberC.text = companyPartner.aadharCardNumber;
    dateOfBirth = companyPartner.dateOfBirth;
    selectedGender = genderList.firstWhere(
      (element) => element['DisplayName'] == companyPartner.gender,
      orElse: () => genderList.first,
    );

    if (companyPartner.panCardFile != null) {
      selectedPANForPopUpFile.fileBytesList =
          companyPartner.panCardFile!.fileBytesList;
      selectedPANForPopUpFile.deletedFileList =
          companyPartner.panCardFile!.deletedFileList;
      selectedPANForPopUpFile.fileNameList =
          companyPartner.panCardFile!.fileNameList;
    } else {
      selectedPANForPopUpFile.fileNameList =
          companyPartner.panCardURL == ""
              ? []
              : companyPartner.panCardURL.split(",");

      selectedPANForPopUpFile.fileBytesList = List.generate(
        selectedPANForPopUpFile.fileNameList.length,
        (_) => Uint8List(0),
      );
    }

    if (companyPartner.aadharCardFile != null) {
      selectedAadharForPopUpFile.fileBytesList =
          companyPartner.aadharCardFile!.fileBytesList;
      selectedAadharForPopUpFile.deletedFileList =
          companyPartner.aadharCardFile!.deletedFileList;
      selectedAadharForPopUpFile.fileNameList =
          companyPartner.aadharCardFile!.fileNameList;
    } else {
      selectedAadharForPopUpFile.fileNameList =
          companyPartner.aadharCardURL == ""
              ? []
              : companyPartner.aadharCardURL.split(",");

      selectedAadharForPopUpFile.fileBytesList = List.generate(
        selectedAadharForPopUpFile.fileNameList.length,
        (_) => Uint8List(0),
      );
    }

    if (companyPartner.photoFile != null) {
      selectedPhotoForPopUpFile.fileBytesList =
          companyPartner.photoFile!.fileBytesList;
      selectedPhotoForPopUpFile.deletedFileList =
          companyPartner.photoFile!.deletedFileList;
      selectedPhotoForPopUpFile.fileNameList =
          companyPartner.photoFile!.fileNameList;
    } else {
      selectedPhotoForPopUpFile.fileNameList =
          companyPartner.photoURL == ""
              ? []
              : companyPartner.photoURL.split(",");

      selectedPhotoForPopUpFile.fileBytesList = List.generate(
        selectedPhotoForPopUpFile.fileNameList.length,
        (_) => Uint8List(0),
      );
    }
  }

  // RESET COMPANY PARTNER BOTTOM SHEET DETAILS
  void _resetCompanyPartnerPopup() {
    _companyPartnerFirstNameC.clear();
    _companyPartnerMiddleNameC.clear();
    _companyPartnerLastNameC.clear();
    _companyPartnerMobileNumberC.clear();
    _companyPartnerEmailC.clear();
    _companyPartnerPercentageC.clear();
    _companyPartnerPanNumberC.clear();
    _companyPartnerAadharNumberC.clear();

    selectedGender = genderList[0];
    dateOfBirth = null;

    selectedAadharForPopUpFile = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );

    selectedPANForPopUpFile = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );

    selectedPhotoForPopUpFile = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );
  }

  // ------------------------- UI SECTION BUILDERS ------------------------- //

  Widget _buildSectionContainer(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: commonCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: AppTextStyle.ts16M(color: AppColor.black.withValues(alpha: .5)),
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Details'),
          CustomTextField(
            title: 'Company Name',
            textController: _companyNameC,
            hint: "Enter Company Name",
            inputFormatterList: [LengthLimitingTextInputFormatter(50)],
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Company Name is required";
              }
              return null;
            },
          ),
          CustomDropDownWidget(
            title: "Company Type",
            initialValue: selectedCompanyType,
            dataList: companyTypeList,
            isRequired: true,
            onSelected: (value) {
              selectedCompanyType = value;
            },
            validator: (value) {
              if (value == null || value['zAttributesId'] == -1) {
                return 'Company Type is required';
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Contact Person',
            textController: _contactPersonC,
            hint: "Enter Contact Person Name",
            inputFormatterList: InputValidator.textOnly(50),
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Contact Person is required";
              }
              return null;
            },
          ),
          CustomTextField(
            title: 'Mobile Number',
            textController: _mobileNumberC,
            keyboardType: TextInputType.number,
            hint: "Enter Mobile Number",
            isRequired: true,
            inputFormatterList: InputValidator.digit(10),
            prefixWidget: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  const Text("+91"),
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
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Mobile Number is required";
              }
              if (!InputValidator.isValidMobileNumber(value)) {
                return "Invalid mobile number";
              }
              return null;
            },
          ),
          CustomTextField(
            textController: _emailIdC,
            title: "E-mail ID",
            hint: "Enter E-mail ID",
            isRequired: true,
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
          CustomTextField(
            title: 'Landline Number',
            textController: _landLineNumberC,
            hint: "Enter Landline Number",
            inputFormatterList: InputValidator.digit(20),
          ),
        ],
      ),
    );
  }

  Widget _buildGovernmentIdentifiersSection() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Government Identifiers'),
          CustomTextField(
            inputFormatterList: InputValidator.gstInputFormatters(),
            textController: _gstNumberC,
            title: "GST Number",
            hint: "Enter GST Number",
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'GST number is required';
              }
              if (!InputValidator.isValidGST(value)) {
                return 'Enter a valid GST number';
              }
              return null;
            },
          ),
          CustomMultiFilePicker(
            maxFiles: 3,
            initialFileList: gstCertificateFile.fileNameList,
            title: "Upload GST Certificate",
            isRequired: true,
            onFilePickedCallback: (fileByteList, fileNameList) {
              gstCertificateFile.fileBytesList = fileByteList;
              gstCertificateFile.fileNameList = fileNameList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedUrl) {
              gstCertificateFile.fileBytesList = fileBytesList;
              gstCertificateFile.fileNameList = fileNameList;
              gstCertificateFile.deletedFileList = deletedUrl;
            },
            validator: (file) {
              if (file == null || file.isEmpty) {
                return "GST Certificate required";
              }
              return null;
            },
          ),
          CustomTextField(
            title: "PAN Number",
            hint: "Enter PAN Number",
            textController: _panNumberC,
            inputFormatterList: InputValidator.panInputFormatters(),
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "PAN Number is required";
              }
              if (!InputValidator.isValidPAN(value)) {
                return "Invalid PAN number";
              }
              return null;
            },
          ),
          CustomMultiFilePicker(
            title: 'PAN URL',
            isRequired: true,
            initialFileList: selectedPANCardFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              selectedPANCardFile.fileNameList = fileNameList;
              selectedPANCardFile.fileBytesList = bytesList;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "PAN Card is required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              selectedPANCardFile.fileNameList = fileNameList;
              selectedPANCardFile.fileBytesList = fileBytesList;
              selectedPANCardFile.deletedFileList = deletedFile;
            },
          ),
          CustomTextField(
            title: "CIN Number",
            hint: "Enter CIN Number",
            isRequired: true,
            textController: _cinNumberC,
            inputFormatterList: InputValidator.cinInputFormatters(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Cin Number is required";
              }
              if (!InputValidator.isValidCIN(value)) {
                return "Invalid CIN number";
              }
              return null;
            },
          ),
          CustomMultiFilePicker(
            title: 'CIN URL',
            isRequired: true,
            initialFileList: cinPhotoFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              cinPhotoFile.fileNameList = fileNameList;
              cinPhotoFile.fileBytesList = bytesList;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "CIN Certificate is required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              cinPhotoFile.fileNameList = fileNameList;
              cinPhotoFile.fileBytesList = fileBytesList;
              cinPhotoFile.deletedFileList = deletedFile;
            },
          ),
          CustomTextField(
            title: 'RERA Number',
            hint: "Enter RERA Number",
            isRequired: true,
            textController: _reraNumberC,
            inputFormatterList: InputValidator.reraInputFormatters(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "RERA Number is required";
              }
              if (!InputValidator.isValidRERA(value)) {
                return "Invalid RERA number";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyVerificationDocumentSection() {
    return Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Company Verification Documents'),
          CustomMultiFilePicker(
            title: 'Company Letterhead Header',
            isRequired: true,
            initialFileList: selectedCompanyLetterHeadHeaderFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              selectedCompanyLetterHeadHeaderFile.fileNameList = fileNameList;
              selectedCompanyLetterHeadHeaderFile.fileBytesList = bytesList;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Company Letter Head Header is required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              selectedCompanyLetterHeadHeaderFile.fileNameList = fileNameList;
              selectedCompanyLetterHeadHeaderFile.fileBytesList = fileBytesList;
              selectedCompanyLetterHeadHeaderFile.deletedFileList = deletedFile;
            },
          ),
          CustomMultiFilePicker(
            title: 'Company Letterhead Footer',
            isRequired: true,
            initialFileList: selectedCompanyLetterHeadFooterFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              selectedCompanyLetterHeadFooterFile.fileNameList = fileNameList;
              selectedCompanyLetterHeadFooterFile.fileBytesList = bytesList;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Company Letter Head Footer is required";
              }
              return null;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              selectedCompanyLetterHeadFooterFile.fileNameList = fileNameList;
              selectedCompanyLetterHeadFooterFile.fileBytesList = fileBytesList;
              selectedCompanyLetterHeadFooterFile.deletedFileList = deletedFile;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Address Details'),
          CustomTextField(
            textController: _addressC,
            title: "Address",
            hint: "Enter Full Address",
            isRequired: true,
            inputFormatterList: [LengthLimitingTextInputFormatter(500)],
            // validator: (value) {
            //   if (value == null || value.trim().isEmpty) {
            //     return "Address is required";
            //   }
            //   return null;
            // },
          ),
          AddressWidget(
            formKey: _formKeys[2],
            incomingStateId: widget.company?.stateMasterId,
            incomingDistrictId: widget.company?.districtMasterId,
            incomingCityId: widget.company?.cityMasterId,
            stateChange: (selectedState) {
              stateMasterId = selectedState['zAttributesId'];
            },
            districtChange: (selectedDistrict) {
              districtMasterId = selectedDistrict['zAttributesId'];
            },
            cityChange: (selectedCity) {
              cityMasterId = selectedCity['zAttributesId'];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPartnerSection() {
    return BlocBuilder<CompanyMasterAddCubit, CompanyMasterAddState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionHeader('Company Partner'),
            if (_companyMasterAddCubit.state.companyPartner.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No partners added yet',
                    style: AppTextStyle.ts14R(color: AppColor.grey),
                  ),
                ),
              )
            else
              ..._companyMasterAddCubit.state.companyPartner
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildCompanyPartnerCard(
                      key: ValueKey(entry.value.hashCode),
                      companyPartnerModel: entry.value,
                      index: entry.key,
                    ),
                  ),
          ],
        );
      },
    );
  }

  // ADD COMPANY PARTNER BOTTOM SHEET
  void addCompanyPartnerBottomSheet({
    CompanyPartnerModel? companyPartnerData,
    int? index,
  }) async {
    if (companyPartnerData != null) {
      _prefillCompanyPartnerData(companyPartnerData);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "Company Partner Details",
      SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // keyboard handling
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Form(
          key: _companyPartnerFormKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'First Name*',
                      textController: _companyPartnerFirstNameC,
                      inputFormatterList: InputValidator.textOnly(50),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "First Name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomTextField(
                      title: 'Middle Name*',
                      textController: _companyPartnerMiddleNameC,
                      inputFormatterList: InputValidator.textOnly(50),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Middle Name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'Last Name*',
                      textController: _companyPartnerLastNameC,
                      inputFormatterList: InputValidator.textOnly(50),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Last Name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomDatePicker(
                      title: "DOB*",
                      initialDate: dateOfBirth,
                      setValue: (value) {
                        dateOfBirth = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Date of Birth is required";
                        }
                        if (!InputValidator.isValidAge(value)) {
                          return 'Age should be greater than or equal to 18.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomDropDownWidget(
                      title: "Gender*",
                      initialValue: selectedGender,
                      dataList: genderList,
                      onSelected: (value) {
                        selectedGender = value;
                      },
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return 'Gender is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomTextField(
                      title: 'Mobile Number*',
                      textController: _companyPartnerMobileNumberC,
                      validator: (value) {
                        if (value == null) {
                          return "Mobile is required";
                        }
                        if (!InputValidator.isValidMobileNumber(value)) {
                          return "Invalid mobile number";
                        }
                        return null;
                      },
                      inputFormatterList: InputValidator.digit(10),
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
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'Email Id*',
                      textController: _companyPartnerEmailC,
                      inputFormatterList: InputValidator.emailInputFormatters(),
                      keyboardType: TextInputType.emailAddress,
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
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomTextField(
                      title: 'Partner Percentage*',
                      textController: _companyPartnerPercentageC,
                      inputFormatterList: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                        ),
                      ],

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Partner percentage is required";
                        }

                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0 || parsed > 100) {
                          return "Enter a valid percentage between 1 and 100";
                        }

                        // ✅ Check if editing
                        final isEdit = index != null;
                        double currentEditingValue = 0;

                        if (isEdit) {
                          currentEditingValue =
                              _companyMasterAddCubit
                                  .state
                                  .companyPartner[index]
                                  .partnerPercentage;
                        }

                        final totalPercentage = _companyMasterAddCubit
                            .state
                            .companyPartner
                            .map((e) => e.partnerPercentage)
                            .fold<double>(0, (prev, element) => prev + element);

                        final adjustedTotal =
                            totalPercentage - currentEditingValue;

                        if (adjustedTotal + parsed > 100) {
                          final available = 100 - adjustedTotal;
                          return "Only $available% is available to allocate";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'PAN Number',
                      textController: _companyPartnerPanNumberC,
                      inputFormatterList: InputValidator.panInputFormatters(),
                      validator: (value) {
                        if (selectedPANForPopUpFile.fileBytesList.isNotEmpty &&
                            (value == null || value.trim().isEmpty)) {
                          return "PAN Number is required";
                        }
                        if (value != null &&
                            value.trim().isNotEmpty &&
                            !InputValidator.isValidPAN(value)) {
                          return "Invalid PAN Number";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomMultiFilePicker(
                      title: "Upload Pan Number",
                      initialFileList: selectedPANForPopUpFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedPANForPopUpFile.fileNameList = fileNameList;
                        selectedPANForPopUpFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedPANForPopUpFile.fileNameList = fileNameList;
                        selectedPANForPopUpFile.fileBytesList = fileBytesList;
                        selectedPANForPopUpFile.deletedFileList = deletedFile;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'Aadhaar Card Number*',
                      textController: _companyPartnerAadharNumberC,
                      inputFormatterList:
                          InputValidator.aadharNumberInputFormatter(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Aadhaar Card Number is required";
                        }

                        if (selectedAadharForPopUpFile
                                .fileBytesList
                                .isNotEmpty &&
                            value.trim().isEmpty) {
                          return "Aadhaar Card Number is required";
                        }

                        final enteredAadhar = value.trim();

                        if (!InputValidator.isValidAadharNumber(
                          enteredAadhar,
                        )) {
                          return "Invalid Aadhaar Card Number";
                        }

                        final isDuplicate = _companyMasterAddCubit
                            .state
                            .companyPartner
                            .any((e) {
                              final isSameIndex =
                                  index != null &&
                                  _companyMasterAddCubit.state.companyPartner
                                          .indexOf(e) ==
                                      index;
                              return e.aadharCardNumber == enteredAadhar &&
                                  !isSameIndex;
                            });

                        if (isDuplicate) {
                          return "Aadhaar Card Number already exists";
                        }

                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomMultiFilePicker(
                      title: "Upload Aadhaar Card",
                      initialFileList: selectedAadharForPopUpFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedAadharForPopUpFile.fileNameList = fileNameList;
                        selectedAadharForPopUpFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedAadharForPopUpFile.fileNameList = fileNameList;
                        selectedAadharForPopUpFile.fileBytesList =
                            fileBytesList;
                        selectedAadharForPopUpFile.deletedFileList =
                            deletedFile;
                      },
                    ),
                  ),
                ],
              ),
              CustomMultiFilePicker(
                title: "Upload Photo",
                initialFileList: selectedPhotoForPopUpFile.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedPhotoForPopUpFile.fileNameList = fileNameList;
                  selectedPhotoForPopUpFile.fileBytesList = bytesList;
                },
                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  selectedPhotoForPopUpFile.fileNameList = fileNameList;
                  selectedPhotoForPopUpFile.fileBytesList = fileBytesList;
                  selectedPhotoForPopUpFile.deletedFileList = deletedFile;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton.save(
                  onPressed: () {
                    if (_companyPartnerFormKey.currentState!.validate()) {
                      if (companyPartnerData != null) {
                        _companyMasterAddCubit.addUpdateCompanyPartnerData(
                          context: context,
                          CompanyPartnerModel(
                            companyPartnerId:
                                companyPartnerData.companyPartnerId,
                            firstName: _companyPartnerFirstNameC.text.trim(),
                            middleName: _companyPartnerMiddleNameC.text.trim(),
                            lastName: _companyPartnerLastNameC.text.trim(),
                            fullName:
                                "${_companyPartnerFirstNameC.text.trim()} ${_companyPartnerMiddleNameC.text.trim()} ${_companyPartnerLastNameC.text.trim()}",
                            dateOfBirth: dateOfBirth!,
                            emailId: _companyPartnerEmailC.text.trim(),
                            gender: selectedGender['DisplayName'],
                            mobileNumber: _companyPartnerMobileNumberC.text,
                            partnerPercentage:
                                double.tryParse(
                                  _companyPartnerPercentageC.text,
                                ) ??
                                0.0,
                            panNumber: _companyPartnerPanNumberC.text,
                            aadharCardNumber: _companyPartnerAadharNumberC.text,
                            uniquekey: companyPartnerData.uniquekey,
                            companyId: companyPartnerData.companyId,
                            panCardURL: '',
                            aadharCardURL: '',
                            photoURL: '',
                            createdById: companyPartnerData.createdById,
                            createdBy: companyPartnerData.createdBy,
                            createdDate: companyPartnerData.createdDate,
                            modifiedById: companyPartnerData.modifiedById,
                            modifiedBy: companyPartnerData.modifiedBy,
                            modifiedDate: companyPartnerData.modifiedDate,
                            panCardFile: selectedPANForPopUpFile,
                            aadharCardFile: selectedAadharForPopUpFile,
                            photoFile: selectedPhotoForPopUpFile,
                          ),
                          index: index,
                        );
                      } else {
                        _companyMasterAddCubit.addUpdateCompanyPartnerData(
                          context: context,
                          CompanyPartnerModel(
                            companyPartnerId: 0,
                            firstName: _companyPartnerFirstNameC.text.trim(),
                            middleName: _companyPartnerMiddleNameC.text.trim(),
                            lastName: _companyPartnerLastNameC.text.trim(),
                            fullName:
                                "${_companyPartnerFirstNameC.text.trim()} ${_companyPartnerMiddleNameC.text.trim()} ${_companyPartnerLastNameC.text.trim()}",
                            dateOfBirth: dateOfBirth!,
                            emailId: _companyPartnerEmailC.text.trim(),
                            gender: selectedGender['DisplayName'],
                            mobileNumber: _companyPartnerMobileNumberC.text,
                            partnerPercentage:
                                double.tryParse(
                                  _companyPartnerPercentageC.text,
                                ) ??
                                0.0,
                            panNumber: _companyPartnerPanNumberC.text,
                            aadharCardNumber: _companyPartnerAadharNumberC.text,
                            uniquekey: '',
                            companyId: widget.company?.companyId ?? 0,
                            panCardURL: '',
                            aadharCardURL: '',
                            photoURL: '',
                            createdById: -1,
                            createdBy: '',
                            createdDate: DateTime.now(),
                            modifiedById: -1,
                            modifiedBy: '',
                            modifiedDate: DateTime.now(),
                            panCardFile: selectedPANForPopUpFile,
                            aadharCardFile: selectedAadharForPopUpFile,
                            photoFile: selectedPhotoForPopUpFile,
                          ),
                        );
                      }
                      goRouter.pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _resetCompanyPartnerPopup();
  }

  // --------------------------- SUBMIT HANDLER --------------------------- //

  void _handleSubmit() {
    final isBasicValid = _formKeys[0].currentState?.validate() ?? false;
    final isGovValid = _formKeys[1].currentState?.validate() ?? false;
    final isAddressValid = _formKeys[2].currentState?.validate() ?? false;
    final isVerificationValid = _formKeys[3].currentState?.validate() ?? false;

    if (!isBasicValid ||
        !isGovValid ||
        !isAddressValid ||
        !isVerificationValid) {
      return;
    }

    if (widget.company == null) {
      _companyMasterAddCubit.addCompanyMaster(
        context: context,
        companyName: _companyNameC.text.trim(),
        companyType: selectedCompanyType["DisplayName"],
        contactPerson: _contactPersonC.text.trim(),
        mobileNumber: _mobileNumberC.text,
        emailId: _emailIdC.text.trim(),
        landLineNumber: _landLineNumberC.text,
        gstNumber: _gstNumberC.text,
        gstCertificateFile: gstCertificateFile,
        cinNumber: _cinNumberC.text,
        cinFile: cinPhotoFile,
        panNumber: _panNumberC.text,
        reraNumber: _reraNumberC.text,
        panCardFile: selectedPANCardFile,
        companyLetterheadHeaderFile: selectedCompanyLetterHeadHeaderFile,
        companyLetterheadFooterFile: selectedCompanyLetterHeadFooterFile,
        countryId: 1,
        stateId: stateMasterId,
        districtId: districtMasterId,
        cityId: cityMasterId,
        pageNumber: 1,
        pageSize: 10,
      );
    } else {
      _companyMasterAddCubit.updateCompanyMaster(
        context: context,
        pageNumber: 1,
        pageSize: 10,
        companyId: widget.company!.companyId,
        uniquekey: widget.company!.uniquekey,
        companyName: _companyNameC.text.trim(),
        companyType: selectedCompanyType["DisplayName"],
        contactPerson: _contactPersonC.text.trim(),
        mobileNumber: _mobileNumberC.text,
        emailId: _emailIdC.text.trim(),
        landLineNumber: _landLineNumberC.text,
        gstNumber: _gstNumberC.text,
        gstCertificateFile: gstCertificateFile,
        cinNumber: _cinNumberC.text,
        cinFile: cinPhotoFile,
        panNumber: _panNumberC.text,
        panCardFile: selectedPANCardFile,
        reraNumber: _reraNumberC.text,
        companyLetterheadHeaderFile: selectedCompanyLetterHeadHeaderFile,
        companyLetterheadFooterFile: selectedCompanyLetterHeadFooterFile,
        countryId: 1,
        stateId: stateMasterId,
        districtId: districtMasterId,
        cityId: cityMasterId,
      );
    }
  }

  Widget _buildCompanyPartnerCard({
    Key? key,
    required CompanyPartnerModel companyPartnerModel,
    int? index,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPartnerField("Name", companyPartnerModel.fullName),
              ),
              Row(
                children: [
                  CustomIconButton(
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.addCompanyPartner,
                        extra: {
                          "partner": companyPartnerModel,
                          "index": index,
                          "cubit": _companyMasterAddCubit,
                        },
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    backgroundColor: AppColor.lightGrey,
                  ),
                  horizontalSpacing(width: 8),
                  CustomIconButton(
                    onPressed: () {
                      if (index != null) {
                        _companyMasterAddCubit.deleteCompanyPartnerData(
                          context,
                          index,
                        );
                      }
                    },
                    icon: SvgPicture.asset(
                      AppAssets.deleteIcon2,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        AppColor.red,
                        BlendMode.srcIn,
                      ),
                    ),
                    backgroundColor: AppColor.lightRed,
                  ),
                ],
              ),
            ],
          ),

          verticalSpacing(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildPartnerField(
                  "Contact No.",
                  companyPartnerModel.mobileNumber,
                ),
              ),
              Expanded(
                child: _buildPartnerField(
                  "Share%",
                  "${companyPartnerModel.partnerPercentage.toStringAsFixed(1)}%",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.ts12R(color: AppColor.grey)),
          Text(value, style: AppTextStyle.ts14R()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Company",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.company == null ? "Add Company" : "Edit Company",
                    style: AppTextStyle.ts16SB(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildBasicDetailsSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildGovernmentIdentifiersSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildAddressSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(
                _buildCompanyVerificationDocumentSection(),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _buildSectionContainer(_buildCompanyPartnerSection()),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: SizedBox(height: 50)), // padding bottom
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: CustomButton(
                  text: widget.company == null ? 'Save' : 'Update',
                  onPressed: _handleSubmit,
                  backgroundColor: AppColor.primary,
                ),
              ),
              Expanded(
                child: CustomButton(
                  text: 'Add Company Partner',
                  onPressed: () async {
                    goRouter.pushNamed(
                      AppRoutes.addCompanyPartner,
                      extra: {"cubit": _companyMasterAddCubit},
                    );
                  },
                  backgroundColor: AppColor.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
