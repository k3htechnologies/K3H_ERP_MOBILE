import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';

class BuildingOverview extends StatelessWidget {
  final RedevelopmentBuildingModel building;
  const BuildingOverview({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionCard(
            title: 'Building Details',
            textColor: AppColor.primary,
            bgColor: AppColor.lightBlue,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Building Name",
                    value: building.buildingName,
                  ),
                  buildColumnTitleValue(
                    title: "CTS Number",
                    value: building.cTSNumber,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Road Width",
                    value: building.roadWidth,
                  ),
                  buildColumnTitleValue(
                    title: "Land Ownership",
                    value: building.landOwnershipType,
                  ),
                ],
              ),
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Google Location",
                    value: building.googleLocation,
                    customValueWidget: CustomClickToContactText(
                      value: building.googleLocation,
                      type: ContactType.url,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // PROPERTY INFORMATION
          sectionCard(
            title: 'Property Information',
            textColor: AppColor.orange,
            bgColor: AppColor.lightOrangeBg.withValues(alpha: 0.5),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Total Plot Area (SqMt)",
                    value: building.totalPlotAreaSqMt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Total Plot Area (SqFt)",
                    value: building.totalPlotAreaSqFt.addCommas(),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Total Floors",
                    value: building.numberOfFloors.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Utilized Unit Area (SqFt)",
                    value: building.totalUnitsAreaUtilizedSqFt.addCommas(),
                  ),
                ],
              ),
              buildRowWrapper(
                child: buildColumnTitleValue(
                  title: "Total Units",
                  value: building.totalNumberOfUnits.addCommas(),
                ),
              ),
            ],
          ),

          // LOCATION DETAILS
          sectionCard(
            title: 'Location Details',
            textColor: AppColor.darkBlue29,
            bgColor: AppColor.darkBlue29.withValues(alpha: 0.1),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Country",
                    value: building.countryName,
                  ),
                  buildColumnTitleValue(
                    title: "State",
                    value: building.stateName,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "District",
                    value: building.districtName,
                  ),
                  buildColumnTitleValue(
                    title: "City",
                    value: building.cityName,
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Village",
                    value:
                        building.villageName.isEmpty
                            ? "-"
                            : building.villageName,
                  ),
                  buildColumnTitleValue(
                    title: "Ward",
                    value: building.wardName,
                  ),
                ],
              ),
            ],
          ),
          // GARDEN INFORMATION
          sectionCard(
            title: 'Garden Information',
            textColor: AppColor.purple700,
            bgColor: AppColor.lightPurpleBg2,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Garden Structure",
                    value: building.isGarden ? "Yes" : "No",
                  ),
                  buildColumnTitleValue(
                    title: "Garden Area (SqFt)",
                    value: building.totalGardenAreaSqFt.addCommas(),
                  ),
                ],
              ),
            ],
          ),
          // RELIGIOUS INFORMATION
          sectionCard(
            title: 'Religious Information',
            textColor: Colors.blue,
            bgColor: Colors.blue.shade100.withValues(alpha: 0.5),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Religious Structure",
                    value: building.isReligiousStructure ? "Yes" : "No",
                  ),
                  buildColumnTitleValue(
                    title: "Structure Area (SqFt)",
                    value: building.totalReligiousStructureAreaSqFt.addCommas(),
                  ),
                ],
              ),
            ],
          ),
          // FSI/TDR INFORMATION
          sectionCard(
            title: 'FSI/TDR Information',
            textColor: AppColor.brown,
            bgColor: AppColor.lightYellow,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "FSI/TDR Utilization (SqFt)",
                    value: building.fSITDRUtilizationSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Property Age (Years)",
                    value: building.propertyAgeYears.addCommas(),
                  ),
                ],
              ),
            ],
          ),
          // LITIGATION INFORMATION
          sectionCard(
            title: 'Litigation Information',
            textColor: AppColor.darkGreen10,
            bgColor: AppColor.darkGreen10.withValues(alpha: 0.1),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Litigation",
                    value: building.isLitigation ? "Yes" : "No",
                  ),
                  buildColumnTitleValue(
                    title: "Litigation Remark",
                    value: building.litigationRemarks,
                  ),
                ],
              ),
            ],
          ),
          // ACTION DETAILS
          actionCardWidget(
            createdBy: building.createdBy,
            createdDate: building.createdDate,
            modifiedBy: building.modifiedBy,
            modifiedDate: building.modifiedDate,
          ),
        ],
      ),
    );
  }
}
