import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/amenity_category.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/cubit/proposed_plans_state.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/widgets/proposed_plan_amenities_view.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/widgets/proposed_plan_details_view.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/widgets/proposed_plan_documents_view.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/presentation/widgets/proposed_plan_parking_details_view.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/form/wing_detail_form_model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProposedPlansScreen extends StatefulWidget {
  const ProposedPlansScreen({super.key});

  @override
  State<ProposedPlansScreen> createState() => _ProposedPlansScreenState();
}

class _ProposedPlansScreenState extends State<ProposedPlansScreen>
    with TickerProviderStateMixin {
  static const _tabTitles = [
    "Basic Details",
    "Documents",
    "Parking Details",
    "Amenities",
  ];

  late final ProposedPlansCubit _proposedPlansCubit;
  late final AuthorizationModel _routeAuthorizationModel;

  late TabController _buildingTabController;
  late final TabController _buildingDetailsTabController;

  late ProjectModel _project;

  late final TextEditingController _totalBuildingC;

  final ValueNotifier<List<AmenityCategory>> _amenitiesList =
      ValueNotifier<List<AmenityCategory>>([]);

  /// Tracks whether the currently-selected building's amenities have
  /// already been pushed into [_amenitiesList], so we don't clobber the
  /// user's in-progress selection on every rebuild.
  bool _amenitiesPrefilledForCurrentBuilding = false;

  final ValueNotifier<bool> _hasSearchResults = ValueNotifier(true);
  Timer? _buildingDebounce;
  String _previousBuildingCount = "";
  @override
  void initState() {
    super.initState();

    _project = getProject();
    _proposedPlansCubit = context.read<ProposedPlansCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.proposedPlan] ??
        AuthorizationModel();

    _totalBuildingC = TextEditingController();

    _buildingTabController = TabController(length: 0, vsync: this);
    _buildingTabController.addListener(_handleBuildingTabChange);
    _proposedPlansCubit.getProposedPlanList(context, _project.projectId);
    _buildingDetailsTabController = TabController(
      length: _tabTitles.length,
      vsync: this,
    );
    _buildingDetailsTabController.addListener(_handleDetailsTabChange);

    _amenitiesList.value = _buildDefaultAmenities();

    _proposedPlansCubit.onTabChanged(_buildingDetailsTabController.index);
  }

  @override
  void dispose() {
    _hasSearchResults.dispose();
    _amenitiesList.dispose();
    _buildingTabController.dispose();
    _buildingDetailsTabController.dispose();
    _totalBuildingC.dispose();
    super.dispose();
  }

  // Tab handling
  void _handleBuildingTabChange() {
    if (!_buildingTabController.indexIsChanging) {
      _proposedPlansCubit.changeBuildingTab(_buildingTabController.index);
    }
  }

  void _handleDetailsTabChange() {
    if (!_buildingDetailsTabController.indexIsChanging) {
      _proposedPlansCubit.onTabChanged(_buildingDetailsTabController.index);
    }
  }

  void _syncBuildingTabController(int length, int index) {
    if (_buildingTabController.length == length) return;

    _buildingTabController.dispose();
    _buildingTabController = TabController(
      length: length,
      vsync: this,
      initialIndex: index < length ? index : 0,
    )..addListener(_handleBuildingTabChange);
  }

  // Amenities
  void _applyAmenitiesSelection(String amenitiesString) {
    final selected =
        amenitiesString
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toSet();

    _amenitiesList.value =
        _amenitiesList.value
            .map(
              (category) => category.copyWith(
                subCategories:
                    category.subCategories
                        .map(
                          (sub) => sub.copyWith(
                            isSelected: selected.contains(
                              sub.name.trim().toLowerCase(),
                            ),
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();
  }

  void _clearAmenitiesSelection() {
    _amenitiesList.value =
        _amenitiesList.value
            .map(
              (category) => category.copyWith(
                subCategories:
                    category.subCategories
                        .map((sub) => sub.copyWith(isSelected: false))
                        .toList(),
              ),
            )
            .toList();
  }

  void _updateAmenityCategory(int index, AmenityCategory updated) {
    final updatedList = List<AmenityCategory>.from(_amenitiesList.value);
    updatedList[index] = updated;
    _amenitiesList.value = updatedList;
  }

  List<String> _selectedAmenityNames() => [
    for (final category in _amenitiesList.value)
      for (final sub in category.subCategories)
        if (sub.isSelected) sub.name,
  ];

  String _selectedAmenitiesCsv() => _selectedAmenityNames().join(',');

  List<AmenityCategory> _buildDefaultAmenities() => [
    AmenityCategory(
      title: "Safety & Security",
      subCategories: [
        AmenitySubCategory(name: "24* 7 Security"),
        AmenitySubCategory(name: "CCTV Surveillance"),
        AmenitySubCategory(name: "Fire Fighting System"),
        AmenitySubCategory(name: "First Aid Room"),
        AmenitySubCategory(name: "Intercom Facility"),
        AmenitySubCategory(name: "Security Cabin"),
        AmenitySubCategory(name: "Earthquake Resistant Structure"),
      ],
    ),
    AmenityCategory(
      title: "Sports & Fitness",
      subCategories: [
        AmenitySubCategory(name: "Swimming Pool"),
        AmenitySubCategory(name: "Gym"),
        AmenitySubCategory(name: "Yoga Room"),
        AmenitySubCategory(name: "Jogging Track"),
        AmenitySubCategory(name: "Badminton Court"),
        AmenitySubCategory(name: "BasketBall Court"),
        AmenitySubCategory(name: "Tennis Court"),
        AmenitySubCategory(name: "Squash Court"),
        AmenitySubCategory(name: "Table Tennis"),
        AmenitySubCategory(name: "Kids Pool"),
        AmenitySubCategory(name: "Indoor Games"),
        AmenitySubCategory(name: "Cycling Track"),
      ],
    ),
    AmenityCategory(
      title: "Community & Social Spaces",
      subCategories: [
        AmenitySubCategory(name: "Club House"),
        AmenitySubCategory(name: "Banquet Hall"),
        AmenitySubCategory(name: "Amphitheatre"),
        AmenitySubCategory(name: "Library"),
        AmenitySubCategory(name: "Reading Room"),
        AmenitySubCategory(name: "Society Office"),
        AmenitySubCategory(name: "Temple/Prayer Hall"),
      ],
    ),
    AmenityCategory(
      title: "Kids & Family",
      subCategories: [
        AmenitySubCategory(name: "Children Play Area"),
        AmenitySubCategory(name: "Creche"),
        AmenitySubCategory(name: "Day Care Center"),
        AmenitySubCategory(name: "School Bus Bay"),
      ],
    ),
    AmenityCategory(
      title: "Pets - Friendly Facilities",
      subCategories: [
        AmenitySubCategory(name: "Pet Park"),
        AmenitySubCategory(name: "Pet Care Area"),
      ],
    ),
    AmenityCategory(
      title: "Work & Business",
      subCategories: [
        AmenitySubCategory(name: "Co-Working Space"),
        AmenitySubCategory(name: "Conference Room"),
        AmenitySubCategory(name: "Society Office"),
      ],
    ),
    AmenityCategory(
      title: "Convenience & Utilities",
      subCategories: [
        AmenitySubCategory(name: "Lift"),
        AmenitySubCategory(name: "Power Backup"),
        AmenitySubCategory(name: "Water Supply"),
        AmenitySubCategory(name: "Parking"),
        AmenitySubCategory(name: "Visitor Parking"),
        AmenitySubCategory(name: "Covered Parking"),
        AmenitySubCategory(name: "EV Charging Points"),
        AmenitySubCategory(name: "Laundry Service"),
        AmenitySubCategory(name: "Garbage Disposal System"),
        AmenitySubCategory(name: "Sewage Treatment Plant"),
        AmenitySubCategory(name: "Rainwater Harvesting"),
        AmenitySubCategory(name: "Service Lift"),
      ],
    ),
    AmenityCategory(
      title: "Health & Wellness",
      subCategories: [
        AmenitySubCategory(name: "Spa"),
        AmenitySubCategory(name: "Steam Room"),
        AmenitySubCategory(name: "Meditation Area"),
        AmenitySubCategory(name: "Jacuzzi"),
      ],
    ),
    AmenityCategory(
      title: "Commercial & Services",
      subCategories: [
        AmenitySubCategory(name: "ATM"),
        AmenitySubCategory(name: "Pharmacy"),
        AmenitySubCategory(name: "Convenience Store"),
        AmenitySubCategory(name: "Co-working Space"),
        AmenitySubCategory(name: "Cafeteria"),
      ],
    ),
  ];

  Future<bool> _confirmBuildingCountChange(
    BuildContext context,
    String buildingCount,
  ) {
    return DialogHelper.showConfirmationDialog(
      confirmText: 'Yes',
      context: context,
      title: 'Update Building Count',
      message:
          'This will update the building count to $buildingCount. Do you want to continue?',
      cancelText: 'No',
    );
  }

  Future<void> _handleTotalBuildingChanged(String value) async {
    _buildingDebounce?.cancel();

    _buildingDebounce = Timer(const Duration(milliseconds: 600), () async {
      final count = int.tryParse(value);
      if (count == null || count < 0) return;

      final confirmed = await _confirmBuildingCountChange(context, value);

      if (!confirmed || !mounted) {
        _totalBuildingC.text = _previousBuildingCount;
        _totalBuildingC.selection = TextSelection.collapsed(
          offset: _previousBuildingCount.length,
        );
        return;
      }
      final plans = _proposedPlansCubit.state.proposedPlansList;
      final buildingIndex = _buildingTabController.index;
      final proposedOfferProposedPlanId =
          plans.isNotEmpty && buildingIndex < plans.length
              ? plans[buildingIndex].proposedOfferProposedPlanId
              : 0;
      final uniquekey =
          plans.isNotEmpty && buildingIndex < plans.length
              ? plans[buildingIndex].uniquekey
              : "";

      _proposedPlansCubit.addUpdateBuildingProposedPlan(
        context: context,
        proposedOfferProposedPlanId: proposedOfferProposedPlanId,
        projectId: _project.projectId,
        totalNumberOfBuilding: count,
        uniquekey: uniquekey,
      );
    });
  }

  void _handleAddOrUpdateProposedPlan(ProposedPlansState state) {
    if (state.proposedPlansList.isEmpty) return;

    final plan = state.proposedPlansList.first;
    final selectedBuilding =
        plan.buildingProposedPlanData[state.currentBuildingIndex];
    final form = state.buildingForm;

    _proposedPlansCubit.addUpdateProposedPlans(
      context: context,
      proposedOfferProposedPlanId: plan.proposedOfferProposedPlanId,
      uniquekey: plan.uniquekey,
      projectId: _project.projectId,
      totalUnits: form.totalUnits,
      totalParking: form.totalParking,
      amenities: _selectedAmenitiesCsv(),
      planFile: form.planFile,
      threeDViewFile: form.threeDViewFile,
      salesPlanFile: form.salesPlanFile,
      walkthroughViewFile: form.walkthroughViewFile,
      buildingProposedPlanId: selectedBuilding.buildingProposedPlanId,
      totalNumberOfWing: form.wings.length,
      totalPodium: form.totalPodium,
      wingProposedPlanJSON:
          form.wings
              .map(
                (e) => e.toApiModel(
                  buildingProposedPlanId:
                      selectedBuilding.buildingProposedPlanId,
                  proposedOfferProposedPlanId: plan.proposedOfferProposedPlanId,
                  buildingName: selectedBuilding.buildingName,
                ),
              )
              .toList(),
      salesResidentialParking: form.salesResidential,
      salesCommercialParking: form.salesCommercial,
      salesVisitorsParking: form.salesVisitor,
      memberResidentialParking: form.memberResidential,
      memberCommercialParking: form.memberCommercial,
      memberVisitorsParking: form.memberVisitor,
    );
  }

  // Bloc listener
  void _onProposedPlansStateChanged(
    BuildContext context,
    ProposedPlansState state,
  ) {
    if (state.proposedPlansList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _clearAmenitiesSelection();
        _amenitiesPrefilledForCurrentBuilding = false;
      });
      _totalBuildingC.clear();
      return;
    }

    _amenitiesPrefilledForCurrentBuilding = false;

    final plan = state.proposedPlansList.first;
    if (plan.buildingProposedPlanData.isEmpty) return;
    final building = plan.buildingProposedPlanData[state.currentBuildingIndex];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _totalBuildingC.text = plan.totalNumberOfBuilding.toString();
      _totalBuildingC.text = plan.totalNumberOfBuilding.toString();
      _previousBuildingCount = _totalBuildingC.text;
      _applyAmenitiesSelection(building.amenities);
      _amenitiesPrefilledForCurrentBuilding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProposedPlansCubit, ProposedPlansState>(
      listenWhen:
          (previous, current) =>
              previous.proposedPlansList != current.proposedPlansList ||
              previous.currentBuildingIndex != current.currentBuildingIndex,
      listener: _onProposedPlansStateChanged,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: SafeArea(
          child: BlocBuilder<ProposedPlansCubit, ProposedPlansState>(
            builder: (context, state) {
              if (state.isLoading ?? false) {
                return Center(child: loader());
              }
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: showSiteSelectedWidget(
                      projectName: _project.projectName,
                    ),
                  ),
                  _buildPlanDetailsSection(),
                  Expanded(child: _buildBuildingSection(state)),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBarWithBackButton(
      screenTitle: "Proposed Plan",
      isMenuButton: true,
      authorization: _routeAuthorizationModel,
      onProjectChangeCallback: (project) {
        _project = project;
        _proposedPlansCubit.getProposedPlanList(context, project.projectId);
        _buildingTabController.animateTo(0);
        _buildingDetailsTabController.animateTo(0);
        _totalBuildingC.clear();
      },
    );
  }

  Widget _buildPlanDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            textController: _totalBuildingC,
            title: "Total Building",
            hint: "Enter Total Building",
            keyboardType: TextInputType.number,
            onChangeFunction: _handleTotalBuildingChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingSection(ProposedPlansState state) {
    final buildingList =
        state.proposedPlansList.isNotEmpty
            ? state.proposedPlansList.first.buildingProposedPlanData
            : const <BuildingProposedPlanDataModel>[];

    _syncBuildingTabController(buildingList.length, state.currentBuildingIndex);

    if (state.isLoading ?? false) {
      return const Center(child: CircularProgressIndicator());
    }

    if (buildingList.isEmpty) {
      return Center(child: noDataWidget(message: "No Proposed Plan Found"));
    }

    final selectedBuilding =
        state.currentBuildingIndex < buildingList.length
            ? buildingList[state.currentBuildingIndex]
            : buildingList.first;

    // Only prefill amenities once per building load — repeated rebuilds
    // (tab switches, unrelated state emissions) must not overwrite the
    // user's in-progress selection.
    if (!_amenitiesPrefilledForCurrentBuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyAmenitiesSelection(selectedBuilding.amenities);
        _amenitiesPrefilledForCurrentBuilding = true;
      });
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ChipStyleTabBar(
                controller: _buildingTabController,
                tabs: List.generate(
                  buildingList.length,
                  (index) => buildingList[index].buildingName,
                ),
              ),
            ),
            horizontalSpacing(),
            CustomButton(
              text: "Duplicate",
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ),
              gradient: LinearGradient(
                colors: [AppColor.primary, AppColor.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDisable:
                  !_routeAuthorizationModel.isAction ||
                  buildingList.length == 1,
              onPressed: () {
                goRouter.pushNamed(
                  AppRoutes.duplicateBuildingProposedPlan,
                  extra: {
                    "projectId": _project.projectId,
                    "selectedBuildingIndex": _buildingTabController.index,
                    "buildingName":
                        buildingList[_buildingTabController.index].buildingName,
                  },
                );
              },
            ),
            horizontalSpacing(),
          ],
        ),
        verticalSpacing(),
        ChipStyleTabBar(
          controller: _buildingDetailsTabController,
          tabs: _tabTitles,
          style: ChipTabBarStyle.underline,
        ),
        Expanded(
          child: TabBarView(
            controller: _buildingDetailsTabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ProposedPlanDetailsView(
                key: ValueKey(
                  "${state.currentBuildingIndex}_${selectedBuilding.modifiedDate}",
                ),
                details:
                    selectedBuilding.wingProposedPlanData
                        .map<WingDetailFormModel>(WingDetailFormModel.fromApi)
                        .toList(),
                totalPodiumCount: selectedBuilding.totalPodium,
                totalUnitC: selectedBuilding.totalUnits,
                buildingName: selectedBuilding.buildingName,
              ),
              ProposedPlanDocumentsView(
                key: ValueKey(
                  "${state.currentBuildingIndex}_${selectedBuilding.modifiedDate}",
                ),
                building: selectedBuilding,
              ),
              ProposedPlanParkingDetailsView(
                key: ValueKey(
                  "${state.currentBuildingIndex}_${selectedBuilding.modifiedDate}",
                ),
                building: selectedBuilding,
              ),
              ValueListenableBuilder<List<AmenityCategory>>(
                valueListenable: _amenitiesList,
                builder: (context, list, child) {
                  return AmenitiesTab(
                    key: ValueKey(state.currentBuildingIndex),
                    amenitiesList: list,
                    onUpdate: _updateAmenityCategory,
                    onSearchResultChanged: (hasData) {
                      _hasSearchResults.value = hasData;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasSearchResults,
      builder: (context, hasSearchResults, child) {
        return BlocBuilder<ProposedPlansCubit, ProposedPlansState>(
          builder: (context, state) {
            return SafeArea(
              child: Container(
                height: 70,
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  isDisable:
                      !hasSearchResults || !_routeAuthorizationModel.isAction,
                  text:
                      state.proposedPlansList.isEmpty
                          ? "Add Proposed Plan"
                          : "Update Proposed Plan",
                  onPressed: () => _handleAddOrUpdateProposedPlan(state),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
