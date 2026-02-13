import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/model/designation.model.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/address/address_widget.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

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
  //EDIT MODE
  bool get _isEditMode => widget.channelPartnerModel != null;

  // REPOSITORY
  final CompanyMasterRepository _companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();
  final DesignationMasterRepository _designationMasterRepository =
      serviceLocator<DesignationMasterRepository>();

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
      _filterLocalityC;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _initializeTextEditingController();
    selectedCompanyType = ValueNotifier<Map<String, dynamic>>(
      companyTypeList[0],
    );
    selectedSpeciality = specialityList[0];
    selectedFirmsType = firmsType[0];
    selectedType = type[0];
    if (widget.channelPartnerModel != null) {
      _prefillChannelPartner(widget.channelPartnerModel!);
    }
  }

  @override
  void dispose() {
    selectedCompanyType.dispose();
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

  // DROPDOWN VARIABLES
  final List<Map<String, dynamic>> specialityList = [
    {"zAttributesId": -1, "DisplayName": "Select"},
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
    {"zAttributesId": -1, "DisplayName": "Select Firms Type"},
    {"zAttributesId": 1, "DisplayName": "International Channel Partner (IPC)"},
    {"zAttributesId": 2, "DisplayName": "Institutional Channel Partner (ICP)"},
    {"zAttributesId": 3, "DisplayName": "Retail Channel Partner (RCP)"},
  ];

  // SELECTION VARIABLE
  Map<String, dynamic>? selectedState;
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;
  late Map<String, dynamic> selectedSpeciality;
  late Map<String, dynamic> selectedSpecialityFilter;
  late ValueNotifier<Map<String, dynamic>> selectedCompanyType;
  late Map<String, dynamic> selectedFirmsType;
  late Map<String, dynamic> selectedType;
  // MULTI SELECT FOR PROJECTS, SINGLE SELECT FOR COMPANY
  List<Map<String, dynamic>> selectedCompany = [];
  List<Map<String, dynamic>> selectedDesignation = [];

  bool hasReraNumber = false;

  // FETCH COMPANY LIST
  Future<Map<String, dynamic>> _fetchCompanyList(
    int pageNumber, {
    String? value,
  }) async {
    try {
      final result = await _companyMasterRepository.getCompanyList(
        pageNumber: pageNumber,
        pageSize: 10,
        queryParams:
            value != null && value.isNotEmpty ? {"CompanyName": value} : null,
      );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final companies = response['data'] as List<CompanyModel>;
          final itemList =
              companies
                  .map(
                    (c) => {
                      'zAttributesId': c.companyId,
                      'DisplayName': c.companyName,
                      'FirmsType': c.firmsType,
                    },
                  )
                  .toList();

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

  // FETCH DESIGNATION LIST
  Future<Map<String, dynamic>> _fetchDesignationList(
    int pageNumber, {
    String? value,
  }) async {
    try {
      final result = await _designationMasterRepository.getDesignationList(
        pageNumber: pageNumber,
        pageSize: 15,
        queryParams:
            value != null && value.isNotEmpty
                ? {"DesignationName": value}
                : null,
      );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final designations = response['data'] as List<DesignationMasterModel>;
          final itemList =
              designations
                  .map(
                    (c) => {
                      'zAttributesId': c.designationMasterId,
                      'DisplayName': c.designationName,
                    },
                  )
                  .toList();

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

  // PREFILL DIALOG TO ADD UPDATE CHANNEL PARTNER
  void _prefillChannelPartner(ChannelPartnerModel channelPartnerMasterModel) {
    _nameC.text = channelPartnerMasterModel.name;
    _emailC.text = channelPartnerMasterModel.emailId;
    _mobileNumberC.text = channelPartnerMasterModel.mobileNumber;
    _alternateMobileNumberC.text =
        channelPartnerMasterModel.alternativeMobileNumber;
    _panNumberC.text = channelPartnerMasterModel.panNumber;
    _aadhaarNumberC.text = channelPartnerMasterModel.aadharCardNumber;
    _companyNameC.text = channelPartnerMasterModel.companyName;
    _reraNumberC.text = channelPartnerMasterModel.reraNumber;
    hasReraNumber = channelPartnerMasterModel.reraNumber.isNotEmpty;
    _gstNumberC.text = channelPartnerMasterModel.gstNumber;
    _officeAddressC.text = channelPartnerMasterModel.officeAddress;
    if (channelPartnerMasterModel.companyName.isNotEmpty) {
      selectedCompany = [
        {
          "DisplayName": channelPartnerMasterModel.companyName,
          "zAttributesId": 0,
        },
      ];
    }
    if (channelPartnerMasterModel.companyName.isNotEmpty) {
      // EXISTING COMPANY FLOW
      selectedCompanyType.value = companyTypeList[2];

      selectedCompany = [
        {
          "DisplayName": channelPartnerMasterModel.companyName,
          "zAttributesId": 0,
        },
      ];

      _companyNameC.text = channelPartnerMasterModel.companyName;

      selectedFirmsType = firmsType.firstWhere(
        (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
        orElse: () => firmsType[0],
      );
    } else {
      // NEW COMPANY FLOW
      selectedCompanyType.value = companyTypeList[1];
    }
    if (channelPartnerMasterModel.designation.isNotEmpty) {
      selectedDesignation = [
        {
          "DisplayName": channelPartnerMasterModel.designation,
          "zAttributesId": 0,
        },
      ];
    }
    selectedSpeciality = specialityList.firstWhere(
      (element) =>
          element['DisplayName'] == channelPartnerMasterModel.speciality,
      orElse: () => specialityList.first,
    );
    selectedFirmsType = firmsType.firstWhere(
      (e) => e['DisplayName'] == channelPartnerMasterModel.firmsType,
      orElse: () => firmsType.first,
    );
    selectedType = type.firstWhere(
      (element) => element["DisplayName"] == channelPartnerMasterModel.type,
      orElse: () => type.first,
    );
    // FILES
    selectedPANForPopUpFile.fileNameList =
        channelPartnerMasterModel.panCardUrl == ""
            ? []
            : channelPartnerMasterModel.panCardUrl.split(",");
    selectedAadhaarForPopUpFile.fileNameList =
        channelPartnerMasterModel.aadharCardUrl == ""
            ? []
            : channelPartnerMasterModel.aadharCardNumber.split(",");

    selectedDistrict = {
      "DisplayName": widget.channelPartnerModel!.districtName,
      "zAttributesId": widget.channelPartnerModel!.districtMasterId,
    };
    selectedCity = {
      "DisplayName": widget.channelPartnerModel!.cityName,
      "zAttributesId": widget.channelPartnerModel!.cityMasterId,
    };
    selectedState = {
      "DisplayName": widget.channelPartnerModel!.stateName,
      "zAttributesId": widget.channelPartnerModel!.stateMasterId,
    };
  }

  // ON SAVE BUTTON
  void _submitForm({int index = 0}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.channelPartnerModel != null) {
      _channelPartnerCubit.updateChannelPartner(
        context: context,
        channelPartnerId: widget.channelPartnerModel!.channelPartnerId,
        uniqueKey: widget.channelPartnerModel!.uniquekey,
        index: widget.index!,
        name: _nameC.text,
        emailId: _emailC.text,
        mobileNumber: _mobileNumberC.text,
        panCardNumber: _panNumberC.text,
        aadharCardNumber: _aadhaarNumberC.text,
        speciality: selectedSpeciality["DisplayName"],
        officeAddress: _officeAddressC.text,
        panCardURL: selectedPANForPopUpFile,
        aadharCardURL: selectedAadhaarForPopUpFile,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        reraNumber: _reraNumberC.text,
        companyName: _companyNameC.text,
      );
    } else {
      _channelPartnerCubit.addChannelPartner(
        context: context,
        channelPartnerId: 0,
        name: _nameC.text,
        emailId: _emailC.text,
        mobileNumber: _mobileNumberC.text,
        panCardNumber: _panNumberC.text,
        aadharCardNumber: _aadhaarNumberC.text,
        speciality: selectedSpeciality["DisplayName"],
        officeAddress: _officeAddressC.text,
        panCardURL: selectedPANForPopUpFile,
        aadharCardURL: selectedAadhaarForPopUpFile,
        selectedCountryNameId: 1,
        selectedStateId: selectedState!["zAttributesId"],
        selectedDistrictId: selectedDistrict!["zAttributesId"],
        selectedCityId: selectedCity!["zAttributesId"],
        reraNumber: _reraNumberC.text,
        companyName: _companyNameC.text,
      );
    }
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
                    Text("Basic Details", style: AppTextStyle.ts14M()),
                    const SizedBox(height: 6.0),
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
                      isRequired: true,
                      hint: "Enter Email Id",
                      inputFormatterList: InputValidator.emailInputFormatters(),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value == "") {
                          return "Email id is required";
                        }
                        if (!InputValidator.isValidEmail(value)) {
                          return "Invalid email id";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Mobile Number',
                      isRequired: true,
                      hint: "Enter Mobile Number",
                      textController: _mobileNumberC,
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
                      initialValue: selectedCompanyType.value,
                      dataList: companyTypeList,
                      onSelected: (value) {
                        _companyNameC.clear();
                        selectedCompanyType.value = value;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: selectedCompanyType,
                      builder: (context, value, child) {
                        final int typeId = value['zAttributesId'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (typeId == 2) ...[
                              /// COMPANY DROPDOWN
                              CustomMultipleSelectPopup(
                                title: "Company",
                                isRequired: true,
                                isMultiSelect: false,
                                initialValue: selectedCompany,
                                dataFetchCallBack: _fetchCompanyList,
                                onSelected: (selectedValue) {
                                  setState(() {
                                    selectedCompany = selectedValue;

                                    if (selectedValue.isNotEmpty) {
                                      final company = selectedValue.first;
                                      _companyNameC.text =
                                          company['DisplayName'] ?? '';
                                      if (company.containsKey('FirmsType')) {
                                        selectedFirmsType = firmsType
                                            .firstWhere(
                                              (e) =>
                                                  e['DisplayName'] ==
                                                  company['FirmsType'],
                                              orElse: () => firmsType[0],
                                            );
                                      }
                                    }
                                  });
                                },

                                validator: (selectedValue) {
                                  if (selectedValue == null ||
                                      selectedValue.isEmpty) {
                                    return "Company is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              /// COMPANY NAME (READ ONLY)
                              CustomTextField(
                                title: 'Company Name',
                                isRequired: true,
                                hint: "Company Name",
                                textController: _companyNameC,
                                readOnly: true,
                              ),
                            ],
                            if (typeId == 1) ...[
                              CustomTextField(
                                title: 'Company Name',
                                isRequired: true,
                                hint: "Enter Company Name",
                                textController: _companyNameC,
                                inputFormatterList: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return "Company Name is required";
                                  }
                                  return null;
                                },
                              ),
                            ],
                            if (typeId == 1 || typeId == 2) ...[
                              CustomDropDownWidget(
                                title: "Firms Type",
                                isRequired: true,
                                dataList: firmsType,
                                initialValue: selectedFirmsType,
                                onSelected: (value) {
                                  if (typeId == 1) {
                                    setState(() {
                                      selectedFirmsType = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: "Designation",
                      isRequired: false,
                      isMultiSelect: false,
                      initialValue: selectedDesignation,
                      dataFetchCallBack: _fetchDesignationList,
                      onSelected: (selectedValue) {
                        setState(() {
                          selectedDesignation = selectedValue;
                        });
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Type",
                      isRequired: false,
                      dataList: type,
                      initialValue: selectedType,
                      onSelected: (value) {
                        setState(() {
                          selectedType = value;
                        });
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: hasReraNumber,
                          onChanged: (value) {
                            setState(() {
                              hasReraNumber = value ?? false;

                              if (!hasReraNumber) {
                                _reraNumberC.clear();
                              }
                            });
                          },
                        ),
                        Text(
                          "Do you have RERA Number",
                          style: AppTextStyle.ts14M(),
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 0.2,
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      title: 'RERA Number',
                      isRequired: hasReraNumber,
                      readOnly: !hasReraNumber,
                      textController: _reraNumberC,
                      inputFormatterList: InputValidator.reraInputFormatters(),
                      validator: (value) {
                        if (hasReraNumber) {
                          if (value == null || value.trim().isEmpty) {
                            return "RERA Number is required";
                          }
                        }
                        return null;
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
                    Text("Speciality", style: AppTextStyle.ts14M()),
                    Divider(
                      thickness: 0.2,
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                    const SizedBox(height: 6.0),
                    CustomDropDownWidget(
                      title: "Speciality",
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
                    Text("Document Details", style: AppTextStyle.ts14M()),
                    Divider(
                      thickness: 0.2,
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                    const SizedBox(height: 6.0),
                    CustomTextField(
                      title: 'PAN Number',
                      isRequired: true,
                      hint: "Enter PAN Number",
                      textController: _panNumberC,
                      inputFormatterList: InputValidator.panInputFormatters(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "PAN Number is required";
                        }
                        if (value.trim().isNotEmpty &&
                            !InputValidator.isValidPAN(value)) {
                          return "Invalid PAN Number";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
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
                    CustomTextField(
                      title: 'Aadhaar Card Number',
                      isRequired: true,
                      hint: "Enter Aadhaar Card Number",
                      textController: _aadhaarNumberC,
                      inputFormatterList:
                          InputValidator.aadharNumberInputFormatter(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Aadhaar Number is required";
                        }
                        if (!InputValidator.isValidAadharNumber(value)) {
                          return "Invalid Aadhaar Number";
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Upload Aadhaar Card",
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
                    ),

                    CustomTextField(
                      title: 'GST Number',
                      textController: _gstNumberC,
                      inputFormatterList: InputValidator.gstInputFormatters(),
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
                    Text("Address Details", style: AppTextStyle.ts14M()),
                    Divider(
                      thickness: 0.2,
                      color: AppColor.black.withValues(alpha: 0.50),
                    ),
                    const SizedBox(height: 6.0),
                    AddressWidget(
                      formKey: _formKey,
                      incomingStateId:
                          widget.channelPartnerModel?.stateMasterId,
                      incomingDistrictId:
                          widget.channelPartnerModel?.districtMasterId,
                      incomingCityId: widget.channelPartnerModel?.cityMasterId,
                      stateChange: (selectedState) {
                        this.selectedState = selectedState;
                      },
                      districtChange: (selectedDistrict) {
                        this.selectedDistrict = selectedDistrict;
                      },
                      cityChange: (selectedCity) {
                        this.selectedCity = selectedCity;
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
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
