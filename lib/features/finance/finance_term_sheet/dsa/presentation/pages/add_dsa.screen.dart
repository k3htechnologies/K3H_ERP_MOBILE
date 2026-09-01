import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsa/presentation/cubit/dsa_cubit.dart';
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

class AddDsaScreen extends StatefulWidget {
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetDirectSellingAgentData? termSheetDirectSellingAgentData;
  const AddDsaScreen({
    super.key,
    this.termSheetDetailsView,
    this.termSheetDirectSellingAgentData,
  });

  @override
  State<AddDsaScreen> createState() => _AddDsaScreenState();
}

class _AddDsaScreenState extends State<AddDsaScreen> {
  late DsaCubit _dsaCubit;

  late TextEditingController _nameOfConsultant,
      _commissionC,
      _amountC,
      _remarkC;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // EDIT MODE
  bool get _isEditMode => widget.termSheetDirectSellingAgentData != null;

  // DATE PICKERS
  DateTime? paymentDate;

  @override
  void initState() {
    super.initState();
    _dsaCubit = context.read<DsaCubit>();
    initialiseControllers();
    if (_isEditMode) {
      prefillDSA();
    }
  }

  void initialiseControllers() {
    _nameOfConsultant = TextEditingController();
    _commissionC = TextEditingController();
    _amountC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void prefillDSA() {
    final dsa = widget.termSheetDirectSellingAgentData;

    if (dsa == null) return;
    _nameOfConsultant.text = dsa.nameOfConsultant;
    _commissionC.text = dsa.commissionInPercentage.toString();
    _amountC.text = dsa.amount.toString();
    paymentDate = dsa.paymentDate;
    _remarkC.text = dsa.remark;
  }

  void _submit() {
    final termSheet = widget.termSheetDetailsView;

    if (termSheet == null) return;

    if (!_formKey.currentState!.validate()) return;
    if (_isEditMode) {
      final dsa = widget.termSheetDirectSellingAgentData;

      if (dsa == null) return;
      _dsaCubit.updateDsa(
        context: context,
        amount: double.parse(_amountC.text.trim()),
        commission: double.parse(_commissionC.text.trim()),
        nameOfCommission: _nameOfConsultant.text.trim(),
        date: paymentDate!,
        projectId: termSheet.projectId,
        remark: _remarkC.text.trim(),
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
        termSheetDirectSellingAgentId: dsa.termSheetDirectSellingAgentId,
        uniquekey: dsa.uniquekey,
      );
    } else {
      _dsaCubit.addDsa(
        context: context,
        amount: double.parse(_amountC.text.trim()),
        commission: double.parse(_commissionC.text.trim()),
        nameOfCommission: _nameOfConsultant.text.trim(),
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
    _nameOfConsultant.dispose();
    _commissionC.dispose();
    _amountC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "DSA",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Direct Selling Agent"
                  : "Add Direct Selling Agent",
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
                      title: "Name Of Consultant",
                      hint: "Enter Name Of Consultant",
                      textController: _nameOfConsultant,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name Of Consultant is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Commission",
                      hint: "Enter Commission",
                      textController: _commissionC,
                      prefixType: CustomTextFieldPrefix.percentage,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(2),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Commission is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Amount",
                      hint: "Enter Amount",
                      textController: _amountC,
                      prefixType: CustomTextFieldPrefix.rupees,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(15),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
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
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              size: 18,
              color: AppColor.white,
            ),
            text: _isEditMode ? "Update" : "Add",
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
