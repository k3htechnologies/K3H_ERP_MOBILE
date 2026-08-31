import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/presentation/cubit/repayment_cubit.dart';
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

class AddRepaymentScreen extends StatefulWidget {
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetRepayLedgerData? termSheetRepayLedgerData;
  const AddRepaymentScreen({
    super.key,
    this.termSheetDetailsView,
    this.termSheetRepayLedgerData,
  });

  @override
  State<AddRepaymentScreen> createState() => _AddRepaymentScreenState();
}

class _AddRepaymentScreenState extends State<AddRepaymentScreen> {
  late RepaymentCubit _repaymentCubit;

  late TextEditingController _repaymentAmountC, _remarkC;

  // EDIT MODE
  bool get _isEditMode => widget.termSheetRepayLedgerData != null;

  // DATE PICKERS
  DateTime? paymentDate;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _repaymentCubit = context.read<RepaymentCubit>();
    _repaymentAmountC = TextEditingController();
    _remarkC = TextEditingController();
    if (_isEditMode) {
      prefillRepayment();
    }
    super.initState();
  }

  void prefillRepayment() {
    final repayment = widget.termSheetRepayLedgerData;

    if (repayment == null) return;
    _repaymentAmountC.text = repayment.amount.toString();
    paymentDate = repayment.paymentDate;
    _remarkC.text = repayment.remark;
  }

  void _submit() {
    final termSheet = widget.termSheetDetailsView;

    if (termSheet == null) return;

    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      final repayment = widget.termSheetRepayLedgerData;

      if (repayment == null) return;
      _repaymentCubit.updateRepayment(
        context: context,
        termSheetRepayLedgerId: repayment.termSheetRepayLedgerId,
        uniquekey: repayment.uniquekey,
        amount: double.parse(_repaymentAmountC.text.trim()),
        date: paymentDate!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    } else {
      _repaymentCubit.addRepayment(
        context: context,
        amount: double.parse(_repaymentAmountC.text.trim()),
        date: paymentDate!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    }
  }

  @override
  void dispose() {
    _repaymentAmountC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Repayment",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? "Update Repayment" : "Add Repayment",
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
                      title: "Repayment Amount",
                      hint: "Enter Repayment Amount",
                      textController: _repaymentAmountC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
                        }
                        final enteredAmount = double.tryParse(value.trim());

                        if (enteredAmount == null) {
                          return "Please enter a valid amount";
                        }

                        final disbursedAmount =
                            widget.termSheetDetailsView?.totalDisbursedAmount ??
                            0;

                        if (enteredAmount > disbursedAmount) {
                          return "Total Repayment Amount cannot be greater than "
                              "Disbursed Amount (${disbursedAmount.toIndianCurrency()})";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Payment Date",
                      hint: "Enter Payment Date",
                      initialDate: paymentDate,
                      setValue: (value) => paymentDate = value,
                      isRequired: true,
                      validator: (value) {
                        if (value == null) {
                          return 'Payment Date is required';
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
