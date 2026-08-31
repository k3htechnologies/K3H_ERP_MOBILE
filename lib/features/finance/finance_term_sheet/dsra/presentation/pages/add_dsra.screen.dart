import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/dsra/presentation/cubit/dsra_cubit.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet/data/model/term_sheet_view.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddDsraScreen extends StatefulWidget {
  final TermSheetDetailsView? termSheetDetailsView;
  final TermSheetDebtServiceReserveAccountData?
  termSheetDebtServiceReserveAccountData;
  const AddDsraScreen({
    super.key,
    this.termSheetDetailsView,
    this.termSheetDebtServiceReserveAccountData,
  });

  @override
  State<AddDsraScreen> createState() => _AddDsraScreenState();
}

class _AddDsraScreenState extends State<AddDsraScreen> {
  late DsraCubit _dsraCubit;

  late TextEditingController _amountC,
      _withdrawAmountC,
      _remarkC,
      _unitC,
      _perUnitRateC,
      _rateOfInterestC,
      _redemptionValueC,
      _maturityPeriodC;
  final ValueNotifier<Map<String, dynamic>?> selectedSupport = ValueNotifier(
    null,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // EDIT MODE
  bool get _isEditMode => widget.termSheetDebtServiceReserveAccountData != null;
  // DATE PICKERS
  DateTime? date, withdrawDate;
  @override
  void initState() {
    super.initState();
    _dsraCubit = context.read<DsraCubit>();
    initialiseControllers();
    if (_isEditMode) {
      prefillDSRA();
    }
  }

  void initialiseControllers() {
    _amountC = TextEditingController();
    _withdrawAmountC = TextEditingController();
    _remarkC = TextEditingController();
    _unitC = TextEditingController();
    _perUnitRateC = TextEditingController();
    _rateOfInterestC = TextEditingController();
    _redemptionValueC = TextEditingController();
    _maturityPeriodC = TextEditingController();

    _unitC.addListener(_calculateAmount);
    _perUnitRateC.addListener(_calculateAmount);
  }

  void prefillDSRA() {
    final dsra = widget.termSheetDebtServiceReserveAccountData;

    if (dsra == null) return;

    // TERM DROPDOWN
    selectedSupport.value = dsraTermList.firstWhere(
      (item) => item['DisplayName'] == dsra.term,
      orElse: () => <String, dynamic>{},
    );

    // BASIC FIELDS
    _unitC.text = dsra.unit.toString();
    _perUnitRateC.text = dsra.perUnitRate.toString();
    _amountC.text = dsra.amount.toString();

    date = dsra.date;

    // FIXED DEPOSIT FIELDS
    _rateOfInterestC.text = dsra.rateOfInterestInPercentage.toString();

    _redemptionValueC.text = dsra.redemptionValue.toString();

    _maturityPeriodC.text = dsra.maturityPeriod.toString();

    // WITHDRAW FIELDS
    _withdrawAmountC.text = dsra.withdrawAmount.toString();

    withdrawDate = dsra.withdrawDate;

    // REMARK
    _remarkC.text = dsra.remark;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final termSheet = widget.termSheetDetailsView;

    if (termSheet == null) return;

    final selectedValue = selectedSupport.value;

    if (selectedValue == null) {
      showErrorMessage(context, "Error", "Please select Term");
      return;
    }
    final String term = selectedValue['DisplayName']?.toString() ?? '';
    final bool isFixedDeposit = term == 'Fixed Deposit (FD)';

    // COMMON VALUES
    final int unit = int.tryParse(_unitC.text.trim()) ?? 0;

    final double perUnitRate = double.tryParse(_perUnitRateC.text.trim()) ?? 0;

    final double amount = double.tryParse(_amountC.text.trim()) ?? 0;

    final double withdrawAmount =
        double.tryParse(_withdrawAmountC.text.trim()) ?? 0;

    // FIXED DEPOSIT VALUES
    final double rateOfInterest =
        double.tryParse(_rateOfInterestC.text.trim()) ?? 0;

    final double redemptionValue =
        double.tryParse(_redemptionValueC.text.trim()) ?? 0;

    final int maturityPeriod = int.tryParse(_maturityPeriodC.text.trim()) ?? 0;

    // EDIT CASE
    if (_isEditMode) {
      final dsra = widget.termSheetDebtServiceReserveAccountData;

      if (dsra == null) return;

      _dsraCubit.updateDsra(
        context: context,

        termSheetDebtServiceReserveAccountId:
            dsra.termSheetDebtServiceReserveAccountId,

        uniqueKey: dsra.uniquekey,

        term: term,

        unit: unit,
        perUnitRate: perUnitRate,
        amount: amount,

        date: date!,

        rateOfInterestInPercentage: isFixedDeposit ? rateOfInterest : 0,

        redemptionValue: isFixedDeposit ? redemptionValue : 0,

        maturityPeriod: isFixedDeposit ? maturityPeriod : 0,

        withdrawAmount: withdrawAmount,
        withdrawDate: withdrawDate,

        remark: _remarkC.text.trim(),

        projectId: termSheet.projectId,
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    }
    // ADD CASE
    else {
      _dsraCubit.addDsra(
        context: context,

        term: term,

        unit: unit,
        perUnitRate: perUnitRate,
        amount: amount,

        date: date!,

        rateOfInterestInPercentage: isFixedDeposit ? rateOfInterest : 0,

        redemptionValue: isFixedDeposit ? redemptionValue : 0,

        maturityPeriod: isFixedDeposit ? maturityPeriod : 0,

        withdrawAmount: withdrawAmount,
        withdrawDate: withdrawDate,

        remark: _remarkC.text.trim(),

        projectId: termSheet.projectId,
        termSheetDetailsId: termSheet.termSheetDetailsId,
        termSheetId: termSheet.termSheetId,
      );
    }
  }

  @override
  void dispose() {
    _amountC.dispose();
    _withdrawAmountC.dispose();
    _remarkC.dispose();
    _unitC.dispose();
    _perUnitRateC.dispose();
    _rateOfInterestC.dispose();
    _redemptionValueC.dispose();
    _maturityPeriodC.dispose();

    selectedSupport.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    final unit = double.tryParse(_unitC.text.trim()) ?? 0;
    final perUnitRate = double.tryParse(_perUnitRateC.text.trim()) ?? 0;

    final amount = unit * perUnitRate;

    _amountC.text = amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "DSRA",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode
                  ? "Update Debt Service Reserve Account"
                  : "Add Debt Service Reserve Account",
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
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: selectedSupport,
                      builder: (context, selectedValue, child) {
                        final String? selectedTerm =
                            selectedValue?['DisplayName']?.toString();

                        final bool isMutualFund =
                            selectedTerm == 'Mutual Fund (MF)';

                        final bool isFixedDeposit =
                            selectedTerm == 'Fixed Deposit (FD)';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropDownWidget(
                              title: "Term",
                              hintText: "Select Term",
                              dataList: dsraTermList,
                              initialValue: selectedValue,
                              onSelected: (value) {
                                debugPrint("Selected Value: $value");

                                selectedSupport.value = value;

                                final selectedName =
                                    value['DisplayName']?.toString();

                                if (selectedName == 'Fixed Deposit (FD)') {
                                  _unitC.clear();
                                  _perUnitRateC.clear();
                                }

                                if (selectedName == 'Mutual Fund (MF)') {
                                  _rateOfInterestC.clear();
                                  _redemptionValueC.clear();
                                  _maturityPeriodC.clear();
                                }
                              },
                              isRequired: true,
                              onValueClear: () {
                                selectedSupport.value = null;

                                _unitC.clear();
                                _perUnitRateC.clear();

                                _rateOfInterestC.clear();
                                _redemptionValueC.clear();
                                _maturityPeriodC.clear();
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Term is required';
                                }
                                return null;
                              },
                            ),
                            if (isMutualFund) ...[
                              CustomTextField(
                                title: "Unit",
                                hint: "Enter Unit",
                                textController: _unitC,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Unit is required";
                                  }
                                  return null;
                                },
                              ),

                              CustomTextField(
                                title: "Per Unit Rate",
                                hint: "Enter Per Unit Rate",
                                prefixType: CustomTextFieldPrefix.rupees,
                                textController: _perUnitRateC,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      15,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Per Unit Rate is required";
                                  }
                                  return null;
                                },
                              ),
                            ],
                            CustomTextField(
                              title: "Amount",
                              hint: "Enter Amount",
                              prefixType: CustomTextFieldPrefix.rupees,
                              textController: _amountC,
                              isRequired: true,
                              readOnly: isMutualFund,

                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    15,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Amount is required";
                                }
                                return null;
                              },
                            ),
                            CustomDatePicker(
                              title: "Date",
                              hint: "Enter Date",
                              initialDate: date,
                              setValue: (value) {
                                setState(() {
                                  date = value;
                                });
                              },
                              isRequired: true,
                              validator: (value) {
                                if (value == null) {
                                  return 'Date is required';
                                }
                                return null;
                              },
                            ),
                            if (isFixedDeposit) ...[
                              CustomTextField(
                                title: "Rate Of Interest",
                                hint: "Enter Rate Of Interest",
                                textController: _rateOfInterestC,
                                prefixType: CustomTextFieldPrefix.percentage,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      15,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Rate Of Interest is required";
                                  }

                                  final rate = double.tryParse(value.trim());

                                  if (rate == null) {
                                    return "Enter a valid interest rate";
                                  }

                                  if (rate <= 0) {
                                    return "Rate Of Interest must be greater than 0";
                                  }

                                  if (rate > 100) {
                                    return "Rate Of Interest cannot be greater than 100%";
                                  }

                                  return null;
                                },
                              ),

                              CustomTextField(
                                title: "Redemption Value",
                                hint: "Enter Redemption Value",
                                textController: _redemptionValueC,
                                prefixType: CustomTextFieldPrefix.rupees,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatterList:
                                    inputFormatterListForDecimalValuesFixedToTwo(
                                      15,
                                    ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Redemption Value is required";
                                  }

                                  final redemptionValue = double.tryParse(
                                    value.trim(),
                                  );

                                  if (redemptionValue == null ||
                                      redemptionValue <= 0) {
                                    return "Enter a valid Redemption Value";
                                  }

                                  return null;
                                },
                              ),

                              CustomTextField(
                                title: "Maturity Period",
                                hint: "Enter Maturity Period",
                                textController: _maturityPeriodC,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Maturity Period is required";
                                  }

                                  final period = int.tryParse(value.trim());

                                  if (period == null || period <= 0) {
                                    return "Enter a valid Maturity Period";
                                  }

                                  return null;
                                },
                              ),
                            ],
                            CustomTextField(
                              title: "Withdraw Amount",
                              hint: "Enter Withdraw Amount",
                              prefixType: CustomTextFieldPrefix.rupees,
                              textController: _withdrawAmountC,
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    15,
                                  ),
                              readOnly: true,
                            ),
                            CustomDatePicker(
                              title: "Withdraw Date",
                              hint: "Enter Withdraw Date",
                              initialDate: withdrawDate,
                              setValue: (value) {
                                setState(() {
                                  withdrawDate = value;
                                });
                              },
                              readOnly: true,
                            ),
                            CustomTextField(
                              title: "Remark",
                              hint: "Enter Remark",
                              textController: _remarkC,
                              minLines: 3,
                              maxLines: 10,
                            ),
                          ],
                        );
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
