import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class GstOnExistingPlusFreeArea extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;
  const GstOnExistingPlusFreeArea({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });
  @override
  State<GstOnExistingPlusFreeArea> createState() =>
      _GstOnExistingPlusFreeAreaState();
}

class _GstOnExistingPlusFreeAreaState extends State<GstOnExistingPlusFreeArea> {
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gstOnAreaByMemberPercentC,
      _gstOnAreaByDeveloperPercentC,
      _totalGstC,
      _remarkC;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeTextEditingControllers();
    _cubit.pullGSTonExistingPlusFreeArea(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
    widget.onSave(_onSave);
  }

  @override
  void dispose() {
    _gstOnAreaByMemberPercentC.dispose();
    _gstOnAreaByDeveloperPercentC.dispose();
    _totalGstC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  void _initializeTextEditingControllers() {
    _gstOnAreaByMemberPercentC = TextEditingController();
    _gstOnAreaByDeveloperPercentC = TextEditingController();
    _totalGstC = TextEditingController(text: '0');
    _remarkC = TextEditingController();
  }

  void _populateFormFields() {
    var gstModel = _cubit.state.gstOnExistingPlusFreeArea!;
    _gstOnAreaByMemberPercentC.text =
        gstModel.gstOnAreaByMemberPercent.toString();
    _gstOnAreaByDeveloperPercentC.text =
        gstModel.gstOnAreaByDeveloperPercent.toString();
    _remarkC.text = gstModel.remark;
    updateTotal();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateGSTonExistingPlusFreeArea(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        gstOnAreaByMemberPercent: double.parse(_gstOnAreaByMemberPercentC.text),
        gstOnAreaByDeveloperPercent: double.parse(
          _gstOnAreaByDeveloperPercentC.text,
        ),
        remark: _remarkC.text.trim(),
      );
    }
  }

  void updateTotal() {
    final total =
        (double.tryParse(_gstOnAreaByMemberPercentC.text) ?? 0) +
        (double.tryParse(_gstOnAreaByDeveloperPercentC.text) ?? 0);
    _totalGstC.text = total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.gstOnExistingPlusFreeArea != null) {
            _populateFormFields();
          } else {
            _gstOnAreaByMemberPercentC.clear();
            _gstOnAreaByDeveloperPercentC.clear();
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
                          svgIcon: AppAssets.gstDetailsIcon,
                          title: "GST on Existing + Free Area",
                        ),
                        verticalSpacing(height: 15),
                        CustomTextField(
                          title: 'GST on Area by Member Percent',
                          isRequired: true,
                          readOnly: disableAction,
                          hint: "Enter GST on Area by Member Percent",
                          textController: _gstOnAreaByMemberPercentC,
                          prefixType: CustomTextFieldPrefix.percentage,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatterList: InputValidator.percentage(),
                          onChangeFunction: (p0) => updateTotal(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "GST on area by member percent is required.";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: 'GST on Area by Developer Percent',
                          isRequired: true,
                          hint: "Enter GST on Area by Developer Percent",
                          readOnly: disableAction,
                          textController: _gstOnAreaByDeveloperPercentC,
                          prefixType: CustomTextFieldPrefix.percentage,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChangeFunction: (p0) => updateTotal(),
                          inputFormatterList: InputValidator.percentage(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "GST on area by developer percent is required.";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: 'Total GST',
                          isRequired: true,
                          textController: _totalGstC,
                          prefixType: CustomTextFieldPrefix.percentage,
                          readOnly: true,
                          inputFormatterList: InputValidator.percentage(),
                          validator: (value) {
                            if (value != null &&
                                ((double.tryParse(value) ?? 0) > 100)) {
                              return "Total GST percentage cannot be more than 100%";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: 'Remark',
                          readOnly: disableAction,
                          hint: 'Enter Remark',
                          textController: _remarkC,
                          minLines: 3,
                          maxLines: 3,
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
                          value: state.gstOnExistingPlusFreeArea?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            state.gstOnExistingPlusFreeArea?.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.gstOnExistingPlusFreeArea?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.gstOnExistingPlusFreeArea?.modifiedDate,
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
