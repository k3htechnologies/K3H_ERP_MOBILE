import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/redevelopment.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewRedevelopmentScreen extends StatefulWidget {
  final int index;
  final RedevelopmentModel redevelopmentModel;
  const ViewRedevelopmentScreen({
    super.key,
    required this.index,
    required this.redevelopmentModel,
  });

  @override
  State<ViewRedevelopmentScreen> createState() =>
      _ViewRedevelopmentScreenState();
}

class _ViewRedevelopmentScreenState extends State<ViewRedevelopmentScreen> {
  late final Future<void> _delayFuture;
  late final PageController pageController;
  int currentIndex = 0;
  late final List<String> projectImages;
  @override
  void initState() {
    _delayFuture = Future.delayed(const Duration(seconds: 2));
    pageController = PageController();

    projectImages =
        (widget.redevelopmentModel.photoUrl)
            .split(',')
            .map((e) => e.trim())
            .where(
              (e) =>
                  e.isNotEmpty &&
                  (e.startsWith('http://') || e.startsWith('https://')),
            )
            .toList();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Redevelopment",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(
                    LucideIcons.building2,
                    color: AppColor.darkBlue,
                    size: 18,
                  ),
                  Text(
                    toTitleCase(widget.redevelopmentModel.buildingName),
                    style: AppTextStyle.ts14M(color: AppColor.grey),
                  ),
                ],
              ),
              verticalSpacing(),
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FutureBuilder(
                          future: _delayFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.grey),
                              );
                            }

                            return PageView.builder(
                              controller: pageController,
                              itemCount: projectImages.length,
                              onPageChanged: (index) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                if (projectImages.isEmpty) {
                                  return Container(
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: AppColor.grey30,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () {
                                    showFilePreviewDialog(
                                      context,
                                      title: "Building Photo",
                                      [projectImages[index]],
                                    );
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // IMAGE
                                      ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                          sigmaX: 0.8,
                                          sigmaY: 0.2,
                                        ),
                                        child: NetworkImageWidget(
                                          imageUrl: projectImages[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),

                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColor.grey10.withValues(
                                                alpha: 0.2,
                                              ),
                                              AppColor.grey30.withValues(
                                                alpha: 0.4,
                                              ),
                                              AppColor.black.withValues(
                                                alpha: 0.6,
                                              ),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${widget.redevelopmentModel.cityName}, ${widget.redevelopmentModel.stateName}",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          size: 28,
                          color:
                              currentIndex == 0
                                  ? AppColor.grey30
                                  : AppColor.black,
                        ),
                        onPressed:
                            currentIndex == 0
                                ? null
                                : () {
                                  pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                      ),
                      Text(
                        '${currentIndex + 1} / ${projectImages.length}',
                        style: AppTextStyle.ts12R(color: AppColor.black),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          size: 28,
                          color:
                              currentIndex == projectImages.length - 1
                                  ? AppColor.grey30
                                  : AppColor.black,
                        ),
                        onPressed:
                            currentIndex == projectImages.length - 1
                                ? null
                                : () {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Basic Details",
                icon: LucideIcons.building,
                iconColor: Color(0xff712AE2),
                iconContainerColor: Color(0xff712AE2).withValues(alpha: 0.10),
                children: [
                  buildColumnTitleValue(
                    title: "Plot / CTS / Survey / Subdivision Number",
                    value:
                        widget
                            .redevelopmentModel
                            .plotNumberCtsNumberSurveyNumberSubdivisionNumber,
                    removeExpanded: true,
                  ),
                  buildColumnTitleValue(
                    title: "State",
                    value: widget.redevelopmentModel.stateName,
                    removeExpanded: true,
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Location Details",
                icon: LucideIcons.mapPin,
                iconColor: Color(0xff712AE2),
                iconContainerColor: Color(0xff712AE2).withValues(alpha: 0.10),
                suffix: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final url =
                            widget.redevelopmentModel.identificationLocation;

                        if (url.isNotEmpty) {
                          final uri = Uri.parse(url);

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      child: Text(
                        "Google Location",
                        style: AppTextStyle.ts12M().copyWith(
                          color: AppColor.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Country",
                        value: widget.redevelopmentModel.countryName,
                      ),
                      buildColumnTitleValue(
                        title: "State",
                        value: widget.redevelopmentModel.stateName,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "District",
                        value: widget.redevelopmentModel.districtName,
                      ),
                      buildColumnTitleValue(
                        title: "City",
                        value: widget.redevelopmentModel.cityName,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Pin Code",
                        value: widget.redevelopmentModel.pinCode,
                      ),
                      buildColumnTitleValue(
                        title: "Ward Number",
                        value: widget.redevelopmentModel.wardNumberZone,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Latitude Longitude",
                        value: widget.redevelopmentModel.latitudeLongitude,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Existing Building Details",
                icon: LucideIcons.warehouse,
                iconColor: AppColor.primary,
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Type Of Land Tenure",
                        value: widget.redevelopmentModel.typeOfLandTenure,
                      ),
                      buildColumnTitleValue(
                        title: "Existing Building Type",
                        value: widget.redevelopmentModel.existingBuildingType,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Construction Type",
                        value: widget.redevelopmentModel.constructionType,
                      ),
                      buildColumnTitleValue(
                        title: "Year Of Original Construction",
                        value:
                            widget.redevelopmentModel.yearOfOriginalConstruction
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Plot Area (SqMt)",
                        value:
                            widget.redevelopmentModel.totalPlotAreaSqM
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Carpet Area (SqFt)",
                        value:
                            widget.redevelopmentModel.totalCarpetArea
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Total Build-Up Area (SqFt)",
                        value:
                            widget.redevelopmentModel.totalBuildUpArea
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Common Area (SqFt)",
                        value:
                            widget.redevelopmentModel.totalCommonArea
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Number of Existing Building / Wings",
                        value:
                            widget
                                .redevelopmentModel
                                .numberOfExistingBuildingsWings
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Number of Existing Floors",
                        value:
                            widget.redevelopmentModel.numberOfExistingFloors
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Number Of Floor Per Wings",
                        value:
                            widget.redevelopmentModel.numberOfFloorsPerWing
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Total Number of Existing Flats / Units",
                        value:
                            widget
                                .redevelopmentModel
                                .totalNumberExistingFlatsUnits
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Member In Favor (%)",
                        value:
                            widget.redevelopmentModel.percentageMemberInFavor
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Plot Under Litigation / Stay Order",
                        value:
                            widget.redevelopmentModel.plotUnderLitigationStay,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Lift Available",
                        value:
                            widget.redevelopmentModel.isLiftAvailable
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Fire Safety Provision Present",
                        value:
                            widget
                                .redevelopmentModel
                                .isFireSafetyProvisionPresent
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Conveyance Deed",
                        value:
                            widget.redevelopmentModel.isConveyanceDeed
                                .toString(),
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Plot Characteristics",
                icon: LucideIcons.ruler,
                iconColor: AppColor.warning,
                iconContainerColor: AppColor.warning.withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Plot Shape",
                        value: widget.redevelopmentModel.plotShape,
                      ),
                      buildColumnTitleValue(
                        title: "Depth Of The Plot",
                        value: widget.redevelopmentModel.plotDepth.toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Road Width",
                        value: widget.redevelopmentModel.roadWidth,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Contact Information",
                icon: LucideIcons.contactRound,
                iconColor: AppColor.darkGreen,
                iconContainerColor: Color(0xffECFDF5),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Name",
                        value: widget.redevelopmentModel.contactPersonName,
                      ),
                      buildColumnTitleValue(
                        title: "Mobile No",
                        value: widget.redevelopmentModel.contactPersonMobile,
                        customValueWidget: CustomClickToContactText(
                          type: ContactType.phone,
                          value: widget.redevelopmentModel.contactPersonMobile,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "E-Mail ID",
                        value: widget.redevelopmentModel.contactPersonEmail,
                        customValueWidget: CustomClickToContactText(
                          type: ContactType.email,
                          value: widget.redevelopmentModel.contactPersonEmail,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Additional Information",
                icon: LucideIcons.messageSquareText,
                iconColor: AppColor.black.withValues(alpha: 0.6),
                iconContainerColor: AppColor.grey.withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Remarks",
                        value: widget.redevelopmentModel.remarks,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Action Details",
                icon: LucideIcons.history,
                iconColor: AppColor.black.withValues(alpha: 0.6),
                iconContainerColor: AppColor.grey.withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Created By",
                        value: widget.redevelopmentModel.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(
                          widget.redevelopmentModel.createdDate,
                        ),
                      ),
                    ],
                  ),
                  if (widget.redevelopmentModel.modifiedBy.isNotEmpty &&
                      widget.redevelopmentModel.modifiedDate != null) ...{
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: widget.redevelopmentModel.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            widget.redevelopmentModel.modifiedDate,
                          ),
                        ),
                      ],
                    ),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
