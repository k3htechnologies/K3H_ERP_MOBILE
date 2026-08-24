import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_extension_helpers.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.pullCarpetPlotDetails(
        context: context,
        projectId: widget.projectId,
        buildingId: widget.buildingId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<ProposedOfferCubit, ProposedOfferState>(
          builder: (context, state) {
            final carpetPlotDetails = state.carpetPlotDetails;
            return Column(
              children: [
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
                          title: "Gross Plot Area (SqFt)",
                          value:
                              carpetPlotDetails?.grossPlotAreaSqFt.addCommas(),
                        ),
                        buildColumnTitleValue(
                          title: "PR Card Area(SqFt)",
                          value:
                              carpetPlotDetails?.plotAreaPRCardSqFt.addCommas(),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Old Approved Plan Area (SqFt)",
                          value:
                              carpetPlotDetails?.plotAreaOldApprovedPlanSqFt
                                  .addCommas(),
                        ),
                        buildColumnTitleValue(
                          title: "Conveyance Area (SqFt)",
                          value:
                              carpetPlotDetails?.plotAreaConveyanceSqFt
                                  .addCommas(),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Physical Survey Area (SqFt)",
                          value:
                              carpetPlotDetails?.plotAreaPhysicalSurveySqFt
                                  .addCommas(),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
                SectionCard(
                  title: 'Building Construction Details',
                  headerBackgroundColor: AppColor.lightBlue,
                  titleTextColor: AppColor.primary,
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Total Carpet Area (SqFt)",
                          value:
                              carpetPlotDetails?.totalCarpetAreaSqFt
                                  .addCommas(),
                        ),
                        buildColumnTitleValue(
                          title: "Total Residential Units",
                          value:
                              carpetPlotDetails?.totalResidentialUnits
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
                              carpetPlotDetails?.totalResidentialCarpetAreaSqFt
                                  .addCommas(),
                        ),
                        buildColumnTitleValue(
                          title: "Total Commercial Units",
                          value:
                              carpetPlotDetails?.totalCommercialUnits
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
                              carpetPlotDetails?.totalCommercialCarpetAreaSqFt
                                  .addCommas(),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
                SectionCard(
                  title: 'Building Key Contact Details',
                  titleTextColor: AppColor.primary,
                  headerBackgroundColor: AppColor.lightBlue,
                  children: [
                    ...(carpetPlotDetails?.buildingKeyContactDetailsData ?? [])
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
                                value: contact.contactName,
                                singleLine: false,
                              ),
                              buildRowTitleValue(
                                title: "Mobile Number",
                                value: contact.mobileNumber,
                                singleLine: false,
                                customValueWidget: CustomClickToContactText(
                                  countryCode: "+91",
                                  value: contact.mobileNumber,
                                  type: ContactType.phone,
                                ),
                              ),
                              buildRowTitleValue(
                                title: "Email Id",
                                value: contact.emailId,
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
            );
          },
        ),
      ),
    );
  }
}
