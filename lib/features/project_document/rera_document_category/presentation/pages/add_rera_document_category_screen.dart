import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_cubit.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddRERADocumentCategoryScreen extends StatefulWidget {
  final RERADocumentCategoryModel? reraDocumentCategoryModel;

  final int index;
  const AddRERADocumentCategoryScreen({
    super.key,
    required this.reraDocumentCategoryModel,

    this.index = 0,
  });

  @override
  State<AddRERADocumentCategoryScreen> createState() =>
      _AddRERADocumentCategoryScreenState();
}

class _AddRERADocumentCategoryScreenState
    extends State<AddRERADocumentCategoryScreen> {
  //CUBIT
  late RERADocumentCategoryCubit _reraDocumentCategoryCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //TEXTEDITING CONTROLLER
  late TextEditingController _reraDocumentCategoryC, _orderByC;

  //EDIT MODE
  bool get _isEditMode => widget.reraDocumentCategoryModel != null;

  //PROJECT ID
  late int projectId;

  @override
  void initState() {
    super.initState();
    _reraDocumentCategoryCubit = context.read<RERADocumentCategoryCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    getProjectId();
    initializeTextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.reraDocumentCategoryModel!);
    }
  }

  void _populateFormFields(RERADocumentCategoryModel reraDocumentCategory) {
    _reraDocumentCategoryC.text =
        reraDocumentCategory.projectRERADocumentCategoryName;
    _orderByC.text = reraDocumentCategory.orderBy.toString();
  }

  void initializeTextEditingController() {
    _reraDocumentCategoryC = TextEditingController();
    _orderByC = TextEditingController();
  }

  void getProjectId() {
    projectId = getProject().projectId;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode) {
      _reraDocumentCategoryCubit.updateRERADocumentCategory(
        index: widget.index,
        context: context,
        uniqueKey: widget.reraDocumentCategoryModel!.uniquekey,
        projectDocumentCategoryId:
            widget.reraDocumentCategoryModel!.projectRERADocumentCategoryId,
        projectId: projectId,
        projectRERADocumentCategory: _reraDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    } else {
      _reraDocumentCategoryCubit.addRERADocumentCategory(
        index: widget.index,
        context: context,
        projectId: projectId,
        projectRERADocumentCategory: _reraDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle:
            _isEditMode
                ? "Add Project RERA Document Category"
                : "Add Project RERA Document Category",
        authorization: _routeAuthorizationModel,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CustomTextField(
                  title: "Project RERA Document Category",
                  hint: "Enter project RERA document category",
                  isRequired: true,
                  textController: _reraDocumentCategoryC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Project Document RERA Category is required";
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  title: "Sequence",
                  hint: "Enter Sequence",
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  textController: _orderByC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Sequence is required";
                    }
                    return null;
                  },
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
            text:
                _isEditMode
                    ? "Update RERA Document Category"
                    : "Add RERA Document Category",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
