import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/data/model/approval_category.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_category/presentation/cubit/approval_category_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddApprovalCategoryScreen extends StatefulWidget {
  final ApprovalDocumentCategoryModel? approvalCategoryModel;

  final int index;
  const AddApprovalCategoryScreen({
    super.key,
    required this.approvalCategoryModel,

    this.index = 0,
  });

  @override
  State<AddApprovalCategoryScreen> createState() =>
      _AddApprovalCategoryScreenState();
}

class _AddApprovalCategoryScreenState extends State<AddApprovalCategoryScreen> {
  //CUBIT
  late ApprovalCategoryCubit _documentCategoryCubit;
  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //TEXT EDITING CONTROLLER
  late TextEditingController _documentCategoryC, _orderByC;

  //EDIT MODE
  bool get _isEditMode => widget.approvalCategoryModel != null;

  //PROJECT ID
  late int projectId;

  @override
  void initState() {
    super.initState();
    _documentCategoryCubit = context.read<ApprovalCategoryCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    getProjectId();
    initializeTextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.approvalCategoryModel!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _documentCategoryC.dispose();
    _orderByC.dispose();
  }

  // INITIALIZE CONTROLLERS
  void initializeTextEditingController() {
    _documentCategoryC = TextEditingController();
    _orderByC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(ApprovalDocumentCategoryModel documentCategory) {
    _documentCategoryC.text = documentCategory.approvalDocumentCategoryName;
    _orderByC.text = documentCategory.orderBy.toString();
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
      _documentCategoryCubit.updateApprovalDocumentCategory(
        index: widget.index,
        context: context,
        uniqueKey: widget.approvalCategoryModel!.uniquekey,
        projectApprovalDocumentCategoryId:
            widget.approvalCategoryModel!.approvalDocumentCategoryId,
        projectId: projectId,
        projectApprovalDocumentCategory: _documentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    } else {
      _documentCategoryCubit.addApprovalDocumentCategory(
        index: widget.index,
        context: context,
        projectId: projectId,
        projectApprovalDocumentCategory: _documentCategoryC.text.trim(),
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
                ? "Update Approval Document Category"
                : "Add Approval Document Category",
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
                  title: "Approval Document Category",
                  hint: "Enter approval document category",
                  isRequired: true,
                  textController: _documentCategoryC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Approval Document Category is required";
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
            leading: Icon(_isEditMode?Icons.edit:Icons.add, size: 16, color: AppColor.white),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
