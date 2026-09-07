import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/model/gate_pass.model.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/presentation/cubit/gate_pass_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/custom_time_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddGatePassScreen extends StatefulWidget {
  final GatePassModel? gatePass;
  final int? index;
  const AddGatePassScreen({super.key, this.gatePass, this.index});

  @override
  State<AddGatePassScreen> createState() => _AddGatePassScreenState();
}

class _AddGatePassScreenState extends State<AddGatePassScreen> {
  // CUBIT
  late GatePassCubit _gatePassCubit;
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _visitorNameC,
      _addressC,
      _mobileNumberC,
      _numberOFParticipantsC,
      _remarkC;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedEmployeeNotifier;
  final ValueNotifier<Map<String, dynamic>?> _selectedGatePassPurpose =
      ValueNotifier(null);

  MultiFilePickerModel selectedFileForUpload = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // TIME VARIABLE
  final ValueNotifier<String?> _appointmentTimeNotifier = ValueNotifier(null);
  // DATE VARIABLE
  DateTime? _enquiryDate;
  bool get _isEditMode => widget.gatePass != null;
  @override
  void initState() {
    _gatePassCubit = context.read<GatePassCubit>();
    initialiseControllers();
    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    if (_isEditMode) {
      _populateFormFields(widget.gatePass!);
    } else {
      _enquiryDate = DateTime.now();
    }

    super.initState();
  }

  @override
  void dispose() {
    _visitorNameC.dispose();
    _addressC.dispose();
    _mobileNumberC.dispose();
    _numberOFParticipantsC.dispose();
    _remarkC.dispose();
    _selectedEmployeeNotifier.dispose();
    _selectedGatePassPurpose.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _visitorNameC = TextEditingController();
    _addressC = TextEditingController();
    _mobileNumberC = TextEditingController();
    _numberOFParticipantsC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _populateFormFields(GatePassModel getPass) async {
    _visitorNameC.text = getPass.fullName;
    _addressC.text = getPass.address;
    _mobileNumberC.text = getPass.mobileNumber;
    _numberOFParticipantsC.text = getPass.noOfParticipants.toString();
    _remarkC.text = getPass.remark;
    _appointmentTimeNotifier.value =
        getPass.passDateTime.toIso8601String().split("T")[1].split(".")[0];
    selectedFileForUpload.fileNameList =
        getPass.photoUrl.isEmpty ? [] : getPass.photoUrl.split(',');
    _selectedGatePassPurpose.value =
        getPass.purpose.isEmpty
            ? null
            : gatePassPurpose.firstWhere(
              (item) => item["DisplayName"] == getPass.purpose,
            );
    _enquiryDate = getPass.passDateTime;
    final employee = await _fetchEmployeesById(employeedId: getPass.employeeId);

    _selectedEmployeeNotifier.value = employee["itemList"] ?? [];
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final time = _appointmentTimeNotifier.value!.split(':');

    final passDateTime = DateTime(
      _enquiryDate!.year,
      _enquiryDate!.month,
      _enquiryDate!.day,
      int.parse(time[0]),
      int.parse(time[1]) + 2,
    );
    if (!_isEditMode) {
      _gatePassCubit.addGatePass(
        context: context,
        file: selectedFileForUpload,
        fullName: _visitorNameC.text.trim(),
        mobileNumber: _mobileNumberC.text.trim(),
        address: _addressC.text.trim(),
        purpose: _selectedGatePassPurpose.value!["DisplayName"],
        remark: _remarkC.text.trim(),
        employeeId: _selectedEmployeeNotifier.value.first["zAttributesId"],
        passDateTime: passDateTime,
        noOfParticipants: int.parse(_numberOFParticipantsC.text.trim()),
      );
    } else {
      _gatePassCubit.updateGatePass(
        context: context,
        externalId: widget.gatePass!.externalId,
        uniquekey: widget.gatePass!.uniquekey,
        index: widget.index!,
        file: selectedFileForUpload,
        fullName: _visitorNameC.text.trim(),
        mobileNumber: _mobileNumberC.text.trim(),
        address: _addressC.text.trim(),
        purpose: _selectedGatePassPurpose.value!["DisplayName"],
        remark: _remarkC.text.trim(),
        employeeId: _selectedEmployeeNotifier.value.first["zAttributesId"],
        passDateTime: passDateTime,
        noOfParticipants: int.parse(_numberOFParticipantsC.text.trim()),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchEmployeesById({
    required int employeedId,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: 1,
      pageSize: 15,
      queryParams: {"EmployeeId": employeedId, "IsCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<UserModel>;

        return {
          "itemList":
              banks.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                  "Department": employee.department,
                  "Designation": employee.designation,
                  "PersonalMobileNumber": employee.personalMobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "IsCheckPermission": false}
              : {"IsCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final banks = response['data'] as List<UserModel>;

        return {
          "itemList":
              banks.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
                  "Department": employee.department,
                  "Designation": employee.designation,
                  "PersonalMobileNumber": employee.personalMobileNumber,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Gate Pass",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${_isEditMode ? 'Update' : 'Add'} Gate Pass",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      title: "Visitor Name",
                      hint: "Enter Visitor Name",
                      textController: _visitorNameC,
                      inputFormatterList: InputValidator.textOnly(100),
                      keyboardType: TextInputType.text,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Visitor Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Address",
                      hint: "Enter Address",
                      textController: _addressC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(250),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Address is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Mobile Number",
                      hint: "Enter Mobile Number",
                      textController: _mobileNumberC,
                      prefixType: CustomTextFieldPrefix.mobile,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mobile number is required";
                        } else if (!isValidMobileNumber(value)) {
                          return "Mobile number is invalid";
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedEmployeeNotifier,
                      builder: (context, value, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultipleSelectPopup(
                              title: "Appointment With",
                              hintText: "Select Appointment With",
                              initialValue: value,
                              dataList: const [],
                              isMultiSelect: false,
                              dataFetchCallBack: _fetchEmployees,
                              onSelected: (value) {
                                _selectedEmployeeNotifier.value = value;
                              },
                              onClear: () {
                                _selectedEmployeeNotifier.value = [];
                              },
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Appointment With is required.';
                                }
                                return null;
                              },
                            ),

                            if (value.isNotEmpty) ...[
                              infoCard([
                                {
                                  "title": "Department",
                                  "value":
                                      value.first["Department"]?.toString() ??
                                      "-",
                                },
                                {
                                  "title": "Designation",
                                  "value":
                                      value.first["Designation"]?.toString() ??
                                      "-",
                                },
                                {
                                  "title": "Personal Mobile Number",
                                  "value":
                                      value.first["PersonalMobileNumber"]
                                          ?.toString() ??
                                      "-",
                                },
                              ]),
                            ],
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedGatePassPurpose,
                      builder: (context, value, child) {
                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Purpose",
                          hintText: "Select Purpose",
                          initialValue: value,
                          dataList: gatePassPurpose,
                          onSelected: (value) {
                            _selectedGatePassPurpose.value = value;
                          },
                          onValueClear: () {
                            _selectedGatePassPurpose.value = null;
                          },
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Purpose is required.';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Number Of Participants",
                      hint: "Enter Number Of Participants",
                      textController: _numberOFParticipantsC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(3),
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Number Of Participants is required";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Appointment Date",
                      startDate: DateTime.now().subtract(
                        const Duration(days: 2),
                      ),
                      isRequired: true,
                      initialDate: _enquiryDate,
                      setValue: (v) => _enquiryDate = v,
                      validator:
                          (value) =>
                              value == null
                                  ? 'Appointment Date is required'
                                  : null,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _appointmentTimeNotifier,
                      builder: (context, appointmentTime, child) {
                        return CustomTimePicker(
                          title: 'Appointment Time',
                          isRequired: true,
                          initialTime: parseTimeOfDayFromHHmm(appointmentTime),
                          setValue:
                              (val) =>
                                  _appointmentTimeNotifier
                                      .value = formatTimeOfDayHHmm(val),
                          validator: (value) {
                            if (value == null) {
                              return "Appointment Time is required.";
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    CustomMultiFilePicker(
                      title: "Photo",
                      filePickType: FilePickType.image,
                      initialFileList: selectedFileForUpload.fileNameList,
                      initialFileBytes: selectedFileForUpload.fileBytesList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedFileForUpload.fileNameList = fileNameList;
                        selectedFileForUpload.fileBytesList = bytesList;
                      },
                      maxFiles: 1,
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deleted,
                      ) {
                        selectedFileForUpload.fileBytesList = fileBytesList;
                        selectedFileForUpload.fileNameList = fileNameList;
                        selectedFileForUpload.deletedFileList = deleted;
                      },
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
