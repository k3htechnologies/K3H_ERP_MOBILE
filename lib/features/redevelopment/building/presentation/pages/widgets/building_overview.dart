import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BuildingOverview extends StatelessWidget {
  final RedevelopmentBuildingModel building;
  const BuildingOverview({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          // BUILDING DETAILS
          buildingViewSectionCard(
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
                    value: building.ctsNumber,
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
          buildingViewSectionCard(
            title: 'Property Information',
            textColor: AppColor.orange,
            bgColor: AppColor.lightOrangeBg.withValues(alpha: 0.5),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Total Plot Area(Sq. ft)",
                    value: building.totalPlotAreaSqFt.toString(),
                  ),
                  buildColumnTitleValue(
                    title: "Total Floors",
                    value: building.numberOfFloors.toString(),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Utilized Unit Area(Sq. ft)",
                    value: building.totalUnitsAreaUtilizedSqFt.toString(),
                  ),
                  buildColumnTitleValue(
                    title: "Total Units",
                    value: building.totalNumberOfUnits.toString(),
                  ),
                ],
              ),
            ],
          ),

          // LOCATION DETAILS
          buildingViewSectionCard(
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
                ],
              ),
            ],
          ),
          // GARDEN INFORMATION
          buildingViewSectionCard(
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
                    title: "Garden Area(Sq. ft)",
                    value: building.totalGardenAreaSqFt.toString(),
                  ),
                ],
              ),
            ],
          ),
          // RELIGIOUS INFORMATION
          buildingViewSectionCard(
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
                    title: "Structure Area(Sq. ft)",
                    value: building.totalReligiousStructureAreaSqFt.toString(),
                  ),
                ],
              ),
            ],
          ),
          // FSI/TDR INFORMATION
          buildingViewSectionCard(
            title: 'FSI/TDR Information',
            textColor: AppColor.brown,
            bgColor: AppColor.lightYellow,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "FSI/TDR Utilization(Sq. ft)",
                    value: building.fsiTdrUtilizationSqFt.toString(),
                  ),
                  buildColumnTitleValue(
                    title: "Property Age (Years)",
                    value: building.propertyAgeYears.toString(),
                  ),
                ],
              ),
            ],
          ),
          // LITIGATION INFORMATION
          buildingViewSectionCard(
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
          buildingViewSectionCard(
            title: 'Action Details',
            textColor: AppColor.black,
            bgColor: AppColor.grey20,
            children: [
              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Created By",
                    value: building.createdBy,
                  ),
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(building.createdDate),
                  ),
                ],
              ),

              Row(
                children: [
                  buildColumnTitleValue(
                    title: "Modified By",
                    value:
                        (building.modifiedBy.isNotEmpty)
                            ? building.modifiedBy
                            : "-",
                  ),
                  buildColumnTitleValue(
                    title: "Modified Date",
                    value:
                        (building.modifiedDate == null ||
                                building.modifiedDate.toString().trim().isEmpty)
                            ? "-"
                            : formatDate(building.modifiedDate),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildingViewSectionCard({
  required String title,
  required Color? textColor,
  required Color? bgColor,
  required List<Widget> children,
}) {
  return Container(
    decoration: commonCardDecoration(),
    margin: EdgeInsets.only(bottom: 16.h),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: bgColor ?? const Color(0xFFDCE8F6),
          child: Text(
            title,
            style: AppTextStyle.ts14SB(
              color: textColor ?? const Color(0xFF1F5CC4),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder:
                (_, __) => Divider(height: 20.h, color: AppColor.lightBlue),
            itemBuilder: (context, index) => children[index],
          ),
        ),
      ],
    ),
  );
}

/*

Widget buildingOverviewSectionCard({
  required String title,
  required Color? textColor,
  required Color? bgColor,
  required List<Widget> children,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFD0D7E2)),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFDCE8F6), // Light blue header
            border: Border(bottom: BorderSide(color: Color(0xFFD0D7E2))),
          ),
          child: Text(
            title,
            style: AppTextStyle.ts14SB(
              color: const Color(0xFF1F5CC4), // Blue text
            ),
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    ),
  );
}
*/
