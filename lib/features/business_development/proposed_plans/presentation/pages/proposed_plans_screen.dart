import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_state.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/pages/widgets/proposed_plan_amenities_view.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/pages/widgets/proposed_plan_details_view.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/pages/widgets/proposed_plan_documents_view.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/pages/widgets/proposed_plan_parking_details_view.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/model/form/wing_detail_form_model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
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
  late final ProposedPlansCubit _proposedPlansCubit;
  late final AuthorizationModel _routeAuthorizationModel;
  late TabController _buildingTabController;
  late final TabController _buildingDetailsTabController;
  late ProjectModel _project;
  late final TextEditingController _totalBuildingC;
  final ValueNotifier<bool> _hasSearchResults = ValueNotifier(true);
  final TextEditingController _buildingCountC = TextEditingController();
  final GlobalKey<FormState> _buildingCountFormKey = GlobalKey<FormState>();
  static const _tabTitles = [
    "Basic Details",
    "Documents",
    "Parking Details",
    "Amenities",
  ];

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
    _proposedPlansCubit.onTabChanged(_buildingDetailsTabController.index);
  }

  @override
  void dispose() {
    _hasSearchResults.dispose();
    _buildingTabController.dispose();
    _buildingDetailsTabController.dispose();
    _totalBuildingC.dispose();
    super.dispose();
  }

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

  void _saveForm(ProposedPlansState state) {
    if (state.proposedPlansList.isEmpty) return;
    final plan = state.proposedPlansList.first;
    final selectedBuilding =
        plan.buildingProposedPlanData[state.currentBuildingIndex];
    final form = state.proposedPlanForm;
    _proposedPlansCubit.addUpdateProposedPlans(
      context: context,
      proposedOfferProposedPlanId: plan.proposedOfferProposedPlanId,
      uniquekey: plan.uniquekey,
      projectId: _project.projectId,
      totalUnits: form.totalUnits,
      totalParking: form.totalParking,
      amenities: form.amenities,
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

  Future<void> _showBuildingCountBottomSheet() async {
    _buildingCountC.text = _totalBuildingC.text;
    await DialogHelper.showCustomBottomSheet(
      context,
      "${_buildingCountC.text.isNotEmpty ? 'Update' : 'Add'} Building",
      contentWidget: Form(
        key: _buildingCountFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),
            CustomTextField(
              title: "Total Number Of Buildings",
              hint: "Enter Total Number Of Buildings",
              textController: _buildingCountC,
              keyboardType: TextInputType.number,
              inputFormatterList: InputValidator.digit(2),
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Total Number Of Buildings is required";
                }
                final count = int.tryParse(value);
                if (count == null) {
                  return "Invalid building count";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomActions: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: "Cancel",
              backgroundColor: AppColor.white,
              textColor: AppColor.black,
              borderColor: AppColor.grey.withValues(alpha: 0.25),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          horizontalSpacing(),
          Expanded(
            child: CustomButton(
              text: "Save",
              onPressed: () async {
                if (!_buildingCountFormKey.currentState!.validate()) {
                  return;
                }
                final count = int.parse(_buildingCountC.text);
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
                _proposedPlansCubit.addUpdateBuilding(
                  context: context,
                  proposedOfferProposedPlanId: proposedOfferProposedPlanId,
                  projectId: _project.projectId,
                  totalNumberOfBuilding: count,
                  uniquekey: uniquekey,
                );
                goRouter.pop();
              },
            ),
          ),
        ],
      ),
    );
    _buildingCountC.clear();
  }

  void _onProposedPlansStateChanged(
    BuildContext context,
    ProposedPlansState state,
  ) {
    if (state.proposedPlansList.isEmpty) {
      _totalBuildingC.clear();
      return;
    }
    final plan = state.proposedPlansList.first;
    if (plan.buildingProposedPlanData.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _totalBuildingC.text = plan.totalNumberOfBuilding.toString();
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
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: CustomTextField(
                  textController: _totalBuildingC,
                  title: "Total No. Of Buildings",
                  hint: "0",
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
              ),
              BlocBuilder<ProposedPlansCubit, ProposedPlansState>(
                builder: (context, state) {
                  return CustomButton(
                    text:
                        state.proposedPlansList.isEmpty
                            ? 'Add Building'
                            : 'Update Building',
                    isDisable: !_routeAuthorizationModel.isAction,
                    onPressed: _showBuildingCountBottomSheet,
                  );
                },
              ),
            ],
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
              AmenitiesDetailsView(
                key: ValueKey(_buildingDetailsTabController.index.toString()),
                initialAmenities: selectedBuilding.amenities,
                onSearchResultChanged: (hasData) {
                  _hasSearchResults.value = hasData;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_hasSearchResults, _totalBuildingC]),
      builder: (context, _) {
        if (_totalBuildingC.text.isEmpty) {
          return SizedBox.shrink();
        }
        return BlocBuilder<ProposedPlansCubit, ProposedPlansState>(
          builder: (context, state) {
            return SafeArea(
              child: Container(
                height: 70,
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  isDisable:
                      _totalBuildingC.text.trim().isEmpty ||
                      !_hasSearchResults.value ||
                      !_routeAuthorizationModel.isAction,
                  text: "Update Proposed Plan",
                  onPressed: () => _saveForm(state),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
