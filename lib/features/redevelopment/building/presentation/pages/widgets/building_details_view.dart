import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BuildingDetailsView extends StatelessWidget {
  final bool canAction;
  const BuildingDetailsView({super.key, required this.canAction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.buildingDetails == null) {
          return Center(child: loader());
        }
        if (state.buildingDetails == null) {
          return Center(child: noDataWidget());
        }
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
                    text: "Update",
                    isDisable: !canAction,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.editBuildingDetails,
                        queryParameters: {
                          "buildingDetail": Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(state.buildingDetails!.toJson()),
                            ),
                          ),
                        },
                      );
                    },
                  ),
                ],
              ),
              verticalSpacing(),
              // BUILDING PLOT AREA
              sectionCard(
                title: 'Building Plot Area',
                textColor: AppColor.primary,
                bgColor: AppColor.lightBlue,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Gross Plot Area (Sq. ft)",
                        value:
                            state.buildingDetails!.grossPlotAreaSqFt.toString(),
                      ),
                      buildColumnTitleValue(
                        title: "PR Card Area(Sq. ft)",
                        value:
                            state.buildingDetails!.plotAreaPRCardSqFt
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Old Approved Plan Area (Sq. ft)",
                        value:
                            state.buildingDetails!.plotAreaOldApprovedPlanSqFt
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Conveyance Area (Sq. ft)",
                        value:
                            state.buildingDetails!.plotAreaConveyanceSqFt
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Physical Survey Area (Sq. ft)",
                        value:
                            state.buildingDetails!.plotAreaPhysicalSurveySqFt
                                .toString(),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
              // BUILDING CONSTRUCTION DETAILS
              sectionCard(
                title: 'Building Construction Details',
                textColor: AppColor.primary,
                bgColor: AppColor.lightBlue,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Build Up Area (Sq. ft)",
                        value:
                            state.buildingDetails!.totalBuiltUpAreaSqFt
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Residential Units",
                        value:
                            state.buildingDetails!.totalResidentialUnits
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Residential Carpet Area (Sq. ft)",
                        value:
                            state
                                .buildingDetails!
                                .totalResidentialCarpetAreaSqFt
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Commercial Units",
                        value:
                            state.buildingDetails!.totalCommercialUnits
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Commercial Carpet Area (Sq. ft)",
                        value:
                            state.buildingDetails!.totalCommercialCarpetAreaSqFt
                                .toString(),
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
              // BUILDING KEY CONTACT DETAILS
              sectionCard(
                title: 'Building Key Contact Details',
                textColor: AppColor.primary,
                bgColor: AppColor.lightBlue,
                children: [
                  ...state.buildingDetails!.buildingKeyContactDetailsData.map((
                    contact,
                  ) {
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
                        ),

                        buildRowTitleValue(
                          title: "Email Id",
                          value:
                              contact.emailId.isEmpty ? "-" : contact.emailId,
                          singleLine: false,
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
