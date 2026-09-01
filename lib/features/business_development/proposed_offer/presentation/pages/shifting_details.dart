import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/shifting_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/widgets/proposed_offer_info_card.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ShiftingDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;
  const ShiftingDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });
  @override
  State<ShiftingDetails> createState() => _ShiftingDetailsState();
}

class _ShiftingDetailsState extends State<ShiftingDetails> {
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _residentialAmountC, _commercialAmountC, _remarkC;
  final ValueNotifier<List<ProposedOfferShiftingDetailsWithPaymentStageData>>
  _shiftingListNotifier =
      ValueNotifier<List<ProposedOfferShiftingDetailsWithPaymentStageData>>([]);
  List<ProposedOfferShiftingDetailsWithPaymentStageData> get _shiftingList =>
      _shiftingListNotifier.value;
  final ValueNotifier<Map<String, dynamic>?> _selectedShiftingType =
      ValueNotifier(null);
  late TextEditingController _stageController;
  late TextEditingController _stagePercentageController;
  late TextEditingController _amountC;
  final GlobalKey<FormState> _shiftingFormKey = GlobalKey<FormState>();
  bool get disableAction => !widget.routeAuthorizationModel.isAction;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeTextEditingControllers();
    widget.onSave(_onSave);
    _cubit.pullShiftingDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialAmountC.dispose();
    _commercialAmountC.dispose();
    _stageController.dispose();
    _stagePercentageController.dispose();
    _amountC.dispose();
    _shiftingListNotifier.dispose();
    _selectedShiftingType.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _residentialAmountC = TextEditingController();
    _commercialAmountC = TextEditingController();
    _stageController = TextEditingController();
    _stagePercentageController = TextEditingController();
    _amountC = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _populateFormFields() {
    var shiftingDetailsModel = _cubit.state.shiftingDetails!;
    _residentialAmountC.text =
        shiftingDetailsModel.shiftingOfferedToResidentialAmount.toString();
    _commercialAmountC.text =
        shiftingDetailsModel.shiftingOfferedToCommercialAmount.toString();
    _shiftingListNotifier.value = List.from(
      shiftingDetailsModel.proposedOfferShiftingDetailsWithPaymentStageData,
    );
    _remarkC.text = shiftingDetailsModel.remark;
  }

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
      final residentialTotal = _shiftingList
          .where((h) => h.type == 'Residential')
          .fold(0.0, (sum, i) => sum + i.amount);
      if (double.parse(_residentialAmountC.text) < residentialTotal) {
        showErrorMessage(
          context,
          "Error",
          "Residential total (${residentialTotal.toIndianCurrency()}) cannot be greater than Hardship amount (${double.parse(_residentialAmountC.text).toIndianCurrency()}).",
        );
        return;
      }
      final commercialTotal = _shiftingList
          .where((h) => h.type == 'Commercial')
          .fold(0.0, (sum, i) => sum + i.amount);
      if (double.parse(_commercialAmountC.text) < commercialTotal) {
        showErrorMessage(
          context,
          "Error",
          "Commercial total (${commercialTotal.toIndianCurrency()}) cannot be greater than Hardship amount (${double.parse(_commercialAmountC.text).toIndianCurrency()}).",
        );
        return;
      }
      _cubit.addUpdateShiftingDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        shiftingOfferedToResidentialAmount: double.parse(
          _residentialAmountC.text,
        ),
        shiftingOfferedToCommercialAmount: double.parse(
          _commercialAmountC.text,
        ),
        paymentStageList: _shiftingList,
        remark: _remarkC.text.trim(),
      );
    }
  }

  void _prefillDialog(
    ProposedOfferShiftingDetailsWithPaymentStageData shifting,
  ) {
    _selectedShiftingType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == shifting.type,
      orElse: () => propertyTypeList.first,
    );
    _stageController.text = shifting.stage;
    _stagePercentageController.text = shifting.stagePercentage.toString();
    _amountC.text = shifting.amount.toString();
  }

  void _clearDialog() {
    _selectedShiftingType.value = null;
    _stageController.clear();
    _stagePercentageController.clear();
    _amountC.clear();
  }

  Future<void> _showShiftingBottomSheet({
    ProposedOfferShiftingDetailsWithPaymentStageData? shifting,
    int? index,
  }) async {
    if (shifting != null) {
      _prefillDialog(shifting);
    }
    void calculateAmount() {
      if (_selectedShiftingType.value == null ||
          _selectedShiftingType.value?['zAttributesId'] == -1) {
        return;
      }
      double percentage = double.tryParse(_stagePercentageController.text) ?? 0;
      if (_selectedShiftingType.value?['zAttributesId'] == 1) {
        _amountC.text =
            ((double.tryParse(_residentialAmountC.text) ?? 0) *
                    percentage /
                    100)
                .toString();
      } else if (_selectedShiftingType.value?['zAttributesId'] == 2) {
        _amountC.text =
            ((double.tryParse(_commercialAmountC.text) ?? 0) * percentage / 100)
                .toString();
      }
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "${shifting != null ? 'Update' : 'Add'} Shifting Details",
      contentWidget: Form(
        key: _shiftingFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder(
              valueListenable: _selectedShiftingType,
              builder: (context, value, child) {
                return CustomDropDownWidget(
                  isRequired: true,
                  initialValue: _selectedShiftingType.value,
                  dataList:
                      (double.tryParse(_commercialAmountC.text) != 0 &&
                              double.tryParse(_residentialAmountC.text) != 0)
                          ? propertyTypeList
                          : (List<Map<String, dynamic>>.from(propertyTypeList)
                            ..removeAt(
                              double.tryParse(_commercialAmountC.text) == 0
                                  ? 1
                                  : 0,
                            )),
                  onSelected: (value) {
                    _selectedShiftingType.value = value;
                    calculateAmount();
                  },
                  title: "Type",
                  hintText: "Select Type",
                  validator: (value) {
                    if (value == null || value['zAttributesId'] == -1) {
                      return "Type is required.";
                    }
                    return null;
                  },
                  onValueClear: () {
                    _selectedShiftingType.value = null;
                    _amountC.clear();
                  },
                );
              },
            ),
            CustomTextField(
              title: "Stage",
              isRequired: true,
              hint: "Enter Stage",
              textController: _stageController,
              inputFormatterList: [LengthLimitingTextInputFormatter(150)],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Stage is required.";
                }
                return null;
              },
            ),
            CustomTextField(
              title: "Stage Percentage (%)",
              isRequired: true,
              hint: "Enter Stage Percentage",
              textController: _stagePercentageController,
              keyboardType: TextInputType.number,
              inputFormatterList: InputValidator.percentage(),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty ||
                    double.tryParse(value) == 0) {
                  return "Stage Percentage is required.";
                }
                return null;
              },
              onChangeFunction: (value) {
                calculateAmount();
              },
            ),
            CustomTextField(
              title: "Amount (₹)",
              hint: "Calculated Amount",
              isRequired: true,
              textController: _amountC,
              keyboardType: TextInputType.number,
              readOnly: true,
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
                (double.tryParse(_residentialAmountC.text) ?? 0) == 0) {
              showErrorMessage(
                context,
                'Error',
                'Residential amount is required.',
              );
              return;
            }
            if (_selectedShiftingType.value?['zAttributesId'] == 2 &&
                (double.tryParse(_commercialAmountC.text) ?? 0) == 0) {
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
                  amount: double.parse(_amountC.text),
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
                    amount: double.parse(_amountC.text),
                    createdById: shifting.createdById,
                    createdBy: shifting.createdBy,
                    createdDate: shifting.createdDate,
                    modifiedById: shifting.modifiedById,
                    modifiedBy: shifting.modifiedBy,
                    modifiedDate: shifting.modifiedDate,
                  );
            }
            _shiftingListNotifier.value = newList;
            goRouter.pop();
          }
        },
      ),
    );
    _clearDialog();
  }

  Future<void> _showPopupToDeleteShiftingData() async {
    var result = await DialogHelper.deleteDialog(
      context,
      'Are sure you want delete Shifting Amount?',
      'Deleting this shifting will permanently remove all associated data.',
      deleteButtonTxt: 'Delete All',
    );
    if (result && context.mounted) {
      _cubit.deleteShiftingDetails(
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
      'You are about to delete a shifting payment stage ?',
      'Deleting this shifting payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final newList =
          List<ProposedOfferShiftingDetailsWithPaymentStageData>.from(
            _shiftingList,
          );
      newList.removeAt(index);
      _shiftingListNotifier.value = newList;
      // ignore: use_build_context_synchronously
      showSuccessMessage(context, subTitle: 'Shifting Payment Stage Removed');
    }
  }

  void _showGeneratePDFConfirmation({
    required ShiftingDetailsModel shiftingDetailsModel,
  }) async {
    final generatePDf = await DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Are sure you want generate shifting?',
      message: 'Once the shifting is generated, it cannot be deleted',
      confirmText: "Generate",
    );
    if (generatePDf && mounted) {
      _cubit.generateProposedOffer(
        context,
        buildingId: shiftingDetailsModel.buildingId,
        projectId: shiftingDetailsModel.projectId,
        chargeType: 'Shifting',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.shiftingDetails != null) {
            _populateFormFields();
          } else {
            _residentialAmountC.clear();
            _commercialAmountC.clear();
            _selectedShiftingType.value = null;
            _shiftingListNotifier.value = [];
            _stageController.clear();
            _stagePercentageController.clear();
            _amountC.clear();
            _remarkC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
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
                              child: CardHeaderTile(
                                svgIcon: AppAssets.shiftingDetailsIcon,
                                title: "Shifting Amount Details",
                              ),
                            ),
                            CustomIconButton.delete(
                              isDisabled:
                                  (state.shiftingDetails == null ||
                                      disableAction),
                              onPressed: _showPopupToDeleteShiftingData,
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder(
                          valueListenable: _shiftingListNotifier,
                          builder: (context, value, child) {
                            return Column(
                              children: [
                                CustomTextField(
                                  title: "Residential Shifting Amount (₹)",
                                  hint: "Enter Residential Shifting Amount",
                                  isRequired: true,
                                  textController: _residentialAmountC,
                                  keyboardType: TextInputType.number,
                                  prefixWidget: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: AppColor.grey,
                                          width: .5,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.currency_rupee,
                                      color: AppColor.grey,
                                      size: 18,
                                    ),
                                  ),
                                  readOnly:
                                      (_shiftingList.any(
                                            (item) =>
                                                item.type.toLowerCase() ==
                                                'residential',
                                          ) ||
                                          disableAction),
                                  inputFormatterList:
                                      inputFormatterListForDecimalValuesFixedToTwo(
                                        10,
                                      ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        double.parse(value) < 0) {
                                      return "Residential amount is required.";
                                    }
                                    return null;
                                  },
                                ),
                                CustomTextField(
                                  title: "Commercial Shifting Amount (₹)",
                                  hint: "Enter Commercial Shifting Amount",
                                  isRequired: true,
                                  textController: _commercialAmountC,
                                  keyboardType: TextInputType.number,
                                  prefixWidget: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: AppColor.grey,
                                          width: .5,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.currency_rupee,
                                      color: AppColor.grey,
                                      size: 18,
                                    ),
                                  ),
                                  readOnly:
                                      (_shiftingList.any(
                                            (item) =>
                                                item.type.toLowerCase() ==
                                                'commercial',
                                          ) ||
                                          disableAction),
                                  inputFormatterList:
                                      inputFormatterListForDecimalValuesFixedToTwo(
                                        10,
                                      ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        double.parse(value) < 0) {
                                      return "Commercial amount is required.";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        CustomTextField(
                          title: 'Remark',
                          hint: 'Enter Remark',
                          readOnly: disableAction,
                          textController: _remarkC,
                          minLines: 3,
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shifting List',
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            Row(
                              spacing: 16,
                              children: [
                                CustomIconButton.add(
                                  isDisabled: disableAction,
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    _showShiftingBottomSheet();
                                  },
                                ),
                                CustomButton(
                                  text: "Generate",
                                  isDisable:
                                      disableAction ||
                                      state.shiftingDetails == null,
                                  onPressed: () {
                                    _showGeneratePDFConfirmation(
                                      shiftingDetailsModel:
                                          state.shiftingDetails!,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(height: 16),
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
                                  return ProposedOfferInfoCard(
                                    title: shifting.stage,
                                    tag: shifting.type,
                                    disable: disableAction,
                                    onEdit: () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      _showShiftingBottomSheet(
                                        shifting: shifting,
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
                                    message: 'No Shifting Details Found',
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
                SectionCard(
                  title: 'Action Details',
                  titleTextColor: AppColor.black,
                  headerBackgroundColor: AppColor.grey20,
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: state.shiftingDetails?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(state.shiftingDetails?.createdDate),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.shiftingDetails?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.shiftingDetails?.modifiedDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
