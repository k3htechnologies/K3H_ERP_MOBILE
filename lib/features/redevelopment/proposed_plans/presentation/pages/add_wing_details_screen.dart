import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/wing_form_detail_model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddWingDetailsScreen extends StatefulWidget {
  final int wingIndex;
  final WingFormDetailModel wing;

  const AddWingDetailsScreen({
    super.key,
    required this.wingIndex,
    required this.wing,
  });

  @override
  State<AddWingDetailsScreen> createState() => _AddWingDetailsScreenState();
}

class _AddWingDetailsScreenState extends State<AddWingDetailsScreen> {
  WingFormDetailModel get wing => widget.wing;

  @override
  void initState() {
    super.initState();

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
                      textController: wing.wingName,
                    ),

                    CustomTextField(
                      title: "Lobby Area",
                      hint: "Lobby Area",
                      keyboardType: TextInputType.number,
                      textController: wing.lobbyArea,
                    ),

                    CustomTextField(
                      title: "Total Lifts",
                      hint: "Total Lifts",
                      keyboardType: TextInputType.number,
                      textController: wing.totalLifts,
                    ),

                    CustomTextField(
                      title: "Member Units",
                      hint: "Member Units",
                      keyboardType: TextInputType.number,
                      textController: wing.memberUnits,
                    ),

                    CustomTextField(
                      title: "Sale Units",
                      hint: "Sale Units",
                      keyboardType: TextInputType.number,
                      textController: wing.saleUnits,
                    ),

                    CustomTextField(
                      title: "Total Units",
                      hint: "Total Units",
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      textController: wing.totalUnits,
                    ),

                    CustomTextField(
                      title: "Member Area",
                      hint: "Member Area",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: wing.memberArea,
                    ),

                    CustomTextField(
                      title: "Sale Area",
                      hint: "Sale Area",
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textController: wing.saleArea,
                    ),

                    CustomTextField(
                      title: "Total Area",
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
