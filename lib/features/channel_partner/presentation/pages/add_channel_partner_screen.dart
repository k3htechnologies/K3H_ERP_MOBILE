import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/country_code.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/data/repository/channel_partner.repository.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
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
  late ChannelPartnerCubit _channelPartnerCubit;
  late UtilsCubit _utilsCubit;
  bool get _isEditMode => widget.channelPartnerModel != null;
  final ChannelPartnerRepository _channelPartnerRepository =
      serviceLocator<ChannelPartnerRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();
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
      _otpController,
      _websiteC;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ValueNotifier<Map<String, dynamic>?> selectedDesignation;
  late ValueNotifier<bool> aadhaarTrigger;
  late ValueNotifier<bool> panTrigger;
  late ValueNotifier<bool> gstTrigger;
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedPrimaryProjectNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>>
  _selectedSecondaryProjectNotifier = ValueNotifier([]);
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
  MultiFilePickerModel aopDocument = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late ValueNotifier<MultiFilePickerModel> selectedGSTCertificateForPopUpFile;

  ValueNotifier<bool> isCompanyPrefilled = ValueNotifier(false);
  bool get isNewCompany => selectedCompanyType.value?['zAttributesId'] == 1;
  Map<String, dynamic>? selectedSpeciality;
  late Map<String, dynamic> selectedSpecialityFilter;
  late ValueNotifier<Map<String, dynamic>?> selectedCompanyType;
  late ValueNotifier<Map<String, dynamic>?> selectedFirmsType;
  late ValueNotifier<Map<String, dynamic>?> selectedType;
  late ValueNotifier<List<Map<String, dynamic>>> selectedCompany;
  late ValueNotifier<bool> hasReraNumber;

  ValueNotifier<Map<String, dynamic>?> selectedCountry = ValueNotifier({
    "zAttributesId": 1,
    "DisplayName": "India",
  });
  ValueNotifier<Map<String, dynamic>?> selectedStateVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedDistrictVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedCityVN = ValueNotifier(null);
  ValueNotifier<Map<String, dynamic>?> selectedVillageVN = ValueNotifier(null);

  DateTime? _dob;
  DateTime? _aopFromDate;
  DateTime? _aopToDate;
  ValueNotifier<CountryCode> selectedMobileNoCountry = ValueNotifier(
    countryList.firstWhere((e) => e.code == "+91"),
  );
  final ValueNotifier<bool> _isAlreadyExist = ValueNotifier(false);
  bool get isExistingCompany =>
      selectedCompanyType.value?['zAttributesId'] == 2;
  @override
  void initState() {
    super.initState();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _utilsCubit = context.read<UtilsCubit>();
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
    _websiteC.dispose();
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
    _websiteC = TextEditingController();
  }

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

          selectedFirmsType.value = firmTypeList.firstWhere(
            (e) => e['DisplayName'] == data.firmsType,
          );
          selectedGSTCertificateForPopUpFile.value = MultiFilePickerModel(
            fileBytesList: [],
            fileNameList:
                data.gstCertificateUrl.isEmpty
                    ? []
                    : data.gstCertificateUrl.split(","),
            deletedFileList: "",
          );
          selectedCountry.value = {
            "DisplayName": data.countryName,
            "zAttributesId": data.countryMasterId,
          };
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

  void _prefillChannelPartner(ChannelPartnerModel channelPartnerMasterModel) {
    _nameC.text = channelPartnerMasterModel.name;
    _emailC.text = channelPartnerMasterModel.emailId;
    _mobileNumberC.text = channelPartnerMasterModel.mobileNumber;
    if (channelPartnerMasterModel.mobileNumberCountryCode.isNotEmpty) {
      selectedMobileNoCountry.value = countryList.firstWhere(
        (e) => e.code == channelPartnerMasterModel.mobileNumberCountryCode,
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

    _alternateMobileNumberC.text =
        channelPartnerMasterModel.alternativeMobileNumber;
    _panNumberC.text = channelPartnerMasterModel.panNumber;
    _aadhaarNumberC.text = channelPartnerMasterModel.aadhaarCardNumber;
    _companyNameC.text = channelPartnerMasterModel.companyName;
    _reraNumberC.text = channelPartnerMasterModel.reraNumber;
    _gstNumberC.text = channelPartnerMasterModel.gstNumber;
    _officeAddressC.text = channelPartnerMasterModel.officeAddress;
    _websiteC.text = channelPartnerMasterModel.websiteURL;
    _dob = channelPartnerMasterModel.dob;
    hasReraNumber.value = channelPartnerMasterModel.reraNumber.isNotEmpty;

    if (channelPartnerMasterModel.companyName.isNotEmpty) {
      selectedCompanyType.value = companyTypeList[1];

      selectedCompany.value = [
        {
          "DisplayName": channelPartnerMasterModel.companyName,
          "zAttributesId": channelPartnerMasterModel.channelPartnerId,
        },
      ];

      _companyNameC.text = channelPartnerMasterModel.companyName;

      selectedFirmsType.value = firmTypeList.firstWhere(
        (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
      );
    } else {
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

    selectedFirmsType.value = firmTypeList.firstWhere(
      (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
      orElse: () => firmTypeList.first,
    );

    selectedType.value = type.firstWhere(
      (element) => element["DisplayName"] == channelPartnerMasterModel.type,
      orElse: () => type.first,
    );

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
    selectedCountry.value = {
      "DisplayName": channelPartnerMasterModel.countryName,
      "zAttributesId": channelPartnerMasterModel.countryMasterId,
    };
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

    if (channelPartnerMasterModel.primaryProjectPortfolioId != 0) {
      _selectedPrimaryProjectNotifier.value = [
        {
          "zAttributesId": channelPartnerMasterModel.primaryProjectPortfolioId,
          "DisplayName": channelPartnerMasterModel.primaryProjectPortfolio,
        },
      ];
    }
    if (channelPartnerMasterModel.secondaryProjectPortfolioId.isNotEmpty) {
      _selectedSecondaryProjectNotifier.value =
          channelPartnerMasterModel.secondaryProjectPortfolioId
              .split(",")
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final projectId = entry.value;
                final projectName =
                    channelPartnerMasterModel.secondaryProjectPortfolio.split(
                      ",",
                    )[index];
                return {
                  "zAttributesId": int.tryParse(projectId) ?? 0,
                  "DisplayName": projectName,
                };
              })
              .toList();
    }

    aopDocument.fileNameList =
        channelPartnerMasterModel.aopDocumentUrl.isEmpty
            ? []
            : channelPartnerMasterModel.aopDocumentUrl.split(",");
    _aopFromDate = channelPartnerMasterModel.aopFromDate;
    _aopToDate = channelPartnerMasterModel.aopToDate;
  }

  Future<Map<String, dynamic>> _fetchProjects(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _projectMasterRepository.getProjectList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"ProjectName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<ProjectModel>;

        return {
          "itemList":
              project.map((pr) {
                return {
                  "zAttributesId": pr.projectId,
                  "DisplayName": pr.projectName,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

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
      _utilsCubit.sendOTPModuleBased(
        context: context,
        mobileNumber: _mobileNumberC.text.trim(),
        module: "CHANNEL PARTNER",
        name: _nameC.text.trim(),
        companyName: _companyNameC.text.trim(),
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
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
        alternativeMobileNumber: _alternateMobileNumberC.text.trim(),
        panCardNumber: _panNumberC.text.trim(),
        aadhaarCardNumber: _aadhaarNumberC.text.trim(),
        gstNumber: _gstNumberC.text.trim(),
        speciality: selectedSpeciality?["DisplayName"] ?? "",
        officeAddress: _officeAddressC.text.trim(),
        panCardDocuments: selectedPANForPopUpFile,
        aadhaarCardDocuments: selectedAadhaarForPopUpFile,
        gstCertificateDocuments: selectedGSTCertificateForPopUpFile.value,
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
        selectedStateId: selectedStateVN.value!["zAttributesId"],
        selectedDistrictId: selectedDistrictVN.value!["zAttributesId"],
        selectedCityId: selectedCityVN.value!["zAttributesId"],
        selectedVillageId: selectedVillageVN.value!["zAttributesId"],
        reraNumber: _reraNumberC.text.trim(),
        companyName: _companyNameC.text.trim(),
        firmsType: firmsTypeValue,
        type: selectedType.value?["DisplayName"] ?? "",
        designation: selectedDesignation.value?["DisplayName"] ?? "",
        dob: _dob?.toIso8601String() ?? "",
        websiteURL: _websiteC.text.trim(),
        primaryProjectPortfolioId:
            _selectedPrimaryProjectNotifier.value.isNotEmpty
                ? _selectedPrimaryProjectNotifier.value.first["zAttributesId"]
                : 0,
        secondaryProjectPortfolioId:
            _selectedSecondaryProjectNotifier.value.isNotEmpty
                ? getSecondaryProjectIds()
                : "",
        otp: _otpController.text.trim(),
        aopDocumentURL: aopDocument,
        aopFromDate: _aopFromDate?.toIso8601String() ?? "",
        aopToDate: _aopToDate?.toIso8601String() ?? "",
      );
    } else {
      _channelPartnerCubit.addChannelPartner(
        context: context,
        channelPartnerId: 0,
        name: _nameC.text.trim(),
        emailId: _emailC.text.trim(),
        mobileNumber: _mobileNumberC.text.trim(),
        mobileNumberCountryCode: selectedMobileNoCountry.value.code,
        alternativeMobileNumber: _alternateMobileNumberC.text.trim(),
        panCardNumber: _panNumberC.text.trim(),
        aadhaarCardNumber: _aadhaarNumberC.text.trim(),
        gstNumber: _gstNumberC.text.trim(),
        speciality: selectedSpeciality?["DisplayName"] ?? "",
        officeAddress: _officeAddressC.text.trim(),
        panCardURL: selectedPANForPopUpFile,
        aadhaarCardURL: selectedAadhaarForPopUpFile,
        selectedCountryNameId: selectedCountry.value?["zAttributesId"] ?? 1,
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
        dob: _dob?.toIso8601String() ?? "",
        websiteURL: _websiteC.text.trim(),
        primaryProjectPortfolioId:
            _selectedPrimaryProjectNotifier.value.isNotEmpty
                ? _selectedPrimaryProjectNotifier.value.first["zAttributesId"]
                : 0,
        secondaryProjectPortfolioId:
            _selectedSecondaryProjectNotifier.value.isNotEmpty
                ? getSecondaryProjectIds()
                : "",
        aopDocumentURL: aopDocument,
        aopFromDate: _aopFromDate?.toIso8601String() ?? "",
        aopToDate: _aopToDate?.toIso8601String() ?? "",
      );
    }
  }

  String getSecondaryProjectIds() {
    if (_selectedSecondaryProjectNotifier.value.isEmpty) {
      return "";
    }
    return _selectedSecondaryProjectNotifier.value
        .map((e) => e["zAttributesId"].toString())
        .join(",");
  }

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
    selectedCountry.value = {"zAttributesId": 1, "DisplayName": "India"};
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
            spacing: 10,
            children: [
              Text(
                _isEditMode ? "Update Channel Partner" : "Add Channel Partner",
                style: AppTextStyle.ts14M(),
              ),

              _card("Basic Details", [
                CustomTextField(
                  title: 'Full Name',
                  isRequired: true,
                  hint: "Enter Full Name",
                  textController: _nameC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(50)],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Full Name is required";
                    }
                    return null;
                  },
                ),
                CustomDatePicker(
                  title: 'DOB',
                  initialDate: _dob,
                  setValue: (value) => _dob = value,
                  validator: (value) {
                    if (value != null && !InputValidator.isValidAge(value)) {
                      return 'Age should be greater than or equal to 18.';
                    }

                    return null;
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: selectedMobileNoCountry,
                  builder: (context, value, child) {
                    return CustomTextField(
                      title: "Mobile Number",
                      textController: _mobileNumberC,
                      hint: "Enter Mobile Number",
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                      readOnly: _isEditMode,
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
                      onChangeFunction: (value) async {
                        final country = selectedMobileNoCountry.value;

                        if (value.isNotEmpty &&
                            country.mobileLength == value.length) {
                          _isAlreadyExist.value =
                              (await _channelPartnerCubit
                                  .fetchChannelPartnersByMobile(
                                    _mobileNumberC.text.trim(),
                                  )).isNotEmpty;
                        } else {
                          _isAlreadyExist.value = false;
                        }
                      },
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
                        if (_isAlreadyExist.value && !_isEditMode) {
                          return "Mobile Number already exists";
                        }
                        return null;
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: selectedMobileNoCountry,
                  builder: (context, selectedMobNovalue, child) {
                    return CustomTextField(
                      title: "E-mail ID",
                      isRequired: selectedMobNovalue.countryCode != "IN",
                      textController: _emailC,
                      keyboardType: TextInputType.emailAddress,
                      hint: "Enter Email",
                      validator:
                          (value) =>
                              (selectedMobNovalue.countryCode != "IN" &&
                                      (value == null || value.isEmpty))
                                  ? "E-mail ID is required"
                                  : null,
                    );
                  },
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
                          if (value == null || value['zAttributesId'] == -1) {
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
                                  _pullChannelPartnerMaster(channelPartnerId);
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
                                dataList: firmTypeList,
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
                CustomTextField(
                  title: 'Website URL',
                  hint: "Enter Website URL",
                  textController: _websiteC,
                  validator: (value) {
                    if ((value != null && value.trim().isNotEmpty) &&
                        !InputValidator.isValidURL(value)) {
                      return "Enter a valid Website URL";
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
                                CustomCheckBox(
                                  isSelected: hasRera,
                                  onChanged:
                                      isNewCompany
                                          ? (value) {
                                            hasReraNumber.value = value;

                                            if (!hasReraNumber.value) {
                                              _reraNumberC.clear();
                                            }
                                          }
                                          : null,
                                ),
                                horizontalSpacing(width: 2),
                                Text(
                                  "Do you have RERA Number",
                                  style: AppTextStyle.ts14M().copyWith(
                                    color: hasRera ? Colors.grey : Colors.black,
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
                                    (value == null || value.trim().isEmpty)) {
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
              ]),

              _card("Speciality", [
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
              ]),

              const SizedBox(height: 10.0),
              _card("Document Details", [
                ValueListenableBuilder(
                  valueListenable: aadhaarTrigger,
                  builder: (context, _, __) {
                    final hasAadhaar = _aadhaarNumberC.text.trim().isNotEmpty;
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
                            if (hasFile && (value == null || value.isEmpty)) {
                              return "Aadhaar Card Number is required";
                            }

                            if (value != null && value.isNotEmpty) {
                              if (!InputValidator.isValidAadharNumber(value)) {
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
                            if (hasFile && (value == null || value.isEmpty)) {
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
                          initialFileList: selectedPANForPopUpFile.fileNameList,

                          onFilePickedCallback: (bytesList, fileNameList) {
                            selectedPANForPopUpFile.fileNameList = fileNameList;
                            selectedPANForPopUpFile.fileBytesList = bytesList;

                            panTrigger.value = !panTrigger.value;
                            _formKey.currentState?.validate();
                          },

                          onFileDeleteCallback: (
                            fileBytesList,
                            fileNameList,
                            deletedFile,
                          ) {
                            selectedPANForPopUpFile.fileNameList = fileNameList;
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
                              readOnly: isExistingCompany,
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
                          ignoring: isExistingCompany,
                          child: Opacity(
                            opacity: isExistingCompany ? 0.6 : 1,
                            child: CustomMultiFilePicker(
                              key: ValueKey(
                                selectedGSTCertificateForPopUpFile.value,
                              ),
                              title: "GST Certificate",
                              filePickType: FilePickType.both,
                              readOnly: isExistingCompany,
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
                                    (fileList == null || fileList.isEmpty)) {
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
              ]),
              const SizedBox(height: 10.0),
              _card("Address Details", [
                AnimatedBuilder(
                  animation: Listenable.merge([
                    selectedCountry,
                    selectedStateVN,
                  ]),
                  builder: (context, _) {
                    return AddressWidget(
                      key: ValueKey(
                        "${selectedStateVN.value?['zAttributesId']}_${selectedCityVN.value?['zAttributesId']}",
                      ),
                      formKey: _formKey,
                      incomingCountryId:
                          selectedCountry.value?['zAttributesId'] ?? 1,

                      incomingStateId: selectedStateVN.value?['zAttributesId'],
                      incomingDistrictId:
                          selectedDistrictVN.value?['zAttributesId'],
                      incomingCityId: selectedCityVN.value?['zAttributesId'],
                      incomingVillageId:
                          selectedVillageVN.value?['zAttributesId'],
                      stateChange: (val) => selectedStateVN.value = val,
                      districtChange: (val) => selectedDistrictVN.value = val,
                      cityChange: (val) => selectedCityVN.value = val,
                      villageChange: (val) => selectedVillageVN.value = val,
                      countryChange: (val) => selectedCountry.value = val,
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
              ]),
              verticalSpacing(),
              _card("Primary & Secondary Project Portfolio Details", [
                ValueListenableBuilder(
                  valueListenable: _selectedPrimaryProjectNotifier,
                  builder: (context, value, child) {
                    return CustomMultipleSelectPopup(
                      title: 'Primary Project',
                      isMultiSelect: false,
                      hintText: "Select Primary Project",
                      initialValue: value,
                      dataList: const [],
                      onSelected: (value) {
                        _selectedPrimaryProjectNotifier.value = value;
                      },
                      dataFetchCallBack: _fetchProjects,
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedSecondaryProjectNotifier,
                  builder: (context, value, child) {
                    return CustomMultipleSelectPopup(
                      title: 'Secondary Project',
                      isMultiSelect: true,
                      hintText: "Select Secondary Project",
                      initialValue: value,
                      dataList: const [],
                      onSelected: (value) {
                        _selectedSecondaryProjectNotifier.value = value;
                      },
                      dataFetchCallBack: _fetchProjects,
                    );
                  },
                ),
              ]),
              _card("AOP Details", [
                CustomMultiFilePicker(
                  title: "AOP Document",
                  filePickType: FilePickType.both,
                  initialFileList: aopDocument.fileNameList,

                  onFilePickedCallback: (bytesList, fileNameList) {
                    aopDocument.fileNameList = fileNameList;
                    aopDocument.fileBytesList = bytesList;
                  },

                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                  ) {
                    aopDocument.fileNameList = fileNameList;
                    aopDocument.fileBytesList = fileBytesList;
                    aopDocument.deletedFileList = deletedFile;
                  },
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (_aopFromDate != null || _aopToDate != null)) {
                      return 'AOP Document is required.';
                    }

                    return null;
                  },
                ),
                CustomDatePicker(
                  title: 'From Date',
                  initialDate: _aopFromDate,
                  setValue: (value) => _aopFromDate = value,
                  validator: (value) {
                    if (value == null &&
                        (_aopToDate != null ||
                            aopDocument.fileNameList.isNotEmpty)) {
                      return 'From Date is required.';
                    }

                    return null;
                  },
                ),
                CustomDatePicker(
                  title: 'To Date',
                  initialDate: _aopToDate,
                  setValue: (value) => _aopToDate = value,
                  validator: (value) {
                    if (value == null &&
                        (_aopFromDate != null ||
                            aopDocument.fileNameList.isNotEmpty)) {
                      return 'To Date is required.';
                    }
                    if (value != null &&
                        _aopFromDate != null &&
                        value.isBefore(_aopFromDate!)) {
                      return 'To Date must be greater than or equal to From Date.';
                    }

                    return null;
                  },
                ),
              ]),
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

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          ...children,
        ],
      ),
    );
  }
}
