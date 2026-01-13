import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentModel documentModel;
  final int index;
  const AddDocumentScreen({
    super.key,
    required this.documentModel,
    this.index = 0,
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
  String? _selectedStatus;
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

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _documentCubit = context.read<DocumentCubit>();
    _initializeTextEditingController();
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

      uniqueKey: widget.documentModel.uniquekey,
      projectDocumentId: widget.documentModel.projectDocumentId,
      projectDocumentCategoryId: widget.documentModel.projectDocumentCategoryId,
      projectId: widget.documentModel.projectId,
      projectDocumentName: widget.documentModel.projectDocumentName,
      documents: selectedDocumentFile,
      isMaster: 0,
      projectDocumentStatus: _selectedStatus!,
      projectDocumentExpiryDate: expiryDate,
      projectDocumentRemark: _remarkC.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Add Document",
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
                  initialValue: statusList[0],
                  isRequired: true,
                  onSelected: (Map<String, dynamic> p1) {
                    _selectedStatus = p1['DisplayName'];
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
          child: CustomButton(text: "Add Document", onPressed: _submitForm),
        ),
      ),
    );
  }
}
