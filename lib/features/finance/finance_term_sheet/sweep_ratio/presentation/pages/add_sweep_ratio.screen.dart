import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/sweep_ratio/presentation/cubit/sweep_ratio_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddSweepRatioScreen extends StatefulWidget {
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetSweepRatioDetailsData? termSheetSweepRatioDetailsData;
  const AddSweepRatioScreen({
    super.key,
    this.termSheetDetailsView,
    this.termSheetSweepRatioDetailsData,
  });

  @override
  State<AddSweepRatioScreen> createState() => _AddSweepRatioScreenState();
}

class _AddSweepRatioScreenState extends State<AddSweepRatioScreen> {
  late SweepRatioCubit _sweepRatioCubit;
  late TextEditingController _ownSweepRatioC, _lenderSweepRatioC, _remarkC;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // EDIT MODE
  bool get _isEditMode => widget.termSheetSweepRatioDetailsData != null;

  // DATE PICKERS
  DateTime? date;

  @override
  void initState() {
    super.initState();
    _sweepRatioCubit = context.read<SweepRatioCubit>();
    initialiseControllers();
    if (_isEditMode) {
      prefillSweepRatio();
    }
  }

  void initialiseControllers() {
    _ownSweepRatioC = TextEditingController();
    _lenderSweepRatioC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void prefillSweepRatio() {
    final sweepRatio = widget.termSheetSweepRatioDetailsData;

    if (sweepRatio == null) return;

    _ownSweepRatioC.text = sweepRatio.ownSweepRatioInPercentage.toString();
    _lenderSweepRatioC.text =
        sweepRatio.lenderSweepRatioInPercentage.toString();
    date = sweepRatio.date!;
    _remarkC.text = sweepRatio.remark;
  }

  void _submit() {
    final termSheet = widget.termSheetDetailsView;

    if (termSheet == null) return;
    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      final sweepRatio = widget.termSheetSweepRatioDetailsData;

      if (sweepRatio == null) return;
      _sweepRatioCubit.updateSweepRatioDetails(
        context: context,
        lenderSweepRatioInPercentage: double.parse(
          _lenderSweepRatioC.text.trim(),
        ),
        ownSweepRatioInPercentage: double.parse(_ownSweepRatioC.text.trim()),
        date: date!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
        termSheetSweepRatioDetailsId: sweepRatio.termSheetSweepRatioDetailsId,
        uniquekey: sweepRatio.uniquekey,
      );
    } else {
      _sweepRatioCubit.addSweepRatioDetails(
        context: context,
        lenderSweepRatioInPercentage: double.parse(
          _lenderSweepRatioC.text.trim(),
        ),
        ownSweepRatioInPercentage: double.parse(_ownSweepRatioC.text.trim()),
        date: date!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    }
  }

  @override
  void dispose() {
    _ownSweepRatioC.dispose();
    _lenderSweepRatioC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  String? validateSweepRatio({
    required String? value,
    required bool isOwnRatio,
  }) {
    if (value == null || value.trim().isEmpty) {
      return isOwnRatio
          ? "Own Sweep Ratio is required"
          : "Lender Sweep Ratio is required";
    }

    final currentValue = double.tryParse(value.trim());

    if (currentValue == null || currentValue < 1 || currentValue > 100) {
      return isOwnRatio
          ? "Own Sweep Ratio must be between 1 and 100%."
          : "Lender Sweep Ratio must be between 1 and 100%.";
    }

    final ownRatio = double.tryParse(_ownSweepRatioC.text.trim()) ?? 0;

    final lenderRatio = double.tryParse(_lenderSweepRatioC.text.trim()) ?? 0;

    final total = ownRatio + lenderRatio;

    if ((total - 100).abs() > 0.001) {
      return "Own Sweep Ratio and Lender Sweep Ratio together must total 100%.";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Sweep Ratio",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Sweep Ratio Details"
                  : "Add Sweep Ratio Details",
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
                      title: "Own Sweep Ratio",
                      hint: "Enter Own Sweep Ratio",
                      textController: _ownSweepRatioC,
                      prefixType: CustomTextFieldPrefix.percentage,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(2),
                      validator: (value) {
                        return validateSweepRatio(
                          value: value,
                          isOwnRatio: true,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Lender Sweep Ratio",
                      hint: "Enter Lender Sweep Ratio",
                      textController: _lenderSweepRatioC,
                      prefixType: CustomTextFieldPrefix.percentage,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(2),
                      validator: (value) {
                        return validateSweepRatio(
                          value: value,
                          isOwnRatio: true,
                        );
                      },
                    ),
                    CustomDatePicker(
                      title: "Date",
                      hint: "Enter Date",
                      initialDate: date,
                      setValue: (value) => date = value,
                      isRequired: true,
                      validator: (value) {
                        if (value == null) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 10,
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
          height: 70.0,
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
