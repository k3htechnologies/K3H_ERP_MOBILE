import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/ready_reckover_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddReadyReckonerDetails extends StatefulWidget {
  final ReadyReckonerRateDetailsModel? readyReckonerRateDetails;
  final int? index;
  final int projectId;
  final int buildingId;
  const AddReadyReckonerDetails({
    super.key,
    required this.readyReckonerRateDetails,
    this.index,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<AddReadyReckonerDetails> createState() =>
      _AddReadyReckonerDetailsState();
}

class _AddReadyReckonerDetailsState extends State<AddReadyReckonerDetails> {
  late ProposedOfferCubit _cubit;

  final _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.readyReckonerRateDetails != null;

  final TextEditingController _residentialRateController =
      TextEditingController();

  final TextEditingController _commercialRateController =
      TextEditingController();

  final TextEditingController _shopRateController = TextEditingController();

  final TextEditingController _industrialRateController =
      TextEditingController();

  final TextEditingController _landRateController = TextEditingController();

  final TextEditingController _remarkController = TextEditingController();
  final ValueNotifier<DateTime?> _effectiveStartDate = ValueNotifier(null);

  final ValueNotifier<DateTime?> _effectiveEndDate = ValueNotifier(null);

  final ValueNotifier<Map<String, dynamic>?> _selectedFinancialYear =
      ValueNotifier(null);

  @override
  void initState() {
    _cubit = context.read<ProposedOfferCubit>();
    _populateFormFields();
    super.initState();
  }

  void _populateFormFields() {
    if (!_isEditMode) return;

    final model = widget.readyReckonerRateDetails!;

    _selectedFinancialYear.value = financialYearList.firstWhere(
      (e) => e['DisplayName'] == model.financialYear,
      orElse: () => financialYearList.first,
    );

    _effectiveStartDate.value = model.effectiveStartDate;
    _effectiveEndDate.value = model.effectiveEndDate;

    _residentialRateController.text = model.residentialRate.toString();

    _commercialRateController.text = model.commercialRate.toString();

    _shopRateController.text = model.shopRate.toString();

    _industrialRateController.text = model.industrialRate.toString();

    _landRateController.text = model.landRate.toString();

    _remarkController.text = model.remark;
  }

  Future<void> _addUpdateReadyReckonerRateDetails(
    BuildContext context,
    ReadyReckonerRateDetailsModel? readyReckonerDetailsModel,
    int index,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    if (readyReckonerDetailsModel != null) {
      await _cubit.updateReadyReckonerRateDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        proposedOfferReadyReckonerRateDetailsId:
            readyReckonerDetailsModel.proposedOfferReadyReckonerRateDetailsId,
        uniqueKey: readyReckonerDetailsModel.uniquekey,
        financialYear: _selectedFinancialYear.value!['DisplayName'],
        residentialRate: _residentialRateController.text.trim(),
        commercialRate: _commercialRateController.text.trim(),
        industrialRate: _industrialRateController.text.trim(),
        shopRate: _shopRateController.text.trim(),
        landRate: _landRateController.text.trim(),
        effectiveStartDate: _effectiveStartDate.value!,
        effectiveEndDate: _effectiveEndDate.value!,
        remark: _remarkController.text.trim(),
        index: index,
      );
    } else {
      await _cubit.addReadyReckonerRateDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        financialYear: _selectedFinancialYear.value!['DisplayName'],
        residentialRate: _residentialRateController.text.trim(),
        commercialRate: _commercialRateController.text.trim(),
        industrialRate: _industrialRateController.text.trim(),
        shopRate: _shopRateController.text.trim(),
        landRate: _landRateController.text.trim(),
        effectiveStartDate: _effectiveStartDate.value!,
        effectiveEndDate: _effectiveEndDate.value!,
        remark: _remarkController.text.trim(),
      );
    }
  }

  void _onSave({
    ReadyReckonerRateDetailsModel? readyReckonerDetailsModel,
    int? index,
  }) {
    if (_formKey.currentState!.validate()) {
      _addUpdateReadyReckonerRateDetails(
        context,
        readyReckonerDetailsModel,
        index ?? 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Add Ready Reckoner Details',
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: commonCardDecoration(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: _selectedFinancialYear,
                  builder: (context, value, _) {
                    return CustomDropDownWidget(
                      title: "Financial Year",
                      hintText: "Select Financial Year",
                      isRequired: true,
                      dataList: financialYearList,
                      initialValue: value,
                      onSelected: (v) => _selectedFinancialYear.value = v,
                      validator:
                          (v) =>
                              v == null ? "Financial Year is required" : null,
                      onValueClear: () => _selectedFinancialYear.value = null,
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: Listenable.merge([
                    _effectiveStartDate,
                    _effectiveEndDate,
                  ]),
                  builder: (context, _) {
                    return CustomFromToDatePicker(
                      fromDateTitle: "Effective Start Date",
                      toDateTitle: "Effective End Date",
                      initialFromDate: _effectiveStartDate.value,
                      initialToDate: _effectiveEndDate.value,
                      isRequired: true,
                      onToDateChanged: (from, to) {
                        _effectiveStartDate.value = from;
                        _effectiveEndDate.value = to;
                      },
                    );
                  },
                ),
                verticalSpacing(height: 12),
                _rateField("Residential Rate (₹)", _residentialRateController),
                _rateField("Commercial Rate (₹)", _commercialRateController),
                _rateField("Shop Rate (₹)", _shopRateController),
                _rateField("Industrial Rate (₹)", _industrialRateController),
                _rateField("Land Rate (₹)", _landRateController),
                CustomTextField(
                  title: "Remark",
                  textController: _remarkController,
                  hint: "Enter Remark",
                  maxLines: 4,
                ),
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
                readyReckonerDetailsModel: widget.readyReckonerRateDetails,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _rateField(String title, TextEditingController controller) {
    final validationTitle = title.replaceAll(" (₹)", "");

    return CustomTextField(
      title: title,
      textController: controller,
      isRequired: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatterList: InputValidator.digitWithDecimal(
        maxDigitsBeforeDecimal: 16,
      ),
      bottomMargin: 12,
      hint: "Enter $validationTitle",
      validator: (v) {
        if (v == null || v.isEmpty) {
          return "$validationTitle is required";
        }
        return null;
      },
    );
  }
}
