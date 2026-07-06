import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ShiftingDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const ShiftingDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<ShiftingDetails> createState() => _ShiftingDetailsState();
}

class _ShiftingDetailsState extends State<ShiftingDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialAmountController;
  late TextEditingController _commercialAmountController;
  final List<Map<String, dynamic>> _configurationTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
  ];

  final ValueNotifier<List<ProposedOfferShiftingDetailsWithPaymentStageData>>
  _shiftingListNotifier =
      ValueNotifier<List<ProposedOfferShiftingDetailsWithPaymentStageData>>([]);

  List<ProposedOfferShiftingDetailsWithPaymentStageData> get _shiftingList =>
      _shiftingListNotifier.value;

  // LITIGATION FORM CONTROLLERS
  final ValueNotifier<Map<String, dynamic>?> _selectedShiftingType =
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
    _cubit.pullShiftingDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialAmountController.dispose();
    _commercialAmountController.dispose();
    _stageController.dispose();
    _stagePercentageController.dispose();
    _amountController.dispose();
    _shiftingListNotifier.dispose();
    _selectedShiftingType.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAmountController = TextEditingController();
    _commercialAmountController = TextEditingController();
    _stageController = TextEditingController();
    _stagePercentageController = TextEditingController();
    _amountController = TextEditingController();
  }

  // CHECK IF AMOUNT EXCEEDS ALLOCATED LIMIT
  bool _isAmountExceedingForSelectedType(int? editIndex) {
    final selectedType = _selectedShiftingType.value;
    if (selectedType == null) return false;

    double limit = 0;
    final typeId = selectedType['zAttributesId'];

    if (typeId == 1) {
      limit = double.tryParse(_residentialAmountController.text) ?? 0;
    } else if (typeId == 2) {
      limit = double.tryParse(_commercialAmountController.text) ?? 0;
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
    var shiftingDetailsModel = _cubit.state.shiftingDetails!;
    _residentialAmountController.text =
        shiftingDetailsModel.shiftingOfferedToResidentialAmount.toString();
    _commercialAmountController.text =
        shiftingDetailsModel.shiftingOfferedToCommercialAmount.toString();

    _shiftingListNotifier.value = List.from(
      shiftingDetailsModel.proposedOfferShiftingDetailsWithPaymentStageData,
    );
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
      _cubit.addUpdateShiftingDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        shiftingOfferedToResidentialAmount: double.parse(
          _residentialAmountController.text,
        ),
        shiftingOfferedToCommercialAmount: double.parse(
          _commercialAmountController.text,
        ),
        paymentStageList: _shiftingList,
      );
    }
  }

  // PREFILL DIALOG
  void _prefillDialog(
    ProposedOfferShiftingDetailsWithPaymentStageData shifting,
  ) {
    _selectedShiftingType.value = _configurationTypeList.firstWhere(
      (e) => e['DisplayName'] == shifting.type,
      orElse: () => _configurationTypeList.first,
    );
    _stageController.text = shifting.stage;
    _stagePercentageController.text = shifting.stagePercentage.toString();
    _amountController.text = shifting.amount.toString();
  }

  // CLEAR DIALOG
  void _clearDialog() {
    _selectedShiftingType.value = null;
    _stageController.clear();
    _stagePercentageController.clear();
    _amountController.clear();
  }

  // SHOW SHIFTING BOTTOM SHEET
  Future<void> _showShiftingBottomSheet({
    ProposedOfferShiftingDetailsWithPaymentStageData? shifting,
    int? index,
  }) async {
    if (shifting != null) {
      _prefillDialog(shifting);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Shifting Details",
      contentWidget: Form(
        key: _shiftingFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TYPE
            ValueListenableBuilder(
              valueListenable: _selectedShiftingType,
              builder: (context, value, child) {
                return CustomDropDownWidget(
                  isRequired: true,
                  initialValue: _selectedShiftingType.value,
                  dataList: _configurationTypeList,
                  onSelected: (value) {
                    _selectedShiftingType.value = value;
                    _amountController.text = '0.0';
                    _stagePercentageController.text = '0.0';
                  },
                  title: "Type",
                  hintText: "Select Type",
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return "Type is required";
                    }
                    return null;
                  },
                  onValueClear: () => _selectedShiftingType.value = null,
                );
              },
            ),

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
                if (_selectedShiftingType.value == null ||
                    _selectedShiftingType.value?['zAttributesId'] == -1) {
                  return;
                }

                double percentage = double.tryParse(value) ?? 0;

                if (_selectedShiftingType.value?['zAttributesId'] == 1) {
                  _amountController.text =
                      ((double.tryParse(_residentialAmountController.text) ??
                                  0) *
                              percentage /
                              100)
                          .toString();
                } else if (_selectedShiftingType.value?['zAttributesId'] == 2) {
                  _amountController.text =
                      ((double.tryParse(_commercialAmountController.text) ??
                                  0) *
                              percentage /
                              100)
                          .toString();
                }
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

                if (_selectedShiftingType.value == null ||
                    _selectedShiftingType.value?['zAttributesId'] == -1) {
                  return "Type must be selected first";
                }

                if (_selectedShiftingType.value?['zAttributesId'] == 1 &&
                    (double.tryParse(_residentialAmountController.text) ?? 0) ==
                        0) {
                  return "Residential amount is required";
                }

                if (_selectedShiftingType.value?['zAttributesId'] == 2 &&
                    (double.tryParse(_commercialAmountController.text) ?? 0) ==
                        0) {
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
            if (_selectedShiftingType.value!['zAttributesId'] == 1 &&
                (double.tryParse(_residentialAmountController.text) ?? 0) ==
                    0) {
              showErrorMessage(
                context,
                'Error',
                'Residential amount is required.',
              );
              return;
            }

            if (_selectedShiftingType.value?['zAttributesId'] == 2 &&
                (double.tryParse(_commercialAmountController.text) ?? 0) == 0) {
              showErrorMessage(
                context,
                'Error',
                'Commercial amount is required.',
              );
              return;
            }

            final newList =
                List<ProposedOfferShiftingDetailsWithPaymentStageData>.from(
                  _shiftingList,
                );
            if (shifting == null) {
              newList.add(
                ProposedOfferShiftingDetailsWithPaymentStageData(
                  proposedOfferShiftingDetailsWithPaymentStageId: 0,
                  uniquekey: '',
                  buildingId: widget.buildingId,
                  projectId: widget.projectId,
                  type: _selectedShiftingType.value?['DisplayName'],
                  stage: _stageController.text,
                  stagePercentage: double.parse(
                    _stagePercentageController.text,
                  ),
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
                  ProposedOfferShiftingDetailsWithPaymentStageData(
                    proposedOfferShiftingDetailsWithPaymentStageId:
                        shifting.proposedOfferShiftingDetailsWithPaymentStageId,
                    uniquekey: shifting.uniquekey,
                    buildingId: shifting.buildingId,
                    projectId: shifting.projectId,
                    type: _selectedShiftingType.value?['DisplayName'],
                    stage: _stageController.text,
                    stagePercentage: double.parse(
                      _stagePercentageController.text,
                    ),
                    amount: double.parse(_amountController.text),
                    createdById: shifting.createdById,
                    createdBy: shifting.createdBy,
                    createdDate: shifting.createdDate,
                    modifiedById: shifting.modifiedById,
                    modifiedBy: shifting.modifiedBy,
                    modifiedDate: shifting.modifiedDate,
                  );
            }

            _shiftingListNotifier.value = newList;
            Navigator.pop(context);
          }
        },
      ),
    );

    _clearDialog();
  }

  // HANDLE AMOUNT CHANGE
  void _handleResidentialAmountChange(double value) {
    final newList = List<ProposedOfferShiftingDetailsWithPaymentStageData>.from(
      _shiftingList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Residential') {
        newList[i] = ProposedOfferShiftingDetailsWithPaymentStageData(
          proposedOfferShiftingDetailsWithPaymentStageId:
              newList[i].proposedOfferShiftingDetailsWithPaymentStageId,
          uniquekey: newList[i].uniquekey,
          buildingId: newList[i].buildingId,
          projectId: newList[i].projectId,
          type: newList[i].type,
          stage: newList[i].stage,
          stagePercentage: newList[i].stagePercentage,
          amount: value * (newList[i].stagePercentage / 100),
          createdById: newList[i].createdById,
          createdBy: newList[i].createdBy,
          createdDate: newList[i].createdDate,
          modifiedById: newList[i].modifiedById,
          modifiedBy: newList[i].modifiedBy,
          modifiedDate: newList[i].modifiedDate,
        );
      }
    }
    _shiftingListNotifier.value = newList;
  }

  // HANDLE AMOUNT CHANGE
  void _handleCommercialAmountChange(double value) {
    final newList = List<ProposedOfferShiftingDetailsWithPaymentStageData>.from(
      _shiftingList,
    );
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].type == 'Commercial') {
        newList[i] = ProposedOfferShiftingDetailsWithPaymentStageData(
          proposedOfferShiftingDetailsWithPaymentStageId:
              newList[i].proposedOfferShiftingDetailsWithPaymentStageId,
          uniquekey: newList[i].uniquekey,
          buildingId: newList[i].buildingId,
          projectId: newList[i].projectId,
          type: newList[i].type,
          stage: newList[i].stage,
          stagePercentage: newList[i].stagePercentage,
          amount: value * (newList[i].stagePercentage / 100),
          createdById: newList[i].createdById,
          createdBy: newList[i].createdBy,
          createdDate: newList[i].createdDate,
          modifiedById: newList[i].modifiedById,
          modifiedBy: newList[i].modifiedBy,
          modifiedDate: newList[i].modifiedDate,
        );
      }
    }
    _shiftingListNotifier.value = newList;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.shiftingDetails != null) {
            fillData();
          } else {
            _residentialAmountController.clear();
            _commercialAmountController.clear();
            _selectedShiftingType.value = null;
            _shiftingListNotifier.value = [];
            _stageController.clear();
            _stagePercentageController.clear();
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
                    Text("Shifting Details", style: AppTextStyle.ts16M()),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: "Residential Shifting Amount (₹)",
                      hint: "Enter Residential Shifting Amount",
                      isRequired: true,
                      textController: _residentialAmountController,
                      keyboardType: TextInputType.number,
                      readOnly: _shiftingListNotifier.value.any(
                        (item) => item.type.toLowerCase() == 'residential',
                      ),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Residential amount is required";
                        }
                        if (double.parse(value) < 0) {
                          return "Amount should be positive";
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
                      title: "Commercial Shifting Amount (₹)",
                      hint: "Enter Commercial Shifting Amount",
                      isRequired: true,
                      textController: _commercialAmountController,
                      keyboardType: TextInputType.number,
                      readOnly: _shiftingListNotifier.value.any(
                        (item) => item.type.toLowerCase() == 'commercial',
                      ),
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Commercial amount is required";
                        }
                        if (double.parse(value) < 0) {
                          return "Amount should be positive";
                        }
                        return null;
                      },
                      onChangeFunction: (value) {
                        _handleCommercialAmountChange(
                          double.tryParse(value) ?? 0,
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Shifting List', style: AppTextStyle.ts16M()),
                        CustomButton(
                          onPressed: () => _showShiftingBottomSheet(),
                          text: "Add Shifting",
                          leading: Icon(Icons.add, color: AppColor.white),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 20),
                    ValueListenableBuilder<
                      List<ProposedOfferShiftingDetailsWithPaymentStageData>
                    >(
                      valueListenable: _shiftingListNotifier,
                      builder: (context, shiftingList, _) {
                        if (shiftingList.isNotEmpty) {
                          return Column(
                            children: List.generate(shiftingList.length, (
                              index,
                            ) {
                              final shifting = shiftingList[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColor.grey.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
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
                                      // HEADER (TYPE + ACTIONS)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            shifting.type,
                                            style: AppTextStyle.ts16M(),
                                          ),

                                          Row(
                                            children: [
                                              CustomIconButton.edit(
                                                onPressed: () {
                                                  _showShiftingBottomSheet(
                                                    shifting: shifting,
                                                    index: index,
                                                  );
                                                },
                                              ),

                                              const SizedBox(width: 12),

                                              CustomIconButton.delete(
                                                onPressed: () {
                                                  final newList = List<
                                                    ProposedOfferShiftingDetailsWithPaymentStageData
                                                  >.from(shiftingList);
                                                  newList.removeAt(index);
                                                  _shiftingListNotifier.value =
                                                      newList;
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Divider(
                                        color: AppColor.grey.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),

                                      _buildShiftingInfoRow(
                                        "Stage",
                                        shifting.stage,
                                      ),

                                      _buildShiftingInfoRow(
                                        "Stage %",
                                        "${shifting.stagePercentage.toStringAsFixed(2)}%",
                                      ),

                                      _buildShiftingInfoRow(
                                        "Amount",
                                        shifting.amount.toIndianCurrency(),
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
                                style: AppTextStyle.ts16R(color: AppColor.grey),
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
              ),
            ),
          );
        },
      ),
    );
  }

  // HELPER METHODS
  Widget _buildShiftingInfoRow(String title, String value) {
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
