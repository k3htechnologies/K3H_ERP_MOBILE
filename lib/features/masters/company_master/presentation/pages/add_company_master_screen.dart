import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
      _tanNumberC,
      // COMPANY PARTNER TEXT CONTROLLER
      _companyPartnerFirstNameC,
      _companyPartnerMiddleNameC,
      _companyPartnerLastNameC,
      _companyPartnerMobileNumberC,
      _companyPartnerEmailC,
      _companyPartnerPercentageC,
      _companyPartnerPanNumberC,
      _companyPartnerAadharNumberC;

  // COMPANY TYPE LIST
  List<Map<String, dynamic>> firmTypeList = [
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

  // INITIAL STATE/DISTRICT/CITY ID
  int stateMasterId = -1;
  int districtMasterId = -1;
  int cityMasterId = -1;

  // DROPDOWN VARIABLES
  late Map<String, dynamic> selectedFirmType;
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
  MultiFilePickerModel selectedTANFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // EDIT MODE
  bool get _isEditMode => widget.company != null;

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
    selectedFirmType = firmTypeList[0];
    _contactPersonC = TextEditingController(text: company?.contactPerson);
    _mobileNumberC = TextEditingController(text: company?.mobileNumber);
    _emailIdC = TextEditingController(text: company?.emailId);
    _landLineNumberC = TextEditingController(text: company?.landLineNumber);
    // GOVERNMENT IDENTIFIERS
    _gstNumberC = TextEditingController(text: company?.gstNumber);
    _cinNumberC = TextEditingController(text: company?.cinNumber);
    _panNumberC = TextEditingController(text: company?.panNumber);
    _tanNumberC = TextEditingController(text: company?.tanNumber);
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
    _tanNumberC.dispose();
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
    selectedFirmType = firmTypeList.firstWhere(
      (element) => element['DisplayName'] == widget.company?.firmsType,
      orElse: () => firmTypeList.first,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Company Master",
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
                    _isEditMode ? "Update Company" : "Add Company",
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
            SliverToBoxAdapter(child: SizedBox(height: 12)),
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
          height: 70,
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Flexible(
                child: CustomButton(
                  text: !_isEditMode ? 'Save' : 'Update',
                  onPressed: _handleSubmit,
                  backgroundColor: AppColor.primary,
                ),
              ),
              Flexible(
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

  // BUILD BASIC DETAILS SECTION
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
          StatefulBuilder(
            builder: (_, innerState) {
              return CustomDropDownWidget(
                title: "Firms Type",
                initialValue: selectedFirmType,
                dataList: firmTypeList,
                isRequired: true,
                onSelected: (value) {
                  innerState(() {
                    selectedFirmType = value;
                  });
                },
                validator: (_) {
                  // Validate against selectedFirmType (source of truth used on submit)
                  if (selectedFirmType['zAttributesId'] == -1) {
                    return 'Firm Type is required';
                  }
                  return null;
                },
              );
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

  // BUILD GOVERNMENT IDENTIFIERS SECTION
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
          ),
          CustomMultiFilePicker(
            maxFiles: 3,
            filePickType: FilePickType.both,
            initialFileList: gstCertificateFile.fileNameList,
            title: "GST Certificate",
            onFilePickedCallback: (fileByteList, fileNameList) {
              gstCertificateFile.fileBytesList = fileByteList;
              gstCertificateFile.fileNameList = fileNameList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedUrl) {
              gstCertificateFile.fileBytesList = fileBytesList;
              gstCertificateFile.fileNameList = fileNameList;
              gstCertificateFile.deletedFileList = deletedUrl;
            },
          ),
          CustomTextField(
            title: "PAN Number",
            hint: "Enter PAN Number",
            textController: _panNumberC,
            inputFormatterList: InputValidator.panInputFormatters(),
          ),
          CustomMultiFilePicker(
            title: 'PAN Card',
            filePickType: FilePickType.both,
            initialFileList: selectedPANCardFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              selectedPANCardFile.fileNameList = fileNameList;
              selectedPANCardFile.fileBytesList = bytesList;
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
            textController: _cinNumberC,
            inputFormatterList: InputValidator.cinInputFormatters(),
          ),
          CustomMultiFilePicker(
            title: 'CIN',
            filePickType: FilePickType.both,
            initialFileList: cinPhotoFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              cinPhotoFile.fileNameList = fileNameList;
              cinPhotoFile.fileBytesList = bytesList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              cinPhotoFile.fileNameList = fileNameList;
              cinPhotoFile.fileBytesList = fileBytesList;
              cinPhotoFile.deletedFileList = deletedFile;
            },
          ),
          CustomTextField(
            title: 'TAN Number',
            hint: "Enter TAN Number",
            textController: _tanNumberC,
            inputFormatterList: InputValidator.reraInputFormatters(),
          ),
          CustomMultiFilePicker(
            title: 'TAN',
            filePickType: FilePickType.both,
            initialFileList: selectedTANFile.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              selectedTANFile.fileNameList = fileNameList;
              selectedTANFile.fileBytesList = bytesList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
              selectedTANFile.fileNameList = fileNameList;
              selectedTANFile.fileBytesList = fileBytesList;
              selectedTANFile.deletedFileList = deletedFile;
            },
          ),
        ],
      ),
    );
  }

  // BUILD COMPANY VERIFICATION DOCUMENTS SECTION
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
            filePickType: FilePickType.both,
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
            filePickType: FilePickType.both,
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

  // BUILD ADDRESS SECTION
  Widget _buildAddressSection() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Address Details'),
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

  // BUILD COMPANY PARTNER SECTION
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

  // --------------------------- SUBMIT HANDLER --------------------------- //

  // SUBMIT HANDLER
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
        firmsType: selectedFirmType["DisplayName"],
        contactPerson: _contactPersonC.text.trim(),
        mobileNumber: _mobileNumberC.text,
        emailId: _emailIdC.text.trim(),
        landLineNumber: _landLineNumberC.text,
        gstNumber: _gstNumberC.text,
        gstCertificateFile: gstCertificateFile,
        cinNumber: _cinNumberC.text,
        cinFile: cinPhotoFile,
        panNumber: _panNumberC.text,
        tanNumber: _tanNumberC.text,
        panCardFile: selectedPANCardFile,
        companyLetterheadHeaderFile: selectedCompanyLetterHeadHeaderFile,
        companyLetterheadFooterFile: selectedCompanyLetterHeadFooterFile,
        countryId: 1,
        stateId: stateMasterId,
        districtId: districtMasterId,
        cityId: cityMasterId,
        tanFile: selectedTANFile,
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
        firmsType: selectedFirmType["DisplayName"],
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
        tanNumber: _tanNumberC.text,
        companyLetterheadHeaderFile: selectedCompanyLetterHeadHeaderFile,
        companyLetterheadFooterFile: selectedCompanyLetterHeadFooterFile,
        countryId: 1,
        stateId: stateMasterId,
        districtId: districtMasterId,
        cityId: cityMasterId,
        tanFile: selectedTANFile,
      );
    }
  }

  // BUILD COMPANY PARTNER CARD
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
                  CustomIconButton.edit(
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
                  ),
                  horizontalSpacing(width: 8),
                  CustomIconButton.delete(
                    onPressed: () {
                      if (index != null) {
                        _companyMasterAddCubit.deleteCompanyPartnerData(
                          context,
                          index,
                        );
                      }
                    },
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

  // BUILD PARTNER FIELD
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
}
