import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SecurityDeposit extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  const SecurityDeposit({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
  });

  @override
  State<SecurityDeposit> createState() => _SecurityDepositState();
}

class _SecurityDepositState extends State<SecurityDeposit> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _securityDepositAmountC,
      _interestAmountC,
      _remarkC;

  final ValueNotifier<
    List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>
  >
  _securityDepositListNotifier = ValueNotifier<
    List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>
  >([]);

  List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>
  get _securityDepositList => _securityDepositListNotifier.value;

  // SECURITY DEPOSIT FORM CONTROLLERS
  final ValueNotifier<Map<String, dynamic>?> _selectedSecurityDepositType =
      ValueNotifier<Map<String, dynamic>?>(null);
  late TextEditingController _stageController;
  late TextEditingController _amountController;
  final GlobalKey<FormState> _securityDepositFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    widget.onSave(_onSave);
    _cubit.pullSecurityDepositDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _securityDepositAmountC.dispose();
    _stageController.dispose();
    _interestAmountC.dispose();
    _amountController.dispose();
    _remarkC.dispose();
    _securityDepositListNotifier.dispose();
    _selectedSecurityDepositType.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _securityDepositAmountC = TextEditingController();
    _stageController = TextEditingController();
    _interestAmountC = TextEditingController();
    _amountController = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var securityDepositDetailsModel = _cubit.state.securityDepositDetails!;
    _securityDepositAmountC.text =
        securityDepositDetailsModel.securityDepositToSocietyAmount.toString();
    _securityDepositListNotifier.value = List.from(
      securityDepositDetailsModel
          .proposedOfferSecurityDepositDetailsWithPaymentStageData,
    );
    _interestAmountC.text =
        securityDepositDetailsModel.interestAmount.toString();
    _remarkC.text = securityDepositDetailsModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_securityDepositList.isEmpty) {
        showErrorMessage(
          context,
          'Error',
          'Please add at least one security deposit.',
        );
        return;
      }
      _cubit.addUpdateSecurityDepositDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        securityDepositToSocietyAmount: double.parse(
          _securityDepositAmountC.text,
        ),
        paymentStageList: _securityDepositList,
        interestAmount: double.tryParse(_interestAmountC.text) ?? 0,
        remark: _remarkC.text.trim(),
      );
    }
  }

  // BOTTOM SHEET TO ADD SECURITY DEPOSIT DETAILS
  Future<void> _showSecurityDepositBottomSheet({
    ProposedOfferSecurityDepositDetailsWithPaymentStageData? securityDeposit,
    int? index,
  }) async {
    if (securityDeposit != null) {
      _prefillBottomSheet(securityDeposit);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Security Deposit Details",
      contentWidget: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedSecurityDepositType,
        builder: (context, selectedSecurityDepositType, _) {
          return Form(
            key: _securityDepositFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TYPE
                CustomDropDownWidget(
                  isRequired: true,
                  initialValue: selectedSecurityDepositType,
                  dataList: propertyTypeList,
                  onSelected: (value) {
                    _selectedSecurityDepositType.value = value;
                  },
                  title: "Type",
                  hintText: "Select Type",
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return "Type is required";
                    }
                    return null;
                  },
                  onValueClear: () => _selectedSecurityDepositType.value = null,
                ),

                /// STAGE
                CustomTextField(
                  title: "Stage",
                  isRequired: true,
                  hint: "Enter Stage",
                  textController: _stageController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Stage is required";
                    }
                    return null;
                  },
                ),

                /// AMOUNT
                CustomTextField(
                  title: "Amount (₹)",
                  isRequired: true,
                  hint: "Enter Amount",
                  textController: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatterList:
                      inputFormatterListForDecimalValuesFixedToTwo(10),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Amount is required";
                    }

                    if (_isSecurityAmountExceeding(index)) {
                      return "Total amount cannot exceed "
                          "${_securityDepositAmountC.text}";
                    }

                    return null;
                  },
                ),

                verticalSpacing(height: 15),
              ],
            ),
          );
        },
      ),
      bottomActions: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedSecurityDepositType,
        builder: (context, selectedSecurityDepositType, _) {
          return CustomButton(
            text: "Save",
            onPressed: () {
              if (_securityDepositFormKey.currentState!.validate()) {
                final newList = List<
                  ProposedOfferSecurityDepositDetailsWithPaymentStageData
                >.from(_securityDepositList);
                if (securityDeposit == null) {
                  newList.add(
                    ProposedOfferSecurityDepositDetailsWithPaymentStageData(
                      proposedOfferSecurityDepositDetailsWithPaymentStageId: 0,
                      uniquekey: '',
                      buildingId: widget.buildingId,
                      projectId: widget.projectId,
                      type: selectedSecurityDepositType!['DisplayName'],
                      stage: _stageController.text,
                      amount: double.parse(_amountController.text),
                      createdById: 1,
                      createdBy: 'Current User',
                      createdDate: DateTime.now(),
                      modifiedById: 0,
                      modifiedBy: '',
                      modifiedDate: null,
                    ),
                  );
                } else {
                  newList[index!] =
                      ProposedOfferSecurityDepositDetailsWithPaymentStageData(
                        proposedOfferSecurityDepositDetailsWithPaymentStageId:
                            securityDeposit
                                .proposedOfferSecurityDepositDetailsWithPaymentStageId,
                        uniquekey: securityDeposit.uniquekey,
                        buildingId: securityDeposit.buildingId,
                        projectId: securityDeposit.projectId,
                        type: selectedSecurityDepositType!['DisplayName'],
                        stage: _stageController.text,
                        amount: double.parse(_amountController.text),
                        createdById: securityDeposit.createdById,
                        createdBy: securityDeposit.createdBy,
                        createdDate: securityDeposit.createdDate,
                        modifiedById: securityDeposit.modifiedById,
                        modifiedBy: securityDeposit.modifiedBy,
                        modifiedDate: securityDeposit.modifiedDate,
                      );
                }

                _securityDepositListNotifier.value = newList;
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );

    _clearDialog();
  }

  // CHECK IF SECURITY AMOUNT EXCEEDS
  bool _isSecurityAmountExceeding(int? editIndex) {
    double limit = double.tryParse(_securityDepositAmountC.text) ?? 0;

    double current = double.tryParse(_amountController.text) ?? 0;

    double sum = current;

    for (int i = 0; i < _securityDepositList.length; i++) {
      if (editIndex != null && i == editIndex) continue;

      sum += _securityDepositList[i].amount;
    }

    return sum > limit;
  }

  // PREFILL BOTTOM SHEET
  void _prefillBottomSheet(
    ProposedOfferSecurityDepositDetailsWithPaymentStageData securityDeposit,
  ) {
    _selectedSecurityDepositType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == securityDeposit.type,
      orElse: () => propertyTypeList.first,
    );
    _stageController.text = securityDeposit.stage;
    _amountController.text = securityDeposit.amount.toString();
  }

  void _clearDialog() {
    _selectedSecurityDepositType.value = null;
    _stageController.clear();
    _amountController.clear();
  }

  Future<void> _showPopupToDeleteSecurityDepositData() async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Are sure you want delete Security Deposit Amount?',
      'Deleting this security deposit will permanently remove all associated data.',
      deleteButtonTxt: 'Delete All',
    );
    if (result && context.mounted) {
      _cubit.deleteSecurityDepositDetails(
        // ignore: use_build_context_synchronously
        context: context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    }
  }

  Future<void> _showPopupToDeleteShifting(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a security deposit payment stage ?',
      'Deleting this security deposit payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final newList =
          List<ProposedOfferSecurityDepositDetailsWithPaymentStageData>.from(
            _securityDepositList,
          );
      newList.removeAt(index);
      _securityDepositListNotifier.value = newList;
      showSuccessMessage(
        // ignore: use_build_context_synchronously
        context,
        subTitle: 'Security Deposit Payment Stage Removed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.securityDepositDetails != null) {
            fillData();
          } else {
            _securityDepositAmountC.clear();
            _selectedSecurityDepositType.value = null;
            _securityDepositListNotifier.value = [];
            _stageController.clear();
            _amountController.clear();
            _remarkC.clear();
            _interestAmountC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ProposedOfferTile(
                            icon: AppAssets.securityDepositIcon,
                            title: "Security Deposit Amount Details",
                          ),
                        ),
                        CustomIconButton.delete(
                          isDisabled: state.securityDepositDetails == null,
                          onPressed: _showPopupToDeleteSecurityDepositData,
                        ),
                      ],
                    ),

                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: 'Security Deposit Amount',
                      isRequired: true,
                      hint: 'Enter Security Deposit Amount',
                      textController: _securityDepositAmountC,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter security deposit amount';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: 'Interest Amount (₹)',
                      hint: 'Enter Interest Amount (₹)',
                      textController: _interestAmountC,
                      keyboardType: TextInputType.number,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 8,
                      ),
                    ),
                    CustomTextField(
                      title: 'Remark',
                      hint: 'Enter Remark',
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                    ),
                    // SECURITY DEPOSIT DETAILS SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Security Deposit List',
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            CustomIconButton.add(
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _showSecurityDepositBottomSheet();
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        ValueListenableBuilder<
                          List<
                            ProposedOfferSecurityDepositDetailsWithPaymentStageData
                          >
                        >(
                          valueListenable: _securityDepositListNotifier,
                          builder: (context, securityDepositList, _) {
                            if (securityDepositList.isNotEmpty) {
                              return Column(
                                children: List.generate(
                                  securityDepositList.length,
                                  (index) {
                                    final securityDeposit =
                                        securityDepositList[index];

                                    return CommonInfoCard(
                                      title: securityDeposit.stage,
                                      tag: securityDeposit.type,
                                      onEdit: () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        _showSecurityDepositBottomSheet(
                                          securityDeposit: securityDeposit,
                                          index: index,
                                        );
                                      },
                                      onDelete: () {
                                        _showPopupToDeleteShifting(index);
                                      },
                                      child: Column(
                                        spacing: 10,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildColumnTitleValue(
                                                title: "Amount",
                                                value:
                                                    (securityDeposit.amount)
                                                        .toIndianCurrency(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: noDataWidget(
                                    message:
                                        'No Security Deposit Details Found',
                                    iconSize: 100,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
