import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
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
  //TEXTEDITNIG CONTROLLER
  late TextEditingController _remarkC;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();
  DateTime? expiryDate;
  List<Map<String, dynamic>> _selectedStatus = [
    {'zAttributesId': -1, 'DisplayName': 'Select Status'},
  ];
  // STATIC LISTS
  List<Map<String, dynamic>> statusList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Status'},
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
  bool get _isEditMode => widget.isEdit ?? widget.documentModel != null;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _documentCubit = context.read<DocumentCubit>();
    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.documentModel!);
  }

  void _initializeTextEditingController() {
    _remarkC = TextEditingController();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _documentCubit.updateDocumentInCategory(
      context: context,
      index: widget.index,

      uniqueKey: widget.documentModel!.uniquekey,
      projectDocumentId: widget.documentModel!.projectDocumentId,
      projectDocumentCategoryId:
          widget.documentModel!.projectDocumentCategoryId,
      projectDocumentName: widget.documentModel!.projectDocumentName,
      documents: selectedDocumentFile,
      isMaster: 0,
      projectDocumentStatus: _selectedStatus[0]['DisplayName'],
      projectDocumentExpiryDate: expiryDate,
      projectDocumentRemark: _remarkC.text.trim(),
      isNew: !_isEditMode,
    );
  }

  void _prefillForm(DocumentModel document) {
    // Find the matching status in the list
    final matchedStatus = statusList.firstWhere(
      (status) => status['DisplayName'] == document.projectDocumentStatus,
      orElse: () => statusList.first, // fallback to "Select Status"
    );

    _selectedStatus = [matchedStatus];

    // Prefill expiry date
    expiryDate = document.projectDocumentExpiryDate;

    // Prefill remark text
    _remarkC.text = document.projectDocumentRemark ?? "";

    // Prefill files if any
    if (document.projectDocumentURL != null) {
      selectedDocumentFile.fileNameList =
          document.projectDocumentURL.isEmpty
              ? []
              : document.projectDocumentURL.split(",");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Edit Document" : "Add Document",
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
                CustomDropDownWidget(
                  title: "Status",
                  dataList: statusList,
                  initialValue:
                      _isEditMode ? _selectedStatus[0] : statusList[0],
                  isRequired: true,
                  onSelected: (Map<String, dynamic> p1) {
                    _selectedStatus = [p1];
                  },
                ),
                CustomMultiFilePicker(
                  maxFiles: 3,
                  title: "Files",
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
                ),
                CustomDatePicker(
                  title: "Expiry Date",
                  initialDate: expiryDate,
                  setValue: (value) => expiryDate = value,
                ),
                CustomTextField(
                  title: "Remark",
                  hint: "Enter Remark",
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
            text: _isEditMode ? "Edit Document" : "Add Document",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
