import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/text_field/rich_text_input.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTermsAndConditionsScreen extends StatefulWidget {
  final TermsAndConditionsModel? termsAndConditions;
  final int index;
  final int? tabIndex; // 0 for Material Requisition, 1 for Booking
  const AddTermsAndConditionsScreen({
    super.key,
    this.termsAndConditions,
    this.index = 0,
    this.tabIndex,
  });

  @override
  State<AddTermsAndConditionsScreen> createState() =>
      _AddTermsAndConditionsScreenState();
}

class _AddTermsAndConditionsScreenState
    extends State<AddTermsAndConditionsScreen> {
  // CUBIT
  late TermsAndConditionsCubit _termsAndConditionsCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _nameC;
  late TextEditingController _descriptionC;

  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Current tab index (0 = Material Requisition, 1 = Booking)
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    // Use service locator to get the singleton cubit instance
    _termsAndConditionsCubit = serviceLocator<TermsAndConditionsCubit>();
    _initializeTextEditingControllers();
    _currentTabIndex = widget.tabIndex ?? 0;
    if (widget.termsAndConditions != null) {
      _prefillForm(widget.termsAndConditions!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameC.dispose();
    _descriptionC.dispose();
  }

  // <---- INITIALIZE TEXT EDITING CONTROLLERS ---->
  void _initializeTextEditingControllers() {
    _nameC = TextEditingController();
    _descriptionC = TextEditingController();
  }

  // <---- PREFILL FORM ---->
  void _prefillForm(TermsAndConditionsModel termsAndConditions) {
    _nameC.text = termsAndConditions.title;
    _descriptionC.text = termsAndConditions.description;
  }

  // <---- ADD/UPDATE TERMS AND CONDITIONS ---->
  Future<void> _addUpdateTermsAndConditions() async {
    if (_formKey.currentState!.validate()) {
      if (_descriptionC.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Description is required'),
            backgroundColor: AppColor.error,
          ),
        );
        return;
      }

      if (widget.termsAndConditions != null) {
        // UPDATE
        if (_currentTabIndex == 0) {
          // Material Requisition
          await _termsAndConditionsCubit.updateMaterialRequisition(
            context: context,
            termsAndConditionId:
                widget.termsAndConditions!.termsAndConditionsMasterId,
            uniqueKey: widget.termsAndConditions!.uniquekey,
            name: _nameC.text.trim(),
            module: "MATERIAL REQUISITION",
            description: _descriptionC.text.trim(),
            index: widget.index,
          );
        } else {
          // Booking
          await _termsAndConditionsCubit.updateBooking(
            context: context,
            termsAndConditionId:
                widget.termsAndConditions!.termsAndConditionsMasterId,
            uniqueKey: widget.termsAndConditions!.uniquekey,
            name: _nameC.text.trim(),
            module: "BOOKING",
            description: _descriptionC.text.trim(),
            index: widget.index,
          );
        }
      } else {
        // ADD
        if (_currentTabIndex == 0) {
          // Material Requisition
          await _termsAndConditionsCubit.addMaterialRequisition(
            context: context,
            name: _nameC.text.trim(),
            module: "MATERIAL REQUISITION",
            description: _descriptionC.text.trim(),
          );
        } else {
          // Booking
          await _termsAndConditionsCubit.addBooking(
            context: context,
            name: _nameC.text.trim(),
            module: "BOOKING",
            description: _descriptionC.text.trim(),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String moduleName =
        _currentTabIndex == 0 ? "Material Requisition" : "Booking";
    final bool isEdit = widget.termsAndConditions != null;

    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Terms & Conditions",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? "Edit Terms & Conditions - $moduleName"
                    : "Add Terms & Conditions - $moduleName",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Name',
                      isRequired: true,
                      textController: _nameC,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    verticalSpacing(),
                    RichTextInput(
                      initialText: _descriptionC.text,
                      label: "Description",
                      isRequired: true,
                      hintText: 'Enter your text here...',
                      onFormattedTextChanged: (value) {
                        _descriptionC.text = value;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColor.white,
          height: 80,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              isEdit ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: isEdit ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: _addUpdateTermsAndConditions,
          ),
        ),
      ),
    );
  }
}

