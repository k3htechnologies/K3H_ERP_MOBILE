import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/bank_guarantee_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BankGuaranteeDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;

  const BankGuaranteeDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
  });

  @override
  State<BankGuaranteeDetails> createState() => _BankGuaranteeDetailsState();
}

class _BankGuaranteeDetailsState extends State<BankGuaranteeDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialAmountC, _accountHolderNameC, _remarkC;

  final ValueNotifier<
    List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  >
  _shiftingListNotifier = ValueNotifier<
    List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  >([]);

  List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>
  get _shiftingList => _shiftingListNotifier.value;

  // LITIGATION FORM CONTROLLERS
  final ValueNotifier<Map<String, dynamic>?> _selectedBankGuaranteeType =
      ValueNotifier(null);
  late TextEditingController _stageController;
  late TextEditingController _stagePercentageController;
  late TextEditingController _amountController;
  final GlobalKey<FormState> _shiftingFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    widget.onSave(_onSave);
    // _cubit.pullBankGuaranteeDetails(
    //   projectId: widget.projectId,
    //   buildingId: widget.buildingId,
    // );
  }

  @override
  void dispose() {
    _residentialAmountC.dispose();
    _accountHolderNameC.dispose();
    _stageController.dispose();
    _stagePercentageController.dispose();
    _amountController.dispose();
    _shiftingListNotifier.dispose();
    _selectedBankGuaranteeType.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAmountC = TextEditingController();
    _accountHolderNameC = TextEditingController();
    _stageController = TextEditingController();
    _stagePercentageController = TextEditingController();
    _amountController = TextEditingController();
    _remarkC = TextEditingController();
  }

  // CHECK IF AMOUNT EXCEEDS ALLOCATED LIMIT
  bool _isAmountExceedingForSelectedType(int? editIndex) {
    final selectedType = _selectedBankGuaranteeType.value;
    if (selectedType == null) return false;

    double limit = 0;
    final typeId = selectedType['zAttributesId'];

    if (typeId == 1) {
      limit = double.tryParse(_residentialAmountC.text) ?? 0;
    } else if (typeId == 2) {
      limit = double.tryParse(_accountHolderNameC.text) ?? 0;
    }

    double currentAmount = double.tryParse(_amountController.text) ?? 0;
    double sum = currentAmount;

    for (int i = 0; i < _shiftingList.length; i++) {
      if (editIndex != null && i == editIndex) continue;

      final item = _shiftingList[i];

      if (item.type == selectedType['DisplayName']) {
        sum += item.amount;
      }
    }

    return sum > limit;
  }

  // FILL DATA
  void fillData() {
    var shiftingDetailsModel = _cubit.state.bankGuaranteeDetails!;
    _residentialAmountC.text =
        shiftingDetailsModel.bankGuaranteeOfferedToResidentialAmount.toString();
    _accountHolderNameC.text =
        shiftingDetailsModel.bankGuaranteeOfferedToCommercialAmount.toString();

    _shiftingListNotifier.value = List.from(
      shiftingDetailsModel
          .proposedOfferBankGuaranteeDetailsWithPaymentStageData,
    );
    _remarkC.text = shiftingDetailsModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_shiftingList.isEmpty) {
        showErrorMessage(
          context,
          'Error',
          'Please add at least one shifting detail.',
        );
        return;
      }
      // _cubit.addUpdateBankGuaranteeDetails(
      //   context,
      //   buildingId: widget.buildingId,
      //   projectId: widget.projectId,
      //   shiftingOfferedToResidentialAmount: double.parse(
      //     _residentialAmountC.text,
      //   ),
      //   shiftingOfferedToCommercialAmount: double.parse(
      //     _accountHolderNameC.text,
      //   ),
      //   paymentStageList: _shiftingList,
      //   remark: _remarkC.text.trim(),
      // );
    }
  }

  // PREFILL DIALOG
  void _prefillDialog(
    ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel shifting,
  ) {
    _selectedBankGuaranteeType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == shifting.type,
      orElse: () => propertyTypeList.first,
    );
    _stageController.text = shifting.stage;
    _stagePercentageController.text = shifting.stagePercentage.toString();
    _amountController.text = shifting.amount.toString();
  }

  // CLEAR DIALOG
  void _clearDialog() {
    _selectedBankGuaranteeType.value = null;
    _stageController.clear();
    _stagePercentageController.clear();
    _amountController.clear();
  }

  // SHOW SHIFTING BOTTOM SHEET
  Future<void> _showBankGuaranteeBottomSheet({
    ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel? shifting,
    int? index,
  }) async {
    if (shifting != null) {
      _prefillDialog(shifting);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Bank Guarantee Details",
      contentWidget: Form(
        key: _shiftingFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// STAGE
            CustomTextField(
              title: "Stage",
              isRequired: true,
              hint: "Enter Stage",
              textController: _stageController,
              inputFormatterList: [LengthLimitingTextInputFormatter(150)],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Stage is required";
                }
                return null;
              },
            ),

            /// STAGE %
            CustomTextField(
              title: "Stage Percentage (%)",
              isRequired: true,
              hint: "Enter Stage Percentage",
              textController: _stagePercentageController,
              keyboardType: TextInputType.number,
              inputFormatterList: inputFormatterListForDecimalValuesFixedToTwo(
                3,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Amount is required";
                }

                if (_isAmountExceedingForSelectedType(index)) {
                  return "Amount exceeds allocated limit";
                }
                return null;
              },
              onChangeFunction: (value) {
                double percentage = double.tryParse(value) ?? 0;

                _amountController.text =
                    ((double.tryParse(_residentialAmountC.text) ?? 0) *
                            percentage /
                            100)
                        .toString();
              },
            ),

            /// AMOUNT
            CustomTextField(
              title: "Amount (₹)",
              hint: "Enter Amount",
              isRequired: true,
              textController: _amountController,
              keyboardType: TextInputType.number,
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Amount is required";
                }

                double amount = double.tryParse(value) ?? 0;

                if (_selectedBankGuaranteeType.value == null ||
                    _selectedBankGuaranteeType.value?['zAttributesId'] == -1) {
                  return "Type must be selected first";
                }

                if (_selectedBankGuaranteeType.value?['zAttributesId'] == 1 &&
                    (double.tryParse(_residentialAmountC.text) ?? 0) == 0) {
                  return "Residential amount is required";
                }

                if (_selectedBankGuaranteeType.value?['zAttributesId'] == 2 &&
                    (double.tryParse(_accountHolderNameC.text) ?? 0) == 0) {
                  return "Commercial amount is required";
                }

                if (amount == 0) {
                  return "Amount cannot be zero";
                }

                return null;
              },
            ),

            verticalSpacing(height: 25),
          ],
        ),
      ),
      bottomActions: CustomButton(
        text: "Save",
        onPressed: () {
          if (_shiftingFormKey.currentState!.validate()) {
            if (_selectedBankGuaranteeType.value!['zAttributesId'] == 1 &&
                (double.tryParse(_residentialAmountC.text) ?? 0) == 0) {
              showErrorMessage(
                context,
                'Error',
                'Residential amount is required.',
              );
              return;
            }

            if (_selectedBankGuaranteeType.value?['zAttributesId'] == 2 &&
                (double.tryParse(_accountHolderNameC.text) ?? 0) == 0) {
              showErrorMessage(
                context,
                'Error',
                'Commercial amount is required.',
              );
              return;
            }

            // final newList = List<
            //   ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel
            // >.from(_shiftingList);
            if (shifting == null) {
              // newList.add(
              //   ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
              //     proposedOfferBankGuaranteeDetailsWithPaymentStageId: 0,
              //     uniquekey: '',
              //     buildingId: widget.buildingId,
              //     projectId: widget.projectId,
              //     type: _selectedBankGuaranteeType.value?['DisplayName'],
              //     stage: _stageController.text,
              //     stagePercentage: double.parse(
              //       _stagePercentageController.text,
              //     ),
              //     amount: double.parse(_amountController.text),
              //     createdById: 1,
              //     createdBy: 'Current User',
              //     createdDate: DateTime.now(),
              //     modifiedById: 0,
              //     modifiedBy: '',
              //     modifiedDate: null,
              //   ),
              // );
            } else {
              // newList[index!] =
              //     ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
              //       proposedOfferBankGuaranteeDetailsWithPaymentStageId:
              //           shifting
              //               .proposedOfferBankGuaranteeDetailsWithPaymentStageId,
              //       uniquekey: shifting.uniquekey,
              //       buildingId: shifting.buildingId,
              //       projectId: shifting.projectId,
              //       type: _selectedBankGuaranteeType.value?['DisplayName'],
              //       stage: _stageController.text,
              //       stagePercentage: double.parse(
              //         _stagePercentageController.text,
              //       ),
              //       amount: double.parse(_amountController.text),
              //       createdById: shifting.createdById,
              //       createdBy: shifting.createdBy,
              //       createdDate: shifting.createdDate,
              //       modifiedById: shifting.modifiedById,
              //       modifiedBy: shifting.modifiedBy,
              //       modifiedDate: shifting.modifiedDate,
              //     );
            }

            // _shiftingListNotifier.value = newList;
            Navigator.pop(context);
          }
        },
      ),
    );

    _clearDialog();
  }

  // HANDLE AMOUNT CHANGE
  void _handleResidentialAmountChange(double value) {
    // final newList =
    //     List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>.from(
    //       _shiftingList,
    //     );
    // for (int i = 0; i < newList.length; i++) {
    //   if (newList[i].type == 'Residential') {
    //     newList[i] = ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel(
    //       proposedOfferBankGuaranteeDetailsWithPaymentStageId:
    //           newList[i].proposedOfferBankGuaranteeDetailsWithPaymentStageId,
    //       uniquekey: newList[i].uniquekey,
    //       buildingId: newList[i].buildingId,
    //       projectId: newList[i].projectId,
    //       type: newList[i].type,
    //       stage: newList[i].stage,
    //       stagePercentage: newList[i].stagePercentage,
    //       amount: value * (newList[i].stagePercentage / 100),
    //       createdById: newList[i].createdById,
    //       createdBy: newList[i].createdBy,
    //       createdDate: newList[i].createdDate,
    //       modifiedById: newList[i].modifiedById,
    //       modifiedBy: newList[i].modifiedBy,
    //       modifiedDate: newList[i].modifiedDate,
    //     );
    //   }
    // }
    // _shiftingListNotifier.value = newList;
  }

  Future<void> _showPopupToDeleteBankGuaranteeData() async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Are sure you want delete BankGuarantee Amount?',
      'Deleting this shifting will permanently remove all associated data.',
      deleteButtonTxt: 'Delete All',
    );
    if (result && context.mounted) {}
  }

  Future<void> _showPopupToDeleteBankGuarantee(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a shifting payment stage ?',
      'Deleting this shifting payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      // final newList =
      //     List<ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>.from(
      //       _shiftingList,
      //     );
      final newList =
          <ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel>[];
      newList.removeAt(index);
      _shiftingListNotifier.value = newList;
      showSuccessMessage(
        // ignore: use_build_context_synchronously
        context,
        subTitle: 'Bank Guarantee Payment Stage Removed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.shiftingDetails != null) {
            fillData();
          } else {
            _residentialAmountC.clear();
            _accountHolderNameC.clear();
            _selectedBankGuaranteeType.value = null;
            _shiftingListNotifier.value = [];
            _stageController.clear();
            _stagePercentageController.clear();
            _amountController.clear();
            _remarkC.clear();
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
                            svgIcon: AppAssets.bankGuaranteeIcon,
                            title: "Bank Guarantee Amount Details",
                          ),
                        ),
                        CustomIconButton.delete(
                          isDisabled: state.shiftingDetails == null,
                          onPressed: _showPopupToDeleteBankGuaranteeData,
                        ),
                      ],
                    ),

                    verticalSpacing(),
                    CustomTextField(
                      title: "Account Holder Name",
                      hint: "Enter Account Holder Name",
                      isRequired: true,
                      textController: _accountHolderNameC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Account Holder Name is required";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Bank Guarantee Amount (₹)",
                      hint: "Enter Bank Guarantee Amount",
                      isRequired: true,
                      textController: _residentialAmountC,
                      keyboardType: TextInputType.number,
                      // readOnly: _shiftingListNotifier.value.any(
                      //   (item) => item.type.toLowerCase() == 'residential',
                      // ),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Bank Guarantee Amount is required";
                        }

                        return null;
                      },
                      onChangeFunction: (value) {
                        _handleResidentialAmountChange(
                          double.tryParse(value) ?? 0,
                        );
                      },
                    ),

                    CustomTextField(
                      title: 'Remark',
                      hint: 'Enter Remark',
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bank Guarantee List',
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        CustomIconButton.add(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }
                            _showBankGuaranteeBottomSheet();
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(height: 16),
                    ValueListenableBuilder<
                      List<
                        ProposedOfferBankGuaranteeDetailsWithPaymentStageDataModel
                      >
                    >(
                      valueListenable: _shiftingListNotifier,
                      builder: (context, shiftingList, _) {
                        if (shiftingList.isNotEmpty) {
                          return Column(
                            children: List.generate(shiftingList.length, (
                              index,
                            ) {
                              final shifting = shiftingList[index];

                              return CommonInfoCard(
                                title: shifting.stage,
                                tag: shifting.type,
                                onEdit: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  _showBankGuaranteeBottomSheet(
                                    shifting: shifting,
                                    index: index,
                                  );
                                },
                                onDelete: () {
                                  _showPopupToDeleteBankGuarantee(index);
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
                                          title: "Percentage",
                                          value:
                                              "${shifting.stagePercentage.toStringAsFixed(2)}%",
                                        ),
                                        buildColumnTitleValue(
                                          title: "Amount",
                                          value:
                                              (shifting.amount)
                                                  .toIndianCurrency(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: noDataWidget(
                                iconSize: 100,
                                message: 'No Bank Guarantee Details Found',
                              ),
                            ),
                          );
                        }
                      },
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
