import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area_comparative.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/presentation/cubit/construction_area_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddConstructionAreaComparativeScreen extends StatefulWidget {
  final ConstructionAreaComparativeModel? constructionAreaComparativeModel;
  final int index;
  final bool isEdit;
  const AddConstructionAreaComparativeScreen({
    super.key,
    this.constructionAreaComparativeModel,
    required this.index,
    required this.isEdit,
  });

  @override
  State<AddConstructionAreaComparativeScreen> createState() =>
      _AddConstructionAreaComparativeScreenState();
}

class _AddConstructionAreaComparativeScreenState
    extends State<AddConstructionAreaComparativeScreen> {
  //CUBIT
  late ConstructionAreaCubit _constructionAreaCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _areaByPLLineC, _remarkC;

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
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel = AuthorizationModel();
    _constructionAreaCubit = context.read<ConstructionAreaCubit>();

    _initializeTextEditingController();
    _areaByPLLineC = TextEditingController(
      text:
          widget.constructionAreaComparativeModel!.areaByPlLineSqMt.toString(),
    );
    if (_isEditMode) _prefillForm(widget.constructionAreaComparativeModel!);
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _areaByPLLineC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // PREFILL FORM
  void _prefillForm(ConstructionAreaComparativeModel document) {
    selectedDocumentFile.fileNameList =
        document.annexureUrl.isEmpty ? [] : document.annexureUrl.split(",");

    _remarkC.text = document.remark.isNotEmpty ? document.remark : "";
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode && widget.constructionAreaComparativeModel != null) {
      _constructionAreaCubit.updateConstructionAreaComparativer(
        context: context,
        index: widget.index,
        constructionAreaComparativeId:
            widget
                .constructionAreaComparativeModel!
                .constructionAreaComparativeId,
        uniqueKey: widget.constructionAreaComparativeModel!.uniqueKey,
        projectId: widget.constructionAreaComparativeModel!.projectId,
        areaByPLLineSqMt:
            widget.constructionAreaComparativeModel!.areaByPlLineSqMt,
        remark: _remarkC.text,
        annexure: selectedDocumentFile,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _areaByPLLineC.dispose();
    _remarkC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Construction Area Comparative",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Drawing Document",
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
                    CustomTextField(
                      title: "Area By PL Line (SqMt)",
                      hint: "Area By PL Line",
                      readOnly: true,
                      textController: _areaByPLLineC,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      minLines: 3,
                      maxLines: 10,
                      textController: _remarkC,
                    ),
                    CustomMultiFilePicker(
                      maxFiles: 5,
                      title: "Files",
                      filePickType: FilePickType.both,
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
                  ],
                ),
              ),
            ),
          ],
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
