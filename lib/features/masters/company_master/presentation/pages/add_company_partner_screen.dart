import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddCompanyPartnerScreen extends StatefulWidget {
  final CompanyPartnerModel? companyPartner;
  final int? index;

  const AddCompanyPartnerScreen({super.key, this.companyPartner, this.index});

  @override
  State<AddCompanyPartnerScreen> createState() =>
      _AddCompanyPartnerScreenState();
}

class _AddCompanyPartnerScreenState extends State<AddCompanyPartnerScreen> {
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _firstNameC;
  late TextEditingController _middleNameC;
  late TextEditingController _lastNameC;
  late TextEditingController _mobileC;
  late TextEditingController _emailC;
  late TextEditingController _percentageC;
  late TextEditingController _panC;
  late TextEditingController _aadhaarC;

  // GENDER LIST
  final List<Map<String, dynamic>> genderList = const [
    {"zAttributesId": -1, "DisplayName": "Select"},
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];
  // SELECTED GENDER
  late Map<String, dynamic> selectedGender;
  DateTime? dateOfBirth;

  // FILE PICKER VARIABLES
  MultiFilePickerModel panFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel aadhaarFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel photoFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // CUBIT
  late CompanyMasterAddCubit _companyMasterAddCubit;

  @override
  void initState() {
    super.initState();
    _companyMasterAddCubit = context.read<CompanyMasterAddCubit>();
    _initControllers(widget.companyPartner);
    _prefill(widget.companyPartner);
  }

  @override
  void dispose() {
    _firstNameC.dispose();
    _middleNameC.dispose();
    _lastNameC.dispose();
    _mobileC.dispose();
    _emailC.dispose();
    _percentageC.dispose();
    _panC.dispose();
    _aadhaarC.dispose();
    super.dispose();
  }

  // INITIALISE CONTROLLERS AND SET VALUES
  void _initControllers(CompanyPartnerModel? partner) {
    _firstNameC = TextEditingController(text: partner?.firstName);
    _middleNameC = TextEditingController(text: partner?.middleName);
    _lastNameC = TextEditingController(text: partner?.lastName);
    _mobileC = TextEditingController(text: partner?.mobileNumber);
    _emailC = TextEditingController(text: partner?.emailId);
    _percentageC = TextEditingController(
      text: partner?.partnerPercentage.toString(),
    );
    _panC = TextEditingController(text: partner?.panNumber);
    _aadhaarC = TextEditingController(text: partner?.aadharCardNumber);
    selectedGender = genderList.first;
    dateOfBirth = partner?.dateOfBirth;
  }

  // PREFILL DATA
  void _prefill(CompanyPartnerModel? partner) {
    if (partner == null) {
      return;
    }
    selectedGender = genderList.firstWhere(
      (e) => e['DisplayName'] == partner.gender,
      orElse: () => genderList.first,
    );

    panFile.fileNameList =
        partner.panCardURL.isEmpty ? [] : partner.panCardURL.split(",");
    panFile.fileBytesList = List.generate(
      panFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    aadhaarFile.fileNameList =
        partner.aadharCardURL.isEmpty ? [] : partner.aadharCardURL.split(",");
    aadhaarFile.fileBytesList = List.generate(
      aadhaarFile.fileNameList.length,
      (_) => Uint8List(0),
    );

    photoFile.fileNameList =
        partner.photoURL.isEmpty ? [] : partner.photoURL.split(",");
    photoFile.fileBytesList = List.generate(
      photoFile.fileNameList.length,
      (_) => Uint8List(0),
    );
  }

  // SAVE FUNCTION
  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final partner = CompanyPartnerModel(
      companyPartnerId: widget.companyPartner?.companyPartnerId ?? 0,
      uniquekey: widget.companyPartner?.uniquekey ?? '',
      companyId:
          widget.companyPartner?.companyId ?? (widget.index != null ? 0 : 0),
      firstName: _firstNameC.text.trim(),
      lastName: _lastNameC.text.trim(),
      middleName: _middleNameC.text.trim(),
      fullName:
          "${_firstNameC.text.trim()} ${_middleNameC.text.trim()} ${_lastNameC.text.trim()}",
      dateOfBirth: dateOfBirth ?? DateTime.now(),
      gender: selectedGender['DisplayName'],
      mobileNumber: _mobileC.text,
      emailId: _emailC.text.trim(),
      partnerPercentage: double.tryParse(_percentageC.text) ?? 0,
      panNumber: _panC.text,
      aadharCardNumber: _aadhaarC.text,
      panCardURL: '',
      aadharCardURL: '',
      photoURL: '',
      createdById: widget.companyPartner?.createdById ?? -1,
      createdBy: widget.companyPartner?.createdBy ?? '',
      createdDate: widget.companyPartner?.createdDate ?? DateTime.now(),
      modifiedById: widget.companyPartner?.modifiedById ?? -1,
      modifiedBy: widget.companyPartner?.modifiedBy ?? '',
      modifiedDate: DateTime.now(),
      panCardFile: panFile,
      aadharCardFile: aadhaarFile,
      photoFile: photoFile,
    );

    _companyMasterAddCubit.addUpdateCompanyPartnerData(
      context: context,
      partner,
      index: widget.index,
    );
    goRouter.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Company",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.companyPartner == null
                        ? "Add Company Partner"
                        : "Update Company Partner",
                    style: AppTextStyle.ts16SB(color: AppColor.black),
                  ),
                  verticalSpacing(),
                  CustomTextField(
                    title: 'First Name',
                    isRequired: true,
                    textController: _firstNameC,
                    hint: "Enter First Name",
                    inputFormatterList: InputValidator.textOnly(50),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? "First Name is required"
                                : null,
                  ),
                  CustomTextField(
                    title: 'Middle Name',
                    isRequired: true,
                    textController: _middleNameC,
                    hint: "Enter Middle Name",
                    inputFormatterList: InputValidator.textOnly(50),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? "Middle Name is required"
                                : null,
                  ),
                  CustomTextField(
                    title: 'Last Name',
                    isRequired: true,
                    textController: _lastNameC,
                    hint: "Enter Last Name",
                    inputFormatterList: InputValidator.textOnly(50),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? "Last Name is required"
                                : null,
                  ),
                  CustomDatePicker(
                    title: "DOB",
                    isRequired: true,
                    initialDate: dateOfBirth,
                    setValue: (value) => dateOfBirth = value,
                    validator: (value) {
                      if (value == null) return "Date of Birth is required";
                      if (!InputValidator.isValidAge(value)) {
                        return 'Age should be greater than or equal to 18.';
                      }
                      return null;
                    },
                  ),
                  CustomDropDownWidget(
                    title: "Gender",
                    isRequired: true,
                    initialValue: selectedGender,
                    dataList: genderList,
                    onSelected: (value) => selectedGender = value,
                    validator: (value) {
                      if (value == null || value['zAttributesId'] == -1) {
                        return 'Gender is required';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Mobile Number',
                    isRequired: true,
                    textController: _mobileC,
                    hint: "Enter Mobile Number",
                    keyboardType: TextInputType.number,
                    inputFormatterList: InputValidator.digit(10),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Mobile is required";
                      }
                      if (!InputValidator.isValidMobileNumber(value)) {
                        return "Invalid mobile number";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Email Id',
                    isRequired: true,
                    textController: _emailC,
                    hint: "Enter Email Id",
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
                  CustomTextField(
                    title: 'Share %',
                    isRequired: true,
                    textController: _percentageC,
                    keyboardType: TextInputType.number,
                    hint: 'Enter Share %',
                    inputFormatterList: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,3}(\.\d{0,2})?$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Share % is required";
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0 || parsed > 100) {
                        return "Enter a valid % between 1 and 100";
                      }

                      final existingPartners =
                          _companyMasterAddCubit.state.companyPartner;
                      double currentEditingValue = 0;
                      if (widget.index != null &&
                          widget.index! < existingPartners.length) {
                        currentEditingValue =
                            existingPartners[widget.index!].partnerPercentage;
                      }
                      final totalWithoutCurrent =
                          existingPartners
                              .map((e) => e.partnerPercentage)
                              .fold<double>(0, (p, e) => p + e) -
                          currentEditingValue;
                      if (totalWithoutCurrent + parsed > 100) {
                        final available = (100 - totalWithoutCurrent)
                            .clamp(0, 100)
                            .toStringAsFixed(2);
                        return "Only $available% available to allocate";
                      }

                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'PAN Number',
                    isRequired: true,
                    textController: _panC,
                    hint: "Enter PAN Number",
                    inputFormatterList: InputValidator.panInputFormatters(),
                    validator: (value) {
                      if ((value == null || value.trim().isEmpty)) {
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
                    title: "Upload PAN Number",
                    isRequired: true,
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
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return "PAN Document is required";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    title: 'Aadhaar Card Number',
                    isRequired: true,
                    textController: _aadhaarC,
                    hint: "Enter Aadhar Card Number",
                    inputFormatterList:
                        InputValidator.aadhaarNumberInputFormatter(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Aadhaar Card Number is required";
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
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return "Aadhaar Document is required";
                      }
                      return null;
                    },
                  ),
                  CustomMultiFilePicker(
                    title: "Upload Photo",
                    isRequired: true,
                    initialFileList: photoFile.fileNameList,
                    onFilePickedCallback: (bytesList, fileNameList) {
                      photoFile.fileNameList = fileNameList;
                      photoFile.fileBytesList = bytesList;
                    },
                    onFileDeleteCallback: (
                      fileBytesList,
                      fileNameList,
                      deleted,
                    ) {
                      photoFile.fileBytesList = fileBytesList;
                      photoFile.fileNameList = fileNameList;
                      photoFile.deletedFileList = deleted;
                    },
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return "Applicant Photo is required";
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
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(text: "Save", onPressed: _save),
        ),
      ),
    );
  }
}
