import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/business_development/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BuildingDetailsView extends StatelessWidget {
  final bool canAction;
  final String buildingName;
  const BuildingDetailsView({
    super.key,
    required this.canAction,
    required this.buildingName,
  });
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Building Details",
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                  CustomButton(
                    text:
                        (state.buildingDetails != null &&
                                state.buildingDetails!.grossPlotAreaSqMt > 0)
                            ? "Update"
                            : "Add",
                    isDisable: !canAction,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.editBuildingDetails,
                        queryParameters: {
                          "buildingDetails": Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(state.buildingDetails!.toJson()),
                            ),
                          ),
                          "buildingName": Uri.encodeComponent(
                            EncryptionManager.encryptData(buildingName),
                          ),
                        },
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: 'Building Plot Area',
                titleTextColor: AppColor.primary,
                headerBackgroundColor: AppColor.lightBlue,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Gross Plot Area (SqMt)",
                        value:
                            state.buildingDetails?.grossPlotAreaSqMt
                                .addCommas(),
                      ),
                      buildColumnTitleValue(
                        title: "Physical Survey Area (SqMt)",
                        value:
                            state.buildingDetails?.plotAreaPhysicalSurveySqMt
                                .addCommas(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Old Approved Plan Area (SqMt)",
                        value:
                            state.buildingDetails?.plotAreaOldApprovedPlanSqMt
                                .addCommas(),
                      ),
                      buildColumnTitleValue(
                        title: "Conveyance Area (SqMt)",
                        value:
                            state.buildingDetails?.plotAreaConveyanceSqMt
                                .addCommas(),
                      ),
                    ],
                  ),
                  buildColumnTitleValue(
                    title: "PR Card Area(SqMt)",
                    value:
                        state.buildingDetails?.plotAreaPRCardSqMt.addCommas(),
                    removeExpanded: true,
                  ),
                ],
              ),
              SectionCard(
                title: 'Existing Details',
                titleTextColor: AppColor.primary,
                headerBackgroundColor: AppColor.lightBlue,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Carpet Area (SqFt)",
                        value:
                            state.buildingDetails?.totalCarpetAreaSqFt
                                .addCommas(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Residential Units",
                        value:
                            state.buildingDetails?.totalResidentialUnits
                                .addCommas(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Residential Carpet Area (SqFt)",
                        value:
                            state
                                .buildingDetails
                                ?.totalResidentialCarpetAreaSqFt
                                .addCommas(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Commercial Units",
                        value:
                            state.buildingDetails?.totalCommercialUnits
                                .addCommas(),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Commercial Carpet Area (SqFt)",
                        value:
                            state.buildingDetails?.totalCommercialCarpetAreaSqFt
                                .addCommas(),
                      ),
                      buildColumnTitleValue(
                        title: "Garage Carpet Area (SqFt)",
                        value:
                            state.buildingDetails?.garageCarpetAreaSqFt
                                .addCommas(),
                      ),
                    ],
                  ),
                  buildRowWrapper(
                    child: buildColumnTitleValue(
                      title: "Terrace Carpet Area (SqFt)",
                      value:
                          state.buildingDetails?.terraceCarpetAreaSqFt
                              .addCommas(),
                    ),
                  ),
                ],
              ),
              SectionCard(
                title: 'Building Key Contact Details',
                titleTextColor: AppColor.primary,
                headerBackgroundColor: AppColor.lightBlue,
                children: [
                  ...(state.buildingDetails?.buildingKeyContactDetailsData ??
                          [])
                      .map((contact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.contactType.isEmpty
                                  ? "-"
                                  : contact.contactType,
                              style: AppTextStyle.ts14M(),
                            ),
                            verticalSpacing(height: 2.h),
                            buildRowTitleValue(
                              title: "Contact Name",
                              value:
                                  contact.contactName.isEmpty
                                      ? "-"
                                      : contact.contactName,
                              singleLine: false,
                            ),
                            buildRowTitleValue(
                              title: "Mobile Number",
                              value:
                                  contact.mobileNumber.isEmpty
                                      ? "-"
                                      : contact.mobileNumber,
                              singleLine: false,
                              customValueWidget: CustomClickToContactText(
                                countryCode: "+91",
                                value: contact.mobileNumber,
                              ),
                            ),
                            buildRowTitleValue(
                              title: "E-Mail ID",
                              value:
                                  contact.emailId.isEmpty
                                      ? "-"
                                      : contact.emailId,
                              singleLine: false,
                              customValueWidget: CustomClickToContactText(
                                value: contact.emailId,
                                type: ContactType.email,
                              ),
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
