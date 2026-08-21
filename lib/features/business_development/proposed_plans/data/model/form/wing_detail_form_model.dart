import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/proposed_plans.model.dart';

class WingDetailFormModel {
  int wingProposedPlanId;
  int proposedOfferProposedPlanId;
  int buildingProposedPlanId;
  String buildingName;

  final TextEditingController wingName = TextEditingController();
  final TextEditingController lobbyArea = TextEditingController();
  final TextEditingController totalLifts = TextEditingController();
  final TextEditingController memberUnits = TextEditingController();
  final TextEditingController saleUnits = TextEditingController();
  final TextEditingController totalUnits = TextEditingController();
  final TextEditingController memberArea = TextEditingController();
  final TextEditingController saleArea = TextEditingController();
  final TextEditingController totalArea = TextEditingController();

  WingDetailFormModel({
    this.wingProposedPlanId = 0,
    this.proposedOfferProposedPlanId = 0,
    this.buildingProposedPlanId = 0,
    required this.buildingName,
  });

  factory WingDetailFormModel.fromApi(WingProposedPlanDataModel data) {
    final model = WingDetailFormModel(
      wingProposedPlanId: data.wingProposedPlanId,
      proposedOfferProposedPlanId: data.proposedOfferProposedPlanId,
      buildingProposedPlanId: data.buildingProposedPlanId,
      buildingName: data.buildingName,
    );

    model.wingName.text = data.wings;
    model.lobbyArea.text = data.mainEntranceLobbyAreaSqFt.toString();
    model.totalLifts.text = data.totalNumberOfLifts.toString();
    model.memberUnits.text = data.totalNumberOfUnitsForMember.toString();
    model.saleUnits.text = data.totalNumberOfUnitsForSale.toString();
    model.totalUnits.text = data.totalNumberOfUnits.toString();
    model.memberArea.text = data.totalNumberOfAreaForMemberSqFt.toString();
    model.saleArea.text = data.totalNumberOfAreaForSaleSqFt.toString();
    model.totalArea.text =
        (data.totalNumberOfAreaForMemberSqFt +
                data.totalNumberOfAreaForSaleSqFt)
            .toString();
    return model;
  }
  WingProposedPlanDataModel toApiModel({
    required int proposedOfferProposedPlanId,
    required int buildingProposedPlanId,
    required String buildingName,
  }) {
    return WingProposedPlanDataModel(
      wingProposedPlanId: wingProposedPlanId,
      proposedOfferProposedPlanId: proposedOfferProposedPlanId,
      buildingProposedPlanId: buildingProposedPlanId,
      buildingName: buildingName,
      wings: wingName.text.trim(),
      mainEntranceLobbyAreaSqFt: double.tryParse(lobbyArea.text) ?? 0,
      totalNumberOfLifts: int.tryParse(totalLifts.text) ?? 0,
      totalNumberOfUnitsForMember: int.tryParse(memberUnits.text) ?? 0,
      totalNumberOfUnitsForSale: int.tryParse(saleUnits.text) ?? 0,
      totalNumberOfUnits: int.tryParse(totalUnits.text) ?? 0,
      totalNumberOfAreaForMemberSqFt: double.tryParse(memberArea.text) ?? 0,
      totalNumberOfAreaForSaleSqFt: double.tryParse(saleArea.text) ?? 0,
    );
  }

  void dispose() {
    wingName.dispose();
    lobbyArea.dispose();
    totalLifts.dispose();
    memberUnits.dispose();
    saleUnits.dispose();
    totalUnits.dispose();
    memberArea.dispose();
    saleArea.dispose();
    totalArea.dispose();
  }
}
