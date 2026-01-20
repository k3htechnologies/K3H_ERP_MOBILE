import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/security_deposite.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SecurityDeposit extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const SecurityDeposit({
    super.key,
    required this.projectId,
    required this.buildingId,
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
  late TextEditingController _securityDepositAmountController;
  final List<Map<String, dynamic>> _securityDepositTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
  ];

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
    _cubit.pullSecurityDepositDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _securityDepositAmountController.dispose();
    _stageController.dispose();
    _amountController.dispose();
    _securityDepositListNotifier.dispose();
    _selectedSecurityDepositType.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _securityDepositAmountController = TextEditingController();
    _stageController = TextEditingController();
    _amountController = TextEditingController();
  }

  // FILL DATA
  void fillData() {
    var securityDepositDetailsModel = _cubit.state.securityDepositDetails!;
    _securityDepositAmountController.text =
        securityDepositDetailsModel.securityDepositToSocietyAmount.toString();
    _securityDepositListNotifier.value = List.from(
      securityDepositDetailsModel
          .proposedOfferSecurityDepositDetailsWithPaymentStageData,
    );
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
          _securityDepositAmountController.text,
        ),
        paymentStageList: _securityDepositList,
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
      SingleChildScrollView(
        child: ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedSecurityDepositType,
          builder: (context, selectedSecurityDepositType, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _securityDepositFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// TYPE
                    CustomDropDownWidget(
                      isRequired: true,
                      initialValue: selectedSecurityDepositType,
                      dataList: _securityDepositTypeList,
                      onSelected: (value) {
                        _selectedSecurityDepositType.value = value;
                      },
                      title: "Type*",
                      validator: (value) {
                        if (value == null || value['zAttributesId'] == -1) {
                          return "Type is required";
                        }
                        return null;
                      },
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
                              "${_securityDepositAmountController.text}";
                        }

                        return null;
                      },
                    ),

                    verticalSpacing(height: 25),

                    /// SAVE
                    CustomButton(
                      text: "Save",
                      onPressed: () {
                        if (_securityDepositFormKey.currentState!.validate()) {
                          final newList = List<
                            ProposedOfferSecurityDepositDetailsWithPaymentStageData
                          >.from(_securityDepositList);
                          if (securityDeposit == null) {
                            newList.add(
                              ProposedOfferSecurityDepositDetailsWithPaymentStageData(
                                proposedOfferSecurityDepositDetailsWithPaymentStageId:
                                    0,
                                uniquekey: '',
                                buildingId: widget.buildingId,
                                projectId: widget.projectId,
                                type:
                                    selectedSecurityDepositType!['DisplayName'],
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
                                  type:
                                      selectedSecurityDepositType!['DisplayName'],
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
                    ),

                    verticalSpacing(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    _clearDialog();
  }

  // CHECK IF SECURITY AMOUNT EXCEEDS
  bool _isSecurityAmountExceeding(int? editIndex) {
    double limit = double.tryParse(_securityDepositAmountController.text) ?? 0;

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
    _selectedSecurityDepositType.value = _securityDepositTypeList.firstWhere(
      (e) => e['DisplayName'] == securityDeposit.type,
      orElse: () => _securityDepositTypeList.first,
    );
    _stageController.text = securityDeposit.stage;
    _amountController.text = securityDeposit.amount.toString();
  }

  void _clearDialog() {
    _selectedSecurityDepositType.value = null;
    _stageController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.securityDepositDetails != null) {
            fillData();
          } else {
            _securityDepositAmountController.clear();
            _selectedSecurityDepositType.value = null;
            _securityDepositListNotifier.value = [];
            _stageController.clear();
            _amountController.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Security Deposit", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: 'Security Deposit Amount',
                      isRequired: true,
                      hint: 'Enter Security Deposit Amount',
                      textController: _securityDepositAmountController,
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
                    // SECURITY DEPOSIT DETAILS SECTION
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButton(
                              onPressed:
                                  () => _showSecurityDepositBottomSheet(),
                              text: "Add Security Deposit",
                              leading: Icon(Icons.add, color: AppColor.white),
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
                                children: List.generate(securityDepositList.length, (
                                  index,
                                ) {
                                  final securityDeposit =
                                      securityDepositList[index];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColor.grey.withAlpha(80),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(10),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// HEADER (TYPE + ACTIONS)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                securityDeposit.type,
                                                style: AppTextStyle.ts16M(),
                                              ),
                                              Row(
                                                children: [
                                                  CustomIconButton.edit(
                                                    onPressed: () {
                                                      _showSecurityDepositBottomSheet(
                                                        securityDeposit:
                                                            securityDeposit,
                                                        index: index,
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 12),
                                                  CustomIconButton.delete(
                                                    onPressed: () {
                                                      final newList = List<
                                                        ProposedOfferSecurityDepositDetailsWithPaymentStageData
                                                      >.from(
                                                        securityDepositList,
                                                      );
                                                      newList.removeAt(index);
                                                      _securityDepositListNotifier
                                                          .value = newList;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          Divider(
                                            color: AppColor.grey.withAlpha(60),
                                          ),

                                          _buildSecurityInfoRow(
                                            "Stage",
                                            securityDeposit.stage,
                                          ),
                                          _buildSecurityInfoRow(
                                            "Amount",
                                            "₹${securityDeposit.amount.toStringAsFixed(2)}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: Text(
                                    'No details added',
                                    style: AppTextStyle.ts16R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        verticalSpacing(height: 20),
                        CustomButton(text: "Save", onPressed: _onSave),
                        verticalSpacing(),
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

  // HELPER METHODS
  Widget _buildSecurityInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          ),
          Text(": "),
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
