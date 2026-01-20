import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
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

  @override
  void initState() {
    super.initState();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _routeAuthorizationModel = AuthorizationModel();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expandedDocumentIds.dispose();
    _childDocuments.dispose();
    _loadingChildDocuments.dispose();
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

  // ───────────────── PICK DOCUMENTS ─────────────────
  Future<void> _pickDocuments(BuildingDocumentModel doc) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final multiFileModel = _convertToMultiFilePicker(result.files);

    await _buildingCubit.updateBuildingDocument(
      context: context,
      buildingDocumentId: doc.buildingDocumentId,
      uniqueKey: doc.uniquekey,
      projectId: doc.projectId,
      buildingId: doc.buildingId,
      documentName: doc.documentName,
      files: multiFileModel,
    );

    if (mounted) {
      final updatedExpanded = Set<int>.from(_expandedDocumentIds.value);
      updatedExpanded.remove(doc.buildingDocumentId);
      _expandedDocumentIds.value = updatedExpanded;

      final updatedChildren = Map<int, List<BuildingDocumentModel>>.from(
        _childDocuments.value,
      );
      updatedChildren.remove(doc.buildingDocumentId);
      _childDocuments.value = updatedChildren;
    }
  }

  MultiFilePickerModel _convertToMultiFilePicker(List<PlatformFile> files) {
    return MultiFilePickerModel(
      fileNameList: files.map((e) => e.name).toList(),

      fileBytesList: files.map((e) => e.bytes!).toList(),

      deletedFileList: "",
    );
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
                    _buildColumnTitleValue(
                      title: "Building Name",
                      value: widget.building.buildingName,
                    ),
                    _buildColumnTitleValue(
                      title: "CTS Number",
                      value: widget.building.ctsNumber,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "Road Width",
                      value: widget.building.roadWidth,
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Total Plot Area(Sq. ft)",
                      value: widget.building.totalPlotAreaSqFt.toString(),
                    ),
                    _buildColumnTitleValue(
                      title: "Total Floors",
                      value: widget.building.numberOfFloors.toString(),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "Utilized Unit Area(Sq. ft)",
                      value:
                          widget.building.totalUnitsAreaUtilizedSqFt.toString(),
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Country",
                      value: widget.building.countryName,
                    ),
                    _buildColumnTitleValue(
                      title: "State",
                      value: widget.building.stateName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
                      title: "District",
                      value: widget.building.districtName,
                    ),
                    _buildColumnTitleValue(
                      title: "City",
                      value: widget.building.cityName,
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Garden Structure",
                      value: widget.building.isGarden ? "Yes" : "No",
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Religious Structure",
                      value:
                          widget.building.isReligiousStructure ? "Yes" : "No",
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "FSI/TDR Utilization(Sq. ft)",
                      value: widget.building.fsiTdrUtilizationSqFt.toString(),
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Litigation",
                      value: widget.building.isLitigation ? "Yes" : "No",
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Created By",
                      value: widget.building.createdBy,
                    ),
                    _buildColumnTitleValue(
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
                    _buildColumnTitleValue(
                      title: "Modified By",
                      value:
                          widget.building.modifiedBy.isEmpty
                              ? "-"
                              : widget.building.modifiedBy,
                    ),
                    _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
                          title: "Gross Plot Area (Sq. ft)",
                          value:
                              state.buildingDetails!.grossPlotAreaSqFt
                                  .toString(),
                        ),
                        _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
                          title: "Old Approved Plan Area (Sq. ft)",
                          value:
                              state.buildingDetails!.plotAreaOldApprovedPlanSqFt
                                  .toString(),
                        ),
                        _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
                          title: "Total Build Up Area (Sq. ft)",
                          value:
                              state.buildingDetails!.totalBuiltUpAreaSqFt
                                  .toString(),
                        ),
                        _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
                          title: "Residential Carpet Area (Sq. ft)",
                          value:
                              state
                                  .buildingDetails!
                                  .totalResidentialCarpetAreaSqFt
                                  .toString(),
                        ),
                        _buildColumnTitleValue(
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
                        _buildColumnTitleValue(
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
                                  _buildColumnTitleValue(
                                    title: "Contact Type",
                                    value:
                                        contact.contactType.isEmpty
                                            ? "-"
                                            : contact.contactType,
                                  ),
                                  _buildColumnTitleValue(
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
                                  _buildColumnTitleValue(
                                    title: "Mobile Number",
                                    value:
                                        contact.mobileNumber.isEmpty
                                            ? "-"
                                            : contact.mobileNumber,
                                  ),
                                  _buildColumnTitleValue(
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

        // Store parent list when it's loaded (top-level documents)
        final parentDocuments = state.buildingDocumentList;

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: parentDocuments.length,
            itemBuilder: (context, index) {
              final doc = parentDocuments[index];

              return ValueListenableBuilder<Set<int>>(
                valueListenable: _expandedDocumentIds,
                builder: (context, expandedSet, _) {
                  final isExpanded = expandedSet.contains(
                    doc.buildingDocumentId,
                  );
                  final childDocs =
                      _childDocuments.value[doc.buildingDocumentId] ?? [];
                  final isLoadingChildren =
                      _loadingChildDocuments.value[doc.buildingDocumentId] ??
                      false;

                  return Container(
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
                              currentExpanded.remove(doc.buildingDocumentId);
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
                                    .getBuildingDocumentList(
                                      context,
                                      _project.projectId,
                                      widget.building.buildingId,
                                      1,
                                      100,
                                      doc.buildingDocumentId,
                                    )
                                    .then((_) {
                                      if (!mounted) return;
                                      final currentState = _buildingCubit.state;

                                      // Update children map
                                      final childrenMap = Map<
                                        int,
                                        List<BuildingDocumentModel>
                                      >.from(_childDocuments.value);
                                      childrenMap[doc.buildingDocumentId] =
                                          List<BuildingDocumentModel>.from(
                                            currentState.buildingDocumentList,
                                          );
                                      _childDocuments.value = childrenMap;

                                      // Set loading false
                                      final loadingMapDone =
                                          Map<int, bool>.from(
                                            _loadingChildDocuments.value,
                                          );
                                      loadingMapDone[doc.buildingDocumentId] =
                                          false;
                                      _loadingChildDocuments.value =
                                          loadingMapDone;

                                      if (context.mounted) {
                                        _buildingCubit.getBuildingDocumentList(
                                          context,
                                          _project.projectId,
                                          widget.building.buildingId,
                                          1,
                                          100,
                                          null,
                                        );
                                      }
                                    });
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    CustomIconButton(
                                      onPressed: () => _pickDocuments(doc),
                                      icon: Icon(
                                        Icons.add,
                                        color: AppColor.darkGreen,
                                        size: 16,
                                      ),
                                      backgroundColor: AppColor.lightGreen,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColor.lightGrey,
                                        borderRadius: BorderRadius.circular(8),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      childDocs.map((childDoc) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColor.lightGreyBackground,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  childDoc.documentName,
                                                  style: AppTextStyle.ts14R(),
                                                ),
                                              ),
                                              CustomIconButton(
                                                onPressed: () {
                                                  showFilePreviewDialog(
                                                    context,
                                                    childDoc.documentURL.split(
                                                      ",",
                                                    ),
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.remove_red_eye_outlined,
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
        );
      },
    );
  }

  // BUILD COLUMN TITLE VALUE
  Widget _buildColumnTitleValue({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          verticalSpacing(height: 4),
          Text(value, style: AppTextStyle.ts14M()),
        ],
      ),
    );
  }
}
