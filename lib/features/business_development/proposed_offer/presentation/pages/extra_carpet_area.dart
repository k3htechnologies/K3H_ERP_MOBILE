import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ExtraCarpetArea extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;
  const ExtraCarpetArea({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });
  @override
  State<ExtraCarpetArea> createState() => _ExtraCarpetAreaState();
}

class _ExtraCarpetAreaState extends State<ExtraCarpetArea> {
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _residentialPercentC,
      _commercialPercentC,
      _remarkC;
  final ValueNotifier<Map<String, dynamic>?> _selectedExtraCarpetType =
      ValueNotifier(null);

  bool get disableAction => !widget.routeAuthorizationModel.isAction;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeTextEditingControllers();
    widget.onSave(_onSave);
    _cubit.pullExtraCarpetArea(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialPercentC.dispose();
    _commercialPercentC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeTextEditingControllers() {
    _residentialPercentC = TextEditingController();
    _commercialPercentC = TextEditingController();
    _remarkC = TextEditingController();
  }

  // FILL DATA
  void _populateFormFields() {
    var extraCarpetModel = _cubit.state.extraCarpetArea!;
    _residentialPercentC.text =
        extraCarpetModel.residentialExtraCarpetPercent.toString();
    _commercialPercentC.text =
        extraCarpetModel.commercialExtraCarpetPercent.toString();
    _selectedExtraCarpetType.value = extraCarpetAreaList.firstWhere(
      (e) => e['DisplayName'] == extraCarpetModel.extraCarpetAreaOfferedType,
      orElse: () => extraCarpetAreaList.first,
    );
    _remarkC.text = extraCarpetModel.remark;
  }

  // SAVE
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateExtraCarpetArea(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        extraCarpetAreaOfferedType:
            _selectedExtraCarpetType.value!['DisplayName'],
        residentialExtraCarpetPercent: double.parse(_residentialPercentC.text),
        commercialExtraCarpetPercent: double.parse(_commercialPercentC.text),
        remark: _remarkC.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.extraCarpetArea != null) {
            _populateFormFields();
          } else {
            _residentialPercentC.clear();
            _commercialPercentC.clear();
            _selectedExtraCarpetType.value = null;
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
                        CardHeaderTile(
                          svgIcon: AppAssets.extraCarpetAreaIcon,
                          title: "Extra Carpet Area",
                        ),
                        verticalSpacing(),
                        Text(
                          "Basic Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),
                        ValueListenableBuilder(
                          valueListenable: _selectedExtraCarpetType,
                          builder: (context, value, child) {
                            return CustomDropDownWidget(
                              title: 'Extra Carpet Area Type',
                              hintText: 'Select Extra Carpet Area Type',
                              isRequired: true,
                              isDisabled: disableAction,
                              dataList: extraCarpetAreaList,
                              initialValue: value,
                              onSelected: (value) {
                                _selectedExtraCarpetType.value = value;
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Extra Carpet Area Type is required.";
                                }
                                return null;
                              },
                              onValueClear:
                                  () => _selectedExtraCarpetType.value = null,
                            );
                          },
                        ),
                        Divider(height: 1, color: AppColor.lightBlue),
                        verticalSpacing(),
                        Text(
                          "Percentage Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),
                        CustomTextField(
                          title: "Residential Extra Carpet",
                          hint: "Enter Residential Extra Carpet",
                          isRequired: true,
                          readOnly: disableAction,
                          textController: _residentialPercentC,
                          prefixType: CustomTextFieldPrefix.percentage,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.percentage(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Residential Extra Carpet is required.";
                            }
                            if (double.parse(value) > 100) {
                              return "Percentage should be less than 100";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Commercial Extra Carpet",
                          hint: "Enter Commercial Extra Carpet",
                          isRequired: true,
                          readOnly: disableAction,
                          keyboardType: TextInputType.number,
                          textController: _commercialPercentC,
                          prefixType: CustomTextFieldPrefix.percentage,
                          inputFormatterList: InputValidator.percentage(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Commercial Extra Carpet is required.";
                            }
                            if (double.parse(value) > 100) {
                              return "Percentage should be less than 100";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Remark",
                          hint: "Enter Remark",
                          readOnly: disableAction,
                          textController: _remarkC,
                          maxLines: 3,
                          minLines: 3,
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
                          value: state.extraCarpetArea?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(state.extraCarpetArea?.createdDate),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.extraCarpetArea?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.extraCarpetArea?.modifiedDate,
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
