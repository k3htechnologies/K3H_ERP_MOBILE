import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/cubit/project_lead_cubit.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/pages/land/land.screen.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/presentation/pages/redevelopment/redevelopment.screen.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_export_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ProjectLeadScreen extends StatefulWidget {
  const ProjectLeadScreen({super.key});

  @override
  State<ProjectLeadScreen> createState() => _ProjectLeadScreenState();
}

class _ProjectLeadScreenState extends State<ProjectLeadScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late ProjectLeadCubit _projectLeadCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _redevlopmentSearchC,
      _landSearchC,
      _filterBuildingAddressC,
      _filterContactPersonNameC,
      _filterContactPersonMobileNumberC,
      _filterPinCodeC,
      _filterPlotNumberC,
      _filterWardNumberZoneC,
      _filterExistingBuildingTypeC,
      _filterConstructionTypeC,
      _filterTypeOfLandTenureC,
      _filterLandAddressC,
      _filterLandContactPersonName,
      _filterLandContactPersonMobileNumberC,
      _filterLandPinCodeC,
      _filterLandPlotNumberC,
      _filterLandWardNumberZoneC,
      _filterLandPlotShapeTypeC,
      _filterLandOwnershipTypeC;

  // TAB CONTROLLER
  late TabController _tabController;
  late List<String> _tabs;

  // FILTER COUNT
  final ValueNotifier<int> _redevlopmentFilterCount = ValueNotifier(0);
  final ValueNotifier<int> _landFilterCount = ValueNotifier(0);

  final ValueNotifier<DateTime?> _startDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _endDateNotifier = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<DateTime?> _landStartDateNotifier =
      ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _landEndDateNotifier =
      ValueNotifier<DateTime?>(null);
  @override
  void initState() {
    _projectLeadCubit = context.read<ProjectLeadCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.projectLead] ??
        AuthorizationModel();
    _tabs = ["Redevlopment", "Land"];
    _initialiseController();

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _projectLeadCubit.getRedevelopmentList(context, 1);
    super.initState();
  }

  void _initialiseController() {
    _redevlopmentSearchC = TextEditingController();
    _landSearchC = TextEditingController();
    _filterBuildingAddressC = TextEditingController();
    _filterContactPersonNameC = TextEditingController();
    _filterContactPersonMobileNumberC = TextEditingController();
    _filterPinCodeC = TextEditingController();
    _filterPlotNumberC = TextEditingController();
    _filterWardNumberZoneC = TextEditingController();
    _filterExistingBuildingTypeC = TextEditingController();
    _filterConstructionTypeC = TextEditingController();
    _filterTypeOfLandTenureC = TextEditingController();
    _filterLandAddressC = TextEditingController();
    _filterLandContactPersonName = TextEditingController();
    _filterLandContactPersonMobileNumberC = TextEditingController();
    _filterLandPinCodeC = TextEditingController();
    _filterLandPlotNumberC = TextEditingController();
    _filterLandWardNumberZoneC = TextEditingController();
    _filterLandPlotShapeTypeC = TextEditingController();
    _filterLandOwnershipTypeC = TextEditingController();
  }

  @override
  void dispose() {
    _redevlopmentSearchC.dispose();
    _landSearchC.dispose();
    _filterBuildingAddressC.dispose();
    _filterContactPersonNameC.dispose();
    _filterContactPersonMobileNumberC.dispose();
    _filterPinCodeC.dispose();
    _filterPlotNumberC.dispose();
    _filterWardNumberZoneC.dispose();
    _filterExistingBuildingTypeC.dispose();
    _filterConstructionTypeC.dispose();
    _filterTypeOfLandTenureC.dispose();
    _redevlopmentFilterCount.dispose();
    _filterLandAddressC.dispose();
    _filterLandContactPersonName.dispose();
    _filterLandContactPersonMobileNumberC.dispose();
    _filterLandPinCodeC.dispose();
    _filterLandPlotNumberC.dispose();
    _filterLandWardNumberZoneC.dispose();
    _filterLandPlotShapeTypeC.dispose();
    _filterLandOwnershipTypeC.dispose();
    _landFilterCount.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _landStartDateNotifier.dispose();
    _landEndDateNotifier.dispose();
    super.dispose();
  }

  // HANDLE TAB CHANGE
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      onTabChanged(context, _tabController.index);
    }
  }

  void onTabChanged(BuildContext context, int index) {
    if (index == 0) {
      _projectLeadCubit.getRedevelopmentList(context, 1);
    } else if (index == 1) {
      _projectLeadCubit.getLandList(context, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectLeadCubit, ProjectLeadState>(
      listener: (context, state) {
        _redevlopmentFilterCount.value = _projectLeadCubit
            .updateRedevelopmentFilterCount(state);
        _landFilterCount.value = _projectLeadCubit.updateLandFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBarWithBackButton(
          screenTitle: "Project Lead",
          authorization: _routeAuthorizationModel,
          isMenuButton: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              tabs: ["Redevlopment", "Land"],
            ),
            Expanded(
              child: BlocBuilder<ProjectLeadCubit, ProjectLeadState>(
                builder: (context, state) {
                  if (state.isLoading ?? true) {
                    return Center(child: loader());
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      redevelopmentWidget(context),
                      landWidget(context),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget redevelopmentWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchbar(isRedevelopment: true),
          verticalSpacing(),
          Expanded(child: RedevelopmentScreen()),
        ],
      ),
    );
  }

  Widget landWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchbar(isRedevelopment: false),
          verticalSpacing(),
          LandScreen(),
        ],
      ),
    );
  }

  Widget _buildSearchbar({required bool isRedevelopment}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SearchWidget(
            onSubmit: (value) {
              if (isRedevelopment) {
                _projectLeadCubit.searchRedevlopment(context, 1, value);
              } else {
                _projectLeadCubit.searchLand(context, 1, value);
              }
            },
            textController:
                isRedevelopment ? _redevlopmentSearchC : _landSearchC,
            hintText:
                isRedevelopment
                    ? "Search By Building Name"
                    : "Search By Land owner Name",
            isFilterOn: true,
            onFilterTap: () {
              if (isRedevelopment) {
                _showBottomSheetToFilterRedevlopment(context);
              } else {
                _showBottomSheetToFilterLand(context);
              }
            },
            filterCountNotifier:
                isRedevelopment ? _redevlopmentFilterCount : _landFilterCount,
          ),
        ),
        horizontalSpacing(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
              text: "Add",
              onPressed: () {
                if (isRedevelopment) {
                  goRouter.pushNamed(AppRoutes.addRedevelopment);
                } else {
                  goRouter.pushNamed(AppRoutes.addLand);
                }
              },
            ),
            horizontalSpacing(),
            CustomExportButton(
              onExport: (value) {
                if (isRedevelopment) {
                  _projectLeadCubit.exportRedevelopmentExcelPdf(context, value);
                } else {
                  _projectLeadCubit.exportLandExcelPdf(context, value);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showBottomSheetToFilterRedevlopment(
    BuildContext context,
  ) async {
    final state = _projectLeadCubit.state;

    _redevlopmentSearchC.text = state.redevelopmentSearchText;
    _filterBuildingAddressC.text = state.redevelopmentBuildingAddressText;
    _filterContactPersonNameC.text = state.redevelopmentContactPersonNameText;
    _filterContactPersonMobileNumberC.text =
        state.redevelopmentContactPersonMobileNumberText;
    _filterPinCodeC.text = state.redevelopmentPinCode;
    _filterPlotNumberC.text = state.redevelopmentPlotNumberText;
    _filterWardNumberZoneC.text = state.redevelopmentWardNumberZone;
    _filterExistingBuildingTypeC.text = state.redevelopmentExistingBuildingType;
    _filterConstructionTypeC.text = state.redevelopmentConstructionType;
    _filterTypeOfLandTenureC.text = state.redevelopmentTypeOfLandTenure;
    _startDateNotifier.value = state.redevelopmentByFromDate;
    _endDateNotifier.value = state.redevelopmentByToDate;

    final String initialName = _redevlopmentSearchC.text;
    final String initialBuildingAddressName = _filterBuildingAddressC.text;
    final String initialContactPersonName = _filterContactPersonNameC.text;
    final String initialContactPersonMobileNumber =
        _filterContactPersonMobileNumberC.text;
    final String initialPinCode = _filterPinCodeC.text;
    final String initialPlotNumber = _filterPlotNumberC.text;
    final String initialWardNumber = _filterWardNumberZoneC.text;
    final String initialExistingBuildingType =
        _filterExistingBuildingTypeC.text;
    final String initialConstructionType = _filterConstructionTypeC.text;
    final String initialTypeOfLandTenure = _filterTypeOfLandTenureC.text;
    final DateTime? initialFromDate = _startDateNotifier.value;
    final DateTime? initialToDate = _endDateNotifier.value;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_redevlopmentSearchC.text.trim() != initialName) ||
            (_filterBuildingAddressC.text.trim() !=
                initialBuildingAddressName) ||
            (_filterContactPersonNameC.text.trim() !=
                initialContactPersonName) ||
            (_filterContactPersonMobileNumberC.text.trim() !=
                initialContactPersonMobileNumber) ||
            (_filterPinCodeC.text.trim() != initialPinCode) ||
            (_filterPlotNumberC.text.trim() != initialPlotNumber) ||
            (_filterWardNumberZoneC.text.trim() != initialWardNumber) ||
            (_filterExistingBuildingTypeC.text.trim() !=
                initialExistingBuildingType) ||
            (_filterConstructionTypeC.text.trim() != initialConstructionType) ||
            (_filterTypeOfLandTenureC.text.trim() != initialTypeOfLandTenure) ||
            (_startDateNotifier.value != initialFromDate) ||
            (_endDateNotifier.value != initialToDate);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Project Redevelopment",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Building Name",
                  hint: "Enter Building Name",
                  textController: _redevlopmentSearchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Building Address",
                  hint: "Enter Building Address",
                  textController: _filterBuildingAddressC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Contact Person Name",
                  hint: "Enter Contact Person Name",
                  textController: _filterContactPersonNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Contact Person Mobile Number",
                  hint: "Enter Contact Person Mobile Number",
                  textController: _filterContactPersonMobileNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Pin Code",
                  hint: "Enter Pin Code",
                  textController: _filterPinCodeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Plot Number",
                  hint: "Enter Plot Number",
                  textController: _filterPlotNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Ward Number (Zone)",
                  hint: "Enter Ward Number Zone",
                  textController: _filterWardNumberZoneC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Existing Building Type",
                  hint: "Enter Existing Building Type",
                  textController: _filterExistingBuildingTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Construction Type",
                  hint: "Enter Construction Type",
                  textController: _filterConstructionTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Type Of Land Tenure",
                  hint: "Enter Type Of Land Tenure",
                  textController: _filterTypeOfLandTenureC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _startDateNotifier,
                        builder: (context, fromDate, child) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: fromDate,
                            setValue: (value) {
                              _startDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _endDateNotifier,
                        builder: (context, toDate, child) {
                          return CustomDatePicker(
                            title: "To Date",
                            initialDate: toDate,
                            setValue: (value) {
                              _endDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _redevlopmentSearchC.clear();
        _filterBuildingAddressC.clear();
        _filterContactPersonNameC.clear();
        _filterContactPersonMobileNumberC.clear();
        _filterPinCodeC.clear();
        _filterPlotNumberC.clear();
        _filterWardNumberZoneC.clear();
        _filterExistingBuildingTypeC.clear();
        _filterConstructionTypeC.clear();
        _filterTypeOfLandTenureC.clear();
        _startDateNotifier.value = null;
        _endDateNotifier.value = null;
        _projectLeadCubit.applyRedevlopmentFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _projectLeadCubit.applyRedevlopmentFilterAndSort(
          context: context,
          buildingName: _redevlopmentSearchC.text.trim(),
          buildingAddress: _filterBuildingAddressC.text.trim(),
          contactPersonName: _filterContactPersonNameC.text.trim(),
          contactPersonMobileNumber:
              _filterContactPersonMobileNumberC.text.trim(),
          pinCode: _filterPinCodeC.text.trim(),
          plotNumber: _filterPlotNumberC.text.trim(),
          wardNumber: _filterWardNumberZoneC.text.trim(),
          buildingType: _filterExistingBuildingTypeC.text.trim(),
          constructionType: _filterConstructionTypeC.text.trim(),
          typeOfLandTenure: _filterTypeOfLandTenureC.text.trim(),
          filterByFromDate: _startDateNotifier.value,
          filterByToDate: _endDateNotifier.value,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _redevlopmentSearchC.clear();
      _filterBuildingAddressC.clear();
      _filterContactPersonNameC.clear();
      _filterContactPersonMobileNumberC.clear();
      _filterPinCodeC.clear();
      _filterPlotNumberC.clear();
      _filterWardNumberZoneC.clear();
      _filterExistingBuildingTypeC.clear();
      _filterConstructionTypeC.clear();
      _filterTypeOfLandTenureC.clear();
    }
  }

  Future<void> _showBottomSheetToFilterLand(BuildContext context) async {
    final state = _projectLeadCubit.state;

    _landSearchC.text = state.landSearchText;
    _filterLandAddressC.text = state.landAddress;
    _filterLandContactPersonName.text = state.landContactPersonName;
    _filterLandContactPersonMobileNumberC.text =
        state.landContactPersonMobileNumber;
    _filterLandPinCodeC.text = state.landPinCode;
    _filterLandPlotNumberC.text = state.landPlotNumberText;
    _filterLandWardNumberZoneC.text = state.landWardNumberZone;
    _filterLandPlotShapeTypeC.text = state.landPlotShape;
    _filterLandOwnershipTypeC.text = state.landOwnershipType;
    _landStartDateNotifier.value = state.landByFromDate;
    _landEndDateNotifier.value = state.landByToDate;

    final String initialName = _landSearchC.text;
    final String initialLandAddressName = _filterLandAddressC.text;
    final String initialLandContactPersonName =
        _filterLandContactPersonName.text;
    final String initialLandContactPersonMobileNumber =
        _filterLandContactPersonMobileNumberC.text;
    final String initialLandPinCode = _filterLandPinCodeC.text;
    final String initialLandPlotNumber = _filterLandPlotNumberC.text;
    final String initialLandWardNumber = _filterLandWardNumberZoneC.text;
    final String initialLandPlotShape = _filterLandPlotShapeTypeC.text;
    final String initialLandOwnershipType = _filterLandOwnershipTypeC.text;
    final DateTime? initialLandFromDate = _landStartDateNotifier.value;
    final DateTime? initialLandToDate = _landEndDateNotifier.value;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_landSearchC.text.trim() != initialName) ||
            (_filterLandAddressC.text.trim() != initialLandAddressName) ||
            (_filterLandContactPersonName.text.trim() !=
                initialLandContactPersonName) ||
            (_filterLandContactPersonMobileNumberC.text.trim() !=
                initialLandContactPersonMobileNumber) ||
            (_filterLandPinCodeC.text.trim() != initialLandPinCode) ||
            (_filterLandPlotNumberC.text.trim() != initialLandPlotNumber) ||
            (_filterLandWardNumberZoneC.text.trim() != initialLandWardNumber) ||
            (_filterLandPlotShapeTypeC.text.trim() != initialLandPlotShape) ||
            (_filterLandOwnershipTypeC.text.trim() !=
                initialLandOwnershipType) ||
            (_landStartDateNotifier.value != initialLandFromDate) ||
            (_landEndDateNotifier.value != initialLandToDate);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Project Land",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Land Owner Name",
                  hint: "Enter Land Owner Name",
                  textController: _landSearchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Land Address",
                  hint: "Enter Land Address",
                  textController: _filterLandAddressC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Contact Person Name",
                  hint: "Enter Contact Person Name",
                  textController: _filterLandContactPersonName,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Contact Person Mobile Number",
                  hint: "Enter Contact Person Mobile Number",
                  textController: _filterLandContactPersonMobileNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Pin Code",
                  hint: "Enter Pin Code",
                  textController: _filterLandPinCodeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Plot Number",
                  hint: "Enter Plot Number",
                  textController: _filterLandPlotNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Ward Number (Zone)",
                  hint: "Enter Ward Number Zone",
                  textController: _filterLandWardNumberZoneC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Plot Shape",
                  hint: "Enter Plot Shape",
                  textController: _filterLandPlotShapeTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Land Ownership Type",
                  hint: "Enter Land Ownership Type",
                  textController: _filterLandOwnershipTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<DateTime?>(
                        valueListenable: _landStartDateNotifier,
                        builder: (context, landFromDate, child) {
                          return CustomDatePicker(
                            title: "From Date",
                            initialDate: landFromDate,
                            setValue: (value) {
                              _landStartDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                    horizontalSpacing(),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _landEndDateNotifier,
                        builder: (context, landToDate, child) {
                          return CustomDatePicker(
                            title: "To Date",
                            initialDate: landToDate,
                            setValue: (value) {
                              _endDateNotifier.value = value;
                              updateApplyState(innerState);
                            },
                            validator: (value) => null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _landSearchC.clear();
        _filterLandAddressC.clear();
        _filterLandContactPersonName.clear();
        _filterLandContactPersonMobileNumberC.clear();
        _filterLandPinCodeC.clear();
        _filterLandPlotNumberC.clear();
        _filterLandWardNumberZoneC.clear();
        _filterLandPlotShapeTypeC.clear();
        _filterLandOwnershipTypeC.clear();
        _landStartDateNotifier.value = null;
        _landEndDateNotifier.value = null;
        _projectLeadCubit.applyLandFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _projectLeadCubit.applyLandFilterAndSort(
          context: context,
          landOwnerName: _landSearchC.text.trim(),
          landAddress: _filterLandAddressC.text.trim(),
          landContactPersonName: _filterLandContactPersonName.text.trim(),
          landContactPersonMobileNumber:
              _filterLandContactPersonMobileNumberC.text.trim(),
          landPinCode: _filterLandPinCodeC.text.trim(),
          landPlotNumber: _filterLandPlotNumberC.text.trim(),
          landWardNumber: _filterLandWardNumberZoneC.text.trim(),
          plotShape: _filterLandPlotShapeTypeC.text.trim(),
          ownershipType: _filterLandOwnershipTypeC.text.trim(),
          filterByLandFromDate: _landStartDateNotifier.value,
          filterByLandToDate: _landEndDateNotifier.value,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _landSearchC.clear();
      _filterLandAddressC.clear();
      _filterLandContactPersonName.clear();
      _filterLandContactPersonMobileNumberC.clear();
      _filterLandPinCodeC.clear();
      _filterLandPlotNumberC.clear();
      _filterLandWardNumberZoneC.clear();
      _filterLandPlotShapeTypeC.clear();
      _filterLandOwnershipTypeC.clear();
    }
  }
}
