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
  late ValueNotifier<Map<String, dynamic>?> selectedDesignation;

  late ValueNotifier<bool> aadhaarTrigger;
  late ValueNotifier<bool> panTrigger;
  late ValueNotifier<bool> gstTrigger;

  // STATIC LIST
  List<Map<String, dynamic>> designationList = [
    {"zAttributesId": 1, "DisplayName": "Business Head"},
    {"zAttributesId": 2, "DisplayName": "Cluster Head"},
    {"zAttributesId": 3, "DisplayName": "Owner"},
    {"zAttributesId": 4, "DisplayName": "Partner"},
    {"zAttributesId": 5, "DisplayName": "Team Member"},
  ];

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

  ValueNotifier<bool> isCompanyPrefilled = ValueNotifier(false);
  bool get isNewCompany => selectedCompanyType.value?['zAttributesId'] == 1;

  // DROPDOWN VARIABLES
  final List<Map<String, dynamic>> specialityList = [
    {"zAttributesId": 1, "DisplayName": "Commercial Sale"},
    {"zAttributesId": 2, "DisplayName": "Commercial Leasing"},
    {"zAttributesId": 3, "DisplayName": "Residential Sale"},
    {"zAttributesId": 4, "DisplayName": "Commercial + Residential Sale"},
  ];

  final List<Map<String, dynamic>> companyTypeList = [
    {"zAttributesId": 1, "DisplayName": "New Company"},
    {"zAttributesId": 2, "DisplayName": "Existing Company"},
  ];

  final List<Map<String, dynamic>> firmsType = [
    {"zAttributesId": 1, "DisplayName": "LLP"},
    {"zAttributesId": 2, "DisplayName": "Private Limited Company"},
    {"zAttributesId": 3, "DisplayName": "Proprietorship"},
  ];

  final List<Map<String, dynamic>> type = [
    {"zAttributesId": 1, "DisplayName": "International Channel Partner (IPC)"},
    {"zAttributesId": 2, "DisplayName": "Institutional Channel Partner (ICP)"},
    {"zAttributesId": 3, "DisplayName": "Retail Channel Partner (RCP)"},
  ];

  // SELECTION VARIABLE

  Map<String, dynamic>? selectedSpeciality;
  late Map<String, dynamic> selectedSpecialityFilter;
  late ValueNotifier<Map<String, dynamic>?> selectedCompanyType;
  late ValueNotifier<Map<String, dynamic>?> selectedFirmsType;
  late ValueNotifier<Map<String, dynamic>?> selectedType;
  // MULTI SELECT FOR PROJECTS, SINGLE SELECT FOR COMPANY
  late ValueNotifier<List<Map<String, dynamic>>> selectedCompany;
  late ValueNotifier<bool> hasReraNumber;

  ValueNotifier<Map<String, dynamic>?> selectedStateVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedDistrictVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedCityVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedVillageVN = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _loginCubit = context.read<LoginCubit>();
    _initializeTextEditingController();
    aadhaarTrigger = ValueNotifier(false);
    panTrigger = ValueNotifier(false);
    gstTrigger = ValueNotifier(false);
    _aadhaarNumberC.addListener(() {
      aadhaarTrigger.value = !aadhaarTrigger.value;
    });
    _panNumberC.addListener(() {
      panTrigger.value = !panTrigger.value;
    });

    _gstNumberC.addListener(() {
      gstTrigger.value = !gstTrigger.value;
    });
    selectedDesignation = ValueNotifier(null);
    selectedType = ValueNotifier(null);
    isCompanyPrefilled = ValueNotifier(false);
    selectedCompanyType = ValueNotifier<Map<String, dynamic>?>(null);
    selectedGSTCertificateForPopUpFile = ValueNotifier(
      MultiFilePickerModel(
        fileBytesList: [],
        fileNameList: [],
        deletedFileList: "",
      ),
    );
    selectedFirmsType = ValueNotifier(null);
    hasReraNumber = ValueNotifier(false);
    selectedCompany = ValueNotifier([]);
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
    selectedDesignation.dispose();
    isCompanyPrefilled.dispose();
    aadhaarTrigger.dispose();
    panTrigger.dispose();
    gstTrigger.dispose();
    selectedType.dispose();
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

          isCompanyPrefilled.value = true;

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
          selectedStateVN.value = {
            "DisplayName": data.stateName,
            "zAttributesId": data.stateMasterId,
          };

          selectedDistrictVN.value = {
            "DisplayName": data.districtName,
            "zAttributesId": data.districtMasterId,
          };

          selectedCityVN.value = {
            "DisplayName": data.cityName,
            "zAttributesId": data.cityMasterId,
          };

          selectedVillageVN.value = {
            "DisplayName": data.villageName,
            "zAttributesId": data.villageMasterId,
          };
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
      selectedCompanyType.value = companyTypeList[1];

      selectedCompany.value = [
        {
          "DisplayName": channelPartnerMasterModel.companyName,
          "zAttributesId": channelPartnerMasterModel.channelPartnerId,
        },
      ];

      _companyNameC.text = channelPartnerMasterModel.companyName;

      selectedFirmsType.value = firmsType.firstWhere(
        (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
      );
    } else {
      // NEW COMPANY FLOW
      selectedCompanyType.value = companyTypeList[1];
    }

    if (channelPartnerMasterModel.designation.isNotEmpty) {
      selectedDesignation.value = designationList.firstWhere(
        (element) =>
            element['DisplayName'] == channelPartnerMasterModel.designation,
        orElse: () => designationList.first,
      );
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

    selectedType.value = type.firstWhere(
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
    selectedStateVN.value = {
      "DisplayName": channelPartnerMasterModel.stateName,
      "zAttributesId": channelPartnerMasterModel.stateMasterId,
    };
    selectedDistrictVN.value = {
      "DisplayName": channelPartnerMasterModel.districtName,
      "zAttributesId": channelPartnerMasterModel.districtMasterId,
    };
    selectedCityVN.value = {
      "DisplayName": channelPartnerMasterModel.cityName,
      "zAttributesId": channelPartnerMasterModel.cityMasterId,
    };
    selectedVillageVN.value = {
      "DisplayName": channelPartnerMasterModel.villageName,
      "zAttributesId": channelPartnerMasterModel.villageMasterId,
    };
  }

  // SUBMIT FORM BY OTP VARIFICATION
  void _verifyAndSubmitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final companyTypeId = selectedCompanyType.value?['zAttributesId'];

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
    final companyTypeId = selectedCompanyType.value?['zAttributesId'];

    final String companyName =
        companyTypeId == 1
            ? _companyNameC.text.trim()
            : selectedCompany.value.isNotEmpty
            ? selectedCompany.value.first["DisplayName"] ?? ""
            : "";

    final String firmsTypeValue =
        selectedFirmsType.value?["zAttributesId"] == null
            ? ""
            : selectedFirmsType.value!["DisplayName"];

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
        panCardDocuments: selectedPANForPopUpFile,
        aadhaarCardDocuments: selectedAadhaarForPopUpFile,
        gstCertificateDocuments: selectedGSTCertificateForPopUpFile.value,
        selectedCountryNameId: 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        selectedVillageId: selectedVillageVN.value!["zAttributesId"],
        reraNumber: _reraNumberC.text.trim(),
        companyName: companyName,
        firmsType: firmsTypeValue,
        type: selectedType.value?["DisplayName"] ?? "",
        designation: selectedDesignation.value?["DisplayName"] ?? "",
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
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        selectedVillageId: selectedVillageVN.value!["zAttributesId"],
        reraNumber: _reraNumberC.text.trim(),
        companyName: companyName,
        firmsType: firmsTypeValue,
        type: selectedType.value?["DisplayName"] ?? "",
        designation: selectedDesignation.value?["DisplayName"] ?? "",
        otp: _otpController.text.trim(),
        gstCertificateURL: selectedGSTCertificateForPopUpFile.value,
      );
    }
  }

  // RESET FIELDS RELATED TO COMPANY SELECTION
  void _resetCompanyFields() {
    selectedCompany.value = [];
    _companyNameC.clear();
    selectedFirmsType.value = null;
    selectedType.value = null;
    hasReraNumber.value = false;
    _gstNumberC.clear();
    selectedGSTCertificateForPopUpFile.value = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );
    _reraNumberC.clear();
    selectedDistrictVN.value = {};
    selectedCityVN.value = {};
    selectedStateVN.value = {};
    selectedVillageVN.value = {};
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
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Basic Details", style: AppTextStyle.ts16SB()),
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
                      readOnly: _isEditMode,
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
                    if (!_isEditMode)
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: selectedCompanyType,
                        builder: (context, value, _) {
                          return CustomDropDownWidget(
                            key: ValueKey(value?['zAttributesId']),
                            title: 'Company Type',
                            hintText: "Select Company Type",
                            isRequired: true,
                            initialValue: value,
                            dataList: companyTypeList,
                            onSelected: (val) {
                              if (selectedCompanyType.value?['zAttributesId'] !=
                                  val['zAttributesId']) {
                                selectedCompanyType.value = val;
                                _resetCompanyFields();
                              }
                            },
                            onValueClear: () {
                              selectedCompanyType.value = null;
                              _resetCompanyFields();
                            },
                            validator: (value) {
                              if (value == null ||
                                  value['zAttributesId'] == -1) {
                                return "Company Type is required";
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ValueListenableBuilder(
                      valueListenable: selectedCompanyType,
                      builder: (context, value, child) {
                        final int companyTypeId = value?['zAttributesId'] ?? -1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEditMode && companyTypeId == 2) ...[
                              CustomMultipleSelectPopup(
                                title: "Company",
                                isRequired: true,
                                isMultiSelect: false,
                                initialValue: selectedCompany.value,
                                dataFetchCallBack: _fetchChannelPartnerList,
                                onClear: () {
                                  selectedCompany.value = [];
                                  isCompanyPrefilled.value = false;
                                  _companyNameC.clear();
                                  selectedFirmsType.value = null;
                                  selectedType.value = null;
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
                            ],

                            if (companyTypeId == 1 || _isEditMode) ...[
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
                                    hintText: "Select Firms Type",
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
                                    onValueClear: () {
                                      selectedFirmsType.value = null;
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
                                    hint: "Select Firms Type",
                                    isRequired: true,
                                    readOnly: true,
                                    textController: TextEditingController(
                                      text: firmsValue?['DisplayName'] ?? '',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedDesignation,
                      builder: (context, value, _) {
                        return CustomDropDownWidget(
                          title: 'Designation',
                          hintText: "Select Designation",
                          isRequired: true,
                          dataList: designationList,
                          initialValue: value,
                          onSelected: (val) {
                            selectedDesignation.value = val;
                          },
                          validator: (val) {
                            if (val == null) {
                              return "Designation is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            selectedDesignation.value = null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedCompanyType,
                      builder: (context, companyType, _) {
                        return ValueListenableBuilder<Map<String, dynamic>?>(
                          valueListenable: selectedType,
                          builder: (context, value, _) {
                            return CustomDropDownWidget(
                              title: "Type",
                              isRequired: true,
                              hintText: "Select Type",
                              dataList: type,
                              initialValue: value,
                              onSelected: (val) {
                                selectedType.value = val;
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Type is required";
                                }
                                return null;
                              },
                              onValueClear: () {
                                selectedType.value = null;
                              },
                            );
                          },
                        );
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
                                            isNewCompany
                                                ? (value) {
                                                  hasReraNumber.value =
                                                      value ?? false;

                                                  if (!hasReraNumber.value) {
                                                    _reraNumberC.clear();
                                                  }
                                                }
                                                : null,
                                        // onChanged:
                                        //     isCompanyPrefilled.value ||
                                        //             (hasRera &&
                                        //                 selectedDesignation
                                        //                         .value !=
                                        //                     null &&
                                        //                 selectedDesignation
                                        //                         .value!["zAttributesId"] !=
                                        //                     3)
                                        //         ? null
                                        //         : (value) {
                                        //           hasReraNumber.value =
                                        //               value ?? false;

                                        //           if (!hasReraNumber.value) {
                                        //             _reraNumberC.clear();
                                        //           }
                                        //         },
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
                                  readOnly: !isNewCompany,
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Speciality", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
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
                      onValueClear: () {
                        selectedSpeciality = null;
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
                    Text("Document Details", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: aadhaarTrigger,
                      builder: (context, _, __) {
                        final hasAadhaar =
                            _aadhaarNumberC.text.trim().isNotEmpty;
                        final hasFile =
                            selectedAadhaarForPopUpFile.fileNameList.isNotEmpty;

                        return Column(
                          children: [
                            CustomTextField(
                              title: 'Aadhaar Card Number',
                              isRequired: hasFile,
                              hint: "Enter Aadhaar Card Number",
                              textController: _aadhaarNumberC,
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  InputValidator.aadhaarNumberInputFormatter(),
                              validator: (value) {
                                if (hasFile &&
                                    (value == null || value.isEmpty)) {
                                  return "Aadhaar Card Number is required";
                                }

                                if (value != null && value.isNotEmpty) {
                                  if (!InputValidator.isValidAadharNumber(
                                    value,
                                  )) {
                                    return "Aadhaar Card Number is invalid";
                                  }
                                }

                                return null;
                              },
                            ),

                            CustomMultiFilePicker(
                              title: "Aadhaar Card",
                              isRequired: hasAadhaar,
                              filePickType: FilePickType.both,
                              initialFileList:
                                  selectedAadhaarForPopUpFile.fileNameList,

                              onFilePickedCallback: (bytesList, fileNameList) {
                                selectedAadhaarForPopUpFile.fileNameList =
                                    fileNameList;
                                selectedAadhaarForPopUpFile.fileBytesList =
                                    bytesList;

                                aadhaarTrigger.value = !aadhaarTrigger.value;
                              },

                              onFileDeleteCallback: (
                                fileBytesList,
                                fileNameList,
                                deletedFile,
                              ) {
                                selectedAadhaarForPopUpFile.fileNameList =
                                    fileNameList;
                                selectedAadhaarForPopUpFile.fileBytesList =
                                    fileBytesList;
                                selectedAadhaarForPopUpFile.deletedFileList =
                                    deletedFile;

                                aadhaarTrigger.value = !aadhaarTrigger.value;
                              },

                              validator: (fileList) {
                                if (hasAadhaar &&
                                    (fileList == null || fileList.isEmpty)) {
                                  return "Aadhaar Card document is required";
                                }

                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: panTrigger,
                      builder: (context, _, __) {
                        final hasPan = _panNumberC.text.trim().isNotEmpty;
                        final hasFile =
                            selectedPANForPopUpFile.fileNameList.isNotEmpty;

                        return Column(
                          children: [
                            CustomTextField(
                              title: 'PAN Number',
                              isRequired: hasFile,
                              hint: "Enter PAN Number",
                              textController: _panNumberC,
                              inputFormatterList:
                                  InputValidator.panInputFormatters(),
                              validator: (value) {
                                if (hasFile &&
                                    (value == null || value.isEmpty)) {
                                  return "PAN Number is required";
                                }

                                if (value != null && value.isNotEmpty) {
                                  if (!InputValidator.isValidPAN(value)) {
                                    return "PAN Number is invalid";
                                  }
                                }

                                return null;
                              },
                            ),

                            CustomMultiFilePicker(
                              title: "Pan Card",
                              isRequired: hasPan,
                              filePickType: FilePickType.both,
                              initialFileList:
                                  selectedPANForPopUpFile.fileNameList,

                              onFilePickedCallback: (bytesList, fileNameList) {
                                selectedPANForPopUpFile.fileNameList =
                                    fileNameList;
                                selectedPANForPopUpFile.fileBytesList =
                                    bytesList;

                                panTrigger.value = !panTrigger.value;
                                _formKey.currentState?.validate();
                              },

                              onFileDeleteCallback: (
                                fileBytesList,
                                fileNameList,
                                deletedFile,
                              ) {
                                selectedPANForPopUpFile.fileNameList =
                                    fileNameList;
                                selectedPANForPopUpFile.fileBytesList =
                                    fileBytesList;
                                selectedPANForPopUpFile.deletedFileList =
                                    deletedFile;

                                panTrigger.value = !panTrigger.value;
                                _formKey.currentState?.validate();
                              },

                              validator: (fileList) {
                                if (hasPan &&
                                    (fileList == null || fileList.isEmpty)) {
                                  return "PAN Card document is required";
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: gstTrigger,
                      builder: (context, _, __) {
                        final hasGst = _gstNumberC.text.trim().isNotEmpty;

                        return Column(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: isCompanyPrefilled,
                              builder: (context, isPrefilled, _) {
                                return CustomTextField(
                                  title: 'GST Number',
                                  hint: "Enter GST Number",
                                  textController: _gstNumberC,
                                  readOnly: isPrefilled,
                                  inputFormatterList:
                                      InputValidator.gstInputFormatters(),
                                  validator: (value) {
                                    final hasFile =
                                        selectedGSTCertificateForPopUpFile
                                            .value
                                            .fileNameList
                                            .isNotEmpty;

                                    if (hasFile &&
                                        (value == null || value.isEmpty)) {
                                      return "GST Number is required";
                                    }

                                    if (value != null && value.isNotEmpty) {
                                      if (!InputValidator.isValidGST(value)) {
                                        return "GST Number is invalid";
                                      }
                                    }

                                    return null;
                                  },
                                );
                              },
                            ),

                            IgnorePointer(
                              ignoring: isCompanyPrefilled.value,
                              child: Opacity(
                                opacity: isCompanyPrefilled.value ? 0.6 : 1,
                                child: CustomMultiFilePicker(
                                  key: ValueKey(
                                    selectedGSTCertificateForPopUpFile.value,
                                  ),
                                  title: "GST Certificate",
                                  filePickType: FilePickType.both,
                                  initialFileList:
                                      selectedGSTCertificateForPopUpFile
                                          .value
                                          .fileNameList,

                                  onFilePickedCallback: (
                                    bytesList,
                                    fileNameList,
                                  ) {
                                    selectedGSTCertificateForPopUpFile
                                        .value
                                        .fileNameList = fileNameList;
                                    selectedGSTCertificateForPopUpFile
                                        .value
                                        .fileBytesList = bytesList;

                                    gstTrigger.value = !gstTrigger.value;
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

                                    gstTrigger.value = !gstTrigger.value;
                                    _formKey.currentState?.validate();
                                  },

                                  validator: (fileList) {
                                    if (hasGst &&
                                        (fileList == null ||
                                            fileList.isEmpty)) {
                                      return "GST Certificate document is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
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
                    Text("Address Details", style: AppTextStyle.ts16SB()),
                    verticalSpacing(),
                    ValueListenableBuilder(
                      valueListenable: selectedStateVN,
                      builder: (context, _, __) {
                        return AddressWidget(
                          key: ValueKey(
                            "${selectedStateVN.value?['zAttributesId']}_${selectedCityVN.value?['zAttributesId']}",
                          ),
                          formKey: _formKey,
                          incomingStateId:
                              selectedStateVN.value?['zAttributesId'],
                          incomingDistrictId:
                              selectedDistrictVN.value?['zAttributesId'],
                          incomingCityId:
                              selectedCityVN.value?['zAttributesId'],
                          incomingVillageId:
                              selectedVillageVN.value?['zAttributesId'],
                          stateChange: (val) => selectedStateVN.value = val,
                          districtChange:
                              (val) => selectedDistrictVN.value = val,
                          cityChange: (val) => selectedCityVN.value = val,
                          villageChange: (val) => selectedVillageVN.value = val,
                        );
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
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
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
