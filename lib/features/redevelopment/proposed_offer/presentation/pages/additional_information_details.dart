import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AdditionalInformationDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;

  const AdditionalInformationDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });

  @override
  State<AdditionalInformationDetails> createState() =>
      _AdditionalInformationDetailsState();
}

class _AdditionalInformationDetailsState
    extends State<AdditionalInformationDetails> {
  late ProposedOfferCubit _cubit;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _taxDetailsC,
      _taxRemarkC,
      _purchaseAdditionalAreaRemarkC,
      _additionalRemarkC;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;

  @override
  void initState() {
    super.initState();

    _cubit = context.read<ProposedOfferCubit>();

    _initializeControllers();

    _cubit.pullAdditionalInformationDetails(
      context: context,
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );

    widget.onSave(_onSave);
  }

  @override
  void dispose() {
    _taxDetailsC.dispose();
    _taxRemarkC.dispose();
    _purchaseAdditionalAreaRemarkC.dispose();
    _additionalRemarkC.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _taxDetailsC = TextEditingController();
    _taxRemarkC = TextEditingController();
    _purchaseAdditionalAreaRemarkC = TextEditingController();
    _additionalRemarkC = TextEditingController();
  }

  void fillData() {
    final model = _cubit.state.additionalInformationDetails;

    if (model != null) {
      _taxDetailsC.text = model.taxAndDutiesDetails;
      _taxRemarkC.text = model.taxRemark;
      _purchaseAdditionalAreaRemarkC.text = model.purchaseOfAdditonalAreaRemark;
      _additionalRemarkC.text = model.additionalRemark;
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _cubit.addUpdateAdditionalInformation(
        context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
        taxAndDutiesDetails: _taxDetailsC.text.trim(),
        taxRemark: _taxRemarkC.text.trim(),
        purchaseOfAdditionalAreaRemark:
            _purchaseAdditionalAreaRemarkC.text.trim(),
        additionalRemark: _additionalRemarkC.text.trim(),
        proposedOfferAdditionalInformationId:
            _cubit
                .state
                .additionalInformationDetails
                ?.proposedOfferAdditionalInformationId ??
            0,
        uniqueKey: _cubit.state.additionalInformationDetails?.uniquekey ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.additionalInformationDetails != null) {
            fillData();
          } else {
            _taxDetailsC.clear();
            _taxRemarkC.clear();
            _purchaseAdditionalAreaRemarkC.clear();
            _additionalRemarkC.clear();
          }
        },
        builder: (context, state) {
          if (state.isLoading ?? true) {
            return loader();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardHeaderTile(
                          svgIcon: AppAssets.additionalInfoIcon,
                          title: "Additional Information",
                        ),

                        verticalSpacing(height: 15),

                        Text(
                          "Tax Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),

                        CustomTextField(
                          title:
                              "Stamp Duty, Registration Charges, Other Govt. Levied Pertaining to Re-Development",
                          hint: "Enter Tax Details",
                          readOnly: disableAction,
                          textController: _taxDetailsC,
                        ),

                        CustomTextField(
                          title: "Remarks",
                          readOnly: disableAction,
                          hint: "Enter Remarks",
                          textController: _taxRemarkC,
                          minLines: 3,
                          maxLines: 3,
                        ),
                        Divider(height: 1, color: AppColor.lightBlue),
                        verticalSpacing(),

                        Text(
                          "Purchase Of Additional Area Details",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),

                        verticalSpacing(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            "1. Additional SqFt RERA Carpet area to be purchase by the members of the society.",
                            style: AppTextStyle.ts14R(),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            "2. Discount rate will be provided for the of extra area upto",
                            style: AppTextStyle.ts14R(),
                          ),
                        ),

                        CustomTextField(
                          hint: "Enter Remarks",
                          textController: _purchaseAdditionalAreaRemarkC,
                          readOnly: disableAction,
                          minLines: 3,
                          maxLines: 3,
                        ),
                        Divider(height: 1, color: AppColor.lightBlue),
                        verticalSpacing(),

                        Text(
                          "Additional Remark",
                          style: AppTextStyle.ts14M(color: AppColor.grey),
                        ),
                        verticalSpacing(),

                        CustomTextField(
                          title: "Remarks",
                          hint: "Enter Remarks",
                          textController: _additionalRemarkC,
                          readOnly: disableAction,
                          minLines: 3,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                actionCardWidget(
                  createdBy:
                      state.additionalInformationDetails?.createdBy ?? "-",
                  createdDate: state.additionalInformationDetails?.createdDate,
                  modifiedBy: state.additionalInformationDetails?.modifiedBy,
                  modifiedDate:
                      state.additionalInformationDetails?.modifiedDate,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
