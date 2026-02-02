import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
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
  late LitigationCubit _litigationCubit;

  bool get _isEditMode => widget.litigationModel != null;

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
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

  DateTime? dateOfFilling;

  late Map<String, dynamic> selectedCaseType;

  final List<Map<String, dynamic>> caseTypeList = [
    {"zAttributesId": -1, "DisplayName": "Select Case Type"},
    {"zAttributesId": 1, "DisplayName": "Criminal"},
    {"zAttributesId": 2, "DisplayName": "Civil"},
  ];

  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();
    _initControllers();
    selectedCaseType = caseTypeList.first;

    if (_isEditMode) {
      _populateForm(widget.litigationModel!);
    }
  }

  void _initControllers() {
    _caseTitleC = TextEditingController();
    _caseNumberC = TextEditingController();
    _caseBriefC = TextEditingController();
    _courtNameC = TextEditingController();
    _courtLocationC = TextEditingController();
    _plantiffC = TextEditingController();
    _defendantC = TextEditingController();
    _assignedRepC = TextEditingController();
    _opposingRepC = TextEditingController();
    _remarkC = TextEditingController();
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
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (dateOfFilling == null) {
      showErrorMessage(context, "Error", "Please select Date of Filing");
      return;
    }

    final payload = {
      if (_isEditMode) "Uniquekey": widget.litigationModel!.uniquekey,
      "LitigationId": _isEditMode ? widget.litigationModel!.litigationId : 0,
      "projectId": getProject().projectId,
      "title": _caseTitleC.text.trim(),
      "caseNumber": _caseNumberC.text.trim(),
      "caseType": selectedCaseType['DisplayName'],
      "dateOfFilling": dateOfFilling!.toIso8601String(),
      "courtName": _courtNameC.text.trim(),
      "courtLocation": _courtLocationC.text.trim(),
      "plantiff": _plantiffC.text.trim(),
      "defendant": _defendantC.text.trim(),
      "assignedRepresentative": _assignedRepC.text.trim(),
      "opposingRepresentative": _opposingRepC.text.trim(),
      "remark": _remarkC.text.trim(),
      "caseBrief": _caseBriefC.text.trim(),
    };

    if (_isEditMode) {
      _litigationCubit.updateLitigation(
        context: context,
        index: widget.index,
        litigationId: widget.litigationModel!.litigationId,
        body: payload,
      );
    } else {
      _litigationCubit.addLitigation(context: context, body: payload);
    }
  }

  @override
  void dispose() {
    _caseTitleC.dispose();
    _caseNumberC.dispose();
    _caseBriefC.dispose();
    _courtNameC.dispose();
    _courtLocationC.dispose();
    _plantiffC.dispose();
    _defendantC.dispose();
    _assignedRepC.dispose();
    _opposingRepC.dispose();
    _remarkC.dispose();
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
              _caseBriefCard(),
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
          ),
          CustomTextField(
            title: "Case Number",
            hint: "Enter Case Number",
            textController: _caseNumberC,
          ),
          CustomDropDownWidget(
            title: "Case Type",
            initialValue: selectedCaseType,
            dataList: caseTypeList,
            onSelected: (v) => selectedCaseType = v,
          ),
          CustomDatePicker(
            title: "Date Of Filing",
            initialDate: dateOfFilling,
            setValue: (v) => dateOfFilling = v,
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
          Text("Case Brief", style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(),
          CustomTextField(
            title: "Add Case Brief",
            hint: "Enter Case Brief",
            textController: _caseBriefC,
            maxLines: 5,
            minLines: 5,
          ),
        ],
      ),
    );
  }
}
