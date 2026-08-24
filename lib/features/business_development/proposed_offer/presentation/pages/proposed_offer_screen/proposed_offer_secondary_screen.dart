import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/additional_information_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/bank_guarantee.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/building_overview.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/carpet_plot_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/hardship_offer_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/extra_carpet_area.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/gst_on_existing_plus_free_area.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/lien_to_society_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/parking_allotment.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/project_completion.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/ready_reckoner_rate_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/temporary_accomodation_alternative_details.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/security_deposit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/shifting_details.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedOffer]!;
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                showSiteSelectedWidget(projectName: widget.projectName),
                verticalSpacing(),
                Text(
                  toTitleCase(widget.buildingName),
                  style: AppTextStyle.ts14M(color: AppColor.grey),
                ),
                verticalSpacing(),
              ],
            ),
          ),
          _buildTypeWidget(widget.type, widget.projectId, widget.buildingId),
        ],
      ),

      bottomNavigationBar:
          (widget.type == "Building Overview" ||
                  widget.type == "Carpet / Plot Area" ||
                  widget.type == "Ready Reckoner Rate" ||
                  widget.type == "Temp Accom Alternative")
              ? null
              : SafeArea(
                child: Container(
                  height: 70,
                  padding: EdgeInsets.all(16),
                  child: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
                    builder: (context, state) {
                      bool hasExistingData() {
                        switch (widget.type) {
                          case "Building Overview":
                            return state.buildingDetails != null;

                          case "Extra Carpet Area":
                            return state.extraCarpetArea != null;

                          case "Hardship Offer Details":
                            return state.hardshipOfferDetails != null;

                          case "Security Deposit":
                            return state.securityDepositDetails != null;

                          case "Shifting Details":
                            return state.shiftingDetails != null;

                          case "Lien to Society Details":
                            return state.lienToSocietyDetails != null;

                          case "Parking Allotment":
                            return state.parkingAllotment != null;

                          case "GST on Existing + Free Area":
                            return state.gstOnExistingPlusFreeArea != null;

                          case "Project Completion":
                            return state.projectCompletion != null;

                          case "Temp Accom Alternative":
                            return state
                                .temporaryAccommodationAlternativeDetails
                                .isNotEmpty;

                          case "Ready Reckoner Rate":
                            return state.readyReckonerRateDetails.isNotEmpty;

                          case "Carpet / Plot Area":
                            return state.carpetPlotDetails != null;

                          case "Additional Information":
                            return state.additionalInformationDetails != null;

                          case "Bank Guarantee":
                            return state.bankGuaranteeDetails != null;

                          default:
                            return false;
                        }
                      }

                      return CustomButton(
                        text: hasExistingData() ? "Update" : "Add",
                        leading: Icon(
                          hasExistingData() ? Icons.edit : Icons.add,
                          size: 16,
                          color:
                              !_routeAuthorizationModel.isAction
                                  ? AppColor.grey2
                                  : AppColor.white,
                        ),
                        isDisable: !_routeAuthorizationModel.isAction,
                        onPressed: () {
                          _onSave?.call();
                        },
                      );
                    },
                  ),
                ),
              ),
    );
  }

  Widget _buildTypeWidget(String type, int projectId, int buildingId) {
    switch (type) {
      case "Building Overview":
        return ProposedOfferBuildingOverview();
      case "Extra Carpet Area":
        return ExtraCarpetArea(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "Hardship Offer Details":
        return HardshipDetails(
          projectId: projectId,
          buildingId: buildingId,
          buildingName: widget.buildingName,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "Security Deposit":
        return SecurityDeposit(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "Shifting Details":
        return ShiftingDetails(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "Lien to Society Details":
        return LienToSocietyDetails(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
          routeAuthorizationModel: _routeAuthorizationModel,
        );
      case "Parking Allotment":
        return ParkingAllotment(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "GST on Existing + Free Area":
        return GstOnExistingPlusFreeArea(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          onSave: (callback) => _onSave = callback,
        );
      case "Project Completion":
        return ProjectCompletion(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
          routeAuthorizationModel: _routeAuthorizationModel,
        );
      case "Temp Accom Alternative":
        return TemporaryAccommodationAlternativeDetails(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          buildingName: widget.buildingName,
        );
      case "Ready Reckoner Rate":
        return ReadyReckonerRateDetails(
          projectId: projectId,
          buildingId: buildingId,
          routeAuthorizationModel: _routeAuthorizationModel,
          buildingName: widget.buildingName,
        );
      case "Carpet / Plot Area":
        return CarpetPlotDetails(projectId: projectId, buildingId: buildingId);
      case "Additional Information":
        return AdditionalInformationDetails(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
          routeAuthorizationModel: _routeAuthorizationModel,
        );
      case "Bank Guarantee":
        return BankGuaranteeDetails(
          projectId: projectId,
          buildingId: buildingId,
          onSave: (callback) => _onSave = callback,
          routeAuthorizationModel: _routeAuthorizationModel,
        );
      default:
        return const Text("Invalid Type", style: TextStyle(color: Colors.red));
    }
  }
}
