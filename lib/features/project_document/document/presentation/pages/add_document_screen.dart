import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddDocumentScreen extends StatefulWidget {
  final DocumentModel? documentModel;
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
  late TextEditingController _documentC;
  //EDIT MODE
  bool get _isEditMode => widget.documentModel != null;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.addDocument] ??
        AuthorizationModel();
    _documentCubit = context.read<DocumentCubit>();
    _initializeTextEditingController();
    if (_isEditMode) {
      _populateFormFields(widget.documentModel!);
    }
  }

  void _initializeTextEditingController() {
    _documentC = TextEditingController();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isEditMode) {
      _documentCubit.updateDocumentInCategory(
        context: context,
        index: widget.index,

        uniqueKey: widget.documentModel!.uniquekey,
        projectDocumentId: widget.documentModel!.projectDocumentId,
        projectDocumentCategoryId:
            widget.documentModel!.projectDocumentCategoryId,
        projectId: widget.documentModel!.projectId,
        projectDocumentName: _documentC.text.trim(),
      );
    } else {
      _documentCubit.addDocumentToCategory(
        context: context,
        projectDocumentId: widget.documentModel!.projectDocumentId,
        projectDocumentCategoryId:
            widget.documentModel!.projectDocumentCategoryId,
        projectId: widget.documentModel!.projectId,
        projectDocumentName: _documentC.text.trim(),
      );
    }
  }

  void _populateFormFields(DocumentModel documentModel) {
    _documentC.text = documentModel.projectDocumentName;
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
                CustomTextField(
                  title: "Document",
                  hint: "Enter Document",
                  textController: _documentC,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Document is required";
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
            text: _isEditMode ? "Update Document" : "Add Document",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
