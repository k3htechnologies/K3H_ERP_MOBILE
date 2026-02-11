import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildingViewScreen extends StatefulWidget {
  final RedevelopmentBuildingModel building;

  const BuildingViewScreen({super.key, required this.building});

  @override
  State<BuildingViewScreen> createState() => _BuildingViewScreenState();
}

class _BuildingViewScreenState extends State<BuildingViewScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late BuildingCubit _buildingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TAB CONTROLLER
  late TabController _tabController;

  // PROJECT
  late ProjectModel _project;

  final ValueNotifier<Set<int>> _expandedDocumentIds = ValueNotifier<Set<int>>(
    {},
  );
  final ValueNotifier<Map<int, List<BuildingDocumentModel>>> _childDocuments =
      ValueNotifier<Map<int, List<BuildingDocumentModel>>>({});
  final ValueNotifier<Map<int, bool>> _loadingChildDocuments =
      ValueNotifier<Map<int, bool>>({});

  // TEXT EDITING CONTROLLER
  late TextEditingController _newDocumentTitleController;

  @override
  void initState() {
    super.initState();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _routeAuthorizationModel = AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _newDocumentTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expandedDocumentIds.dispose();
    _childDocuments.dispose();
    _loadingChildDocuments.dispose();
    _newDocumentTitleController.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _buildingCubit.onTabChanged(
        _tabController.index,
        context,
        _project.projectId,
        widget.building.buildingId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building",
        authorization: _routeAuthorizationModel,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Details'),
                      Tab(text: 'Document'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildDetailsTab(),
                  _buildDocumentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(),
          // BUILDING DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Building Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Building Name",
                      value: widget.building.buildingName,
                    ),
                    buildColumnTitleValue(
                      title: "CTS Number",
                      value: widget.building.ctsNumber,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Road Width",
                      value: widget.building.roadWidth,
                    ),
                    buildColumnTitleValue(
                      title: "Land Ownership",
                      value: widget.building.landOwnershipType,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Google Location",
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                          ),
                          verticalSpacing(height: 4),
                          GestureDetector(
                            onTap: () async {
                              final url = widget.building.googleLocation;

                              if (url.isEmpty) return;

                              final uri = Uri.parse(url);

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                if (mounted) {
                                  showErrorMessage(
                                    context,
                                    "Error",
                                    "Could not open location",
                                  );
                                }
                              }
                            },
                            child: Text(
                              widget.building.googleLocation.isEmpty
                                  ? "-"
                                  : widget.building.googleLocation,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PROPERTY INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Property Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Total Plot Area(Sq. ft)",
                      value: widget.building.totalPlotAreaSqFt.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Total Floors",
                      value: widget.building.numberOfFloors.toString(),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Utilized Unit Area(Sq. ft)",
                      value:
                          widget.building.totalUnitsAreaUtilizedSqFt.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Total Units",
                      value: widget.building.totalNumberOfUnits.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LOCATION DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Location Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Country",
                      value: widget.building.countryName,
                    ),
                    buildColumnTitleValue(
                      title: "State",
                      value: widget.building.stateName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "District",
                      value: widget.building.districtName,
                    ),
                    buildColumnTitleValue(
                      title: "City",
                      value: widget.building.cityName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Village",
                      value:
                          widget.building.villageName.isEmpty
                              ? "-"
                              : widget.building.villageName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // GARDEN INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Garden Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Garden Structure",
                      value: widget.building.isGarden ? "Yes" : "No",
                    ),
                    buildColumnTitleValue(
                      title: "Garden Area(Sq. ft)",
                      value: widget.building.totalGardenAreaSqFt.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // RELIGIOUS INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Religious Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Religious Structure",
                      value:
                          widget.building.isReligiousStructure ? "Yes" : "No",
                    ),
                    buildColumnTitleValue(
                      title: "Structure Area(Sq. ft)",
                      value:
                          widget.building.totalReligiousStructureAreaSqFt
                              .toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // FSI/TDR INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("FSI/TDR Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "FSI/TDR Utilization(Sq. ft)",
                      value: widget.building.fsiTdrUtilizationSqFt.toString(),
                    ),
                    buildColumnTitleValue(
                      title: "Property Age (Years)",
                      value: widget.building.propertyAgeYears.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // LITIGATION INFORMATION
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Litigation Information", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Litigation",
                      value: widget.building.isLitigation ? "Yes" : "No",
                    ),
                    buildColumnTitleValue(
                      title: "Litigation Remark",
                      value: widget.building.litigationRemarks,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ACTION DETAILS
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: widget.building.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.building.createdDate,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value:
                          widget.building.modifiedBy.isEmpty
                              ? "-"
                              : widget.building.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value:
                          widget.building.modifiedDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.building.modifiedDate!,
                              )
                              : "-",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // DETAILS
  Widget _buildDetailsTab() {
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: "Update",
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
              Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Building Plot Area", style: AppTextStyle.ts16SB()),
                    verticalSpacing(height: 15),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Gross Plot Area (Sq. ft)",
                          value:
                              state.buildingDetails!.grossPlotAreaSqFt
                                  .toString(),
                        ),
                        buildColumnTitleValue(
                          title: "PR Card Area(Sq. ft)",
                          value:
                              state.buildingDetails!.plotAreaPRCardSqFt
                                  .toString(),
                        ),
                      ],
                    ),
                    verticalSpacing(),
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
                    verticalSpacing(),
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
              ),
              // BUILDING CONSTRUCTION DETAILS
              Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Building Construction Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    verticalSpacing(height: 15),
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
                    verticalSpacing(),
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
                    verticalSpacing(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Commercial Carpet Area (Sq. ft)",
                          value:
                              state
                                  .buildingDetails!
                                  .totalCommercialCarpetAreaSqFt
                                  .toString(),
                        ),
                        Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              // BUILDING KEY CONTACT DETAILS
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Building Key Contact Details",
                      style: AppTextStyle.ts16SB(),
                    ),
                    verticalSpacing(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          state
                              .buildingDetails!
                              .buildingKeyContactDetailsData
                              .length,
                      itemBuilder: (_, index) {
                        final contact =
                            state
                                .buildingDetails!
                                .buildingKeyContactDetailsData[index];
                        return Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColor.white,
                            border: Border.all(color: AppColor.lightBlue),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Contact Type",
                                    value:
                                        contact.contactType.isEmpty
                                            ? "-"
                                            : contact.contactType,
                                  ),
                                  buildColumnTitleValue(
                                    title: "Contact Name",
                                    value:
                                        contact.contactName.isEmpty
                                            ? "-"
                                            : contact.contactName,
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildColumnTitleValue(
                                    title: "Mobile Number",
                                    value:
                                        contact.mobileNumber.isEmpty
                                            ? "-"
                                            : contact.mobileNumber,
                                  ),
                                  buildColumnTitleValue(
                                    title: "Email Id",
                                    value:
                                        contact.emailId.isEmpty
                                            ? "-"
                                            : contact.emailId,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // DOCUMENT
  Widget _buildDocumentTab() {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.buildingDocumentList.isEmpty) {
          return Center(child: loader());
        }
        if (state.buildingDocumentList.isEmpty) {
          return Center(child: noDataWidget());
        }

        final parentDocuments = state.buildingDocumentList;

        final filteredDocuments = parentDocuments
            .where((e) => (e.uploadedBuildingDocumentCount) > 0)
            .toList();

        if (filteredDocuments.isEmpty) {
          return Center(child: noDataWidget());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            verticalSpacing(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 160,
                child: CustomButton(
                  text: "Add/Update",
                  onPressed: () async {
                    await goRouter.pushNamed(
                      AppRoutes.addUpdateBuildingDoc,
                      queryParameters: {
                        "building": Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(widget.building.toJson()),
                          ),
                        ),
                      },
                    );

                    if (!context.mounted) return;
                    _buildingCubit.getBuildingDocumentList(
                      context,
                      _project.projectId,
                      widget.building.buildingId,
                      1,
                      100,
                      null,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];

                  return ValueListenableBuilder<Set<int>>(
                    valueListenable: _expandedDocumentIds,
                    builder: (context, expandedSet, _) {
                      final isExpanded = expandedSet.contains(
                        doc.buildingDocumentId,
                      );
                      final childDocs =
                          _childDocuments.value[doc.buildingDocumentId] ?? [];
                      final isLoadingChildren =
                          _loadingChildDocuments.value[doc
                              .buildingDocumentId] ??
                          false;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: commonCardDecoration(),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                final currentExpanded = Set<int>.from(
                                  _expandedDocumentIds.value,
                                );

                                if (isExpanded) {
                                  // Collapse
                                  currentExpanded.remove(
                                    doc.buildingDocumentId,
                                  );
                                  _expandedDocumentIds.value = currentExpanded;
                                } else {
                                  // Expand - call API if not already loaded
                                  currentExpanded.add(doc.buildingDocumentId);
                                  _expandedDocumentIds.value = currentExpanded;

                                  if (!_childDocuments.value.containsKey(
                                    doc.buildingDocumentId,
                                  )) {
                                    // Set loading true
                                    final loadingMap = Map<int, bool>.from(
                                      _loadingChildDocuments.value,
                                    );
                                    loadingMap[doc.buildingDocumentId] = true;
                                    _loadingChildDocuments.value = loadingMap;

                                    _buildingCubit
                                        .getBuildingChildDocuments(
                                          context,
                                          _project.projectId,
                                          widget.building.buildingId,
                                          doc.buildingDocumentId,
                                        )
                                        .then((children) {
                                          if (!mounted) return;

                                          // Update children map
                                          final childrenMap = Map<
                                            int,
                                            List<BuildingDocumentModel>
                                          >.from(_childDocuments.value);
                                          childrenMap[doc.buildingDocumentId] =
                                              List<
                                                BuildingDocumentModel
                                              >.from(children);
                                          _childDocuments.value = childrenMap;

                                          // Set loading false
                                          final loadingMapDone =
                                              Map<int, bool>.from(
                                                _loadingChildDocuments.value,
                                              );
                                          loadingMapDone[doc
                                                  .buildingDocumentId] =
                                              false;
                                          _loadingChildDocuments.value =
                                              loadingMapDone;

                                          _expandedDocumentIds.value =
                                              Set<int>.from(
                                                _expandedDocumentIds.value,
                                              );
                                        });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doc.documentName,
                                        style: AppTextStyle.ts14SB(),
                                      ),
                                    ),
                                    Row(
                                      spacing: 20,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: AppColor.lightGrey,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            isExpanded
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Builder(
                                builder: (context) {
                                  if (isLoadingChildren) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (childDocs.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text(
                                          "No documents found",
                                          style: AppTextStyle.ts14R(
                                            color: AppColor.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          childDocs.map((childDoc) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColor
                                                        .lightGreyBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      childDoc.documentName,
                                                      style:
                                                          AppTextStyle.ts14R(),
                                                    ),
                                                  ),
                                                  CustomIconButton(
                                                    onPressed: () {
                                                      showFilePreviewDialog(
                                                        context,
                                                        childDoc.documentURL
                                                            .split(","),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      color: AppColor.primary,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
