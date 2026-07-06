import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/custom_verification_dialog.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddLitigationScreen extends StatefulWidget {
  final LitigationModel? litigationModel;
  final int index;

  const AddLitigationScreen({super.key, this.litigationModel, this.index = 0});

  @override
  State<AddLitigationScreen> createState() => _AddLitigationScreenState();
}

class _AddLitigationScreenState extends State<AddLitigationScreen> {
  // CUBIT
  late LitigationCubit _litigationCubit;

  // EDIT MODE
  bool get _isEditMode => widget.litigationModel != null;

  // FORM VALIDATION
  final _formKey = GlobalKey<FormState>();

  // CONTROLLERS
  late final List<TextEditingController> _controllers;
  late TextEditingController _caseTitleC,
      _caseNumberC,
      _caseBriefC,
      _courtNameC,
      _courtLocationC,
      _plantiffC,
      _defendantC,
      _assignedRepC,
      _opposingRepC,
      _remarkC;

  // DATE VARIABLE
  DateTime? dateOfFilling;

  // DROPDOWN VARIABLE
  Map<String, dynamic>? selectedCaseType;
  Map<String, dynamic>? selectedCourtType;
  Map<String, dynamic>? _selectedProject;
  List<Map<String, dynamic>> projects = [];
  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();
    _initControllers(); // First check if project list exists in storage
    final projectListString = LocalStorageManager().getString(
      StorageKey.projectList,
    );

    if (projectListString != null && projectListString.isNotEmpty) {
      // Load from storage
      final List<dynamic> projectJsonList = jsonDecode(projectListString);
      final List<ProjectModel> projectsfromStorage =
          projectJsonList
              .map(
                (json) => ProjectModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      for (var p in projectsfromStorage) {
        projects.add({
          "zAttributesId": p.projectId,
          "DisplayName": p.projectName,
        });
      }
      if (_isEditMode) {
        _populateFormFields(widget.litigationModel!);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _controllers = [
      _caseTitleC = TextEditingController(),
      _caseNumberC = TextEditingController(),
      _caseBriefC = TextEditingController(),
      _courtNameC = TextEditingController(),
      _courtLocationC = TextEditingController(),
      _plantiffC = TextEditingController(),
      _defendantC = TextEditingController(),
      _assignedRepC = TextEditingController(),
      _opposingRepC = TextEditingController(),
      _remarkC = TextEditingController(),
    ];
  }

  // POPULATE FORM
  void _populateFormFields(LitigationModel model) {
    _selectedProject =
        projects.where((m) => m['zAttributesId'] == model.projectId).first;
    _caseTitleC.text = model.title;
    _caseNumberC.text = model.caseNumber;
    _caseBriefC.text = model.caseBrief;
    _courtNameC.text = model.courtName;
    _courtLocationC.text = model.courtLocation;
    _plantiffC.text = model.plantiff;
    _defendantC.text = model.defendant;
    _assignedRepC.text = model.assignedRepresentative;
    _opposingRepC.text = model.opposingRepresentative;
    _remarkC.text = model.remark;

    dateOfFilling = model.dateOfFilling;

    selectedCaseType = caseTypeList.firstWhere(
      (e) => e['DisplayName'] == model.caseType,
      orElse: () => caseTypeList.first,
    );

    selectedCourtType = courtTypeList.firstWhere(
      (e) => e['DisplayName'] == model.courtType,
      orElse: () => courtTypeList.first,
    );
  }

  // SUBMIT FORM
  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      _submitForm();
    } else {
      showCompleteVerificationDialog(
        context,
        subTitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Verify Details To Continue',
                style: AppTextStyle.ts14R(color: AppColor.grey),
              ),
              TextSpan(
                text: ' • ${_selectedProject?['DisplayName']}',
                style: AppTextStyle.ts14M(color: AppColor.primary),
              ),
            ],
          ),
        ),
        verificationSteps: {
          "Title": _caseTitleC.text.trim().isNotEmpty,
          "Date Of Filling": dateOfFilling != null,
          "Case Type": selectedCaseType != null,
          "Case Number": _caseNumberC.text.trim().isNotEmpty,
        },
        onVerifyOTP: () {
          _submitForm();
        },
      );
    }
  }

  void _submitForm() {
    final payload = {
      if (_isEditMode) "Uniquekey": widget.litigationModel!.uniquekey,
      "ProjectId": _selectedProject!['zAttributesId'],
      "LitigationId": _isEditMode ? widget.litigationModel!.litigationId : 0,
      "Title": _caseTitleC.text.trim(),
      "CaseNumber": _caseNumberC.text.trim(),
      "CaseType": selectedCaseType?['DisplayName'],
      "CourtType": selectedCourtType?['DisplayName'],
      "DateOfFilling": dateOfFilling!.toIso8601String(),
      "CourtName": _courtNameC.text.trim(),
      "CourtLocation": _courtLocationC.text.trim(),
      "Plantiff": _plantiffC.text.trim(),
      "Defendant": _defendantC.text.trim(),
      "AssignedRepresentative": _assignedRepC.text.trim(),
      "OpposingRepresentative": _opposingRepC.text.trim(),
      "Remark": _remarkC.text.trim(),
      "CaseBrief": _caseBriefC.text.trim(),
    };

    if (_isEditMode) {
      _litigationCubit.updateLitigation(
        context: context,
        index: widget.index,
        body: payload,
      );
    } else {
      _litigationCubit.addLitigation(context: context, body: payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: _isEditMode ? "Update Litigation" : "Add Litigation",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10,
            children: [_caseDetailsCard(), _courtDetailsCard()],
          ),
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
            onPressed: () {
              _submit(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _caseDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Case Details", style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          CustomDropDownWidget(
            title: "Project",
            hintText: "Select Project",
            isDisabled: _isEditMode,
            initialValue: _selectedProject,
            dataList: projects,
            isRequired: true,
            validator:
                (v) => (v == null || v.isEmpty) ? "Project is required" : null,
            onSelected: (v) {
              _selectedProject = v;
            },
            onValueClear: () {
              _selectedProject = null;
            },
          ),

          CustomTextField(
            title: "Title",
            hint: "Enter Title",
            textController: _caseTitleC,
            inputFormatterList: [LengthLimitingTextInputFormatter(100)],
            isRequired: true,
            validator: (v) => v!.isEmpty ? "Title is required" : null,
          ),

          CustomDatePicker(
            title: "Date Of Filling",
            initialDate: dateOfFilling,
            isRequired: true,
            readOnly:
                (_isEditMode && widget.litigationModel!.hearingDate != null),
            setValue: (v) => dateOfFilling = v,
            validator: (value) {
              if (value == null) {
                return 'Date Of Filing is required';
              }
              return null;
            },
          ),

          CustomDropDownWidget(
            title: "Case Type",
            hintText: "Select Case Type",
            initialValue: selectedCaseType,
            isRequired: true,
            dataList: caseTypeList,
            onSelected: (v) => selectedCaseType = v,
            validator: (value) {
              if (value == null || value["zAttributesId"] == -1) {
                return "Case Type is required";
              }
              return null;
            },
            onValueClear: () {
              selectedCaseType = null;
            },
          ),

          CustomTextField(
            title: "Case / Petition / Dispute Number",
            hint: "Enter Case / Petition / Dispute Number",
            inputFormatterList: [LengthLimitingTextInputFormatter(250)],
            isRequired: true,
            textController: _caseNumberC,
            validator:
                (v) =>
                    v!.isEmpty
                        ? "Case / Petition / Dispute Number is required"
                        : null,
          ),
        ],
      ),
    );
  }

  Widget _courtDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Court Details",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(),

          CustomTextField(
            title: "Court Name",
            isRequired: true,
            hint: "Enter Court Name",
            textController: _courtNameC,
            validator: (v) => v!.isEmpty ? "Court Name is required" : null,
          ),

          CustomTextField(
            title: "Court Location",
            isRequired: true,
            hint: "Enter Court Location",
            textController: _courtLocationC,
            validator: (v) => v!.isEmpty ? "Court Location is required" : null,
          ),

          CustomDropDownWidget(
            title: "Court Type",
            hintText: "Select Court Type",
            initialValue: selectedCourtType,
            dataList: courtTypeList,
            isRequired: true,
            onSelected: (v) => selectedCourtType = v,
            validator: (value) {
              if (value == null || value["zAttributesId"] == -1) {
                return "Court Type is required";
              }
              return null;
            },
            onValueClear: () {
              selectedCourtType = null;
            },
          ),

          CustomTextField(
            title: "Plaintiff / Complaint / Petitioner",
            isRequired: true,
            hint: "Enter Plaintiff / Complaint / Petitioner",
            textController: _plantiffC,
            validator:
                (v) =>
                    v!.isEmpty
                        ? "Plaintiff / Complaint / Petitioner is required"
                        : null,
          ),

          CustomTextField(
            title: "Defendant / Opposite Party / Respondents",
            isRequired: true,
            hint: "Enter Defendant / Opposite Party / Respondents Name",
            textController: _defendantC,
            validator:
                (v) =>
                    v!.isEmpty
                        ? "Defendant / Opposite Party / Respondents is required"
                        : null,
          ),

          CustomTextField(
            isRequired: true,
            title: "Assigned Representative",
            hint: "Enter Assigned Representative",
            textController: _assignedRepC,
            validator:
                (v) =>
                    v!.isEmpty ? "Assigned Representative is required" : null,
          ),

          CustomTextField(
            title: "Opposing Representative",
            hint: "Enter Opposing Representative",
            textController: _opposingRepC,
          ),

          CustomTextField(
            title: "Case Brief / Petition / Suit",
            hint: "Enter Case Brief / Petition / Suit",
            isRequired: true,
            textController: _caseBriefC,
            maxLines: 3,
            minLines: 3,
            validator:
                (v) =>
                    v!.isEmpty
                        ? "Case Brief / Petition / Suit is required"
                        : null,
          ),

          CustomTextField(
            title: "Case Remarks / Comments",
            isRequired: true,
            hint: "Enter Case Remark",
            textController: _remarkC,
            minLines: 3,
            maxLines: 3,
            validator:
                (v) =>
                    v!.isEmpty ? "Case Remarks / Comments is required" : null,
          ),
        ],
      ),
    );
  }
}
