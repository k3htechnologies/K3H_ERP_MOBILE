import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddUpdateDocumentScreen extends StatefulWidget {
  final BuildingDocumentModel? subDocumentModel;
  final BuildingDocumentModel documentModel;

  const AddUpdateDocumentScreen({
    super.key,
    required this.subDocumentModel,
    required this.documentModel,
  });

  @override
  State<AddUpdateDocumentScreen> createState() =>
      _AddUpdateDocumentScreenState();
}

class _AddUpdateDocumentScreenState extends State<AddUpdateDocumentScreen> {
  //CUBIT
  late BuildingCubit _buildingCubit;

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
  bool get _isEditMode => widget.subDocumentModel != null;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _buildingCubit = context.read<BuildingCubit>();
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.subDocumentModel!);
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
    if (!_isEditMode) {
      _buildingCubit.updateBuildingChildDocument(
        context: context,
        buildingId: widget.documentModel.buildingId,
        documentName: widget.documentModel.documentName,
        projectId: widget.documentModel.projectId,
        files: selectedDocumentFile,
        buildingDocumentId: widget.documentModel.buildingDocumentId,
        documentRemark: _remarkC.text.trim(),
        uniqueKey: widget.documentModel.uniquekey,
      );
    } else {
      _buildingCubit.updateBuildingChildDocument(
        context: context,
        buildingId: widget.subDocumentModel!.buildingId,
        documentName: _documentNameC.text,
        projectId: widget.subDocumentModel!.projectId,
        files: selectedDocumentFile,
        buildingDocumentId: widget.subDocumentModel!.buildingDocumentId,
        documentRemark: _remarkC.text.trim(),
        uniqueKey: widget.subDocumentModel!.uniquekey,
      );
    }
  }

  // PREFILL FORM
  void _prefillForm(BuildingDocumentModel document) {
    _documentNameC.text = document.documentName;

    // Prefill remark text
    _remarkC.text =
        document.documentRemark.isNotEmpty ? document.documentRemark : "";

    // Prefill files if any
    selectedDocumentFile.fileNameList =
        document.documentURL.isEmpty ? [] : document.documentURL.split(",");
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
                      return "File is required";
                    }
                    return null;
                  },
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
