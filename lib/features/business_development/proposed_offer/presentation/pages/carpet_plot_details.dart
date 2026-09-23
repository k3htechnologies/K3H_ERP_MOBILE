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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Carpet / Plot Area',
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            verticalSpacing(),
            Expanded(
              child: SingleChildScrollView(
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
                                  title: "Gross Plot Area (SqMt)",
                                  value:
                                      carpetPlotDetails?.grossPlotAreaSqMt
                                          .addCommas(),
                                ),
                                buildColumnTitleValue(
                                  title: "Physical Survey Area (SqMt)",
                                  value:
                                      carpetPlotDetails
                                          ?.plotAreaPhysicalSurveySqMt
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
                                      carpetPlotDetails
                                          ?.plotAreaOldApprovedPlanSqMt
                                          .addCommas(),
                                ),
                                buildColumnTitleValue(
                                  title: "Conveyance Area (SqMt)",
                                  value:
                                      carpetPlotDetails?.plotAreaConveyanceSqMt
                                          .addCommas(),
                                ),
                              ],
                            ),
                            buildColumnTitleValue(
                              title: "PR Card Area(SqMt)",
                              value:
                                  carpetPlotDetails?.plotAreaPRCardSqMt
                                      .addCommas(),
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
                                      carpetPlotDetails
                                          ?.totalResidentialCarpetAreaSqFt
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
                                      carpetPlotDetails
                                          ?.totalCommercialCarpetAreaSqFt
                                          .addCommas(),
                                ),
                                buildColumnTitleValue(
                                  title: "Garage Carpet Area (SqFt)",
                                  value:
                                      carpetPlotDetails?.garageCarpetAreaSqFt
                                          .addCommas(),
                                ),
                              ],
                            ),
                            buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "Terrace Carpet Area (SqFt)",
                                value:
                                    carpetPlotDetails?.terraceCarpetAreaSqFt
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
                            ...(carpetPlotDetails
                                        ?.buildingKeyContactDetailsData ??
                                    [])
                                .map((contact) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        customValueWidget:
                                            CustomClickToContactText(
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
                                        customValueWidget:
                                            CustomClickToContactText(
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
            ),
          ],
        ),
      ),
    );
  }
}
