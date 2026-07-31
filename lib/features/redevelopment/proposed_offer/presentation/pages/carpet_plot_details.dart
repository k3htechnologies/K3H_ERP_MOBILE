import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CarpetPlotDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  const CarpetPlotDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<CarpetPlotDetails> createState() => _CarpetPlotDetailsState();
}

class _CarpetPlotDetailsState extends State<CarpetPlotDetails> {
  late ProposedOfferCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _cubit.pullCarpetPlotDetails(
      context: context,
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
          builder: (context, state) {
            if ((state.isLoading ?? true) && state.carpetPlotDetails == null) {
              return Center(child: loader());
            }
            final carpetPlotDetails = state.carpetPlotDetails!;
            return Column(
              children: [
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
                          value: carpetPlotDetails.grossPlotAreaSqFt.toString(),
                        ),
                        buildColumnTitleValue(
                          title: "PR Card Area(Sq. ft)",
                          value:
                              carpetPlotDetails.plotAreaPRCardSqFt.toString(),
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
                              carpetPlotDetails.plotAreaOldApprovedPlanSqFt
                                  .toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Conveyance Area (Sq. ft)",
                          value:
                              carpetPlotDetails.plotAreaConveyanceSqFt
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
                              carpetPlotDetails.plotAreaPhysicalSurveySqFt
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
                              carpetPlotDetails.totalBuiltUpAreaSqFt.toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Total Residential Units",
                          value:
                              carpetPlotDetails.totalResidentialUnits
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
                              carpetPlotDetails.totalResidentialCarpetAreaSqFt
                                  .toString(),
                        ),
                        buildColumnTitleValue(
                          title: "Total Commercial Units",
                          value:
                              carpetPlotDetails.totalCommercialUnits.toString(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Commercial Carpet Area (Sq. ft)",
                          value:
                              carpetPlotDetails.totalCommercialCarpetAreaSqFt
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
                    ...carpetPlotDetails.buildingKeyContactDetailsData.map((
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
            );
          },
        ),
      ),
    );
  }
}
