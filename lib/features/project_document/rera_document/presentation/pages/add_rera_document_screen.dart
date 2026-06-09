import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddRERADocumentScreen extends StatefulWidget {
  final RERADocumentModel? documentModel;
  final int index;
  final bool isEdit;
  const AddRERADocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
    this.isEdit = false,
  });

  @override
  State<AddRERADocumentScreen> createState() => _AddRERADocumentScreenState();
}

class _AddRERADocumentScreenState extends State<AddRERADocumentScreen> {
  //CUBIT
  late RERADocumentCubit _documentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentNameC, _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

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
  MultiFilePickerModel selectedScreenShotFile = MultiFilePickerModel(
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
    _documentCubit = context.read<RERADocumentCubit>();
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
      _documentCubit.addRERASubDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        projectRERADocumentId: widget.documentModel!.projectRERADocumentId,
        projectRERADocumentCategoryId:
            widget.documentModel!.projectRERADocumentCategoryId,
        documents: selectedDocumentFile,
        projectRERADocumentStatus: _selectedStatus.value?['DisplayName'],
        screenshots: selectedScreenShotFile,
        projectRERADocumentRemark: _remarkC.text.trim(),
        projectRERADocumentName: widget.documentModel!.projectRERADocumentName,
      );
    } else {
      _documentCubit.updateRERASubDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        projectRERADocumentId: widget.documentModel!.projectRERADocumentId,
        projectRERADocumentCategoryId:
            widget.documentModel!.projectRERADocumentCategoryId,
        documents: selectedDocumentFile,
        projectRERADocumentStatus: _selectedStatus.value?['DisplayName'],
        screenshots: selectedScreenShotFile,
        projectRERADocumentRemark: _remarkC.text.trim(),
        projectRERADocumentName: widget.documentModel!.projectRERADocumentName,
      );
    }
  }

  // PREFILL FORM
  void _prefillForm(RERADocumentModel document) {
    final matchedStatus = statusList.firstWhere(
      (status) => status['DisplayName'] == document.projectRERADocumentStatus,
      orElse: () => statusList.first,
    );

    _selectedStatus.value = matchedStatus;

    if (document.reraPortalScreenShotURL != null) {
      selectedScreenShotFile.fileNameList =
          document.reraPortalScreenShotURL!.isEmpty
              ? []
              : document.reraPortalScreenShotURL!.split(",");
    }

    _remarkC.text =
        document.projectRERADocumentRemark.isNotEmpty
            ? document.projectRERADocumentRemark
            : "";
    _documentNameC.text = document.projectRERADocumentName;
    selectedDocumentFile.fileNameList =
        document.projectRERADocumentURL.isEmpty
            ? []
            : document.projectRERADocumentURL.split(",");
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
                if (_isEditMode)
                  CustomTextField(
                    title: "Document",
                    textController: _documentNameC,
                    isRequired: true,
                    readOnly: true,
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
                CustomMultiFilePicker(
                  maxFiles: 5,
                  title: "Screenshot",
                  initialFileList: selectedScreenShotFile.fileNameList,
                  onFilePickedCallback: (bytesList, fileNameList) {
                    selectedScreenShotFile.fileNameList = fileNameList;
                    selectedScreenShotFile.fileBytesList = bytesList;
                  },
                  onFileDeleteCallback: (
                    fileBytesList,
                    fileNameList,
                    deletedFile,
                  ) {
                    selectedScreenShotFile.fileNameList = fileNameList;
                    selectedScreenShotFile.fileBytesList = fileBytesList;
                    selectedScreenShotFile.deletedFileList = deletedFile;
                  },
                ),
                CustomTextField(
                  title: "Remark",
                  hint: "Enter Remark",
                  minLines: 3,
                  maxLines: 10,
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
