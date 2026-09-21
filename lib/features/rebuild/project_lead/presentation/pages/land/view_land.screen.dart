import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/model/land.model.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewLandScreen extends StatefulWidget {
  final int index;
  final LandModel landModel;
  const ViewLandScreen({
    super.key,
    required this.index,
    required this.landModel,
  });

  @override
  State<ViewLandScreen> createState() => _ViewLandScreenState();
}

class _ViewLandScreenState extends State<ViewLandScreen> {
  late final Future<void> _delayFuture;
  late final PageController pageController;
  int currentIndex = 0;
  late final List<String> projectImages;
  @override
  void initState() {
    _delayFuture = Future.delayed(const Duration(seconds: 2));
    pageController = PageController();

    projectImages =
        (widget.landModel.photoUrl)
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
        screenTitle: "Land",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.landModel.landOwnerName,
                  style: AppTextStyle.ts16SB(color: AppColor.primary),
                ),
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
                                      title: widget.landModel.landOwnerName,
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
                              "${widget.landModel.cityName}, ${widget.landModel.stateName}",
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
                title: "Location Details",
                icon: LucideIcons.mapPin,
                iconColor: Color(0xff712AE2),
                iconContainerColor: Color(0xff712AE2).withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Country",
                        value: widget.landModel.countryName,
                      ),
                      buildColumnTitleValue(
                        title: "State",
                        value: widget.landModel.stateName,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "District",
                        value: widget.landModel.districtName,
                      ),
                      buildColumnTitleValue(
                        title: "City",
                        value: widget.landModel.cityName,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Pin Code",
                        value: widget.landModel.pinCode,
                      ),
                      buildColumnTitleValue(
                        title: "Ward Number",
                        value: widget.landModel.wardNumberZone,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Latitude Longitude",
                        value: widget.landModel.latitudeLongitude,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final url = widget.landModel.identificationLocation;

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
                        title: "Total Plot Area (SqMt)",
                        value: widget.landModel.totalPlotAreaSqM.toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Plot Shape",
                        value: widget.landModel.plotShape,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Depth Of The Plot",
                        value: widget.landModel.plotDepth.toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Road Width",
                        value: widget.landModel.roadWidth,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Soil Type",
                        value: widget.landModel.soilType,
                      ),
                      buildColumnTitleValue(
                        title: "Existing Ground Conditions",
                        value: widget.landModel.existingGroundCondition,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Surrounding Land Use",
                        value: widget.landModel.surroundingLandUse,
                      ),
                      buildColumnTitleValue(
                        title: "Total Number Of Trees on Site",
                        value:
                            widget.landModel.totalNumberOfTreesonSite
                                .toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Available of Access Road",
                        value: widget.landModel.accessRoadAvailable,
                      ),
                      buildColumnTitleValue(
                        title: "Electricity Connection Nearby",
                        value: widget.landModel.electricityConnectionNearby,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "FSI Permissible",
                        value: widget.landModel.fsiPermissible.toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Type of Water Supply Available",
                        value: widget.landModel.waterSupplyAvailable,
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Legal & Ownership Details",
                icon: LucideIcons.badgeCheck,
                iconColor: AppColor.primary,
                iconContainerColor: AppColor.primary.withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Type Of Land Tenure",
                        value: widget.landModel.typeOfLandTenureType,
                      ),
                      buildColumnTitleValue(
                        title: "Land Ownership Type",
                        value: widget.landModel.landOwnershipType,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Any Power Of Attorney Involved",
                        value: widget.landModel.anyPowerofAttorneyInvolved,
                      ),
                      buildColumnTitleValue(
                        title: "Fencing / Boundary Wall Present",
                        value: widget.landModel.fencingBoundaryWallPresent,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Land Converted To Non-Agricultural",
                        value: widget.landModel.landConvertedToNonAgricultural,
                      ),
                      buildColumnTitleValue(
                        title: "Plot Under Litigation / Stay Order",
                        value: widget.landModel.underLitigationOrStayOrder,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "7 / 12",
                        value: widget.landModel.is712Available ? "Yes" : "No",
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final url = widget.landModel.identificationLocation;

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
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Distance From Key Landmarks",
                icon: LucideIcons.route,
                iconColor: Color(0xff712AE2),
                iconContainerColor: Color(0xff712AE2).withValues(alpha: 0.10),
                children: [
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Town (KM)",
                        value:
                            widget.landModel.distanceFromNearestTownKm
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Highway (KM)",
                        value:
                            widget.landModel.distanceFromHighwayKm.toString(),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "Railway Station (KM)",
                        value:
                            widget.landModel.distanceFromRailwayStationKm
                                .toString(),
                      ),
                      buildColumnTitleValue(
                        title: "Airport (KM)",
                        value:
                            widget.landModel.distanceFromAirportKm.toString(),
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpacing(),
              SectionCard(
                title: "Land Contact Information",
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
                        value: widget.landModel.contactPersonName,
                      ),
                      buildColumnTitleValue(
                        title: "Mobile No",
                        value: widget.landModel.contactPersonMobile,
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildColumnTitleValue(
                        title: "E-Mail ID",
                        value: widget.landModel.contactPersonEmail,
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
                        value: widget.landModel.remark,
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
                        value: widget.landModel.createdBy,
                      ),
                      buildColumnTitleValue(
                        title: "Created Date",
                        value: formatDate(widget.landModel.createdDate),
                      ),
                    ],
                  ),
                  if (widget.landModel.modifiedBy.isNotEmpty &&
                      widget.landModel.modifiedDate != null) ...{
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: widget.landModel.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(widget.landModel.modifiedDate),
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
