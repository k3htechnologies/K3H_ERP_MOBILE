import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/cubit/sourcing_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SourcingScreen extends StatefulWidget {
  const SourcingScreen({super.key});

  @override
  State<SourcingScreen> createState() => _SourcingScreenState();
}

class _SourcingScreenState extends State<SourcingScreen> {
  // CUBIT
  late SourcingCubit _sourcingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterCompanyNameC,
      _filterDesignationC,
      _filterFirmTypeC,
      _filterTypeC,
      _filterCPNameC,
      _filterOfficeAddressC,
      _filterGSTNumberC,
      _filterRERANumberC,
      _filterPANNumberC,
      _filterAadhaarNumberC,
      _filterSpecialityC,
      _filterCityC,
      _filterVillageC;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _sourcingCubit = context.read<SourcingCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.sourcing]!;
    _project = getProject();
    _initializeTextEditingController();
    _onScroll();
    _sourcingCubit.getChannelPartnerList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCompanyNameC = TextEditingController();
    _filterDesignationC = TextEditingController();
    _filterFirmTypeC = TextEditingController();
    _filterTypeC = TextEditingController();
    _filterCPNameC = TextEditingController();
    _filterOfficeAddressC = TextEditingController();
    _filterGSTNumberC = TextEditingController();
    _filterRERANumberC = TextEditingController();
    _filterPANNumberC = TextEditingController();
    _filterAadhaarNumberC = TextEditingController();
    _filterSpecialityC = TextEditingController();
    _filterCityC = TextEditingController();
    _filterVillageC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_sourcingCubit.state.isLoading! &&
          _sourcingCubit.state.channelPartnerList.length <
              _sourcingCubit.state.totalNumberOfRecordCP) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _sourcingCubit.getChannelPartnerList(
            context,
            _sourcingCubit.state.currentPageCp + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterChannelPartner(
    BuildContext context,
  ) async {
    final state = _sourcingCubit.state;

    _filterCompanyNameC.text = state.filterByCompanyName;
    _filterDesignationC.text = state.filterByDesignation;
    _filterFirmTypeC.text = state.filterByFirmType;
    _filterTypeC.text = state.filterByType;
    _filterCPNameC.text = state.filterByCPName;
    _filterOfficeAddressC.text = state.filterByOfficeAddress;
    _filterGSTNumberC.text = state.filterByGSTNumber;
    _filterRERANumberC.text = state.filterByRERANumber;
    _filterPANNumberC.text = state.filterByPANNumber;
    _filterAadhaarNumberC.text = state.filterByAadhaarNumber;
    _filterSpecialityC.text = state.filterBySpeciality;
    _filterCityC.text = state.filterByCity;
    _filterVillageC.text = state.filterByVillage;

    String? selectedDirection =
        state.currentSortColumn == "Mobile Number"
            ? state.currentSortDirection
            : null;

    final String initialCompanyName = _filterCompanyNameC.text;
    final String initialDesignation = _filterDesignationC.text;
    final String initialFirmType = _filterFirmTypeC.text;
    final String initialType = _filterTypeC.text;
    final String initialMobileNumber = _filterCPNameC.text;
    final String initialOfficeAddress = _filterOfficeAddressC.text;
    final String initialGSTNumber = _filterGSTNumberC.text;
    final String initialRERANumber = _filterRERANumberC.text;
    final String initialPANNumber = _filterPANNumberC.text;
    final String initialAadhaarNumber = _filterAadhaarNumberC.text;
    final String initialSpeciality = _filterSpecialityC.text;
    final String initialCity = _filterCityC.text;
    final String initialVillage = _filterVillageC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterCompanyNameC.text.trim() != initialCompanyName) ||
            (_filterDesignationC.text.trim() != initialDesignation) ||
            (_filterFirmTypeC.text.trim() != initialFirmType) ||
            (_filterTypeC.text.trim() != initialType) ||
            (_filterCPNameC.text.trim() != initialMobileNumber) ||
            (_filterOfficeAddressC.text.trim() != initialOfficeAddress) ||
            (_filterGSTNumberC.text.trim() != initialGSTNumber) ||
            (_filterRERANumberC.text.trim() != initialRERANumber) ||
            (_filterPANNumberC.text.trim() != initialPANNumber) ||
            (_filterAadhaarNumberC.text.trim() != initialAadhaarNumber) ||
            (_filterSpecialityC.text.trim() != initialSpeciality) ||
            (_filterCityC.text.trim() != initialCity) ||
            (_filterVillageC.text.trim() != initialVillage) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Channel Partner",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Full Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => selectDirection("ASC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "ASC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("A-Z", style: AppTextStyle.ts12R()),
                      ),
                    ),

                    horizontalSpacing(),

                    GestureDetector(
                      onTap: () => selectDirection("DESC"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              selectedDirection == "DESC"
                                  ? AppColor.lightBlue
                                  : Colors.transparent,
                          border: Border.all(color: AppColor.grey, width: .5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),

                verticalSpacing(height: 20),

                CustomTextField(
                  title: "Full Name",
                  hint: "Enter Full Name",
                  textController: _filterCPNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                CustomTextField(
                  title: "Company Name",
                  hint: "Enter Company Name",
                  textController: _filterCompanyNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Designation",
                  hint: "Enter Designation",
                  textController: _filterDesignationC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Firm Type",
                  hint: "Enter Firm Type",
                  textController: _filterFirmTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Type",
                  hint: "Enter Type",
                  textController: _filterTypeC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Office Address",
                  hint: "Enter Office Address",
                  textController: _filterOfficeAddressC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "GST Number",
                  hint: "Enter GST Number",
                  textController: _filterGSTNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "RERA Number",
                  hint: "Enter RERA Number",
                  textController: _filterRERANumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "PAN Number",
                  hint: "Enter PAN Number",
                  textController: _filterPANNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Aadhaar Card Number",
                  hint: "Enter Aadhaar Card Number",
                  textController: _filterAadhaarNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Speciality",
                  hint: "Enter Speciality",
                  textController: _filterSpecialityC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "City",
                  hint: "Enter City",
                  textController: _filterCityC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),

                CustomTextField(
                  title: "Village",
                  hint: "Enter Village",
                  textController: _filterVillageC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _filterCompanyNameC.clear();
        _filterDesignationC.clear();
        _filterFirmTypeC.clear();
        _filterTypeC.clear();
        _filterCPNameC.clear();
        _filterOfficeAddressC.clear();
        _filterGSTNumberC.clear();
        _filterRERANumberC.clear();
        _filterPANNumberC.clear();
        _filterAadhaarNumberC.clear();
        _filterSpecialityC.clear();
        _filterCityC.clear();
        _filterVillageC.clear();

        _sourcingCubit.applyChannelPartnerSourcingFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _sourcingCubit.applyChannelPartnerSourcingFilterAndSort(
          context: context,
          companyName: _filterCompanyNameC.text.trim(),
          designation: _filterDesignationC.text.trim(),
          firmType: _filterFirmTypeC.text.trim(),
          type: _filterTypeC.text.trim(),
          mobileNumber: _filterCPNameC.text.trim(),
          officeAddress: _filterOfficeAddressC.text.trim(),
          gstNumber: _filterGSTNumberC.text.trim(),
          reraNumber: _filterRERANumberC.text.trim(),
          panNumber: _filterPANNumberC.text.trim(),
          aadhaarNumber: _filterAadhaarNumberC.text.trim(),
          speciality: _filterSpecialityC.text.trim(),
          city: _filterCityC.text.trim(),
          village: _filterVillageC.text.trim(),
          sortColumn: selectedDirection != null ? "Full Name" : null,
          sortDirection: selectedDirection,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterCompanyNameC.clear();
      _filterDesignationC.clear();
      _filterFirmTypeC.clear();
      _filterTypeC.clear();
      _filterCPNameC.clear();
      _filterOfficeAddressC.clear();
      _filterGSTNumberC.clear();
      _filterRERANumberC.clear();
      _filterPANNumberC.clear();
      _filterAadhaarNumberC.clear();
      _filterSpecialityC.clear();
      _filterCityC.clear();
      _filterVillageC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Sourcing",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Mobile Number",
        onSearchSubmit: (value) {
          _sourcingCubit.searchChannelPartner(context, value);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _sourcingCubit.searchChannelPartner(context, "");
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterChannelPartner(context);
        },
      ),
      body: BlocBuilder<SourcingCubit, SourcingState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.channelPartnerList.isEmpty) {
            return Center(child: loader());
          }
          if (state.channelPartnerList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Channel Partner Sourcing found"),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _sourcingCubit.state.channelPartnerList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.channelPartnerList.length) {
                return state.channelPartnerList.length <
                        state.totalNumberOfRecordCP
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var channelPartner = state.channelPartnerList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_project.projectId == 0) {
                                showErrorMessage(
                                  context,
                                  'Error',
                                  'Please select a project',
                                );
                                return;
                              }
                              goRouter.pushNamed(
                                AppRoutes.viewSourcing,
                                queryParameters: {
                                  'channelPartner': Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(channelPartner.toJson()),
                                    ),
                                  ),
                                  "projectId": _project.projectId.toString(),
                                },
                              );
                            },
                            child: Text(
                              channelPartner.name,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        if (channelPartner.isIncomplete) ...[
                          CustomIconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.warning_amber_outlined,
                              color: AppColor.yellow,
                              size: 16,
                            ),
                            backgroundColor: AppColor.yellow.withValues(
                              alpha: .2,
                            ),
                          ),
                        ],
                      ],
                    ),
                    buildRowTitleValue(
                      title: "CP Code",
                      value: channelPartner.systemGeneratedCode,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Mobile No.",
                      value: channelPartner.mobileNumber,
                      customValueWidget: CustomClickToContactText(
                        value:
                            "${channelPartner.mobileNumberCountryCode} ${channelPartner.mobileNumber}",
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Email",
                      value: channelPartner.emailId,
                      customValueWidget: CustomClickToContactText(
                        value: channelPartner.emailId,
                        type: ContactType.email,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Company Name",
                      value: channelPartner.companyName,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "RERA Number",
                      value: channelPartner.reraNumber,
                      singleLine: false,
                    ),
                    buildRowTitleValue(
                      title: "Office Address",
                      value: channelPartner.officeAddress,
                      singleLine: false,
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
}
