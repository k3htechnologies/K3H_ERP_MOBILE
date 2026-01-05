import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/widgets/employee_document_dialog.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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

  late TabController _tabController;

  // PROJECT
  late ProjectModel _project;

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
    super.dispose();
  }

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
                  height: 48,
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
                    _buildColumnTitleValue(
                      title: "Google Location",
                      value: "-",
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
    return SingleChildScrollView(
      child: BlocBuilder<BuildingCubit, BuildingState>(
        builder: (context, state) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: state.buildingDocumentList.length,
            itemBuilder: (context, index) {
              final doc = state.buildingDocumentList[index];

              final urls =
                  doc.documentURL.isEmpty
                      ? <String>[]
                      : doc.documentURL.split(',');

              final isFresh = urls.isEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Row(
                  children: [
                    Expanded(child: Text(doc.documentName, style: AppTextStyle.ts14SB())),
                    const Spacer(),

                    CustomIconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (_) => EmployeeDocumentDialog(
                                title: doc.documentName,
                                urls: urls,
                                isFreshAdd: isFresh,

                                addDocument: (pickedFiles) async {
                                  if (pickedFiles.isEmpty) return;
                                  
                                  final files = MultiFilePickerModel(
                                    fileNameList:
                                        pickedFiles.map((e) => e.name).toList(),
                                    fileBytesList:
                                        pickedFiles
                                            .where((e) => e.bytes != null)
                                            .map((e) => e.bytes!)
                                            .toList(),
                                    deletedFileList: "",
                                  );

                                  await _buildingCubit.updateBuildingDocument(
                                    context: context,
                                    buildingDocumentId: isFresh ? 0 : doc.buildingDocumentId,
                                    uniqueKey: isFresh ? '' : doc.uniquekey,
                                    projectId: _project.projectId,
                                    buildingId: widget.building.buildingId,
                                    documentName: doc.documentName,
                                    files: files,
                                  );
                                },

                                // 🗑 DELETE
                                deleteDocument: (removeUrl) async {
                                  final files = MultiFilePickerModel(
                                    fileNameList: [],
                                    fileBytesList: [],
                                    deletedFileList: removeUrl,
                                  );

                                  await _buildingCubit.updateBuildingDocument(
                                    context: context,
                                    buildingDocumentId: doc.buildingDocumentId,
                                    uniqueKey: doc.uniquekey,
                                    projectId: _project.projectId,
                                    buildingId: widget.building.buildingId,
                                    documentName: doc.documentName,
                                    files: files,
                                  );
                                },
                              ),
                        );
                      },
                      icon: Icon(
                        Icons.remove_red_eye,
                        size: 16,
                        color: isFresh ? AppColor.grey : AppColor.primary,
                      ),
                      backgroundColor:
                          isFresh ? AppColor.lightGrey : AppColor.lightBlue,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
