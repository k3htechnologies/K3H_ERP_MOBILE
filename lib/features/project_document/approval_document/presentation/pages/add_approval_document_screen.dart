import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddApprovalDocumentScreen extends StatefulWidget {
  final ApprovalDocumentModel? documentModel;
  final int index;
  final bool isEdit;
  const AddApprovalDocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
    this.isEdit = false,
  });

  @override
  State<AddApprovalDocumentScreen> createState() =>
      _AddApprovalDocumentScreenState();
}

class _AddApprovalDocumentScreenState extends State<AddApprovalDocumentScreen> {
  //CUBIT
  late ApprovalDocumentCubit _documentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  DateTime? expiryDate;
  final ValueNotifier<Map<String, dynamic>?> _selectedStatus = ValueNotifier(
    null,
  );
  // STATIC LISTS
  List<Map<String, dynamic>> statusList = [
    {'zAttributesId': 1, 'DisplayName': 'Applied'},
    {'zAttributesId': 2, 'DisplayName': 'Doc Missing'},
    {'zAttributesId': 3, 'DisplayName': 'In Process'},
    {'zAttributesId': 4, 'DisplayName': 'Issued'},
    {'zAttributesId': 5, 'DisplayName': 'Not Applied'},
    {'zAttributesId': 6, 'DisplayName': 'Not Applicable'},
    {'zAttributesId': 7, 'DisplayName': 'Paid'},
    {'zAttributesId': 8, 'DisplayName': 'Payment Due'},
    {'zAttributesId': 9, 'DisplayName': 'Rejected'},
  ];

  // FILE VARIABLES
  MultiFilePickerModel selectedApprovalDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  //EDIT MODE
  bool get _isEditMode => widget.isEdit;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _documentCubit = context.read<ApprovalDocumentCubit>();
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.documentModel!);
  }

  @override
  void dispose() {
    super.dispose();
    _remarkC.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeTextEditingController() {
    _remarkC = TextEditingController();
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!widget.isEdit) {
      _documentCubit.addSubApprovalDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        approvalDocumentId: widget.documentModel!.approvalDocumentId,
        approvalDocumentCategoryId:
            widget.documentModel!.approvalDocumentCategoryId,
        documents: selectedApprovalDocumentFile,
        approvalDocumentStatus: _selectedStatus.value?['DisplayName'],
        approvalDocumentExpiryDate: expiryDate,
        approvalDocumentRemark: _remarkC.text.trim(),
        approvalDocumentName: widget.documentModel!.approvalDocumentName,
      );
    } else {
      _documentCubit.updateSubApprovalDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        approvalDocumentId: widget.documentModel!.approvalDocumentId,
        approvalDocumentCategoryId:
            widget.documentModel!.approvalDocumentCategoryId,
        documents: selectedApprovalDocumentFile,
        approvalDocumentStatus: _selectedStatus.value?['DisplayName'],
        approvalDocumentExpiryDate: expiryDate,
        approvalDocumentRemark: _remarkC.text.trim(),
      );
    }
  }

  // POPULATE FORM FIELDS
  void _prefillForm(ApprovalDocumentModel document) {
    final matchedStatus = statusList.firstWhere(
      (status) => status['DisplayName'] == document.approvalDocumentStatus,
      orElse: () => statusList.first,
    );

    _selectedStatus.value = matchedStatus;

    expiryDate = document.approvalDocumentExpiryDate;

    _remarkC.text =
        document.approvalDocumentRemark.isNotEmpty
            ? document.approvalDocumentRemark
            : "";

    selectedApprovalDocumentFile.fileNameList =
        document.approvalDocumentURL.isEmpty
            ? []
            : document.approvalDocumentURL.split(",");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Document" : "Add Document",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          decoration: commonCardDecoration(),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Visibility(
                  visible: _isEditMode,
                  child: CustomTextField(
                    title: "Document Name",
                    hint: widget.documentModel!.approvalDocumentName,
                    isRequired: true,
                    readOnly: true,
                    textController: TextEditingController(),
                  ),
                ),
                CustomDropDownWidget(
                  title: "Status",
                  dataList: statusList,
                  hintText: "Select Status",
                  initialValue: _selectedStatus.value,
                  isRequired: true,
                  onSelected: (value) {
                    _selectedStatus.value = value;
                  },
                  validator: (value) {
                    if (value == null || value["zAttributesId"] == -1) {
                      return 'Status is required';
                    }
                    return null;
                  },
                  onValueClear: () {
                    _selectedStatus.value = null;
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedStatus,
                  builder: (context, value, child) {
                    return CustomMultiFilePicker(
                      maxFiles: 5,
                      title: "Files",
                      isRequired:
                          (_selectedStatus.value != null &&
                              _selectedStatus.value!['DisplayName']
                                  .toString()
                                  .toLowerCase()
                                  .contains('issued')),
                      initialFileList:
                          selectedApprovalDocumentFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedApprovalDocumentFile.fileNameList =
                            fileNameList;
                        selectedApprovalDocumentFile.fileBytesList = bytesList;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedApprovalDocumentFile.fileNameList =
                            fileNameList;
                        selectedApprovalDocumentFile.fileBytesList =
                            fileBytesList;
                        selectedApprovalDocumentFile.deletedFileList =
                            deletedFile;
                      },
                      validator: (value) {
                        if (_selectedStatus.value != null &&
                            _selectedStatus.value!['DisplayName']
                                .toString()
                                .toLowerCase()
                                .contains('issued') &&
                            (value == null || value.isEmpty)) {
                          return "File is required";
                        }
                        return null;
                      },
                    );
                  },
                ),
                CustomDatePicker(
                  title: "Expiry Date",
                  initialDate: expiryDate,
                  setValue: (value) => expiryDate = value,
                ),
                CustomTextField(
                  title: "Remark",
                  hint: "Enter Remark",
                  maxLines: 10,
                  minLines: 3,
                  textController: _remarkC,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 16,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update Document" : "Add Document",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
