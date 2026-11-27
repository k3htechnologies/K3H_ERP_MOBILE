import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/model/tax_tracker.model.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddRequestTaxTrackerScreen extends StatefulWidget {
  final TaxTrackerModel? taxTrackerModel;
  const AddRequestTaxTrackerScreen({super.key, this.taxTrackerModel});

  @override
  State<AddRequestTaxTrackerScreen> createState() =>
      _AddRequestTaxTrackerScreenState();
}

class _AddRequestTaxTrackerScreenState
    extends State<AddRequestTaxTrackerScreen> {
  // CUBIT
  late TaxTrackerCubit _taxTrackerCubit;
  // EDIT MODE
  bool get _isEditMode => widget.taxTrackerModel != null;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // DATE PICKERS
  DateTime? date, appealDate, appealDueDate;

  final MultiFilePickerModel files = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedRequestType =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedOrderStatus =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedAuthorityType =
      ValueNotifier(null);
  final ValueNotifier<int> _resetCount = ValueNotifier(0);

  late TextEditingController _descriptionC, _officerNameC, _divisionalAddressC;

  int _requestTypeKey = 0;

  @override
  void initState() {
    _taxTrackerCubit = context.read<TaxTrackerCubit>();
    initialiseControllers();
    super.initState();
  }

  @override
  void dispose() {
    _selectedRequestType.dispose();
    _resetCount.dispose();
    _descriptionC.dispose();
    _officerNameC.dispose();
    _divisionalAddressC.dispose();
    _selectedOrderStatus.dispose();
    _selectedAuthorityType.dispose();
    super.dispose();
  }

  void initialiseControllers() {
    _descriptionC = TextEditingController();
    _officerNameC = TextEditingController();
    _divisionalAddressC = TextEditingController();
  }

  void _resetRequestFields() {
    date = null;
    appealDate = null;
    appealDueDate = null;
    files.fileBytesList.clear();
    files.fileNameList.clear();
    files.deletedFileList = "";
    _resetCount.value++;
    _descriptionC.clear();
    _officerNameC.clear();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    _taxTrackerCubit.addTaxTrackerRequest(
      context: context,
      taxTrackerId: widget.taxTrackerModel!.taxTrackerId,
      authorityType: _selectedAuthorityType.value?["DisplayName"] ?? "",
      requestType: _selectedRequestType.value!["DisplayName"],
      noticeDescription: _descriptionC.text.trim(),
      officerName: _officerNameC.text.trim(),
      officerAddress: _divisionalAddressC.text.trim(),
      amountUnderDispute: 0.0,
      noticeDocument: files,
      amountUnderDisputeDate: date,
      dateOfAppeal: appealDate,
      orderStatus: _selectedOrderStatus.value?["DisplayName"] ?? "",
      noticeStatus: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Tax Tracker',
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Requests" : "Add Requests",
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
                    infoCard(title: "Notice Details", [
                      {
                        "title": "Notice Title",
                        "value": widget.taxTrackerModel?.noticeType,
                      },
                      {"spacer": true},
                      {
                        "title": "Company Name",
                        "value": widget.taxTrackerModel?.companyName,
                      },
                      {
                        "title": "Financial Year",
                        "value": widget.taxTrackerModel?.financialYear,
                      },
                      {
                        "title": "Notice Status",
                        "value": widget.taxTrackerModel?.noticeStatus,
                        "widget": taxTrackerNoticeStatusWidget(
                          widget.taxTrackerModel!.noticeStatus,
                        ),
                      },
                      {
                        "title": "Authority Type",
                        "value": widget.taxTrackerModel?.authority,
                      },
                      {
                        "title": "Government Compliance",
                        "value": widget.taxTrackerModel?.governmentCompliance,
                      },
                      {
                        "title": "Notice U/S",
                        "value": widget.taxTrackerModel?.noticeSection,
                      },
                      {
                        "title": "Notice Date",
                        "value": formatDateTimeAsDDMMMYYYY(
                          widget.taxTrackerModel!.noticeDate,
                        ),
                      },
                      {
                        "title": "Reply Due Date",
                        "value": formatDateTimeAsDDMMMYYYY(
                          widget.taxTrackerModel!.dueDate,
                        ),
                      },
                    ]),
                    verticalSpacing(),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedRequestType,
                      builder: (context, selectedRequest, child) {
                        return CustomDropDownWidget(
                          key: ValueKey(_requestTypeKey),
                          title: "Request Type",
                          hintText: "Select Request Type",
                          isRequired: true,
                          dataList: taxTrackerRequestType,
                          initialValue: selectedRequest,
                          onSelected: (value) {
                            _selectedRequestType.value = value;
                            _requestTypeKey++;
                            _resetRequestFields();
                          },

                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return 'Request Type is required.';
                            }
                            return null;
                          },
                          onValueClear: () {
                            _selectedRequestType.value = null;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedRequestType,
                      builder: (context, requestType, child) {
                        final selectedType =
                            requestType?['DisplayName']?.toString();

                        Widget fields;

                        switch (selectedType) {
                          case "Reply":
                            fields = _buildReplyFields();
                            break;

                          case "Order":
                            fields = _buildOrderFields();
                            break;

                          case "Appeal":
                            fields = _buildAppealFields();
                            break;

                          case "Notice":
                            fields = _buildNoticeFields();
                            break;

                          case "Close-Notice":
                            fields = _buildCloseNoticeFields();
                            break;

                          default:
                            fields = const SizedBox.shrink();
                        }

                        return KeyedSubtree(
                          key: ValueKey(selectedType),
                          child: fields,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Description",
                      hint: "Enter Description",
                      textController: _descriptionC,
                      isRequired: true,
                      minLines: 3,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
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

  Widget _buildReplyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomDatePicker(
                title: "Date",
                hint: "Enter Date",
                initialDate: date,
                setValue: (value) => date = value,
                isRequired: true,
                validator: (value) {
                  if (value == null) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: CustomMultiFilePicker(
                title: "Documents",
                isRequired: true,
                maxFiles: 20,
                filePickType: FilePickType.kycDocument,
                initialFileList: files.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  files.fileNameList = fileNameList;
                  files.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  files.fileNameList = fileNameList;
                  files.fileBytesList = fileBytesList;
                  files.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if (fileList == null || fileList.isEmpty) {
                    return "Document is required.";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _selectedOrderStatus,
          builder: (context, selectedOrderStatus, child) {
            return CustomDropDownWidget(
              title: "Order Status",
              hintText: "Select Order Status",
              isRequired: true,
              dataList: taxTrackerOrderStatus,
              initialValue: selectedOrderStatus,
              onSelected: (value) {
                _selectedOrderStatus.value = value;
              },
              onValueClear: () {
                _selectedOrderStatus.value = null;
              },
              validator: (value) {
                if (value == null || value['zAttributesId'] == -1) {
                  return 'Order Status is required.';
                }
                return null;
              },
            );
          },
        ),
        CustomMultiFilePicker(
          title: "Documents",
          isRequired: true,
          maxFiles: 20,
          filePickType: FilePickType.kycDocument,
          initialFileList: files.fileNameList,
          onFilePickedCallback: (bytesList, fileNameList) {
            files.fileNameList = fileNameList;
            files.fileBytesList = bytesList;
          },

          onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
            files.fileNameList = fileNameList;
            files.fileBytesList = fileBytesList;
            files.deletedFileList = deletedFile;
          },

          validator: (fileList) {
            if (fileList == null || fileList.isEmpty) {
              return "Document is required.";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAppealFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomDatePicker(
                title: "Date of Appeal",
                hint: "Enter Date of Appeal",
                initialDate: appealDate,
                setValue: (value) => appealDate = value,
                isRequired: true,
                validator: (value) {
                  if (value == null) {
                    return 'Date of Appeal is required';
                  }
                  return null;
                },
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: CustomDatePicker(
                title: "Appeal Due Date",
                hint: "Enter Appeal Due Date",
                initialDate: appealDueDate,
                setValue: (value) => appealDueDate = value,
                isRequired: true,
                validator: (value) {
                  if (value == null) {
                    return 'Appeal Due Date is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        CustomMultiFilePicker(
          title: "Documents",
          isRequired: true,
          maxFiles: 20,
          filePickType: FilePickType.kycDocument,
          initialFileList: files.fileNameList,
          onFilePickedCallback: (bytesList, fileNameList) {
            files.fileNameList = fileNameList;
            files.fileBytesList = bytesList;
          },

          onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
            files.fileNameList = fileNameList;
            files.fileBytesList = fileBytesList;
            files.deletedFileList = deletedFile;
          },

          validator: (fileList) {
            if (fileList == null || fileList.isEmpty) {
              return "Document is required.";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNoticeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: _selectedAuthorityType,
              builder: (context, selectedAuthorityType, child) {
                return Expanded(
                  child: CustomDropDownWidget(
                    title: "Authority Type",
                    hintText: "Select Authority Type",
                    isRequired: true,
                    dataList: taxTrackerAuthorityType,
                    initialValue: selectedAuthorityType,
                    onSelected: (value) {
                      _selectedAuthorityType.value = value;
                    },
                    onValueClear: () {
                      _selectedAuthorityType.value = null;
                    },
                    validator: (value) {
                      if (value == null || value['zAttributesId'] == -1) {
                        return 'Authority Type is required.';
                      }
                      return null;
                    },
                  ),
                );
              },
            ),
            horizontalSpacing(),
            Expanded(
              child: CustomTextField(
                title: "Officer Name",
                hint: "Enter Officer Name",
                textController: _officerNameC,
                isRequired: true,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Officer Name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomMultiFilePicker(
                title: "Documents",
                isRequired: true,
                maxFiles: 20,
                filePickType: FilePickType.kycDocument,
                initialFileList: files.fileNameList,
                onFilePickedCallback: (bytesList, fileNameList) {
                  files.fileNameList = fileNameList;
                  files.fileBytesList = bytesList;
                },

                onFileDeleteCallback: (
                  fileBytesList,
                  fileNameList,
                  deletedFile,
                ) {
                  files.fileNameList = fileNameList;
                  files.fileBytesList = fileBytesList;
                  files.deletedFileList = deletedFile;
                },

                validator: (fileList) {
                  if (fileList == null || fileList.isEmpty) {
                    return "Document is required.";
                  }
                  return null;
                },
              ),
            ),
            horizontalSpacing(),
            Expanded(
              child: CustomDatePicker(
                title: "Date",
                hint: "Enter Date",
                initialDate: date,
                setValue: (value) => date = value,
                isRequired: true,
                validator: (value) {
                  if (value == null) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        CustomTextField(
          title: "Divisional Address",
          hint: "Divisional Address",
          textController: _divisionalAddressC,
          isRequired: true,
          minLines: 3,
          maxLines: 10,
          validator: (value) {
            if (value == null) {
              return 'Divisional Address is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCloseNoticeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomMultiFilePicker(
          title: "Documents",
          isRequired: true,
          maxFiles: 20,
          filePickType: FilePickType.kycDocument,
          initialFileList: files.fileNameList,
          onFilePickedCallback: (bytesList, fileNameList) {
            files.fileNameList = fileNameList;
            files.fileBytesList = bytesList;
          },

          onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
            files.fileNameList = fileNameList;
            files.fileBytesList = fileBytesList;
            files.deletedFileList = deletedFile;
          },

          validator: (fileList) {
            if (fileList == null || fileList.isEmpty) {
              return "Document is required.";
            }
            return null;
          },
        ),
      ],
    );
  }
}
