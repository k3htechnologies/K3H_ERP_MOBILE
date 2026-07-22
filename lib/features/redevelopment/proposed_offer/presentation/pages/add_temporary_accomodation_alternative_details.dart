import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/temporary_accomodation_alternative_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/widgets/common_redevelopment_widgets.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddTemporaryAccommodationAlternativeDetails extends StatefulWidget {
  final TemporaryAccommodationAlternativeDetailsModel? rentDetailsModel;
  final int? index;
  final int projectId;
  final int buildingId;

  const AddTemporaryAccommodationAlternativeDetails({
    super.key,
    this.rentDetailsModel,
    this.index,
    required this.projectId,
    required this.buildingId,
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

  final List<Map<String, dynamic>> _tenureList = [
    {"zAttributesId": 1, "DisplayName": "Tenure 1"},
    {"zAttributesId": 2, "DisplayName": "Tenure 2"},
    {"zAttributesId": 3, "DisplayName": "Tenure 3"},
    {"zAttributesId": 4, "DisplayName": "Tenure 4"},
    {"zAttributesId": 5, "DisplayName": "Tenure 5"},
  ];

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
        rentDetailsModel.temporaryAccommodationAlternativeStartDate;
    _rentEndDate.value =
        rentDetailsModel.temporaryAccommodationAlternativeEndDate;
    _isAdditionalTemporaryAccommodationAlternative.value =
        rentDetailsModel.isAdditionalTemporaryAccommodationAlternative;
    _isPayBrokerage.value = rentDetailsModel.isPayBrokerage;

    // Prefill dropdowns
    _selectedType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.type,
      orElse: () => propertyTypeList.first,
    );

    _selectedTenure.value = _tenureList.firstWhere(
      (e) => e['DisplayName'] == rentDetailsModel.tenure,
      orElse: () => _tenureList.first,
    );
    _isPerSqFt.value =
        rentDetailsModel.unitSqFtLumsum.toLowerCase().contains('per sq ft')
            ? true
            : false;
  }

  // API CALLS TO ADD/UPDATE RENT DETAILS
  Future<void> _addUpdateTemporaryAccommodationAlternativeDetails(
    BuildContext context,
    TemporaryAccommodationAlternativeDetailsModel? rentDetailsModel,
    ProposedOfferState state,
    int index,
  ) async {
    if (_formKey.currentState!.validate()) {
      debugPrint(_carpetAreaController.text);
      debugPrint((double.tryParse(_carpetAreaController.text) ?? 0).toString());
      rentDetailsModel != null
          ? _cubit.updateTemporaryAccommodationAlternativeDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            proposedOfferTemporaryAccommodationAlternativeDetailsId:
                rentDetailsModel
                    .proposedOfferTemporaryAccommodationAlternativeDetailsId,
            uniqueKey: rentDetailsModel.uniquekey,
            isAdditionalTemporaryAccommodationAlternative:
                _isAdditionalTemporaryAccommodationAlternative.value,
            type: _selectedType.value!['DisplayName'],
            tenure:
                _isAdditionalTemporaryAccommodationAlternative.value != true
                    ? (_selectedTenure.value?['DisplayName'] ?? "")
                    : "",
            amount: double.tryParse(_amountController.text) ?? 0,
            unitSqFtLumsum: _isPerSqFt.value == true ? 'Per Sq Ft' : 'Lumpsum',
            carpetAreaSqFt: double.tryParse(_carpetAreaController.text) ?? 0,
            temporaryAccommodationAlternativeStartDate: _rentStartDate.value!,
            temporaryAccommodationAlternativeEndDate: _rentEndDate.value!,
            isPayBrokerage: _isPayBrokerage.value,
            index: index,
          )
          : _cubit.addTemporaryAccommodationAlternativeDetails(
            context,
            buildingId: widget.buildingId,
            projectId: widget.projectId,
            isAdditionalTemporaryAccommodationAlternative:
                _isAdditionalTemporaryAccommodationAlternative.value,
            type: _selectedType.value!['DisplayName'],
            tenure:
                _isAdditionalTemporaryAccommodationAlternative.value != true
                    ? (_selectedTenure.value?['DisplayName'] ?? "")
                    : "",
            amount: double.tryParse(_amountController.text) ?? 0,
            unitSqFtLumsum: _isPerSqFt.value == true ? 'Per Sq Ft' : 'Lumpsum',
            carpetAreaSqFt: double.tryParse(_carpetAreaController.text) ?? 0,
            temporaryAccommodationAlternativeStartDate: _rentStartDate.value!,
            temporaryAccommodationAlternativeEndDate: _rentEndDate.value!,
            isPayBrokerage: _isPayBrokerage.value,
          );
    }
  }

  void _onSave({
    TemporaryAccommodationAlternativeDetailsModel? rentDetailsModel,
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
        screenTitle: "TAA Details",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: commonCardDecoration(),
            child: Column(
              children: [
                ProposedOfferTile(
                  icon: AppAssets.rentDetailsIcon,
                  title: "TAA Details",
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
      Row(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _isAdditionalTemporaryAccommodationAlternative,
              builder: (_, value, __) {
                return _buildYesNoRadio(
                  title: "Additional TAA",
                  value: value,
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
                        dataList: _tenureList,
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

      verticalSpacing(),

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

      verticalSpacing(),

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
            fromDateTitle: 'TAA Start Date',
            toDateTitle: 'TAA End Date',
            initialFromDate: _rentStartDate.value,
            initialToDate: _rentEndDate.value,
            onToDateChanged: (start, end) {
              _rentStartDate.value = start;
              _rentEndDate.value = end;
            },
            isRequired: true,
            fromDateValidator: (value) {
              if (value == null) {
                return 'TAA Start Date is required';
              }
              return null;
            },
            toDateValidator: (value) {
              if (value == null) {
                return 'TAA End Date is required';
              }
              return null;
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
            children: const [
              Radio<bool>(value: true),
              Text("Yes"),
              Radio<bool>(value: false),
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
