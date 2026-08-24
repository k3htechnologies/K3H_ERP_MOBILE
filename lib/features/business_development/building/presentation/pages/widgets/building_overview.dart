import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/business_development/building/data/model/building.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';

class BuildingOverview extends StatelessWidget {
  final BusinessDevelopmentBuildingModel building;
  const BuildingOverview({super.key, required this.building});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: 'Building Details',
            titleTextColor: AppColor.primary,
            headerBackgroundColor: AppColor.lightBlue,
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
          if (building.category == 'Tender') ...[
            SectionCard(
              title: 'Tender Amount Details',
              titleTextColor: AppColor.purple700,
              headerBackgroundColor: AppColor.lightPurpleBg2,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Amount",
                      value: building.tenderAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Payment Mode",
                      value: building.tenderAmountPaymentMode,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "Purchase Start Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        building.tenderPurchaseStartDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Purchase End Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        building.tenderPurchaseEndDate,
                      ),
                    ),
                  ],
                ),
                buildColumnTitleValue(
                  title: "Transaction / Cheque / DD No",
                  value: building.tenderAmountChequeNumber,
                  removeExpanded: true,
                  customValueWidget:
                      (building.tenderAmountChequeNumber.isEmpty)
                          ? null
                          : Row(
                            children: [
                              Text(
                                building.tenderAmountChequeNumber,
                                style: AppTextStyle.ts14M(),
                              ),
                              CustomIconButton(
                                onPressed: () {
                                  showFilePreviewDialog(
                                    title: "Transaction / Cheque / DD No",
                                    context,
                                    building.tenderAmountChequeNumberURL.split(
                                      ",",
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 16,
                                  color: AppColor.primary,
                                ),
                                backgroundColor: AppColor.white,
                              ),
                            ],
                          ),
                ),
                buildColumnTitleValue(
                  title: "Payorder Remark",
                  value: building.tenderAmountPayorderRemark,
                  removeExpanded: true,
                ),
              ],
            ),
            SectionCard(
              title: 'Tender EMD Details',
              titleTextColor: AppColor.red,
              headerBackgroundColor: AppColor.lightRed.withValues(alpha: 0.5),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    buildColumnTitleValue(
                      title: "EMD Amount",
                      value: building.tenderEMDAmount.toIndianCurrency(),
                    ),
                    buildColumnTitleValue(
                      title: "Submission Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        building.tenderSubmissionDate,
                      ),
                    ),
                  ],
                ),
                buildColumnTitleValue(
                  title: "Payment Mode",
                  value: building.tenderEMDPaymentMode,
                  removeExpanded: true,
                ),
                buildColumnTitleValue(
                  title: "Transaction / Cheque / DD No",
                  value: building.tenderEMDChequeNumberURL,
                  removeExpanded: true,
                  customValueWidget:
                      (building.tenderEMDChequeNumberURL.isEmpty)
                          ? null
                          : Row(
                            children: [
                              Text(
                                building.tenderEMDChequeNumber,
                                style: AppTextStyle.ts14M(),
                              ),
                              CustomIconButton(
                                onPressed: () {
                                  showFilePreviewDialog(
                                    title: "Transaction / Cheque / DD No",
                                    context,
                                    building.tenderEMDChequeNumberURL.split(
                                      ",",
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 16,
                                  color: AppColor.primary,
                                ),
                                backgroundColor: AppColor.white,
                              ),
                            ],
                          ),
                ),
                buildColumnTitleValue(
                  title: "Payorder Remark",
                  value: building.tenderEMDPayorderRemark,
                  removeExpanded: true,
                ),
              ],
            ),
          ],
          SectionCard(
            title: 'Property Information',
            titleTextColor: AppColor.orange,
            headerBackgroundColor: AppColor.lightOrangeBg.withValues(
              alpha: 0.5,
            ),
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
                    title: "Utilized Unit Area (SqFt)",
                    value: building.totalUnitsAreaUtilizedSqFt.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Total Units",
                    value: building.totalNumberOfUnits.addCommas(),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  buildColumnTitleValue(
                    title: "Number Of Floors",
                    value: building.numberOfFloors.addCommas(),
                  ),
                  buildColumnTitleValue(
                    title: "Number Of Wings",
                    value: building.numberOfWings.addCommas(),
                  ),
                ],
              ),
            ],
          ),
          SectionCard(
            title: 'Location Details',
            titleTextColor: AppColor.darkBlue29,
            headerBackgroundColor: AppColor.darkBlue29.withValues(alpha: 0.1),
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
          SectionCard(
            title: 'FSI/TDR Information',
            titleTextColor: AppColor.brown,
            headerBackgroundColor: AppColor.lightYellow,
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
          SectionCard(
            title: 'Garden Information',
            titleTextColor: AppColor.purple700,
            headerBackgroundColor: AppColor.lightPurpleBg2,
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
          SectionCard(
            title: 'Religious Information',
            titleTextColor: Colors.blue,
            headerBackgroundColor: Colors.blue.shade100.withValues(alpha: 0.5),
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
          SectionCard(
            title: 'Litigation',
            titleTextColor: AppColor.darkGreen10,
            headerBackgroundColor: AppColor.darkGreen10.withValues(alpha: 0.1),
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
                    value: building.createdBy,
                  ),
                  buildColumnTitleValue(
                    title: "Created Date",
                    value: formatDate(building.createdDate),
                  ),
                ],
              ),
              Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildColumnTitleValue(
                    title: "Modified By",
                    value: building.modifiedBy,
                  ),
                  buildColumnTitleValue(
                    title: "Modified Date",
                    value: formatDate(building.modifiedDate),
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
