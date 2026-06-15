import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddInwardOutwardScreen extends StatefulWidget {
  const AddInwardOutwardScreen({super.key});

  @override
  State<AddInwardOutwardScreen> createState() => _AddInwardOutwardScreenState();
}

class _AddInwardOutwardScreenState extends State<AddInwardOutwardScreen> {
  // REPOSITORY
  final EmployeeMasterRepository _employeeMasterRepository =
      serviceLocator<EmployeeMasterRepository>();

  final ValueNotifier<bool> isOther = ValueNotifier(true);
  final ValueNotifier<Map<String, dynamic>?> _selectedDocumentType =
      ValueNotifier(null);
  DateTime? _date, _invoiceDate, _handoverDate;
  late TextEditingController _documentTitleC,
      _invoiceNoC,
      _amountC,
      _chequeNoC,
      _senderMobileNoC,
      _senderNameC,
      _senderEmailC,
      _senderAddress,
      _receiverMobileNoC,
      _receiverNameC,
      _receiverEmailC,
      _receiverAddress,
      _documentDescC,
      _receivedByC,
      _handoverToC,
      _remarkC;
  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  MultiFilePickerModel selectedReceiverDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  MultiFilePickerModel selectedAcknowledgement = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  late final ValueNotifier<List<Map<String, dynamic>>>
  _selectedEmployeeNotifier;

  @override
  void initState() {
    _initializeTextEditingControllers();

    _selectedEmployeeNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    super.initState();
  }

  void _initializeTextEditingControllers() {
    _documentTitleC = TextEditingController();
    _invoiceNoC = TextEditingController();
    _amountC = TextEditingController();
    _chequeNoC = TextEditingController();

    _senderMobileNoC = TextEditingController();
    _senderNameC = TextEditingController();
    _senderEmailC = TextEditingController();
    _senderAddress = TextEditingController();

    _receiverMobileNoC = TextEditingController();
    _receiverNameC = TextEditingController();
    _receiverEmailC = TextEditingController();
    _receiverAddress = TextEditingController();

    _documentDescC = TextEditingController();
    _receivedByC = TextEditingController();
    _handoverToC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FETCH EMPLOYEE
  Future<Map<String, dynamic>> _fetchEmployees(
    int pageNumber, {
    String? value,
  }) async {
    final result = await _employeeMasterRepository.getEmployeeMasterList(
      pageNumber: pageNumber,
      pageSize: 15,
      queryParams:
          value != null && value.isNotEmpty
              ? {"EmployeeName": value, "isCheckPermission": false}
              : {"isCheckPermission": false},
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final employees = response['data'] as List<UserModel>;

        return {
          "itemList":
              employees.map((employee) {
                return {
                  "zAttributesId": employee.employeeId,
                  "DisplayName": employee.fullName,
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
        screenTitle: "Inward Outward",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          spacing: 12.h,
          children: [
            _card("Details", [
              Text(
                'Delivery Type',
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isOther,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        // ignore: deprecated_member_use
                        groupValue: value,
                        // ignore: deprecated_member_use
                        onChanged: (val) {
                          if (val == null) return;
                          isOther.value = val;
                        },
                      ),
                      Text("Others", style: AppTextStyle.ts14M()),

                      const SizedBox(width: 16),

                      Radio<bool>(
                        value: false,
                        // ignore: deprecated_member_use
                        groupValue: value,
                        // ignore: deprecated_member_use
                        onChanged: (val) {
                          if (val == null) return;
                          isOther.value = val;
                        },
                      ),
                      Text("Cheque", style: AppTextStyle.ts14M()),
                    ],
                  );
                },
              ),
              verticalSpacing(),
              ValueListenableBuilder(
                valueListenable: _selectedDocumentType,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    title: "Document Type",
                    hintText: "Select Document Type",
                    initialValue: value,
                    isRequired: true,
                    dataList: inwardOutwardDocumentType,
                    onSelected: (value) {
                      _selectedDocumentType.value = value;
                    },
                    onValueClear: () {
                      _selectedDocumentType.value = null;
                    },
                    validator: (value) {
                      if (value == null || value.toString().trim().isEmpty) {
                        return "Status is required";
                      }
                      return null;
                    },
                  );
                },
              ),
              CustomTextField(
                textController: _documentTitleC,
                title: "Document Title",
                isRequired: true,
                hint: "Enter Document Title",
              ),
              CustomDatePicker(
                title: "Date",
                initialDate: _date,
                readOnly: true,
                setValue: (value) {},
                isRequired: true,
              ),
              CustomTextField(
                textController: _invoiceNoC,
                title: "Invoice Number",
                isRequired: true,
                hint: "Enter Invoice Number",
              ),
              CustomDatePicker(
                title: "Date",
                initialDate: _invoiceDate,
                setValue: (value) {},
                isRequired: true,
              ),
              CustomTextField(
                textController: _amountC,
                title: "Amount (₹)",
                isRequired: true,
                hint: "Enter Invoice Number",
              ),
              CustomTextField(
                textController: _chequeNoC,
                title: "Cheque No",
                isRequired: true,
                hint: "Enter Cheque No",
              ),
            ]),
            _card("Sender Details", [
              CustomTextField(
                textController: _senderMobileNoC,
                title: "Mobile No.",
                isRequired: true,
                hint: "Enter Sender Mobile No.",
              ),
              CustomTextField(
                textController: _senderNameC,
                title: "Name",
                isRequired: true,
                hint: "Enter Sender Name",
              ),
              CustomTextField(
                textController: _senderEmailC,
                title: "Email-ID",
                isRequired: true,
                hint: "Enter Sender Email-ID",
              ),
              CustomTextField(
                textController: _senderAddress,
                title: "Address",
                isRequired: true,
                hint: "Enter Sender Address",
              ),
            ]),
            _card("Receiver Details", [
              CustomTextField(
                textController: _receiverMobileNoC,
                title: "Mobile No.",
                isRequired: true,
                hint: "Enter Receiver Mobile No.",
              ),
              CustomTextField(
                textController: _receiverNameC,
                title: "Name",
                isRequired: true,
                hint: "Enter Receiver Name",
              ),
              CustomTextField(
                textController: _receiverEmailC,
                title: "Email-ID",
                isRequired: true,
                hint: "Enter Receiver Email-ID",
              ),
              CustomTextField(
                textController: _receiverAddress,
                title: "Address",
                isRequired: true,
                hint: "Enter Receiver Address",
              ),
            ]),
            _card("Document Details", [
              CustomMultiFilePicker(
                title: "Document",
                isRequired: true,
                filePickType: FilePickType.both,
                initialFileList: selectedDocumentFile.fileNameList,

                onFilePickedCallback: (bytesList, fileNameList) {
                  selectedDocumentFile.fileNameList = fileNameList;
                  selectedDocumentFile.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  selectedDocumentFile.fileNameList = fileNameList;
                  selectedDocumentFile.fileBytesList = fileBytesList;
                  selectedDocumentFile.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if (fileList == null || fileList.isEmpty) {
                    return "Document is required";
                  }

                  return null;
                },
              ),
              CustomTextField(
                textController: _documentDescC,
                title: "Document Description",
                isRequired: true,
                hint: "Enter Document Description",
              ),
            ]),
            _card("Assign To", [
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _selectedEmployeeNotifier,
                builder: (context, selectedEmployee, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomMultipleSelectPopup(
                        title: 'Assign Employee',
                        isRequired: true,
                        hintText: "Select Assign Employee",
                        isMultiSelect: true,
                        initialValue: selectedEmployee,
                        dataList: const [],
                        onSelected: (value) {
                          _selectedEmployeeNotifier.value = value;
                        },
                        dataFetchCallBack: _fetchEmployees,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Employee Reference Name is required";
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  // HELPER
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
