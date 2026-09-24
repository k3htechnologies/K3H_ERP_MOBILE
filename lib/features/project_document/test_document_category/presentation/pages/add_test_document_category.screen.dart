import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/presentation/cubit/test_document_category_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTestDocumentCategoryScreen extends StatefulWidget {
  final TestDocumentCategoryModel? testDocumentCategoryModel;
  final int index;
  const AddTestDocumentCategoryScreen({
    super.key,
    this.testDocumentCategoryModel,
    this.index = 0,
  });

  @override
  State<AddTestDocumentCategoryScreen> createState() =>
      _AddTestDocumentCategoryScreenState();
}

class _AddTestDocumentCategoryScreenState
    extends State<AddTestDocumentCategoryScreen> {
  //CUBIT
  late TestDocumentCategoryCubit _testDocumentCategoryCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //TEXT EDITING CONTROLLER
  late TextEditingController _reraDocumentCategoryC, _orderByC;

  //EDIT MODE
  bool get _isEditMode => widget.testDocumentCategoryModel != null;

  //PROJECT ID
  late int projectId;

  @override
  void initState() {
    super.initState();
    _testDocumentCategoryCubit = context.read<TestDocumentCategoryCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    projectId = getProject().projectId;
    initializeTextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.testDocumentCategoryModel!);
    }
  }

  // INITIALIZE CONTROLLERS
  void initializeTextEditingController() {
    _reraDocumentCategoryC = TextEditingController();
    _orderByC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(TestDocumentCategoryModel reraDocumentCategory) {
    _reraDocumentCategoryC.text = reraDocumentCategory.testDocumentCategoryName;
    _orderByC.text = reraDocumentCategory.orderBy.toString();
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode) {
      _testDocumentCategoryCubit.updateTestDocumentCategory(
        index: widget.index,
        context: context,
        uniqueKey: widget.testDocumentCategoryModel!.uniquekey,
        testDocumentCategoryId:
            widget.testDocumentCategoryModel!.testDocumentCategoryId,
        projectId: projectId,
        testDocumentCategory: _reraDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    } else {
      _testDocumentCategoryCubit.addTestADocumentCategory(
        index: widget.index,
        context: context,
        projectId: projectId,
        testDocumentCategory: _reraDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Test Document Category",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Test Document Category"
                  : "Add Test Document Category",
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
                      title: "Test Document Category",
                      hint: "Enter Test Document Category",
                      isRequired: true,
                      textController: _reraDocumentCategoryC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Test Document Category is required.";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Sequence",
                      hint: "Enter Sequence",
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digit(5),
                      textController: _orderByC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Sequence is required.";
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
              size: 18,
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
