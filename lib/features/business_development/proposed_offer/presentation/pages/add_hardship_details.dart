import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/offer_hardship_details.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddHardshipDetails extends StatefulWidget {
  final ProposedOfferHardshipDetailsWithPaymentStageData? hardship;
  final int? index;
  final int projectId;
  final int buildingId;
  final double commercialAmount;
  final double residentialAmount;
  final List<ProposedOfferHardshipDetailsWithPaymentStageData> hardshipList;
  final String buildingName;
  const AddHardshipDetails({
    super.key,
    this.index,
    this.hardship,
    required this.projectId,
    required this.buildingId,
    required this.residentialAmount,
    required this.commercialAmount,
    required this.hardshipList,
    required this.buildingName,
  });

  @override
  State<AddHardshipDetails> createState() => _AddHardshipDetailsState();
}

class _AddHardshipDetailsState extends State<AddHardshipDetails> {
  final ValueNotifier<Map<String, dynamic>?> _selectedHardshipType =
      ValueNotifier<Map<String, dynamic>?>(null);
  final GlobalKey<FormState> _corpusFormKey = GlobalKey<FormState>();

  final ValueNotifier<Map<String, dynamic>?> _selectedUnitSqFtLumsum =
      ValueNotifier(null);
  late TextEditingController _residentialAmountC,
      _commercialAmountC,
      _stageC,
      _stagePercentageC,
      _amountC,
      _carpetAreaSqFtC;
  final ValueNotifier<List<ProposedOfferHardshipDetailsWithPaymentStageData>>
  _corpusListNotifier =
      ValueNotifier<List<ProposedOfferHardshipDetailsWithPaymentStageData>>([]);
  List<ProposedOfferHardshipDetailsWithPaymentStageData> get _corpusList =>
      _corpusListNotifier.value;
  bool get _isEditMode => widget.hardship != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _corpusListNotifier
        .value = List<ProposedOfferHardshipDetailsWithPaymentStageData>.from(
      widget.hardshipList,
    );
    _prefillData(hardship: widget.hardship);
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAmountC = TextEditingController(
      text: widget.residentialAmount.toString(),
    );
    _commercialAmountC = TextEditingController(
      text: widget.commercialAmount.toString(),
    );
    _stageC = TextEditingController();
    _stagePercentageC = TextEditingController();
    _amountC = TextEditingController();
    _carpetAreaSqFtC = TextEditingController();
  }

  void _prefillData({
    ProposedOfferHardshipDetailsWithPaymentStageData? hardship,
  }) {
    if (hardship == null) return;
    _selectedHardshipType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == hardship.type,
      orElse: () => propertyTypeList.first,
    );
    _stageC.text = hardship.stage;
    _stagePercentageC.text = hardship.stagePercentage.toString();
    _amountC.text = hardship.amount.toString();
    _carpetAreaSqFtC.text = hardship.carpetAreaSqFt.toString();
    _selectedUnitSqFtLumsum.value = unitSqFtLumsumList.firstWhere(
      (e) => e['DisplayName'] == hardship.unitSqFtLumsum,
      orElse: () => unitSqFtLumsumList.first,
    );
  }

  // CHECK IF AMOUNT EXCEEDS ALLOCATED LIMIT
  bool _isAmountExceedingForSelectedType(int? editIndex) {
    final selectedType = _selectedHardshipType.value;
    if (selectedType == null) return false;

    double limit = 0;
    final typeId = selectedType['zAttributesId'];

    if (typeId == 1) {
      limit = double.tryParse(_residentialAmountC.text) ?? 0;
    } else if (typeId == 2) {
      limit = double.tryParse(_commercialAmountC.text) ?? 0;
    }

    double currentAmount = double.tryParse(_amountC.text) ?? 0;
    double sum = currentAmount;

    for (int i = 0; i < _corpusList.length; i++) {
      if (editIndex != null && i == editIndex) continue;

      final item = _corpusList[i];

      if (item.type == selectedType['DisplayName']) {
        sum += item.amount;
      }
    }

    return sum > limit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Offer",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showSiteSelectedWidget(projectName: getProject().projectName),
            Text(
              toTitleCase(widget.buildingName),
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: ValueListenableBuilder<Map<String, dynamic>?>(
                  valueListenable: _selectedHardshipType,
                  builder: (context, selectedHardshipType, _) {
                    return Form(
                      key: _corpusFormKey,
                      child: Container(
                        decoration: commonCardDecoration(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CardHeaderTile(
                              svgIcon: AppAssets.hardshipDetailsIcon,
                              title:
                                  _isEditMode
                                      ? "Update Hardship Payment Stage"
                                      : "Add Hardship Payment Stage",
                            ),
                            verticalSpacing(height: 15),

                            /// TYPE
                            CustomDropDownWidget(
                              isRequired: true,
                              initialValue: selectedHardshipType,
                              dataList: propertyTypeList,
                              onSelected: (value) {
                                _selectedHardshipType.value = value;
                                _amountC.text = '0.0';
                                _stagePercentageC.text = '0.0';
                              },
                              title: "Type",
                              hintText: "Select Type",
                              validator: (value) {
                                if (value == null ||
                                    value['zAttributesId'] == -1) {
                                  return "Type is required";
                                }
                                return null;
                              },
                              onValueClear: () {
                                _selectedHardshipType.value = null;
                              },
                            ),

                            // STAGE
                            CustomTextField(
                              title: "Stage",
                              isRequired: true,
                              hint: "Enter Stage",
                              textController: _stageC,
                              inputFormatterList: [
                                LengthLimitingTextInputFormatter(150),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Stage is required";
                                }
                                return null;
                              },
                            ),

                            // STAGE %
                            CustomTextField(
                              title: "Stage Percentage",
                              isRequired: true,
                              hint: "Enter Stage Percentage",
                              prefixType: CustomTextFieldPrefix.percentage,
                              textController: _stagePercentageC,
                              keyboardType: TextInputType.number,
                              inputFormatterList:
                                  inputFormatterListForDecimalValuesFixedToTwo(
                                    3,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Amount is required";
                                }

                                if (_isAmountExceedingForSelectedType(
                                  widget.index,
                                )) {
                                  return "Amount exceeds allocated limit";
                                }
                                return null;
                              },
                              onChangeFunction: (value) {
                                if (selectedHardshipType == null) {
                                  return;
                                }

                                double percentage = double.tryParse(value) ?? 0;

                                if (selectedHardshipType['zAttributesId'] ==
                                    1) {
                                  _amountC.text =
                                      ((double.tryParse(
                                                    _residentialAmountC.text,
                                                  ) ??
                                                  0) *
                                              percentage /
                                              100)
                                          .toString();
                                } else if (selectedHardshipType['zAttributesId'] ==
                                    2) {
                                  _amountC.text =
                                      ((double.tryParse(
                                                    _commercialAmountC.text,
                                                  ) ??
                                                  0) *
                                              percentage /
                                              100)
                                          .toString();
                                }
                              },
                            ),

                            // AMOUNT
                            CustomTextField(
                              title: "Amount",
                              textController: _amountC,
                              prefixType: CustomTextFieldPrefix.rupees,
                              hint: "Enter Amount",
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Amount is required";
                                }

                                double amount = double.tryParse(value) ?? 0;

                                if (selectedHardshipType == null) {
                                  return "Type must be selected first";
                                }

                                if (selectedHardshipType['zAttributesId'] ==
                                        1 &&
                                    (double.tryParse(
                                              _residentialAmountC.text,
                                            ) ??
                                            0) ==
                                        0) {
                                  return "Residential amount is required";
                                }

                                if (selectedHardshipType['zAttributesId'] ==
                                        2 &&
                                    (double.tryParse(_commercialAmountC.text) ??
                                            0) ==
                                        0) {
                                  return "Commercial amount is required";
                                }

                                if (amount == 0) {
                                  return "Amount cannot be zero";
                                }

                                return null;
                              },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _selectedUnitSqFtLumsum,
                              builder: (context, value, child) {
                                return CustomDropDownWidget(
                                  title: 'Unit / SqFt / Lumsum',
                                  hintText: 'Select Unit / SqFt / Lumsum',
                                  isRequired: true,
                                  dataList: unitSqFtLumsumList,
                                  initialValue: value,
                                  onSelected:
                                      (v) => _selectedUnitSqFtLumsum.value = v,
                                  validator:
                                      (v) =>
                                          v == null
                                              ? "Unit SqFt Lumsum is required"
                                              : null,
                                  onValueClear:
                                      () =>
                                          _selectedUnitSqFtLumsum.value = null,
                                );
                              },
                            ),
                            CustomTextField(
                              title: "Carpet Area (SqFt)",
                              textController: _carpetAreaSqFtC,
                              isRequired: true,
                              hint: "Enter Carpet Area (SqFt)",
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Carpet Area (SqFt) is required";
                                }

                                return null;
                              },
                            ),
                            verticalSpacing(height: 15),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: ValueListenableBuilder<Map<String, dynamic>?>(
            valueListenable: _selectedHardshipType,
            builder: (context, selectedHardshipType, _) {
              return CustomButton(
                text: "Save",
                onPressed: () {
                  if (_corpusFormKey.currentState!.validate()) {
                    if (selectedHardshipType!['zAttributesId'] == 1 &&
                        (double.tryParse(_residentialAmountC.text) ?? 0) == 0) {
                      showErrorMessage(
                        context,
                        'Error',
                        'Residential amount is required.',
                      );
                      return;
                    }

                    if (selectedHardshipType['zAttributesId'] == 2 &&
                        (double.tryParse(_commercialAmountC.text) ?? 0) == 0) {
                      showErrorMessage(
                        context,
                        'Error',
                        'Commercial amount is required.',
                      );
                      return;
                    }

                    final newList = List<
                      ProposedOfferHardshipDetailsWithPaymentStageData
                    >.from(_corpusList);
                    if (!_isEditMode) {
                      newList.add(
                        ProposedOfferHardshipDetailsWithPaymentStageData(
                          proposedOfferHardshipDetailsWithPaymentStageId: 0,
                          uniquekey: '',
                          buildingId: widget.buildingId,
                          projectId: widget.projectId,
                          type: selectedHardshipType['DisplayName'],
                          stage: _stageC.text,
                          stagePercentage: double.parse(_stagePercentageC.text),
                          amount: double.parse(_amountC.text),
                          createdById: 1,
                          createdBy: 'Current User',
                          createdDate: DateTime.now(),
                          modifiedById: 0,
                          modifiedBy: '',
                          modifiedDate: null,
                          unitSqFtLumsum:
                              _selectedUnitSqFtLumsum.value!['DisplayName'],
                          carpetAreaSqFt: double.parse(_carpetAreaSqFtC.text),
                        ),
                      );
                    } else {
                      final hardship = widget.hardship!;
                      newList[widget.index!] =
                          ProposedOfferHardshipDetailsWithPaymentStageData(
                            proposedOfferHardshipDetailsWithPaymentStageId:
                                hardship
                                    .proposedOfferHardshipDetailsWithPaymentStageId,
                            uniquekey: hardship.uniquekey,
                            buildingId: hardship.buildingId,
                            projectId: hardship.projectId,
                            type: selectedHardshipType['DisplayName'],
                            stage: _stageC.text,
                            stagePercentage: double.parse(
                              _stagePercentageC.text,
                            ),
                            amount: double.parse(_amountC.text),
                            createdById: hardship.createdById,
                            createdBy: hardship.createdBy,
                            createdDate: hardship.createdDate,
                            modifiedById: hardship.modifiedById,
                            modifiedBy: hardship.modifiedBy,
                            modifiedDate: hardship.modifiedDate,
                            unitSqFtLumsum:
                                _selectedUnitSqFtLumsum.value!['DisplayName'],
                            carpetAreaSqFt: double.parse(_carpetAreaSqFtC.text),
                          );
                    }

                    _corpusListNotifier.value = newList;
                    goRouter.pop(_corpusListNotifier.value);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
