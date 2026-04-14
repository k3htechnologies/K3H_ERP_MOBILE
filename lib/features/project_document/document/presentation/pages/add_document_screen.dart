import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentModel? documentModel;
  final int index;
  final bool isEdit;
  const AddDocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
    this.isEdit = false,
  });

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  //CUBIT
  late DocumentCubit _documentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentNameC, _remarkC;

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
  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
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
    _documentCubit = context.read<DocumentCubit>();
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.documentModel!);
  }

  @override
  void dispose() {
    super.dispose();
    _documentNameC.dispose();
    _remarkC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _documentNameC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // SUBMIT FORM
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!widget.isEdit) {
      _documentCubit.addSubDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        projectDocumentId: widget.documentModel!.projectDocumentId,
        projectDocumentCategoryId:
            widget.documentModel!.projectDocumentCategoryId,
        documents: selectedDocumentFile,
        projectDocumentStatus: _selectedStatus.value?['DisplayName'],
        projectDocumentExpiryDate: expiryDate,
        projectDocumentRemark: _remarkC.text.trim(),
        projectDocumentName: widget.documentModel!.projectDocumentName,
      );
    } else {
      _documentCubit.updateSubDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        projectDocumentId: widget.documentModel!.projectDocumentId,
        projectDocumentCategoryId:
            widget.documentModel!.projectDocumentCategoryId,
        documents: selectedDocumentFile,
        projectDocumentStatus: _selectedStatus.value?['DisplayName'],
        projectDocumentExpiryDate: expiryDate,
        projectDocumentRemark: _remarkC.text.trim(),
      );
    }
  }

  // PREFILL FORM
  void _prefillForm(DocumentModel document) {
    _documentNameC.text = document.projectDocumentName;
    // Find the matching status in the list
    final matchedStatus = statusList.firstWhere(
      (status) => status['DisplayName'] == document.projectDocumentStatus,
      orElse: () => statusList.first, // fallback to "Select Status"
    );

    _selectedStatus.value = matchedStatus;

    // Prefill expiry date
    expiryDate = document.projectDocumentExpiryDate;

    // Prefill remark text
    _remarkC.text =
        document.projectDocumentRemark.isNotEmpty
            ? document.projectDocumentRemark
            : "";

    // Prefill files if any
    selectedDocumentFile.fileNameList =
        document.projectDocumentURL.isEmpty
            ? []
            : document.projectDocumentURL.split(",");
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
                if (_isEditMode) ...[
                  CustomTextField(
                    title: "Document Name",
                    hint: "Enter Document Name",
                    isRequired: true,
                    readOnly: true,
                    textController: _documentNameC,
                  ),
                ],
                CustomDropDownWidget(
                  title: "Status",
                  dataList: statusList,
                  initialValue: _selectedStatus.value,
                  hintText: "Select Status",
                  isRequired: true,
                  onSelected: (value) {
                    _selectedStatus.value = value;
                  },
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return "Status is required";
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
                  minLines: 3,
                  maxLines: 3,
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
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
