import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_floating_action_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class AddCompanyMasterScreen extends StatefulWidget {
  final CompanyModel? company;
  const AddCompanyMasterScreen({super.key, this.company});

  @override
  State<AddCompanyMasterScreen> createState() =>
      _AddCompanyMasterMobileScreenState();
}

class _AddCompanyMasterMobileScreenState
    extends State<AddCompanyMasterScreen> {

  // CUBIT
  late CompanyMasterAddCubit _companyMasterAddCubit;

  // PAGE CONTROLLER AND CURRENT PAGE
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  final int totalPages = 5;

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

  // FORM KEYS
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
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
    _pageController.dispose();
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

  // BASIC DETAILS VIEW
  Widget _buildBasicDetailsView() {
    return Form(
      key: _formKeys[0],
      child: Container(
        color: AppColor.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Company Details', style: AppTextStyle.ts16R()),
              verticalSpacing(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'Company Name*',
                      textController: _companyNameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Company Name is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomDropDownWidget(
                      title: "Company Type*",
                      initialValue: selectedCompanyType,
                      dataList: companyTypeList,
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
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'Contact Person*',
                      textController: _contactPersonC,
                      inputFormatterList: InputValidator.textOnly(50),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Contact Person is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomTextField(
                      title: 'Mobile Number*',
                      textController: _mobileNumberC,
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
                      validator: (value) {
                        if (value == null) {
                          return "Mobile number is required";
                        }
                        if (!InputValidator.isValidMobileNumber(value)) {
                          return "Invalid mobile number";
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
                      title: 'Email Id*',
                      textController: _emailIdC,
                      inputFormatterList: InputValidator.emailInputFormatters(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Email id is required";
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
                      title: 'Landline Number',
                      textController: _landLineNumberC,
                      inputFormatterList: InputValidator.digit(20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // GOVERNMENT IDENTIFIERS VIEW
  Widget _buildGovernmentIdentifiersView() {
    return Form(
      key: _formKeys[1],
      child: Container(
        color: AppColor.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Government Identifiers', style: AppTextStyle.ts16R()),
              verticalSpacing(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: 'GST Number*',
                      textController: _gstNumberC,
                      inputFormatterList: InputValidator.gstInputFormatters(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "GST Number is required";
                        }
                        if (!InputValidator.isValidGST(value)) {
                          return "Invalid GST number";
                        }
                        return null;
                      },
                    ),
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomMultiFilePicker(
                      title: 'GST Certificate*',
                      initialFileList: gstCertificateFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        gstCertificateFile.fileNameList = fileNameList;
                        gstCertificateFile.fileBytesList = bytesList;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "GST Certificate is required";
                        }
                        return null;
                      },
                      onFileDeleteCallback: (
                          fileBytesList,
                          fileNameList,
                          deletedFile,
                          ) {
                        gstCertificateFile.fileNameList = fileNameList;
                        gstCertificateFile.fileBytesList = fileBytesList;
                        gstCertificateFile.deletedFileList = deletedFile;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: "PAN Number*",
                      textController: _panNumberC,
                      inputFormatterList: InputValidator.panInputFormatters(),

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
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomMultiFilePicker(
                      title: 'PAN URL*',
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
                      onFileDeleteCallback: (
                          fileBytesList,
                          fileNameList,
                          deletedFile,
                          ) {
                        selectedPANCardFile.fileNameList = fileNameList;
                        selectedPANCardFile.fileBytesList = fileBytesList;
                        selectedPANCardFile.deletedFileList = deletedFile;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: "CIN Number*",
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
                  ),
                  horizontalSpacing(),
                  Expanded(
                    child: CustomMultiFilePicker(
                      title: 'CIN URL*',
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
                      onFileDeleteCallback: (
                          fileBytesList,
                          fileNameList,
                          deletedFile,
                          ) {
                        cinPhotoFile.fileNameList = fileNameList;
                        cinPhotoFile.fileBytesList = fileBytesList;
                        cinPhotoFile.deletedFileList = deletedFile;
                      },
                    ),
                  ),
                ],
              ),
              CustomTextField(
                title: 'RERA Number*',
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
        ),
      ),
    );
  }

  // ADDRESS VIEW
  Widget _buildAddressView() {
    return Form(
      key: _formKeys[2],
      child: Container(
        color: AppColor.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address', style: AppTextStyle.ts16R()),
              verticalSpacing(height: 12),
              AddressWidget(
                formKey: _companyPartnerFormKey,
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
        ),
      ),
    );
  }

  // COMPANY VERIFICATION VIEW
  Widget _buildCompanyVerificationView() {
    return Form(
      key: _formKeys[3],
      child: Container(
        color: AppColor.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Verification', style: AppTextStyle.ts16R()),
              verticalSpacing(height: 12),
              CustomMultiFilePicker(
                title: 'Company Letterhead Header*',
                initialFileList:
                selectedCompanyLetterHeadHeaderFile.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedCompanyLetterHeadHeaderFile.fileNameList =
                      fileNameList;
                  selectedCompanyLetterHeadHeaderFile.fileBytesList = bytesList;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Company Letter Head Header is required";
                  }
                  return null;
                },
                onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                    ) {
                  selectedCompanyLetterHeadHeaderFile.fileNameList =
                      fileNameList;
                  selectedCompanyLetterHeadHeaderFile.fileBytesList =
                      fileBytesList;
                  selectedCompanyLetterHeadHeaderFile.deletedFileList =
                      deletedFile;
                },
              ),
              CustomMultiFilePicker(
                title: 'Company Letterhead Footer*',
                initialFileList:
                selectedCompanyLetterHeadFooterFile.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedCompanyLetterHeadFooterFile.fileNameList =
                      fileNameList;
                  selectedCompanyLetterHeadFooterFile.fileBytesList = bytesList;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Company Letter Head Footer is required";
                  }
                  return null;
                },
                onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                    ) {
                  selectedCompanyLetterHeadFooterFile.fileNameList =
                      fileNameList;
                  selectedCompanyLetterHeadFooterFile.fileBytesList =
                      fileBytesList;
                  selectedCompanyLetterHeadFooterFile.deletedFileList =
                      deletedFile;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COMPANY PARTNER VIEW
  Widget _buildCompanyPartnerView() {
    return Container(
      color: AppColor.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: BlocBuilder<CompanyMasterAddCubit, CompanyMasterAddState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Verification', style: AppTextStyle.ts16R()),
              verticalSpacing(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _companyMasterAddCubit.state.companyPartner.length,
                  itemBuilder: (context, partnerIndex) {
                    return _buildCompanyPartnerCard(
                      key: ValueKey(
                        _companyMasterAddCubit.state.companyPartner.hashCode,
                      ),
                      companyPartnerModel:
                      _companyMasterAddCubit
                          .state
                          .companyPartner[partnerIndex],
                      index: partnerIndex,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
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

  // FLOATING ACTION BUTTON WIDGET
  Widget? _buildFloatingActionButton() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, child) {
        if (currentPage == 4) {
          return Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: CommonFloatingActionButton(
              onPressed: () async {
                addCompanyPartnerBottomSheet();
              },
              backgroundColor: AppColor.yellow,
            ),
          );
        }
        return Container(); // returning null is fine here
      },
    );
  }

  // COMPANY PARTNER CARD
  Widget _buildCompanyPartnerCard({
    Key? key,
    required CompanyPartnerModel companyPartnerModel,
    int? index,
  }) {
    return StatefulBuilder(
      key: key,
      builder: (context, localSetState) {
        var isExpanded = ValueNotifier(false);

        return ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (context, value, _) {
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.pink.shade100,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.fullName,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.grey.withValues(
                                          alpha: 0.4,
                                        ),
                                        spreadRadius: 2,
                                        blurRadius: 20,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: SimpleCircularProgressBar(
                                      progressColors: [AppColor.green],
                                      maxValue: 100,
                                      backStrokeWidth: 4,
                                      progressStrokeWidth: 4,
                                      valueNotifier: ValueNotifier(
                                        companyPartnerModel.partnerPercentage,
                                      ),
                                      size: 60,
                                      backColor: AppColor.grey.withValues(
                                        alpha: 0.2,
                                      ),
                                      mergeMode: true,
                                      onGetText:
                                          (double value) => Text(
                                        '${value.toInt()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Share", style: AppTextStyle.ts12M()),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Gender :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.gender,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile Number :",
                                    style: AppTextStyle.ts12R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  Text(
                                    companyPartnerModel.mobileNumber,
                                    style: AppTextStyle.ts14R(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (value)
                    AnimatedSize(
                      alignment: Alignment.centerLeft,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child:
                      isExpanded.value
                          ? Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DOB :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        formatDateTimeAsDDMMYYYY(
                                          companyPartnerModel
                                              .dateOfBirth,
                                        ),
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Email Id :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        companyPartnerModel.emailId,
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "PAN Card :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        companyPartnerModel
                                            .panNumber
                                            .isNotEmpty
                                            ? companyPartnerModel
                                            .panNumber
                                            : "-",
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Aadhaar Card :",
                                        style: AppTextStyle.ts12R(
                                          color: AppColor.grey,
                                        ),
                                      ),
                                      Text(
                                        companyPartnerModel
                                            .aadharCardNumber
                                            .isNotEmpty
                                            ? companyPartnerModel
                                            .aadharCardNumber
                                            : "-",
                                        style: AppTextStyle.ts14R(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          : SizedBox.shrink(),
                    ),

                  Container(
                    color: AppColor.grey.withValues(alpha: 0.05),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                addCompanyPartnerBottomSheet(
                                  companyPartnerData: companyPartnerModel,
                                  index: index,
                                );
                              },
                              child: SvgPicture.asset(
                                AppAssets.editIcon,
                                height: 24,
                              ),
                            ),
                            horizontalSpacing(width: 20),
                            GestureDetector(
                              onTap: () {
                                _companyMasterAddCubit.deleteCompanyPartnerData(
                                  context,
                                  index!,
                                );
                              },
                              child: SvgPicture.asset(
                                AppAssets.deleteIcon,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => isExpanded.value = !isExpanded.value,
                          child: AnimatedRotation(
                            turns: isExpanded.value ? 0.5 : 0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColor.primary),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 24,
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            goRouter.pop();
          },
          child: Icon(Icons.arrow_back_ios, color: AppColor.black),
        ),
        title: Text('Add Details', style: AppTextStyle.ts16R()),
      ),
      body: Column(
        children: [
          Container(
            color: AppColor.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                Flexible(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (context, currentPage, child) {
                      return LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(12),
                        value: (currentPage + 1) / totalPages,
                        backgroundColor: AppColor.grey.withValues(alpha: 0.5),
                        color: AppColor.slightDarkBlue,
                        minHeight: 8,
                      );
                    },
                  ),
                ),
                horizontalSpacing(),
                ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Text(
                      '${_currentPageNotifier.value + 1}/$totalPages',
                      style: AppTextStyle.ts12M(),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(color: AppColor.grey.withValues(alpha: 0.3), height: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                _currentPageNotifier.value = index;
              },
              children: [
                KeepAlivePage(child: _buildBasicDetailsView()),
                KeepAlivePage(child: _buildGovernmentIdentifiersView()),
                KeepAlivePage(child: _buildAddressView()),
                KeepAlivePage(child: _buildCompanyVerificationView()),
                KeepAlivePage(child: _buildCompanyPartnerView()),
              ],
            ),
          ),
          ColoredBox(
            color: AppColor.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPageNotifier,
                builder: (context, value, child) {
                  return Row(
                    spacing: 20,
                    children: [
                      Expanded(
                        child:
                        value > 0
                            ? CustomButton(
                          onPressed: () {
                            _pageController.jumpToPage(
                              _currentPageNotifier.value - 1,
                            );
                          },
                          text: 'Previous',
                          textColor: AppColor.green,
                          backgroundColor: AppColor.white,
                          borderColor: AppColor.green,
                        )
                            : SizedBox(),
                      ),

                      Expanded(
                        child:
                        value == 4
                            ? CustomButton.save(
                          onPressed: () async {
                            if (widget.company == null) {
                              _companyMasterAddCubit.addCompanyMaster(
                                context: context,
                                companyName: _companyNameC.text.trim(),
                                companyType:
                                selectedCompanyType["DisplayName"],
                                contactPerson:
                                _contactPersonC.text.trim(),
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
                                companyLetterheadHeaderFile:
                                selectedCompanyLetterHeadHeaderFile,
                                companyLetterheadFooterFile:
                                selectedCompanyLetterHeadFooterFile,
                                countryId: 1,
                                stateId: stateMasterId,
                                districtId: districtMasterId,
                                cityId: cityMasterId,
                                pageNumber: 1,
                                pageSize: 10,
                              );
                            } else {
                              await _companyMasterAddCubit.updateCompanyMaster(
                                context: context,
                                pageNumber: 1,
                                pageSize: 10,
                                companyId: widget.company!.companyId,
                                uniquekey: widget.company!.uniquekey,
                                companyName: _companyNameC.text.trim(),
                                companyType:
                                selectedCompanyType["DisplayName"],
                                contactPerson:
                                _contactPersonC.text.trim(),
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
                                companyLetterheadHeaderFile:
                                selectedCompanyLetterHeadHeaderFile,
                                companyLetterheadFooterFile:
                                selectedCompanyLetterHeadFooterFile,
                                countryId: 1,
                                stateId: stateMasterId,
                                districtId: districtMasterId,
                                cityId: cityMasterId,
                              );
                            }
                          },
                        )
                            : CustomButton(
                          onPressed: () {
                            if (_currentPageNotifier.value < 4) {
                              final formKey =
                              _formKeys[_currentPageNotifier.value];
                              final formState = formKey.currentState;

                              if (formState != null &&
                                  formState.validate()) {
                                _pageController.jumpToPage(
                                  _currentPageNotifier.value + 1,
                                );
                              }
                            } else {
                              // For non-form pages, directly go to the next page
                              _pageController.jumpToPage(
                                _currentPageNotifier.value + 1,
                              );
                            }
                          },
                          text: 'Next',
                          backgroundColor: AppColor.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  int counter = 0;

  @override
  bool get wantKeepAlive => true; // Tells Flutter to keep the widget alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important when using AutomaticKeepAliveClientMixin

    return widget.child;
  }
}
