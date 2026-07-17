import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/corpus_details.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/extra_carpet_area.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/gst_on_existing_plus_free_area.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/lien_to_society_details.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/parking_allotment.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/project_completion.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/rent_details.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/security_deposit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/pages/shifting_details.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class ProposedOfferSecondaryScreen extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final String projectName;
  final String buildingName;
  final String type;
  const ProposedOfferSecondaryScreen({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.projectName,
    required this.buildingName,
    required this.type,
  });

  @override
  State<ProposedOfferSecondaryScreen> createState() =>
      _ProposedOfferSecondaryScreenState();
}

class _ProposedOfferSecondaryScreenState
    extends State<ProposedOfferSecondaryScreen> {
  VoidCallback? _onSave;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Proposed Offer",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                showSiteSelectedWidget(projectName: widget.projectName),
                Text(
                  toTitleCase(widget.buildingName),
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
              ],
            ),
          ),
          _buildTypeWidget(widget.type, widget.projectId, widget.buildingId),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            text: "Save",
            onPressed: () {
              _onSave?.call();
            },
          ),
        ),
      ),
    );
  }

  // BUILD TYPE WIDGET
  Widget _buildTypeWidget(String type, int projectId, int buildingId) {
    switch (type) {
      case "Extra Carpet Area":
        return ExtraCarpetArea(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
        );

      case "Hardship Details":
        return HardshipDetails(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
        );
      case "Security Deposit":
        return SecurityDeposit(projectId: projectId, buildingId: buildingId);
      case "Shifting Details":
        return ShiftingDetails(projectId: projectId, buildingId: buildingId);
      case "Lien to Society Details":
        return LienToSocietyDetails(
          projectId: projectId,
          buildingId: buildingId,
        );
      case "Parking Allotment":
        return ParkingAllotment(projectId: projectId, buildingId: buildingId);
      case "GST on Existing + Free Area":
        return GstOnExistingPlusFreeArea(
          projectId: projectId,
          buildingId: buildingId,
        );
      case "Project Completion":
        return ProjectCompletion(projectId: projectId, buildingId: buildingId);
      case "Rent Details":
        return RentDetails(projectId: projectId, buildingId: buildingId);

      default:
        return const Text("Invalid Type", style: TextStyle(color: Colors.red));
    }
  }
}
