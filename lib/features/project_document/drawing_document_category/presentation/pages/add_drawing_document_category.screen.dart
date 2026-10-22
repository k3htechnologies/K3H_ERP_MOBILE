import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/presentation/cubit/drawing_document_category_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDrawingDocumentCategoryScreen extends StatefulWidget {
  final DrawingDocumentCategoryModel? drawingDocumentCategoryModel;
  final int index;
  const AddDrawingDocumentCategoryScreen({
    super.key,
    this.drawingDocumentCategoryModel,
    this.index = 0,
  });

  @override
  State<AddDrawingDocumentCategoryScreen> createState() =>
      _AddDrawingDocumentCategoryScreenState();
}

class _AddDrawingDocumentCategoryScreenState
    extends State<AddDrawingDocumentCategoryScreen> {
  //CUBIT
  late DrawingDocumentCategoryCubit _drawingDocumentCategoryCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  //TEXT EDITING CONTROLLER
  late TextEditingController _drawingDocumentCategoryC, _orderByC;

  //EDIT MODE
  bool get _isEditMode => widget.drawingDocumentCategoryModel != null;

  //PROJECT ID
  late int projectId;

  @override
  void initState() {
    super.initState();
    _drawingDocumentCategoryCubit =
        context.read<DrawingDocumentCategoryCubit>();
    _routeAuthorizationModel = AuthorizationModel();
    projectId = getProject().projectId;
    initializeTextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.drawingDocumentCategoryModel!);
    }
  }

  // INITIALIZE CONTROLLERS
  void initializeTextEditingController() {
    _drawingDocumentCategoryC = TextEditingController();
    _orderByC = TextEditingController();
  }

  // POPULATE FORM FIELDS
  void _populateFormFields(
    DrawingDocumentCategoryModel drawingDocumentCategoryModel,
  ) {
    _drawingDocumentCategoryC.text =
        drawingDocumentCategoryModel.drawingDocumentCategoryName;
    _orderByC.text = drawingDocumentCategoryModel.orderBy.toString();
  }

  // SUBMIT FORM
  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode) {
      _drawingDocumentCategoryCubit.updateDrawingDocumentCategory(
        index: widget.index,
        context: context,
        uniqueKey: widget.drawingDocumentCategoryModel!.uniquekey,
        drawingDocumentCategoryId:
            widget.drawingDocumentCategoryModel!.drawingDocumentCategoryId,
        projectId: projectId,
        drawingDocumentCategory: _drawingDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    } else {
      _drawingDocumentCategoryCubit.addDrawingADocumentCategory(
        index: widget.index,
        context: context,
        projectId: projectId,
        drawingDocumentCategory: _drawingDocumentCategoryC.text.trim(),
        orderBy: int.parse(_orderByC.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Drawing Document Category",
        authorization: _routeAuthorizationModel,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Drawing Document Category"
                  : "Add Drawing Document Category",
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
                      title: "Drawing Document Category",
                      hint: "Enter Drawing Document Category",
                      isRequired: true,
                      textController: _drawingDocumentCategoryC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Drawing Document Category is required.";
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
                        final sequence = int.tryParse(value.trim());
                        if (sequence == null) {
                          return "Sequence is required.";
                        }
                        if (sequence <= 0) {
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
