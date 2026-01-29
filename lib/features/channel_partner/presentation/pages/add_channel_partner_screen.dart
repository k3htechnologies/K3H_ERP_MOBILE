import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
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
  //EDIT MODE
  bool get _isEditMode => widget.channelPartnerModel != null;

  // REPOSITORY
  final CompanyMasterRepository _companyMasterRepository =
      serviceLocator<CompanyMasterRepository>();
  final ProjectMasterRepository _projectMasterRepository =
      serviceLocator<ProjectMasterRepository>();

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
    _initializeTextEditingController();
    selectedCompanyType = ValueNotifier<Map<String, dynamic>>(
      companyTypeList[0],
    );
    selectedSpeciality = specialityList[0];

    // Prefill if in edit mode
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

  // SELECTION VARIABLE
  late Map<String, dynamic> selectedSpeciality;
  late Map<String, dynamic> selectedSpecialityFilter;
  late ValueNotifier<Map<String, dynamic>> selectedCompanyType;
  // MULTI SELECT FOR PROJECTS, SINGLE SELECT FOR COMPANY
  List<Map<String, dynamic>> selectedProject = [];
  List<Map<String, dynamic>> selectedCompany = [];

  // FETCH PROJECT LIST
  Future<Map<String, dynamic>> _fetchProjectList(
    int pageNumber, {
    String? value,
  }) async {
    try {
      final result = await _projectMasterRepository.getProjectList(
        pageNumber: pageNumber,
        pageSize: 10,
        queryParams:
            value != null && value.isNotEmpty ? {"ProjectName": value} : null,
      );

      return result.fold(
        (failure) => {'itemList': [], 'totalNumberOfRecord': 0},
        (response) {
          final projects = response['data'] as List<ProjectModel>;
          final itemList =
              projects
                  .map(
                    (p) => {
                      'zAttributesId': p.projectId,
                      'DisplayName': p.projectName,
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
    _aadhaarNumberC.text = channelPartnerMasterModel.adharCardNumber;
    _companyNameC.text = channelPartnerMasterModel.companyName;
    _reraNumberC.text = channelPartnerMasterModel.reraNumber;
    _gstNumberC.text = channelPartnerMasterModel.gstNumber;
    _officeAddressC.text = channelPartnerMasterModel.officeAddress;
    selectedCompanyType.value = companyTypeList[1];

    selectedSpeciality = specialityList.firstWhere(
      (element) =>
          element['DisplayName'] == channelPartnerMasterModel.speciality,
      orElse: () => specialityList.first,
    );
    // FILES
    selectedPANForPopUpFile.fileNameList =
        channelPartnerMasterModel.panCardUrl == ""
            ? []
            : channelPartnerMasterModel.panCardUrl.split(",");
    selectedAadhaarForPopUpFile.fileNameList =
        channelPartnerMasterModel.adharCardUrl == ""
            ? []
            : channelPartnerMasterModel.adharCardUrl.split(",");

    // Prefill Project (multi select - all projects)
    if (channelPartnerMasterModel.projectId.isNotEmpty) {
      var cpProjectIdList = channelPartnerMasterModel.projectId.split(',');
      var cpProjectNameList = channelPartnerMasterModel.projectName.split(',');
      if (cpProjectIdList.isNotEmpty && cpProjectNameList.isNotEmpty) {
        selectedProject =
            cpProjectIdList.asMap().entries.map((entry) {
              return {
                'zAttributesId': int.parse(entry.value),
                'DisplayName': cpProjectNameList[entry.key],
              };
            }).toList();
      }
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
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? "Update Channel Partner"
                      : "Add Channel Partner",
                  style: AppTextStyle.ts16SB(),
                ),
                verticalSpacing(height: 15),
                CustomTextField(
                  title: 'Name',
                  isRequired: true,
                  hint: "Enter Name",
                  textController: _nameC,
                  inputFormatterList: InputValidator.textOnly(50),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required";
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
                    if (value['zAttributesId'] == 1) {
                      return CustomTextField(
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
                      );
                    }
                    if (value['zAttributesId'] == 2) {
                      return CustomMultipleSelectPopup(
                        title: "Company",
                        isRequired: true,
                        isMultiSelect: false,
                        initialValue: selectedCompany,
                        dataFetchCallBack: _fetchCompanyList,
                        onSelected: (selectedValue) {
                          setState(() {
                            selectedCompany = selectedValue;
                            if (selectedValue.isNotEmpty) {
                              _companyNameC.text =
                                  selectedValue.first['DisplayName'] ?? '';
                            }
                          });
                        },
                        validator: (selectedValue) {
                          if (selectedValue == null || selectedValue.isEmpty) {
                            return "Company is required";
                          }
                          return null;
                        },
                      );
                    }
                    return SizedBox();
                  },
                ),
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
                    selectedAadhaarForPopUpFile.fileBytesList = fileBytesList;
                    selectedAadhaarForPopUpFile.deletedFileList = deletedFile;
                  },
                ),
                CustomTextField(
                  title: 'RERA Number',
                  textController: _reraNumberC,
                  inputFormatterList: InputValidator.reraInputFormatters(),
                ),
                CustomTextField(
                  title: 'GST Number',
                  textController: _gstNumberC,
                  inputFormatterList: InputValidator.gstInputFormatters(),
                ),
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
                // Project (Multi Select)
                CustomMultipleSelectPopup(
                  title: "Project",
                  isRequired: true,
                  isMultiSelect: true,
                  initialValue: selectedProject,
                  dataFetchCallBack: _fetchProjectList,
                  onSelected: (value) {
                    setState(() {
                      selectedProject = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Project is required";
                    }
                    return null;
                  },
                ),
                verticalSpacing(),
                CustomTextField(
                  textController: _officeAddressC,
                  title: 'Office Address',
                  isRequired: true,
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 35,
          color: AppColor.white,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: CustomButton(
            leading: Icon(_isEditMode?Icons.edit:Icons.add,size: 18,color: AppColor.white,),
            text: _isEditMode ? "Update" : "Add",
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
