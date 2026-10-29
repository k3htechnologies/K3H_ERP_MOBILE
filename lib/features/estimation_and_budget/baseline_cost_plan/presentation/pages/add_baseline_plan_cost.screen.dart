import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/model/baseline_cost_plan.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/presentation/cubit/baseline_cost_plan_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddBaselinePlanCostDocumentScreen extends StatefulWidget {
  final BaselineCostPlanDocumentModel? baselineCostPlanDocumentModel;
  final int index;
  final bool isEdit;
  const AddBaselinePlanCostDocumentScreen({
    super.key,
    this.baselineCostPlanDocumentModel,
    required this.index,
    required this.isEdit,
  });

  @override
  State<AddBaselinePlanCostDocumentScreen> createState() =>
      _AddBaselinePlanCostDocumentScreenState();
}

class _AddBaselinePlanCostDocumentScreenState
    extends State<AddBaselinePlanCostDocumentScreen> {
  //CUBIT
  late BaselineCostPlanCubit _baselineCostPlanCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentNameC, _baselineCostPlanC, _remarkC;

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
    _baselineCostPlanCubit = context.read<BaselineCostPlanCubit>();

    _initializeTextEditingController();
    if (_isEditMode) _prefillForm(widget.baselineCostPlanDocumentModel!);
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _documentNameC = TextEditingController();
    _baselineCostPlanC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // PREFILL FORM
  void _prefillForm(BaselineCostPlanDocumentModel document) {
    _documentNameC.text = document.baselineCostPlanDocumentName;

    final value = document.baselineCostPlanValue;
    _baselineCostPlanC.text = value == 0 ? '' : value.toString();
    print("the value is :${value}");
    selectedDocumentFile.fileNameList =
        document.baselineCostPlanDocumentUrl.isEmpty
            ? []
            : document.baselineCostPlanDocumentUrl.split(',');

    _remarkC.text = document.baselineCostPlanDocumentRemark;
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final amount = _baselineCostPlanC.text.trim();

    if (!widget.isEdit) {
      _baselineCostPlanCubit.addSubDrawingDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.baselineCostPlanDocumentModel!.uniquekey,
        baselineCostPlanDocumentId:
            widget.baselineCostPlanDocumentModel!.baselineCostPlanDocumentId,
        baselineCostPlanDocumentCategoryId:
            widget
                .baselineCostPlanDocumentModel!
                .baselineCostPlanDocumentCategoryId,
        baselineCostPlanDocumentName:
            widget.baselineCostPlanDocumentModel!.baselineCostPlanDocumentName,
        baselineCostPlanValue: amount.isEmpty ? null : amount,
        documents: selectedDocumentFile,
        baselineCostPlanDocumentRemark: _remarkC.text,
      );
    } else {
      _baselineCostPlanCubit.updateSubDrawingDocument(
        context: context,
        index: widget.index,
        uniqueKey: widget.baselineCostPlanDocumentModel!.uniquekey,
        baselineCostPlanDocumentId:
            widget.baselineCostPlanDocumentModel!.baselineCostPlanDocumentId,
        baselineCostPlanDocumentName:
            widget.baselineCostPlanDocumentModel!.baselineCostPlanDocumentName,
        baselineCostPlanDocumentCategoryId:
            widget
                .baselineCostPlanDocumentModel!
                .baselineCostPlanDocumentCategoryId,
        baselineCostPlanValue: amount.isEmpty ? null : amount,
        baselineCostPlanDocumentRemark: _remarkC.text,
        documents: selectedDocumentFile,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _documentNameC.dispose();
    _baselineCostPlanC.dispose();
    _remarkC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Baseline Plan Cost Document",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Baseline Plan Document"
                  : "Add Baseline Plan Document",
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
                    if (_isEditMode) ...[
                      CustomTextField(
                        title: "Document Name",
                        hint: "Enter Document Name",
                        isRequired: true,
                        readOnly: true,
                        textController: _documentNameC,
                      ),
                    ],
                    CustomTextField(
                      title: "Baseline Cost Plan Value (₹)",
                      hint: "Enter Baseline Cost Plan Value",
                      prefixType: CustomTextFieldPrefix.rupees,
                      textController: _baselineCostPlanC,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 16,
                      ),
                      onChangeFunction: (value) {
                        debugPrint('Typed value: "$value"');
                        debugPrint(
                          'Controller value: "${_baselineCostPlanC.text}"',
                        );
                      },
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
