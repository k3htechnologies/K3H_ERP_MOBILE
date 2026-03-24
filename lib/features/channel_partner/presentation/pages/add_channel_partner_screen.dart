import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/custom_verification_dialog.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddChannelPartnerScreen extends StatefulWidget {
  final ChannelPartnerModel? channelPartnerModel;
  final int? index;

  const AddChannelPartnerScreen({
    super.key,
    this.channelPartnerModel,
    this.index = 0,
  });

  @override
  State<AddChannelPartnerScreen> createState() =>
      _AddChannelPartnerScreenState();
}

class _AddChannelPartnerScreenState extends State<AddChannelPartnerScreen> {
  // CUBIT
  late ChannelPartnerCubit _channelPartnerCubit;
  late LoginCubit _loginCubit;

  //EDIT MODE
  bool get _isEditMode => widget.channelPartnerModel != null;

  // REPOSITORY

  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();

  // TEXT EDITING CONTROLLER
  late TextEditingController _nameC,
      _emailC,
      _mobileNumberC,
      _alternateMobileNumberC,
      _panNumberC,
      _aadhaarNumberC,
      _companyNameC,
      _reraNumberC,
      _gstNumberC,
      _officeAddressC,
      _filterLocalityC,
      _otpController;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // SELECT EARNING
  List<Map<String, dynamic>> _selectedDesignation = [];

  // STATIC LIST
  List<Map<String, dynamic>> designationList = [
    {"zAttributesId": 1, "DisplayName": "Business Head"},
    {"zAttributesId": 2, "DisplayName": "Cluster Head"},
    {"zAttributesId": 3, "DisplayName": "Owner"},
    {"zAttributesId": 4, "DisplayName": "Partner"},
    {"zAttributesId": 5, "DisplayName": "Team Member"},
  ];

  @override
  void initState() {
    super.initState();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _loginCubit = context.read<LoginCubit>();
    _initializeTextEditingController();
    selectedGSTCertificateForPopUpFile = ValueNotifier(
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      ),
    );
    selectedCompanyType = ValueNotifier<Map<String, dynamic>>(
      companyTypeList[0],
    );
    selectedFirmsType = ValueNotifier(firmsType[0]);
    hasReraNumber = ValueNotifier(false);
    selectedCompany = ValueNotifier([]);
    selectedType = type[0];
    if (_isEditMode) {
      _prefillChannelPartner(widget.channelPartnerModel!);
    }
  }

  @override
  void dispose() {
    // CONTROLLERS
    _nameC.dispose();
    _emailC.dispose();
    _mobileNumberC.dispose();
    _alternateMobileNumberC.dispose();
    _panNumberC.dispose();
    _aadhaarNumberC.dispose();
    _companyNameC.dispose();
    _reraNumberC.dispose();
    _gstNumberC.dispose();
    _officeAddressC.dispose();
    _filterLocalityC.dispose();
    _otpController.dispose();

    // VALUE NOTIFIERS
    selectedCompanyType.dispose();
    selectedFirmsType.dispose();
    selectedCompany.dispose();
    hasReraNumber.dispose();
    selectedGSTCertificateForPopUpFile.dispose();
    super.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _nameC = TextEditingController();
    _emailC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _alternateMobileNumberC = TextEditingController();
    _panNumberC = TextEditingController();
    _aadhaarNumberC = TextEditingController();
    _companyNameC = TextEditingController();
    _reraNumberC = TextEditingController();
    _gstNumberC = TextEditingController();
    _officeAddressC = TextEditingController();
    _filterLocalityC = TextEditingController();
    _otpController = TextEditingController();
  }

  // FILE VARIABLES
  MultiFilePickerModel selectedPANForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedAadhaarForPopUpFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late ValueNotifier<MultiFilePickerModel> selectedGSTCertificateForPopUpFile;

  // DROPDOWN VARIABLES
  final List<Map<String, dynamic>> specialityList = [
    {"zAttributesId": 1, "DisplayName": "Commercial Sale"},
    {"zAttributesId": 2, "DisplayName": "Commercial Leasing"},
    {"zAttributesId": 3, "DisplayName": "Residential Sale"},
    {"zAttributesId": 4, "DisplayName": "Office Sale"},
    {"zAttributesId": 5, "DisplayName": "Office Leasing"},
  ];

  final List<Map<String, dynamic>> companyTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Company Type"},
    {"zAttributesId": 1, "DisplayName": "New Company"},
    {"zAttributesId": 2, "DisplayName": "Existing Company"},
  ];

  final List<Map<String, dynamic>> firmsType = [
    {"zAttributesId": -1, "DisplayName": "Select Firms Type"},
    {"zAttributesId": 1, "DisplayName": "LLP"},
    {"zAttributesId": 2, "DisplayName": "Private Limited Company"},
    {"zAttributesId": 3, "DisplayName": "Proprietorship"},
  ];

  final List<Map<String, dynamic>> type = [
    {"zAttributesId": -1, "DisplayName": "Select Type"},
    {"zAttributesId": 1, "DisplayName": "International Channel Partner (IPC)"},
    {"zAttributesId": 2, "DisplayName": "Institutional Channel Partner (ICP)"},
    {"zAttributesId": 3, "DisplayName": "Retail Channel Partner (RCP)"},
  ];

  // SELECTION VARIABLE
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedVillage;
  Map<String, dynamic>? selectedSpeciality;
  late Map<String, dynamic> selectedSpecialityFilter;
  late ValueNotifier<Map<String, dynamic>> selectedCompanyType;
  late ValueNotifier<Map<String, dynamic>> selectedFirmsType;
  late Map<String, dynamic> selectedType;
  // MULTI SELECT FOR PROJECTS, SINGLE SELECT FOR COMPANY
  late ValueNotifier<List<Map<String, dynamic>>> selectedCompany;
  late ValueNotifier<bool> hasReraNumber;

  // FETCH COMPANY LIST FOR EXISTING COMPANY FLOW
  Future<Map<String, dynamic>> _fetchChannelPartnerList(
    int pageNumber, {
    String? value,
  }) async {
    try {
      final result = await _channelPartnerRepository
          .getChannelPartnerCompanyList(
            pageNumber: pageNumber,
            pageSize: 15,
            queryParams:
                value != null && value.isNotEmpty
                    ? {
                      "ProjectId": getProject().projectId,
                      "CompanyName": value,
                    }
                    : {"ProjectId": getProject().projectId},
          );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final List<dynamic> partners = response['data'] ?? [];

          final itemList =
              partners.map((c) {
                return {
                  'zAttributesId': c['ChannelPartnerId'],
                  'DisplayName': c['CompanyName'],
                };
              }).toList();

          return {
            'itemList': itemList,
            'totalNumberOfRecord':
                response['totalNumberOfRecord'] ?? itemList.length,
          };
        },
      );
    } catch (error) {
      return {'itemList': [], 'totalNumberOfRecord': 0};
    }
  }

  // PULL CHANNEL PARTNER MASTER
  Future<void> _pullChannelPartnerMaster(int channelPartnerId) async {
    try {
      final result = await _channelPartnerRepository.getChannelPartnerList(
        pageNumber: 1,
        pageSize: 1,
        queryParams: {"ChannelPartnerId": channelPartnerId},
      );

      result.fold((failure) {}, (response) {
        final partners = response['data'] as List<ChannelPartnerModel>;

        if (partners.isNotEmpty) {
          final data = partners.first;

          _companyNameC.text = data.companyName;
          _gstNumberC.text = data.gstNumber;
          _reraNumberC.text = data.reraNumber;

          hasReraNumber.value = data.reraNumber.isNotEmpty;

          selectedFirmsType.value = firmsType.firstWhere(
            (e) => e['DisplayName'] == data.firmsType,
            orElse: () => firmsType[0],
          );
          selectedGSTCertificateForPopUpFile.value = MultiFilePickerModel(
            fileBytesList: [],
            fileNameList:
                data.gstCertificateUrl.isEmpty
                    ? []
                    : data.gstCertificateUrl.split(","),
            deletedFileList: "",
          );
        }
      });
    } catch (error) {
      debugPrint("Pull Channel Partner Error: $error");
    }
  }

  // PREFILL DIALOG TO ADD UPDATE CHANNEL PARTNER
  void _prefillChannelPartner(ChannelPartnerModel channelPartnerMasterModel) {
    _nameC.text = channelPartnerMasterModel.name;
    _emailC.text = channelPartnerMasterModel.emailId;
    _mobileNumberC.text = channelPartnerMasterModel.mobileNumber;
    _alternateMobileNumberC.text =
        channelPartnerMasterModel.alternativeMobileNumber;
    _panNumberC.text = channelPartnerMasterModel.panNumber;
    _aadhaarNumberC.text = channelPartnerMasterModel.aadhaarCardNumber;
    _companyNameC.text = channelPartnerMasterModel.companyName;
    _reraNumberC.text = channelPartnerMasterModel.reraNumber;
    _gstNumberC.text = channelPartnerMasterModel.gstNumber;
    _officeAddressC.text = channelPartnerMasterModel.officeAddress;

    hasReraNumber.value = channelPartnerMasterModel.reraNumber.isNotEmpty;

    if (channelPartnerMasterModel.companyName.isNotEmpty) {
      // EXISTING COMPANY FLOW
      selectedCompanyType.value = companyTypeList[2];

      selectedCompany.value = [
        {
          "DisplayName": channelPartnerMasterModel.companyName,
          "zAttributesId": channelPartnerMasterModel.channelPartnerId,
        },
      ];

      _companyNameC.text = channelPartnerMasterModel.companyName;

      selectedFirmsType.value = firmsType.firstWhere(
        (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
        orElse: () => firmsType.first,
      );
    } else {
      // NEW COMPANY FLOW
      selectedCompanyType.value = companyTypeList[1];
    }

    if (channelPartnerMasterModel.designation.isNotEmpty) {
      _selectedDesignation = [
        designationList.firstWhere(
          (element) =>
              element['DisplayName'] == channelPartnerMasterModel.designation,
          orElse: () => designationList.first,
        ),
      ];
    }

    selectedSpeciality = specialityList.firstWhere(
      (element) =>
          element['DisplayName'] == channelPartnerMasterModel.speciality,
      orElse: () => specialityList.first,
    );

    selectedFirmsType.value = firmsType.firstWhere(
      (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
      orElse: () => firmsType.first,
    );

    selectedType = type.firstWhere(
      (element) => element["DisplayName"] == channelPartnerMasterModel.type,
      orElse: () => type.first,
    );

    // FILES
    selectedPANForPopUpFile.fileNameList =
        channelPartnerMasterModel.panCardUrl.isEmpty
            ? []
            : channelPartnerMasterModel.panCardUrl.split(",");

    selectedAadhaarForPopUpFile.fileNameList =
        channelPartnerMasterModel.aadhaarCardUrl.isEmpty
            ? []
            : channelPartnerMasterModel.aadhaarCardUrl.split(",");
    selectedGSTCertificateForPopUpFile.value = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList:
          channelPartnerMasterModel.gstCertificateUrl.isEmpty
              ? []
              : channelPartnerMasterModel.gstCertificateUrl.split(","),
      deletedFileList: "",
    );
    if (widget.channelPartnerModel!.districtName.isNotEmpty) {
      selectedDistrict = {
        "DisplayName": widget.channelPartnerModel!.districtName,
        "zAttributesId": widget.channelPartnerModel!.districtMasterId,
      };
    }
    if (widget.channelPartnerModel!.cityName.isNotEmpty) {
      selectedCity = {
        "DisplayName": widget.channelPartnerModel!.cityName,
        "zAttributesId": widget.channelPartnerModel!.cityMasterId,
      };
    }
    if (widget.channelPartnerModel!.stateName.isNotEmpty) {
      selectedState = {
        "DisplayName": widget.channelPartnerModel!.stateName,
        "zAttributesId": widget.channelPartnerModel!.stateMasterId,
      };
    }

    if (widget.channelPartnerModel!.villageName.isNotEmpty) {
      selectedVillage = {
        "DisplayName": widget.channelPartnerModel!.villageName,
        "zAttributesId": widget.channelPartnerModel!.villageMasterId,
      };
    }
  }

  // SUBMIT FORM BY OTP VARIFICATION
  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final companyTypeId = selectedCompanyType.value['zAttributesId'];

    if (companyTypeId == -1) {
      showErrorMessage(context, "", "Please select Company Type");
      return;
    }

    if (companyTypeId == 1 && _companyNameC.text.trim().isEmpty) {
      showErrorMessage(context, "", "Company Name is required");
      return;
    }

    if (companyTypeId == 2 && selectedCompany.value.isEmpty) {
      showErrorMessage(context, "", "Company is required");
      return;
    }

    if (!_isEditMode) {
      _loginCubit.sendOTPModuleBased(
        context: context,
        mobileNumber: _mobileNumberC.text.trim(),
        module: "CHANNEL PARTNER",
      );

      final isReraValid = _reraNumberC.text.trim().isNotEmpty;
      final isDocumentValid =
          _aadhaarNumberC.text.isNotEmpty &&
          _panNumberC.text.isNotEmpty &&
          _gstNumberC.text.isNotEmpty;

      showCompleteVerificationDialog(
        context,
        otpController: _otpController,
        verificationSteps: {
          "Basic Details": true,
          "RERA Details": isReraValid,
          "Speciality": true,
          "Document Details": isDocumentValid,
          "Address Details": true,
        },
        onResendOTP: () {
          _loginCubit.sendOTPModuleBased(
            context: context,
            mobileNumber: _mobileNumberC.text.trim(),
            module: "CHANNEL PARTNER",
          );
        },
        onVerifyOTP: () {
          _submitForm();
        },
      );
    } else {
      _submitForm();
    }
  }

  // ON SAVE BUTTON
  void _submitForm() {
    final companyTypeId = selectedCompanyType.value['zAttributesId'];

    final String companyName =
        companyTypeId == 1
            ? _companyNameC.text.trim()
            : selectedCompany.value.isNotEmpty
            ? selectedCompany.value.first["DisplayName"] ?? ""
            : "";

    final String firmsTypeValue =
        selectedFirmsType.value["zAttributesId"] == -1
            ? ""
            : selectedFirmsType.value["DisplayName"];

    if (_isEditMode && widget.channelPartnerModel != null) {
      _channelPartnerCubit.updateChannelPartner(
        context: context,
        channelPartnerId: widget.channelPartnerModel!.channelPartnerId,
        uniqueKey: widget.channelPartnerModel!.uniquekey,
        index: widget.index!,
        name: _nameC.text.trim(),
        emailId: _emailC.text.trim(),
        mobileNumber: _mobileNumberC.text.trim(),
        alternativeMobileNumber: _alternateMobileNumberC.text.trim(),
        panCardNumber: _panNumberC.text.trim(),
        aadhaarCardNumber: _aadhaarNumberC.text.trim(),
        gstNumber: _gstNumberC.text.trim(),
        speciality: selectedSpeciality?["DisplayName"] ?? "",
        officeAddress: _officeAddressC.text.trim(),
        panCardURL: selectedPANForPopUpFile,
        aadhaarCardURL: selectedAadhaarForPopUpFile,
        gstCertificateURL: selectedGSTCertificateForPopUpFile.value,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        selectedVillageId: selectedVillage!["zAttributesId"],
        reraNumber: _reraNumberC.text.trim(),
        companyName: companyName,
        firmsType: firmsTypeValue,
        type: selectedType["DisplayName"],
        designation: _selectedDesignation.first["DisplayName"],
        otp: _otpController.text.trim(),
      );
    } else {
      _channelPartnerCubit.addChannelPartner(
        context: context,
        channelPartnerId: 0,
        name: _nameC.text.trim(),
        emailId: _emailC.text.trim(),
        mobileNumber: _mobileNumberC.text.trim(),
        alternativeMobileNumber: _alternateMobileNumberC.text.trim(),
        panCardNumber: _panNumberC.text.trim(),
        aadhaarCardNumber: _aadhaarNumberC.text.trim(),
        gstNumber: _gstNumberC.text.trim(),
        speciality: selectedSpeciality?["DisplayName"] ?? "",
        officeAddress: _officeAddressC.text.trim(),
        panCardURL: selectedPANForPopUpFile,
        aadhaarCardURL: selectedAadhaarForPopUpFile,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        selectedVillageId: selectedVillage!["zAttributesId"],
        reraNumber: _reraNumberC.text.trim(),
        companyName: companyName,
        firmsType: firmsTypeValue,
        type: selectedType["DisplayName"],
        designation: _selectedDesignation.first["DisplayName"],
        otp: _otpController.text.trim(),
        gstCertificateURL: selectedGSTCertificateForPopUpFile.value,
      );
    }
  }

  // RESET FIELDS RELATED TO COMPANY SELECTION
  void _resetCompanyFields() {
    selectedCompany.value = [];
    _companyNameC.clear();
    selectedFirmsType.value = firmsType[0];
    hasReraNumber.value = false;
    _gstNumberC.clear();
    selectedGSTCertificateForPopUpFile.value = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );
    _reraNumberC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Channel Partner",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  _isEditMode
                      ? "Update Channel Partner"
                      : "Add Channel Partner",
                  style: AppTextStyle.ts16SB(),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Basic Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Full Name',
                      isRequired: true,
                      hint: "Enter Full Name",
                      textController: _nameC,
                      inputFormatterList: InputValidator.textOnly(50),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Full Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Email Id',
                      textController: _emailC,
                      hint: "Enter Valid E-mail Id",
                      inputFormatterList: InputValidator.emailInputFormatters(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      title: 'Mobile Number',
                      isRequired: true,
                      hint: "Enter Mobile Number",
                      textController: _mobileNumberC,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Mobile number is required";
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
                    CustomTextField(
                      title: 'Alternate Mobile Number',
                      hint: "Enter Alternate Mobile Number",
                      textController: _alternateMobileNumberC,
                      keyboardType: TextInputType.phone,
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
                    CustomDropDownWidget(
                      title: 'Company Type',
                      hintText: "Select Company Type",
                      isRequired: true,
                      initialValue: selectedCompanyType.value,
                      dataList: companyTypeList,
                      onSelected: (value) {
                        if (selectedCompanyType.value['zAttributesId'] !=
                            value['zAttributesId']) {
                          selectedCompanyType.value = value;
                          _resetCompanyFields();
                        }
                      },
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return "Company Type is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedCompanyType,
                      builder: (context, value, child) {
                        final int companyTypeId = value['zAttributesId'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (companyTypeId == 2) ...[
                              CustomMultipleSelectPopup(
                                title: "Company",
                                isRequired: true,
                                isMultiSelect: false,
                                initialValue: selectedCompany.value,
                                dataFetchCallBack: _fetchChannelPartnerList,
                                onClear: () {
                                  selectedCompany.value = [];
                                  _companyNameC.clear();
                                  selectedFirmsType.value = firmsType[0];
                                  hasReraNumber.value = false;
                                  _reraNumberC.clear();
                                  _gstNumberC.clear();
                                  selectedGSTCertificateForPopUpFile
                                      .value = MultiFilePickerModel(
                                    fileBytesList: [],
                                    fileNameList: [],
                                    deletedFileList: "",
                                  );
                                },
                                onSelected: (selectedValue) {
                                  selectedCompany.value = selectedValue;

                                  if (selectedValue.isNotEmpty) {
                                    final company = selectedValue.first;
                                    _companyNameC.text =
                                        company['DisplayName'] ?? '';

                                    final int channelPartnerId =
                                        company['zAttributesId'] ?? 0;
                                    if (channelPartnerId != 0) {
                                      _pullChannelPartnerMaster(
                                        channelPartnerId,
                                      );
                                    }
                                  }
                                },
                                validator: (selectedValue) {
                                  if (companyTypeId == 2 &&
                                      (selectedValue == null ||
                                          selectedValue.isEmpty)) {
                                    return "Company is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CustomTextField(
                                title: 'Company Name',
                                isRequired: true,
                                hint: "Company Name",
                                textController: _companyNameC,
                                readOnly: true,
                              ),
                            ],

                            if (companyTypeId == 1) ...[
                              CustomTextField(
                                title: 'Company Name',
                                isRequired: true,
                                hint: "Enter Company Name",
                                textController: _companyNameC,
                                inputFormatterList: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                validator: (value) {
                                  if (companyTypeId == 1 &&
                                      (value == null || value.trim().isEmpty)) {
                                    return "Company Name is required";
                                  }
                                  return null;
                                },
                              ),
                            ],

                            if (companyTypeId == 1) ...[
                              ValueListenableBuilder(
                                valueListenable: selectedFirmsType,
                                builder: (context, firmsValue, _) {
                                  return CustomDropDownWidget(
                                    title: "Firms Type",
                                    isRequired: true,
                                    dataList: firmsType,
                                    initialValue: firmsValue,
                                    onSelected: (value) {
                                      selectedFirmsType.value = value;
                                    },
                                    validator: (value) {
                                      if (companyTypeId == 1 &&
                                          (value == null ||
                                              value['zAttributesId'] == -1)) {
                                        return "Firms Type is required";
                                      }
                                      return null;
                                    },
                                  );
                                },
                              ),
                            ],

                            if (companyTypeId == 2) ...[
                              ValueListenableBuilder(
                                valueListenable: selectedFirmsType,
                                builder: (context, firmsValue, _) {
                                  return CustomTextField(
                                    title: "Firms Type",
                                    isRequired: true,
                                    readOnly: true,
                                    textController: TextEditingController(
                                      text: firmsValue['DisplayName'] ?? '',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: 'Designation',
                      hintText: "Select Designation",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: _selectedDesignation,
                      dataList: designationList,
                      onSelected: (value) {
                        _selectedDesignation = value;
                      },
                      dataFetchCallBack: (pageNumber, {value}) async {
                        return {
                          "itemList": designationList,
                          "totalNumberOfRecord": designationList.length,
                        };
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Designation Name is required";
                        }
                        if (selectedCompanyType.value['zAttributesId'] == 2 &&
                            _selectedDesignation.first['zAttributesId'] == 3) {
                          return "You can't be Owner";
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Type",
                      isRequired: true,
                      dataList: type,
                      initialValue: selectedType,
                      onSelected: (value) {
                        selectedType = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return "Type is required";
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Speciality",
                      hintText: "Select Speciality",
                      isRequired: true,
                      dataList: specialityList,
                      initialValue: selectedSpeciality,
                      onSelected: (value) {
                        selectedSpeciality = value;
                      },
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return "Speciality is required";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedCompanyType,
                      builder: (context, value, child) {
                        return ValueListenableBuilder(
                          valueListenable: hasReraNumber,
                          builder: (context, hasRera, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: hasRera,
                                        onChanged:
                                            (hasRera &&
                                                    _selectedDesignation
                                                            .first["zAttributesId"] !=
                                                        3)
                                                ? null
                                                : (value) {
                                                  hasReraNumber.value =
                                                      value ?? false;

                                                  if (!hasReraNumber.value) {
                                                    _reraNumberC.clear();
                                                  }
                                                },
                                      ),
                                    ),
                                    horizontalSpacing(width: 2),
                                    Text(
                                      "Do you have RERA Number",
                                      style: AppTextStyle.ts14M().copyWith(
                                        color:
                                            hasRera
                                                ? Colors.grey
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                CustomTextField(
                                  title: 'RERA Number',
                                  isRequired: hasRera,
                                  readOnly:
                                      hasRera &&
                                      _selectedDesignation
                                              .first["zAttributesId"] !=
                                          3,
                                  hint: "Enter RERA Number",
                                  textController: _reraNumberC,
                                  inputFormatterList:
                                      InputValidator.reraInputFormatters(),
                                  validator: (value) {
                                    if (hasRera &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return "RERA Number is required";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Document Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    CustomTextField(
                      title: 'Aadhaar Card Number',
                      hint: "Enter Aadhaar Card Number",
                      textController: _aadhaarNumberC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          InputValidator.aadhaarNumberInputFormatter(),
                      validator: (value) {
                        if (selectedAadhaarForPopUpFile
                            .fileNameList
                            .isNotEmpty) {
                          if (value == null || value.isEmpty) {
                            return "Aadhaar Card Number is required";
                          }
                          if (!InputValidator.isValidAadharNumber(value)) {
                            return "Aadhaar Card Number is invalid";
                          }
                        } else {
                          if (value != null &&
                              value.isNotEmpty &&
                              !InputValidator.isValidAadharNumber(value)) {
                            return "Aadhaar Card Number is invalid";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Aadhaar Card",
                      filePickType: FilePickType.both,
                      initialFileList: selectedAadhaarForPopUpFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedAadhaarForPopUpFile.fileNameList = fileNameList;
                        selectedAadhaarForPopUpFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedAadhaarForPopUpFile.fileNameList = fileNameList;
                        selectedAadhaarForPopUpFile.fileBytesList =
                            fileBytesList;
                        selectedAadhaarForPopUpFile.deletedFileList =
                            deletedFile;
                      },
                      validator: (fileList) {
                        if (_aadhaarNumberC.text.isNotEmpty &&
                            _aadhaarNumberC.text.trim().length == 12 &&
                            (fileList == null || fileList.isEmpty)) {
                          return "Aadhaar Card document is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'PAN Number',
                      hint: "Enter PAN Number",
                      textController: _panNumberC,
                      inputFormatterList: InputValidator.panInputFormatters(),
                      validator: (value) {
                        if (selectedPANForPopUpFile.fileNameList.isNotEmpty) {
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
                      title: "Pan Card",
                      filePickType: FilePickType.both,
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
                      validator: (fileList) {
                        if (_panNumberC.text.isNotEmpty &&
                            InputValidator.isValidPAN(
                              _panNumberC.text.trim(),
                            ) &&
                            (fileList == null || fileList.isEmpty)) {
                          return "PAN Card is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'GST Number',
                      hint: "Enter GST Number",
                      textController: _gstNumberC,
                      inputFormatterList: InputValidator.gstInputFormatters(),
                      validator: (value) {
                        if (selectedGSTCertificateForPopUpFile
                            .value
                            .fileNameList
                            .isNotEmpty) {
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
                    ValueListenableBuilder(
                      valueListenable: selectedGSTCertificateForPopUpFile,
                      builder: (context, value, child) {
                        return CustomMultiFilePicker(
                          key: ValueKey(
                            selectedGSTCertificateForPopUpFile
                                .value
                                .fileNameList
                                .join(),
                          ),
                          title: "GST Certificate",
                          filePickType: FilePickType.both,
                          initialFileList:
                              selectedGSTCertificateForPopUpFile
                                  .value
                                  .fileNameList,
                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedGSTCertificateForPopUpFile
                                .value
                                .fileNameList = fileNameList;
                            selectedGSTCertificateForPopUpFile
                                .value
                                .fileBytesList = bytesList;
                          },
                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedGSTCertificateForPopUpFile
                                .value
                                .fileNameList = fileNameList;
                            selectedGSTCertificateForPopUpFile
                                .value
                                .fileBytesList = fileBytesList;
                            selectedGSTCertificateForPopUpFile
                                .value
                                .deletedFileList = deletedFile;
                          },
                          validator: (value) {
                            if (_gstNumberC.text.isNotEmpty &&
                                InputValidator.isValidGST(
                                  _gstNumberC.text.trim(),
                                ) &&
                                (value == null || value.isEmpty)) {
                              return "GST Certificate document is required";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Address Details",
                      style: AppTextStyle.ts14M(color: AppColor.grey),
                    ),
                    verticalSpacing(),
                    AddressWidget(
                      formKey: _formKey,
                      incomingStateId: selectedState?['zAttributesId'],
                      incomingDistrictId: selectedDistrict?['zAttributesId'],
                      incomingCityId: selectedCity?['zAttributesId'],
                      incomingVillageId: selectedVillage?['zAttributesId'],
                      stateChange: (selectedState) {
                        this.selectedState = selectedState;
                      },
                      districtChange: (selectedDistrict) {
                        this.selectedDistrict = selectedDistrict;
                      },
                      cityChange: (selectedCity) {
                        this.selectedCity = selectedCity;
                      },
                      villageChange: (selectedVillage) {
                        this.selectedVillage = selectedVillage;
                      },
                    ),
                    CustomTextField(
                      textController: _officeAddressC,
                      title: 'Office Address',
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      hint: "Enter Office Address",
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Office Address is required";
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
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 35,
          color: AppColor.white,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _verifyAndSubmitForm,
          ),
        ),
      ),
    );
  }
}
