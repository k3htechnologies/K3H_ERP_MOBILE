import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
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
  late Map<String, dynamic> selectedCaseType;
  late Map<String, dynamic> selectedCourtType;

  final List<Map<String, dynamic>> caseTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Case Type"},
    {"zAttributesId": 1, "DisplayName": "Criminal"},
    {"zAttributesId": 2, "DisplayName": "Civil"},
  ];

  final List<Map<String, dynamic>> courtTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Court Type"},
    {"zAttributesId": 1, "DisplayName": "Civil Court"},
    {"zAttributesId": 2, "DisplayName": "District Court"},
    {"zAttributesId": 3, "DisplayName": "High Court"},
    {"zAttributesId": 4, "DisplayName": "Session Court"},
    {"zAttributesId": 4, "DisplayName": "Supreme Court"},
  ];

  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();
    _initControllers();

    selectedCaseType = caseTypeList.first;
    selectedCourtType = courtTypeList.first;

    if (_isEditMode) {
      _populateForm(widget.litigationModel!);
    }
  }

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

  void _populateForm(LitigationModel model) {
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      if (_isEditMode) "Uniquekey": widget.litigationModel!.uniquekey,
      "LitigationId": _isEditMode ? widget.litigationModel!.litigationId : 0,
      "ProjectId": getProject().projectId,
      "Title": _caseTitleC.text.trim(),
      "CaseNumber": _caseNumberC.text.trim(),
      "CaseType": selectedCaseType['DisplayName'],
      "CourtType": selectedCourtType['DisplayName'],
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
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
            children: [
              _caseDetailsCard(),
              verticalSpacing(height: 16),
              _partyDetailsCard(),
              verticalSpacing(height: 16),
              _caseBriefCard(),
              verticalSpacing(height: 24),
              CustomButton(
                text: _isEditMode ? "Update" : "Submit",
                onPressed: _submitForm,
              ),
            ],
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

          CustomTextField(
            title: "Case Title",
            hint: "Enter Case Title",
            textController: _caseTitleC,
            inputFormatterList: [LengthLimitingTextInputFormatter(250)],
            isRequired: true,
            validator: (v) => v!.isEmpty ? "Case Title is required" : null,
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

          CustomDropDownWidget(
            title: "Case Type",
            initialValue: selectedCaseType,
            isRequired: true,
            dataList: caseTypeList,
            onSelected: (v) => selectedCaseType = v,
            validator: (value) {
              if (value == null || value["zAttributesId"] == -1) {
                return "Please select Case Type";
              }
              return null;
            },
          ),

          CustomDropDownWidget(
            title: "Court Type",
            initialValue: selectedCourtType,
            dataList: courtTypeList,
            isRequired: true,
            onSelected: (v) => selectedCourtType = v,
            validator: (value) {
              if (value == null || value["zAttributesId"] == -1) {
                return "Please select Court Type";
              }
              return null;
            },
          ),

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

          CustomDatePicker(
            title: "Date Of Filing",
            initialDate: dateOfFilling,
            isRequired: true,
            setValue: (v) => dateOfFilling = v,
            validator: (value) {
              if (value == null) {
                return 'Date Of Filing is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _partyDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Party Details",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(),

          CustomTextField(
            title: "Plainiff / Petitioner",
            isRequired: true,
            hint: "Enter Plainiff / Petitioner Name",
            textController: _plantiffC,
            validator:
                (v) => v!.isEmpty ? "Plainiff / Petitioner is required" : null,
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
            isRequired: true,
            title: "Opposing Representative",
            hint: "Enter Opposing Representative",
            textController: _opposingRepC,
            validator:
                (v) =>
                    v!.isEmpty ? "Opposing Representative is required" : null,
          ),

          CustomTextField(
            title: "Case Remark",
            isRequired: true,
            hint: "Enter Case Remark",
            textController: _remarkC,
            maxLines: 3,
            validator: (v) => v!.isEmpty ? "Case Remark is required" : null,
          ),
        ],
      ),
    );
  }

  Widget _caseBriefCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Case Description",
            style: AppTextStyle.ts14M(color: AppColor.grey),
          ),
          verticalSpacing(),

          CustomTextField(
            title: "Case Brief / Petition / Suit",
            hint: "Enter Case Brief / Petition / Suit",
            isRequired: true,
            textController: _caseBriefC,
            maxLines: 5,
            minLines: 5,
            validator: (v) => v!.isEmpty ? "Case Brief is required" : null,
          ),
        ],
      ),
    );
  }
}
