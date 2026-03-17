import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
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

  //TEXT EDITING CONTROLLER
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

  // INITIALIZE CONTROLLERS
  void initializeTextEditingController() {
    _reraDocumentCategoryC = TextEditingController();
    _orderByC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(RERADocumentCategoryModel reraDocumentCategory) {
    _reraDocumentCategoryC.text =
        reraDocumentCategory.projectRERADocumentCategoryName;
    _orderByC.text = reraDocumentCategory.orderBy.toString();
  }

  // GET PROJECT ID
  void getProjectId() {
    projectId = getProject().projectId;
  }

  // SUBMIT FORM
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
                ? "Update Project RERA Document Category"
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
            leading: Icon(_isEditMode?Icons.edit:Icons.add,size: 18,color: AppColor.white,),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
