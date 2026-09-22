import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameC;
  late TextEditingController _middleNameC;
  late TextEditingController _lastNameC;
  late TextEditingController _mobileC;
  late TextEditingController _emailC;
  late TextEditingController _percentageC;
  late TextEditingController _panC;
  late TextEditingController _aadhaarC;
  DateTime? dateOfBirth;
  late final ValueNotifier<Map<String, dynamic>?> _selectedGenderNotifier;
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
  late CompanyMasterAddCubit _companyMasterAddCubit;
  @override
  void initState() {
    super.initState();
    _companyMasterAddCubit = context.read<CompanyMasterAddCubit>();
    _selectedGenderNotifier = ValueNotifier(null);
    _initControllers(widget.companyPartner);
    _populateFormFields(widget.companyPartner);
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
    _selectedGenderNotifier.dispose();
    super.dispose();
  }

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
    dateOfBirth = partner?.dateOfBirth;
  }

  void _populateFormFields(CompanyPartnerModel? partner) {
    if (partner == null) return;
    _selectedGenderNotifier.value = genderList.firstWhere(
      (e) => e['DisplayName'] == partner.gender,
      orElse: () => genderList.first,
    );
    if (partner.panCardFile != null &&
        partner.panCardFile!.fileNameList.isNotEmpty) {
      panFile.fileNameList = partner.panCardFile!.fileNameList;
      panFile.fileBytesList = partner.panCardFile!.fileBytesList;
      panFile.deletedFileList = partner.panCardFile!.deletedFileList;
    } else if (partner.panCardURL.isNotEmpty) {
      panFile.fileNameList = partner.panCardURL.split(",");
      panFile.fileBytesList = [];
    }
    if (partner.aadharCardFile != null &&
        partner.aadharCardFile!.fileNameList.isNotEmpty) {
      aadhaarFile.fileNameList = partner.aadharCardFile!.fileNameList;
      aadhaarFile.fileBytesList = partner.aadharCardFile!.fileBytesList;
      aadhaarFile.deletedFileList = partner.aadharCardFile!.deletedFileList;
    } else if (partner.aadharCardURL.isNotEmpty) {
      aadhaarFile.fileNameList = partner.aadharCardURL.split(",");
      aadhaarFile.fileBytesList = [];
    }
    if (partner.photoFile != null &&
        partner.photoFile!.fileNameList.isNotEmpty) {
      photoFile.fileNameList = partner.photoFile!.fileNameList;
      photoFile.fileBytesList = partner.photoFile!.fileBytesList;
      photoFile.deletedFileList = partner.photoFile!.deletedFileList;
    } else if (partner.photoURL.isNotEmpty) {
      photoFile.fileNameList = partner.photoURL.split(",");
      photoFile.fileBytesList = [];
    }
  }

  void _saveForm() {
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
          "${_firstNameC.text.trim()} "
          "${_middleNameC.text.trim()} "
          "${_lastNameC.text.trim()}",
      dateOfBirth: dateOfBirth ?? DateTime.now(),
      gender: _selectedGenderNotifier.value?['DisplayName'] ?? "",
      mobileNumber: _mobileC.text,
      emailId: _emailC.text.trim(),
      partnerPercentage: double.tryParse(_percentageC.text) ?? 0,
      panNumber: _panC.text,
      aadharCardNumber: _aadhaarC.text,
      panCardURL:
          panFile.fileNameList.isNotEmpty
              ? panFile.fileNameList.join(",")
              : widget.companyPartner?.panCardURL ?? '',
      aadharCardURL:
          aadhaarFile.fileNameList.isNotEmpty
              ? aadhaarFile.fileNameList.join(",")
              : widget.companyPartner?.aadharCardURL ?? '',
      photoURL:
          photoFile.fileNameList.isNotEmpty
              ? photoFile.fileNameList.join(",")
              : widget.companyPartner?.photoURL ?? '',
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
        screenTitle: "Company Master",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.companyPartner == null
                    ? "Add Company Partner"
                    : "Update Company Partner",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        title: "Date Of Birth",
                        isRequired: true,
                        initialDate: dateOfBirth,
                        setValue: (value) => dateOfBirth = value,
                        validator: (value) {
                          if (value == null) {
                            return "Date Of Birth is required.";
                          }
                          if (!InputValidator.isValidAge(value)) {
                            return 'Age should be greater than or equal to 18.';
                          }
                          return null;
                        },
                      ),
                      ValueListenableBuilder<Map<String, dynamic>?>(
                        valueListenable: _selectedGenderNotifier,
                        builder: (context, gender, _) {
                          return CustomDropDownWidget(
                            title: 'Gender',
                            isRequired: true,
                            initialValue: gender,
                            hintText: "Select Gender",
                            dataList: genderList,
                            onSelected: (value) {
                              _selectedGenderNotifier.value = value;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value["zAttributesId"] == -1) {
                                return 'Gender is required.';
                              }
                              return null;
                            },
                            onValueClear: () {
                              _selectedGenderNotifier.value = null;
                            },
                          );
                        },
                      ),
                      CustomTextField(
                        title: 'Mobile Number',
                        isRequired: true,
                        textController: _mobileC,
                        hint: "Enter Mobile Number",
                        keyboardType: TextInputType.number,
                        prefixType: CustomTextFieldPrefix.mobile,
                        inputFormatterList: InputValidator.digit(10),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Mobile Number is required.";
                          }
                          if (!InputValidator.isValidMobileNumber(value)) {
                            return "Invalid mobile number";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: 'E-Mail ID',
                        isRequired: true,
                        textController: _emailC,
                        hint: "Enter E-Mail ID",
                        inputFormatterList:
                            InputValidator.emailInputFormatters(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "E-Mail ID is required.";
                          }
                          if (!InputValidator.isValidEmail(value)) {
                            return "Enter a Valid E-Mail ID";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: 'Share',
                        isRequired: true,
                        textController: _percentageC,
                        prefixType: CustomTextFieldPrefix.percentage,
                        keyboardType: TextInputType.number,
                        hint: 'Enter Share',
                        inputFormatterList: InputValidator.percentage(),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              double.parse(value) == 0) {
                            return "Partner Percentage must be between 1 and 100";
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
                          if (value == null || value.trim().isEmpty) {
                            return "PAN Number is required.";
                          }
                          if (value.trim().isNotEmpty &&
                              !InputValidator.isValidPAN(value)) {
                            return "Invalid PAN Number";
                          }
                          return null;
                        },
                      ),
                      CustomMultiFilePicker(
                        title: "PAN Card",
                        isRequired: true,
                        filePickType: FilePickType.kycDocument,
                        initialFileList: panFile.fileNameList,
                        initialFileBytes: panFile.fileBytesList,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "PAN Document is required.";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        title: 'Aadhaar Card Number',
                        isRequired: true,
                        textController: _aadhaarC,
                        hint: "Enter Aadhar Card Number",
                        keyboardType: TextInputType.number,
                        inputFormatterList:
                            InputValidator.aadhaarNumberInputFormatter(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Aadhaar Card Number is required.";
                          }
                          if (!InputValidator.isValidAadharNumber(
                            value.trim(),
                          )) {
                            return "Invalid Aadhaar Card Number";
                          }
                          return null;
                        },
                      ),
                      CustomMultiFilePicker(
                        title: "Aadhaar Card",
                        isRequired: true,
                        filePickType: FilePickType.kycDocument,
                        initialFileList: aadhaarFile.fileNameList,
                        initialFileBytes: aadhaarFile.fileBytesList,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Aadhaar Document is required.";
                          }
                          return null;
                        },
                      ),
                      CustomMultiFilePicker(
                        title: "Photo",
                        maxFiles: 1,
                        isRequired: true,
                        filePickType: FilePickType.image,
                        initialFileList: photoFile.fileNameList,
                        initialFileBytes: photoFile.fileBytesList,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Partner Photo is required.";
                          }
                          return null;
                        },
                      ),
                      verticalSpacing(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(
            leading: Icon(
              widget.companyPartner == null ? Icons.add : Icons.edit,
              size: 16,
              color: AppColor.white,
            ),
            text: widget.companyPartner == null ? "Add" : "Update",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
