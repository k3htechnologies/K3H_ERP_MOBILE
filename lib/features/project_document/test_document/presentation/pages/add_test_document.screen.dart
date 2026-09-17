import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/test_document/data/model/test_document.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document/presentation/cubit/test_document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddTestDocumentScreen extends StatefulWidget {
  final TestDocumentModel? testDocumentModel;
  final int index;
  final bool isEdit;
  const AddTestDocumentScreen({
    super.key,
    this.testDocumentModel,
    required this.index,
    required this.isEdit,
  });

  @override
  State<AddTestDocumentScreen> createState() => _AddTestDocumentScreenState();
}

class _AddTestDocumentScreenState extends State<AddTestDocumentScreen> {
  //CUBIT
  late TestDocumentCubit _testDocumentCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentNameC, _remarkC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // FILE VARIABLES
  MultiFilePickerModel selectedDocumentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  //EDIT MODE
  bool get _isEditMode => widget.isEdit;

  DateTime? expiryDate;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _testDocumentCubit = context.read<TestDocumentCubit>();
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.testDocumentModel!);
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _documentNameC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // PREFILL FORM
  void _prefillForm(TestDocumentModel document) {
    _documentNameC.text = document.testDocumentName;

    // Prefill expiry date
    expiryDate = document.testDocumentExpiryDate;

    // Prefill remark text
    _remarkC.text =
        document.testDocumentRemark.isNotEmpty
            ? document.testDocumentRemark
            : "";

    // Prefill files if any
    selectedDocumentFile.fileNameList =
        document.testDocumentUrl.isEmpty
            ? []
            : document.testDocumentUrl.split(",");
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // if (!widget.isEdit) {
    _testDocumentCubit.addSubDocument(
      context: context,
      index: widget.index,
      uniqueKey: widget.testDocumentModel!.uniquekey,
      projectDocumentId: widget.testDocumentModel!.testDocumentId,
      projectDocumentCategoryId:
          widget.testDocumentModel!.testDocumentCategoryId,
      documents: selectedDocumentFile,
      projectDocumentExpiryDate: expiryDate,
      projectDocumentRemark: _remarkC.text.trim(),
      projectDocumentName: widget.testDocumentModel!.testDocumentName,
    );
    // } else {
    //   _documentCubit.updateSubDocument(
    //     context: context,
    //     index: widget.index,
    //     uniqueKey: widget.documentModel!.uniquekey,
    //     projectDocumentId: widget.documentModel!.projectDocumentId,
    //     projectDocumentCategoryId:
    //         widget.documentModel!.projectDocumentCategoryId,
    //     documents: selectedDocumentFile,
    //     projectDocumentStatus: _selectedStatus.value?['DisplayName'],
    //     projectDocumentExpiryDate: expiryDate,
    //     projectDocumentRemark: _remarkC.text.trim(),
    //   );
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _documentNameC.dispose();
    _remarkC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Test Document" : "Add Test Document",
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                CustomMultiFilePicker(
                  maxFiles: 5,
                  title: "Files",
                  isRequired: true,
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
                    if ((value == null || value.isEmpty)) {
                      return "File is required.";
                    }
                    return null;
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
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }
}
