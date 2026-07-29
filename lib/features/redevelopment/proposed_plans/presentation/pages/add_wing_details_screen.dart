import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/wing_detail_form_model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddWingDetailsScreen extends StatefulWidget {
  final int wingIndex;
  final WingDetailFormModel wing;

  const AddWingDetailsScreen({
    super.key,
    required this.wingIndex,
    required this.wing,
  });

  @override
  State<AddWingDetailsScreen> createState() => _AddWingDetailsScreenState();
}

class _AddWingDetailsScreenState extends State<AddWingDetailsScreen> {
  WingDetailFormModel get wing => widget.wing;
  late final AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedPlan] ??
        AuthorizationModel();

    // Listeners for auto calculation
    wing.memberUnits.addListener(_calculateTotalUnits);
    wing.saleUnits.addListener(_calculateTotalUnits);

    wing.memberArea.addListener(_calculateTotalArea);
    wing.saleArea.addListener(_calculateTotalArea);

    // Initial calculation
    _calculateTotalUnits();
    _calculateTotalArea();
  }

  void _calculateTotalUnits() {
    final memberUnits = int.tryParse(wing.memberUnits.text.trim()) ?? 0;
    final saleUnits = int.tryParse(wing.saleUnits.text.trim()) ?? 0;

    final total = memberUnits + saleUnits;

    if (wing.totalUnits.text != total.toString()) {
      wing.totalUnits.text = total.toString();
    }
  }

  void _calculateTotalArea() {
    final memberArea = double.tryParse(wing.memberArea.text.trim()) ?? 0;
    final saleArea = double.tryParse(wing.saleArea.text.trim()) ?? 0;

    final total = memberArea + saleArea;

    final value =
        total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);

    if (wing.totalArea.text != value) {
      wing.totalArea.text = value;
    }
  }

  @override
  void dispose() {
    wing.memberUnits.removeListener(_calculateTotalUnits);
    wing.saleUnits.removeListener(_calculateTotalUnits);

    wing.memberArea.removeListener(_calculateTotalArea);
    wing.saleArea.removeListener(_calculateTotalArea);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Plan",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              "Wing ${widget.wingIndex + 1} Details",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            Container(
              decoration: commonCardDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Wing Name",
                      hint: "Wing Name",
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(25),
                      ],
                      readOnly: !_routeAuthorizationModel.isAction,
                      textController: wing.wingName,
                    ),

                    CustomTextField(
                      title: "Main Entrance Lobby Area (SqFt)",
                      hint: "Lobby Area",
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 7,
                      ),
                      readOnly: !_routeAuthorizationModel.isAction,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: wing.lobbyArea,
                    ),

                    CustomTextField(
                      title: "Total Number Of Lifts",
                      hint: "Total Lifts",
                      readOnly: !_routeAuthorizationModel.isAction,
                      inputFormatterList: InputValidator.digit(2),
                      keyboardType: TextInputType.number,
                      textController: wing.totalLifts,
                    ),

                    CustomTextField(
                      title: "Total No. Units For Member",
                      hint: "Member Units",
                      readOnly: !_routeAuthorizationModel.isAction,
                      inputFormatterList: InputValidator.digit(4),
                      keyboardType: TextInputType.number,
                      textController: wing.memberUnits,
                    ),

                    CustomTextField(
                      title: "Total No. Units For Sale",
                      hint: "Sale Units",
                      readOnly: !_routeAuthorizationModel.isAction,
                      inputFormatterList: InputValidator.digit(4),
                      keyboardType: TextInputType.number,
                      textController: wing.saleUnits,
                    ),

                    CustomTextField(
                      title: "Total Number Of Units",
                      hint: "Total Units",
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      textController: wing.totalUnits,
                    ),

                    CustomTextField(
                      title: "Total Area For Member (SqFt)",
                      hint: "Member Area",
                      readOnly: !_routeAuthorizationModel.isAction,
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 5,
                      ),

                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: wing.memberArea,
                    ),

                    CustomTextField(
                      title: "Total Area For Sale (SqFt)",
                      hint: "Sale Area",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatterList: InputValidator.digitWithDecimal(
                        maxDigitsBeforeDecimal: 5,
                      ),
                      readOnly: !_routeAuthorizationModel.isAction,
                      textController: wing.saleArea,
                    ),

                    CustomTextField(
                      title: "Total Area (SqFt)",
                      hint: "Total Area",
                      readOnly: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: wing.totalArea,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: "Save",
              isDisable: !_routeAuthorizationModel.isAction,
              onPressed: () {
                goRouter.pop(wing);
              },
            ),
          ),
        ),
      ),
    );
  }
}
