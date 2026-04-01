import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class UpdateUserDetailsScreen extends StatefulWidget {
  final UserModel? userData;
  const UpdateUserDetailsScreen({super.key, this.userData});

  @override
  State<UpdateUserDetailsScreen> createState() =>
      _UpdateUserDetailsScreenState();
}

class _UpdateUserDetailsScreenState extends State<UpdateUserDetailsScreen> {
  // CUBIT
  late ProfileCubit _profileCubit;
  // FORM KEY
  final GlobalKey<FormState> _updateUserBasicDetailsKey =
      GlobalKey<FormState>();

  late TextEditingController _firstNameC,
      _middleNameC,
      _lastNameC,
      _personalEmailC,
      _personalMobileNumberC,
      _communicationAddressC,
      _permanentAddressC,
      _aadharNumberC,
      _panNumberC,
      _drivingLicenceNumberC,
      _voterIdNumberC,
      _passportNumberC;

  // DATES
  DateTime? dateOfBirth;
  // SELECTED VALUES
  Map<String, dynamic>? selectedGender;
  Map<String, dynamic>? selectedMaritalStatus;
  Map<String, dynamic>? selectedBloodGroup;

  // LISTS
  List<Map<String, dynamic>> genderList = [
    {"zAttributesId": -1, "DisplayName": "Select Gender"},
    {"zAttributesId": 1, "DisplayName": "Male"},
    {"zAttributesId": 2, "DisplayName": "Female"},
    {"zAttributesId": 3, "DisplayName": "Other"},
  ];
  List<Map<String, dynamic>> maritalStatusList = [
    {"zAttributesId": -1, "DisplayName": "Select Marital Status"},
    {"zAttributesId": 1, "DisplayName": "Single"},
    {"zAttributesId": 2, "DisplayName": "Married"},
    {"zAttributesId": 3, "DisplayName": "Divorce"},
    {"zAttributesId": 4, "DisplayName": "Widow"},
  ];
  List<Map<String, dynamic>> bloodGroupList = [
    {"zAttributesId": -1, "DisplayName": "Select Blood Group"},
    {"zAttributesId": 1, "DisplayName": "A+"},
    {"zAttributesId": 2, "DisplayName": "A-"},
    {"zAttributesId": 3, "DisplayName": "O+"},
    {"zAttributesId": 4, "DisplayName": "O-"},
    {"zAttributesId": 5, "DisplayName": "AB+"},
    {"zAttributesId": 6, "DisplayName": "AB-"},
    {"zAttributesId": 7, "DisplayName": "B+"},
    {"zAttributesId": 8, "DisplayName": "B-"},
  ];

  @override
  void initState() {
    super.initState();
    _profileCubit = context.read<ProfileCubit>();
    initializeControllers();
    _initializeDropdowns();
    if (widget.userData != null) {
      _populateForm(widget.userData!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _profileCubit.state.user;

      if (user != null) {
        _profileCubit.getEmployeeMasterList(1, 100, user.employeeId);
      }
    });
  }

  void initializeControllers() {
    _firstNameC = TextEditingController();
    _middleNameC = TextEditingController();
    _lastNameC = TextEditingController();
    _personalEmailC = TextEditingController();
    _personalMobileNumberC = TextEditingController();
    _communicationAddressC = TextEditingController();
    _permanentAddressC = TextEditingController();
    _aadharNumberC = TextEditingController();
    _panNumberC = TextEditingController();
    _drivingLicenceNumberC = TextEditingController();
    _voterIdNumberC = TextEditingController();
    _passportNumberC = TextEditingController();
  }

  @override
  void dispose() {
    // TEXT CONTROLLERS
    _firstNameC.dispose();
    _middleNameC.dispose();
    _lastNameC.dispose();
    _personalEmailC.dispose();
    _personalMobileNumberC.dispose();
    _communicationAddressC.dispose();
    _permanentAddressC.dispose();
    _aadharNumberC.dispose();
    _panNumberC.dispose();
    _drivingLicenceNumberC.dispose();
    _voterIdNumberC.dispose();
    _passportNumberC.dispose();
    super.dispose();
  }

  // INITIALIZE DROPDOWNS
  void _initializeDropdowns() {
    // BASIC EMPLOYEE DETAILS
    selectedGender = genderList.first;
    selectedMaritalStatus = maritalStatusList.first;
    selectedBloodGroup = bloodGroupList.first;
  }

  // PREFILL
  void _populateForm(UserModel model) async {
    // TEXT CONTROLLER
    _firstNameC.text = model.firstName;
    _middleNameC.text = model.middleName;
    _lastNameC.text = model.lastName;
    _personalEmailC.text = model.emailId;
    _personalMobileNumberC.text = model.personalMobileNumber;
    _communicationAddressC.text = model.communicationAddress;
    _permanentAddressC.text = model.permanentAddress;

    // DROPDOWNS
    selectedGender = genderList.firstWhere(
      (item) => item['DisplayName'] == model.gender,
      orElse: () => genderList.first,
    );
    selectedMaritalStatus = maritalStatusList.firstWhere(
      (item) => item['DisplayName'] == model.maritalStatus,
      orElse: () => maritalStatusList.first,
    );
    selectedBloodGroup = bloodGroupList.firstWhere(
      (item) => item['DisplayName'] == model.bloodGroup,
      orElse: () => bloodGroupList.first,
    );

    // DATES
    dateOfBirth = model.dateOfBirth;
    _aadharNumberC.text = model.aadharCardNumber;
    _panNumberC.text = model.panCardNumber;
    _drivingLicenceNumberC.text = model.drivingLicenceNumber;
    _voterIdNumberC.text = model.voterCardNumber;
    _passportNumberC.text = model.passportNumber;
  }

  // UPDATE USER BASIC DETAILS
  void _updateUserBasicDetails() async {
    if (_updateUserBasicDetailsKey.currentState!.validate()) {
      final payload = {
        "EmployeeId": widget.userData!.employeeId,
        "UniqueKey": widget.userData!.uniqueKey,
        "FirstName": _firstNameC.text.trim(),
        "MiddleName": _middleNameC.text.trim(),
        "LastName": _lastNameC.text.trim(),
        "Gender": selectedGender!["DisplayName"],
        "MaritalStatus": selectedMaritalStatus!["DisplayName"],
        "DateOfBirth": dateOfBirth!.toIso8601String(),
        "EmailId": _personalEmailC.text.trim(),
        "PersonalMobileNumber": _personalMobileNumberC.text.trim(),
        "CommunicationAddress": _communicationAddressC.text.trim(),
        "PermanentAddress": _permanentAddressC.text.trim(),
        "BloodGroup": selectedBloodGroup!["DisplayName"],
        "AadharCardNumber": _aadharNumberC.text.trim(),
        "PanCardNumber": _panNumberC.text.trim(),
        "DrivingLicenceNumber": _drivingLicenceNumberC.text.trim(),
        "VoterCardNumber": _voterIdNumberC.text.trim(),
        "PassportNumber": _passportNumberC.text.trim(),
      };
      //  SUBMIT USER BASIC DETAILS
      await _profileCubit.updateUserBasicDetails(
        context: context,
        body: payload,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Basic Details",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _updateUserBasicDetailsKey,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Update Basic Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(),
                CustomTextField(
                  title: 'First Name',
                  isRequired: true,
                  hint: "Enter First Name",
                  textController: _firstNameC,
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'First Name is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: 'Middle Name',
                  isRequired: true,
                  hint: "Enter Middle Name",
                  textController: _middleNameC,
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'Middle Name is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: 'Last Name',
                  isRequired: true,
                  hint: "Enter Last Name",
                  textController: _lastNameC,
                  validator: (string) {
                    if (string == null || string.trim().isEmpty) {
                      return 'Last Name is required';
                    }
                    return null;
                  },
                ),
                CustomDropDownWidget(
                  title: 'Gender',
                  isRequired: true,
                  initialValue: selectedGender,
                  dataList: genderList,
                  onSelected: (value) => selectedGender = value,
                  validator: (value) {
                    if (value == null || value["zAttributesId"] == -1) {
                      return 'Gender is required';
                    }
                    return null;
                  },
                ),
                CustomDropDownWidget(
                  title: 'Marital Status',
                  isRequired: true,
                  initialValue: selectedMaritalStatus,
                  dataList: maritalStatusList,
                  onSelected: (value) => selectedMaritalStatus = value,
                  validator: (value) {
                    if (value == null || value["zAttributesId"] == -1) {
                      return 'Marital Status is required';
                    }
                    return null;
                  },
                ),
                CustomDropDownWidget(
                  title: 'Blood Group',
                  isRequired: true,
                  initialValue: selectedBloodGroup,
                  dataList: bloodGroupList,
                  onSelected: (value) => selectedBloodGroup = value,
                  validator: (value) {
                    if (value == null || value["zAttributesId"] == -1) {
                      return 'Blood Group is required';
                    }
                    return null;
                  },
                ),
                CustomDatePicker(
                  title: 'DOB',
                  isRequired: true,
                  initialDate: dateOfBirth,
                  validator: (value) {
                    if (value == null) {
                      return 'DOB is required';
                    }
                    if (!InputValidator.isValidAge(value)) {
                      return 'Age should be greater than or equal to 18.';
                    }
                    return null;
                  },
                  setValue: (value) => dateOfBirth = value,
                ),
                CustomTextField(
                  title: 'Email Id',
                  hint: "Enter Email Id",
                  isRequired: true,
                  textController: _personalEmailC,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Id is required';
                    }
                    if (!InputValidator.isValidEmail(value)) {
                      return 'Email Id is not valid';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: 'Personal Mobile Number',
                  hint: "Enter Personal Mobile Number",
                  isRequired: true,
                  textController: _personalMobileNumberC,
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Personal Mobile Number is required';
                    }
                    if (!InputValidator.isValidMobileNumber(value)) {
                      return 'Mobile number is not valid';
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
                  title: "Aadhaar Number",
                  isRequired: true,
                  hint: "Enter Aadhaar Number",
                  textController: _aadharNumberC,
                  inputFormatterList:
                      InputValidator.aadhaarNumberInputFormatter(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Aadhaar Card Number is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "PAN Number",
                  isRequired: true,
                  hint: "Enter PAN Number",
                  textController: _panNumberC,
                  inputFormatterList: InputValidator.panInputFormatters(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'PAN Card Number is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Passport Number",
                  hint: "Enter Passport Number",
                  textController: _passportNumberC,
                  inputFormatterList: InputValidator.passportInputFormatters(),
                ),
                CustomTextField(
                  title: "Driving License Number",
                  hint: "Enter Driving License Number",
                  textController: _drivingLicenceNumberC,
                  inputFormatterList:
                      InputValidator.drivingLicenceInputFormatters(),
                ),
                CustomTextField(
                  title: "Voting Card Number",
                  hint: "Enter Voting Card Number",
                  textController: _voterIdNumberC,
                  inputFormatterList: InputValidator.voterIdInputFormatters(),
                ),
                CustomTextField(
                  title: 'Communication Address',
                  hint: "Enter Communication Address",
                  isRequired: true,
                  textController: _communicationAddressC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(500)],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Communication Address is required';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: 'Permanent Address',
                  hint: "Enter Permanent Address",
                  isRequired: true,
                  textController: _permanentAddressC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(500)],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Permanent Address is required';
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
          color: AppColor.white,
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(Icons.edit, color: AppColor.white, size: 18),
            text: 'Update',
            backgroundColor: AppColor.primary,
            onPressed: _updateUserBasicDetails,
          ),
        ),
      ),
    );
  }
}
