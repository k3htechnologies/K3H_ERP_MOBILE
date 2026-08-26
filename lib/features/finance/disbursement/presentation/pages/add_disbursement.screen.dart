import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/disbursement/presentation/cubit/disbursement_cubit.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDisbursementScreen extends StatefulWidget {
  final bool isEdit;
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetDisbursedAmountDetailsData? disbursementData;

  const AddDisbursementScreen({
    super.key,
    required this.isEdit,
    this.termSheetDetailsView,
    this.disbursementData,
  });

  @override
  State<AddDisbursementScreen> createState() => _AddDisbursementScreenState();
}

class _AddDisbursementScreenState extends State<AddDisbursementScreen> {
  late DisbursementCubit _disbursementCubit;

  late TextEditingController _disbursedAmountC, _remarkC;

  // DATE PICKERS
  DateTime? disbursedDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _disbursementCubit = context.read<DisbursementCubit>();
    _disbursedAmountC = TextEditingController();
    _remarkC = TextEditingController();

    if (widget.isEdit && widget.disbursementData != null) {
      prefillDisbursement();
    }
  }

  void prefillDisbursement() {
    final disbursement = widget.disbursementData;

    if (disbursement == null) return;

    _disbursedAmountC.text = disbursement.disbursedAmount.toString();

    _remarkC.text = disbursement.remark;

    disbursedDate = disbursement.disbursedDate;
  }

  void _submit() {
    final termSheet = widget.termSheetDetailsView;

    if (termSheet == null) return;

    if (!_formKey.currentState!.validate()) return;

    if (disbursedDate == null) {
      return;
    }

    final disbursedAmount = double.tryParse(_disbursedAmountC.text.trim()) ?? 0;

    if (widget.isEdit) {
      final disbursement = widget.disbursementData;

      if (disbursement == null) return;

      _disbursementCubit.updateDisbursement(
        context: context,
        disbursedAmount: disbursedAmount,
        disbursedDate: disbursedDate!,
        projectId: disbursement.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: disbursement.termSheetDetailsId,
        termSheetId: disbursement.termSheetId,
        termSheetDisbursedAmountDetailsId:
            disbursement.termSheetDisbursedAmountDetailsId,
        uniquekey: disbursement.uniquekey,
      );
    } else {
      _disbursementCubit.addDisbursement(
        context: context,
        disbursedAmount: disbursedAmount,
        disbursedDate: disbursedDate!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    }
  }

  @override
  void dispose() {
    _disbursedAmountC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Disbursement",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEdit
                  ? "Update Disbursed Amount"
                  : "Add Disbursed Amount",
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
                      title: "Disbursed Amount (₹)",
                      hint: "Enter Disbursed Amount",
                      textController: _disbursedAmountC,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Disbursed Amount is required";
                        }
                        final enteredAmount = double.tryParse(value.trim());

                        if (enteredAmount == null) {
                          return "Please enter a valid amount";
                        }

                        final facilityAmount =
                            widget.termSheetDetailsView?.facilityAmount ?? 0;

                        if (enteredAmount > facilityAmount) {
                          return "Total Disbursed Amount cannot be greater than "
                              "Facility Amount (${facilityAmount.toIndianCurrency()})";
                        }

                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: 'Term Sheet Date',
                      isRequired: true,
                      initialDate: disbursedDate,
                      setValue: (value) => disbursedDate = value,
                      validator: (value) {
                        if (value == null) {
                          return 'Disbursed Date is required';
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
            text: widget.isEdit ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
