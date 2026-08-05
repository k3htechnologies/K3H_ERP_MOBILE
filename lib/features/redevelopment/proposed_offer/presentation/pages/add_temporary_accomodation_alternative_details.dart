import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
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
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTemporaryAccommodationAlternativeDetails extends StatefulWidget {
  final TemporaryAlternativeAccommodationDetailsModel? rentDetailsModel;
  final int? index;
  final int projectId;
  final int buildingId;
  final String buildingName;

  const AddTemporaryAccommodationAlternativeDetails({
    super.key,
    this.rentDetailsModel,
    this.index,
    required this.projectId,
    required this.buildingId,
    required this.buildingName,
  });

  @override
  State<AddTemporaryAccommodationAlternativeDetails> createState() =>
      _AddTemporaryAccommodationAlternativeDetailsState();
}

class _AddTemporaryAccommodationAlternativeDetailsState
    extends State<AddTemporaryAccommodationAlternativeDetails> {
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.rentDetailsModel != null;

  final ValueNotifier<bool> _isAdditionalTemporaryAccommodationAlternative =
      ValueNotifier(false);
  final ValueNotifier<bool> _isPayBrokerage = ValueNotifier(false);
  final ValueNotifier<bool> _isPerSqFt = ValueNotifier(true);

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _carpetAreaController = TextEditingController();

  final ValueNotifier<DateTime?> _rentStartDate = ValueNotifier(null);
  final ValueNotifier<DateTime?> _rentEndDate = ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedType = ValueNotifier(
    null,
  );

  final ValueNotifier<Map<String, dynamic>?> _selectedTenure = ValueNotifier(
    null,
  );

  final ValueNotifier<bool> _isPayTAA = ValueNotifier(false);

  @override
  void initState() {
    _cubit = context.read<ProposedOfferCubit>();
    _populateFormFields();
    super.initState();
  }

  void _populateFormFields() {
    if (!_isEditMode) return;
    final rentDetailsModel = widget.rentDetailsModel!;
    _amountController.text = rentDetailsModel.amount.toString();
    _carpetAreaController.text = rentDetailsModel.carpetAreaSqFt.toString();
    _rentStartDate.value =
        rentDetailsModel.temporaryAlternateAccommodationStartDate;
    _rentEndDate.value =
        rentDetailsModel.temporaryAlternateAccommodationEndDate;
    _isAdditionalTemporaryAccommodationAlternative.value =
        rentDetailsModel.isAdditionalTemporaryAlternateAccommodation;
    _isPayBrokerage.value = rentDetailsModel.isPayBrokerage;
    _isPayTAA.value = rentDetailsModel.isPayTAA;

    // Prefill dropdowns
    _selectedType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.type,
      orElse: () => propertyTypeList.first,
    );

    _selectedTenure.value = tenureList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.tenure,
      orElse: () => tenureList.first,
    );
    _isPerSqFt.value =
        rentDetailsModel.unitSqFtLumsum.toLowerCase().contains('per sq ft')
            ? true
            : false;
  }

  // API CALLS TO ADD/UPDATE RENT DETAILS
  Future<void> _addUpdateTemporaryAccommodationAlternativeDetails(
    BuildContext context,
    TemporaryAlternativeAccommodationDetailsModel? rentDetailsModel,
    ProposedOfferState state,
    int index,
  ) async {
    if (_formKey.currentState!.validate()) {
      debugPrint(
        "Adding/Updating Temporary Accommodation Alternative Details ${rentDetailsModel?.proposedOfferTemporaryAlternateAccommodationDetailsId ?? 0}",
      );
      rentDetailsModel != null
          ? _cubit.updateTemporaryAccommodationAlternativeDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            proposedOfferTemporaryAlternateAccommodationDetailsId:
                rentDetailsModel
                    .proposedOfferTemporaryAlternateAccommodationDetailsId,
            uniqueKey: rentDetailsModel.uniquekey,
            isAdditionalTemporaryAlternateAccommodation:
                _isAdditionalTemporaryAccommodationAlternative.value,
            type: _selectedType.value!['DisplayName'],
            tenure:
                _isAdditionalTemporaryAccommodationAlternative.value != true
                    ? (_selectedTenure.value?['DisplayName'] ?? "")
                    : "",
            amount: double.tryParse(_amountController.text) ?? 0,
            unitSqFtLumsum: _isPerSqFt.value == true ? 'Per SqFt' : 'Lumpsum',
            carpetAreaSqFt: double.tryParse(_carpetAreaController.text) ?? 0,
            temporaryAlternateAccommodationStartDate: _rentStartDate.value,
            temporaryAlternateAccommodationEndDate: _rentEndDate.value,
            isPayBrokerage: _isPayBrokerage.value,
            index: index,
            isPayTAA: _isPayTAA.value,
          )
          : _cubit.addTemporaryAccommodationAlternativeDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            isAdditionalTemporaryAlternateAccommodation:
                _isAdditionalTemporaryAccommodationAlternative.value,
            type: _selectedType.value!['DisplayName'],
            tenure:
                _isAdditionalTemporaryAccommodationAlternative.value != true
                    ? (_selectedTenure.value?['DisplayName'] ?? "")
                    : "",
            amount: double.tryParse(_amountController.text) ?? 0,
            unitSqFtLumsum: _isPerSqFt.value == true ? 'Per SqFt' : 'Lumpsum',
            carpetAreaSqFt: double.tryParse(_carpetAreaController.text) ?? 0,
            temporaryAlternateAccommodationStartDate: _rentStartDate.value,
            temporaryAlternateAccommodationEndDate: _rentEndDate.value,
            isPayBrokerage: _isPayBrokerage.value,
            isPayTAA: _isPayTAA.value,
          );
    }
  }

  void _onSave({
    TemporaryAlternativeAccommodationDetailsModel? rentDetailsModel,
    int? index,
  }) {
    if (_formKey.currentState!.validate()) {
      _addUpdateTemporaryAccommodationAlternativeDetails(
        context,
        rentDetailsModel,
        _cubit.state,
        index ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Offer",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            showSiteSelectedWidget(projectName: getProject().projectName),
            Text(
              toTitleCase(widget.buildingName),
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: Column(
                      children: [
                        CardHeaderTile(
                          svgIcon: AppAssets.tempAccomAlternativeIcon,
                          title:
                              _isEditMode
                                  ? "Update TAA Details"
                                  : "Add TAA Details",
                        ),
                        verticalSpacing(height: 15),
                        _buildBasicPreferenceCard(),
                        Divider(height: 30, color: AppColor.grey2),

                        _buildLeaseTermsCard(),
                        Divider(height: 30, color: AppColor.grey2),

                        _buildValuationCard(),
                        Divider(height: 30, color: AppColor.grey2),

                        _buildRentPeriodCard(),
                      ],
                    ),
                  ),
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
          child: CustomButton(
            text: "Save",
            onPressed: () {
              _onSave(
                index: widget.index,
                rentDetailsModel: widget.rentDetailsModel,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBasicPreferenceCard() {
    return _buildCardSection("Basic Preference", [
      ValueListenableBuilder(
        valueListenable: _isPayTAA,
        builder: (context, isPayTAA, child) {
          return CustomCheckBox(
            isSelected: isPayTAA,
            onChanged: (val) {
              _isPayTAA.value = val;
            },
            title: "Do You Want to Pay Temp Alternative Accom",
          );
        },
      ),
      verticalSpacing(height: 10),
      Row(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _isPayTAA,
                _isAdditionalTemporaryAccommodationAlternative,
              ]),
              builder: (context, _) {
                return _buildYesNoRadio(
                  title: "Additional TAA",
                  isEnabled: !_isPayTAA.value,
                  value: _isAdditionalTemporaryAccommodationAlternative.value,
                  onChanged: (v) {
                    _isAdditionalTemporaryAccommodationAlternative.value = v;
                    if (v) {
                      _selectedTenure.value = null;
                    }
                  },
                );
              },
            ),
          ),
          horizontalSpacing(width: 20),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _isPayBrokerage,
              builder: (_, value, __) {
                return _buildYesNoRadio(
                  title: "Pay Brokerage",
                  value: value,
                  onChanged: (v) {
                    _isPayBrokerage.value = v;
                  },
                );
              },
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildLeaseTermsCard() {
    return _buildCardSection("Lease Terms", [
      ValueListenableBuilder<bool>(
        valueListenable: _isAdditionalTemporaryAccommodationAlternative,
        builder: (context, isAdditionalRent, _) {
          return Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _selectedType,
                builder: (context, value, child) {
                  return CustomDropDownWidget(
                    title: 'Type',
                    hintText: 'Select Type',
                    isRequired: true,
                    dataList: propertyTypeList,
                    initialValue: value,
                    onSelected: (v) => _selectedType.value = v,
                    validator: (v) => v == null ? "Type is required" : null,
                    onValueClear: () => _selectedType.value = null,
                  );
                },
              ),
              horizontalSpacing(),
              !isAdditionalRent
                  ? ValueListenableBuilder(
                    valueListenable: _selectedTenure,
                    builder: (context, value, child) {
                      return CustomDropDownWidget(
                        title: 'Tenure',
                        hintText: "Select Tenure",
                        isRequired: true,
                        dataList: tenureList,
                        initialValue: value,
                        onSelected: (v) => _selectedTenure.value = v,
                        validator: (v) {
                          if (isAdditionalRent) return null;
                          if (v == null || v['zAttributesId'] == -1) {
                            return "Tenure is required";
                          }
                          return null;
                        },
                        onValueClear: () {
                          _selectedTenure.value = null;
                        },
                      );
                    },
                  )
                  : const SizedBox(),
            ],
          );
        },
      ),
    ]);
  }

  Widget _buildValuationCard() {
    return _buildCardSection("Valuation Details", [
      Text("Additional Rent", style: AppTextStyle.ts14R()),

      verticalSpacing(height: 10),

      ValueListenableBuilder(
        valueListenable: _isPerSqFt,
        builder: (_, value, __) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.grey10,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _isPerSqFt.value = false;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration:
                          !_isPerSqFt.value
                              ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.grey30),
                              )
                              : null,
                      child: Text(
                        "Lump Sum",
                        style:
                            !_isPerSqFt.value
                                ? AppTextStyle.ts14SB()
                                : AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _isPerSqFt.value = true;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration:
                          _isPerSqFt.value
                              ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColor.grey30),
                              )
                              : null,
                      alignment: Alignment.center,
                      child: Text(
                        "Per Sq.ft",
                        style:
                            _isPerSqFt.value
                                ? AppTextStyle.ts14SB()
                                : AppTextStyle.ts14M(color: AppColor.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      verticalSpacing(height: 16),

      CustomTextField(
        title: "Amount (₹)",
        textController: _amountController,
        isRequired: true,
        keyboardType: TextInputType.numberWithOptions(),
        inputFormatterList: InputValidator.digitWithDecimal(
          maxDigitsBeforeDecimal: 16,
        ),
        hint: "Enter Amount (₹)",
        validator:
            (v) => (v == null || v.isEmpty) ? "Amount is required" : null,
      ),

      CustomTextField(
        title: "Carpet Area (Sq. ft)",
        textController: _carpetAreaController,
        keyboardType: TextInputType.numberWithOptions(),
        inputFormatterList: InputValidator.digitWithDecimal(
          maxDigitsBeforeDecimal: 16,
        ),
        hint: "Enter Carpet Area",
      ),
    ]);
  }

  Widget _buildRentPeriodCard() {
    return _buildCardSection("TAA Period", [
      AnimatedBuilder(
        animation: Listenable.merge([_rentStartDate, _rentEndDate]),
        builder: (context, _) {
          return CustomFromToDatePicker(
            fromDateTitle: 'Start Date',
            toDateTitle: 'End Date',
            initialFromDate: _rentStartDate.value,
            initialToDate: _rentEndDate.value,
            onToDateChanged: (start, end) {
              _rentStartDate.value = start;
              _rentEndDate.value = end;
            },
          );
        },
      ),
    ]);
  }

  Widget _buildYesNoRadio({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyle.ts14R()),
        verticalSpacing(height: 6),
        RadioGroup<bool>(
          groupValue: value,
          onChanged: (bool? v) {
            if (v != null) {
              onChanged(v);
            }
          },
          child: Row(
            children: [
              Radio<bool>(enabled: isEnabled, value: true),
              Text("Yes"),
              Radio<bool>(enabled: isEnabled, value: false),
              Text("No"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
        verticalSpacing(),
        ...children,
      ],
    );
  }
}
