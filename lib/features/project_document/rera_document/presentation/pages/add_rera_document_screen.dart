import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
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
  bool get _isEditMode => widget.isEdit;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _documentCubit = context.read<RERADocumentCubit>();
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
    if (!widget.isEdit) {
      _documentCubit.addRERASubDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.documentModel!.uniquekey,
        projectRERADocumentId: widget.documentModel!.projectRERADocumentId,
        projectRERADocumentCategoryId:
            widget.documentModel!.projectRERADocumentCategoryId,
        documents: selectedDocumentFile,
        projectRERADocumentStatus: _selectedStatus[0]['DisplayName'],
        projectRERADocumentExpiryDate: expiryDate,
        projectRERADocumentRemark: _remarkC.text.trim(),
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
        projectRERADocumentStatus: _selectedStatus[0]['DisplayName'],
        projectRERADocumentExpiryDate: expiryDate,
        projectRERADocumentRemark: _remarkC.text.trim(),
      );
    }
  }

  void _prefillForm(RERADocumentModel document) {
    // Find the matching status in the list
    final matchedStatus = statusList.firstWhere(
      (status) => status['DisplayName'] == document.projectRERADocumentStatus,
      orElse: () => statusList.first, // fallback to "Select Status"
    );

    _selectedStatus = [matchedStatus];

    // Prefill expiry date
    expiryDate = document.projectRERADocumentExpiryDate;

    // Prefill remark text
    _remarkC.text =
        document.projectRERADocumentRemark.isNotEmpty
            ? document.projectRERADocumentRemark
            : "";

    // Prefill files if any
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
            text: _isEditMode ? "Update Document" : "Add Document",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
