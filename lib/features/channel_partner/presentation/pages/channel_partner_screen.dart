import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ChannelPartnerScreen extends StatefulWidget {
  const ChannelPartnerScreen({super.key});

  @override
  State<ChannelPartnerScreen> createState() => _ChannelPartnerScreenState();
}

class _ChannelPartnerScreenState extends State<ChannelPartnerScreen> {
  // CUBIT
  late ChannelPartnerCubit _channelPartnerCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC,
      _filterCompanyNameC,
      _filterDesignationC,
      _filterFirmTypeC,
      _filterTypeC,
      _filterMobileNumberC,
      _filterOfficeAddressC,
      _filterGSTNumberC,
      _filterRERANumberC,
      _filterPANNumberC,
      _filterAadhaarNumberC,
      _filterSpecialityC,
      _filterCityC,
      _filterVillageC;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  final ValueNotifier<Map<String, dynamic>?> _selectedNoOfIBM = ValueNotifier(
    null,
  );
  final ValueNotifier<Map<String, dynamic>?> _selectedNoOfOBM = ValueNotifier(
    null,
  );

  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.channelPartner]!;
    _initializeTextEditingController();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _onScroll();
    _channelPartnerCubit.getChannelPartnerList(context, 1);
  }

  @override
  void dispose() {
    _searchC.dispose();
    _filterCompanyNameC.dispose();
    _filterDesignationC.dispose();
    _filterFirmTypeC.dispose();
    _filterTypeC.dispose();
    _filterMobileNumberC.dispose();
    _filterOfficeAddressC.dispose();
    _filterGSTNumberC.dispose();
    _filterRERANumberC.dispose();
    _filterPANNumberC.dispose();
    _filterAadhaarNumberC.dispose();
    _filterSpecialityC.dispose();
    _filterCityC.dispose();
    _filterVillageC.dispose();

    _filterCount.dispose();
    scrollController.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCompanyNameC = TextEditingController();
    _filterDesignationC = TextEditingController();
    _filterFirmTypeC = TextEditingController();
    _filterTypeC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterOfficeAddressC = TextEditingController();
    _filterGSTNumberC = TextEditingController();
    _filterRERANumberC = TextEditingController();
    _filterPANNumberC = TextEditingController();
    _filterAadhaarNumberC = TextEditingController();
    _filterSpecialityC = TextEditingController();
    _filterCityC = TextEditingController();
    _filterVillageC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_channelPartnerCubit.state.isLoading! &&
          _channelPartnerCubit.state.channelPartnerList.length <
              _channelPartnerCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _channelPartnerCubit.getChannelPartnerList(
            context,
            _channelPartnerCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // CHANNEL PARTNER FILTER
  Future<void> _showBottomSheetToFilterChannelPartner(
    BuildContext context,
  ) async {
    final state = _channelPartnerCubit.state;

    _searchC.text = state.searchText;
    _filterCompanyNameC.text = state.filterByCompanyName;
    _filterDesignationC.text = state.filterByDesignation;
    _filterFirmTypeC.text = state.filterByFirmType;
    _filterTypeC.text = state.filterByType;
    _filterMobileNumberC.text = state.filterByMobileNumber;
    _filterOfficeAddressC.text = state.filterByOfficeAddress;
    _filterGSTNumberC.text = state.filterByGSTNumber;
    _filterRERANumberC.text = state.filterByRERANumber;
    _filterPANNumberC.text = state.filterByPANNumber;
    _filterAadhaarNumberC.text = state.filterByAadhaarNumber;
    _filterSpecialityC.text = state.filterBySpeciality;
    _filterCityC.text = state.filterByCity;
    _filterVillageC.text = state.filterByVillage;

    String? selectedDirection =
        state.currentSortColumn == "Full Name"
            ? state.currentSortDirection
            : null;

    final String initialFullNameName = _searchC.text;
    final String initialCompanyName = _filterCompanyNameC.text;
    final String initialDesignation = _filterDesignationC.text;
    final String initialFirmType = _filterFirmTypeC.text;
    final String initialType = _filterTypeC.text;
    final String initialMobileNumber = _filterMobileNumberC.text;
    final String initialOfficeAddress = _filterOfficeAddressC.text;
    final String initialGSTNumber = _filterGSTNumberC.text;
    final String initialRERANumber = _filterRERANumberC.text;
    final String initialPANNumber = _filterPANNumberC.text;
    final String initialAadhaarNumber = _filterAadhaarNumberC.text;
    final String initialSpeciality = _filterSpecialityC.text;
    final String initialCity = _filterCityC.text;
    final String initialVillage = _filterVillageC.text;
    final String? initialDirection = selectedDirection;
    final initialNoOfIBM = state.filterByNoOfIBM;
    final initialNoOfOBM = state.filterByNoOfOBM;

    if (initialNoOfIBM.isNotEmpty) {
      _selectedNoOfIBM.value = ibmObmRangeFilter.firstWhere(
        (e) => e['DisplayName'] == initialNoOfIBM,
        orElse: () => ibmObmRangeFilter.first,
      );
    }
    if (initialNoOfOBM.isNotEmpty) {
      _selectedNoOfOBM.value = ibmObmRangeFilter.firstWhere(
        (e) => e['DisplayName'] == initialNoOfOBM,
        orElse: () => ibmObmRangeFilter.first,
      );
    }
    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      final currentNoOfIBM = _selectedNoOfIBM.value?['DisplayName'] ?? '';

      final currentNoOfOBM = _selectedNoOfOBM.value?['DisplayName'] ?? '';

      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialFullNameName) ||
            (_filterCompanyNameC.text.trim() != initialCompanyName) ||
            (_filterDesignationC.text.trim() != initialDesignation) ||
            (_filterFirmTypeC.text.trim() != initialFirmType) ||
            (_filterTypeC.text.trim() != initialType) ||
            (_filterMobileNumberC.text.trim() != initialMobileNumber) ||
            (_filterOfficeAddressC.text.trim() != initialOfficeAddress) ||
            (_filterGSTNumberC.text.trim() != initialGSTNumber) ||
            (_filterRERANumberC.text.trim() != initialRERANumber) ||
            (_filterPANNumberC.text.trim() != initialPANNumber) ||
            (_filterAadhaarNumberC.text.trim() != initialAadhaarNumber) ||
            (_filterSpecialityC.text.trim() != initialSpeciality) ||
            (_filterCityC.text.trim() != initialCity) ||
            (_filterVillageC.text.trim() != initialVillage) ||
            (currentNoOfIBM != initialNoOfIBM) ||
            (currentNoOfOBM != initialNoOfOBM) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
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
                  textController: _searchC,
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
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  keyboardType: TextInputType.number,
                  textController: _filterMobileNumberC,
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
                ValueListenableBuilder(
                  valueListenable: _selectedNoOfIBM,
                  builder: (context, noOfIBM, child) {
                    return CustomDropDownWidget(
                      title: 'No Of IBM',
                      hintText: 'Select No Of IBM',
                      initialValue: noOfIBM,
                      dataList: ibmObmRangeFilter,
                      onSelected: (v) {
                        _selectedNoOfIBM.value = v;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedNoOfIBM.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedNoOfOBM,
                  builder: (context, noOfOBM, child) {
                    return CustomDropDownWidget(
                      title: 'No Of OBM',
                      hintText: 'Select No Of OBM',
                      initialValue: noOfOBM,
                      dataList: ibmObmRangeFilter,
                      onSelected: (v) {
                        _selectedNoOfOBM.value = v;
                        updateApplyState(innerState);
                      },
                      onValueClear: () {
                        _selectedNoOfOBM.value = null;
                        updateApplyState(innerState);
                      },
                    );
                  },
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
        _filterMobileNumberC.clear();
        _filterOfficeAddressC.clear();
        _filterGSTNumberC.clear();
        _filterRERANumberC.clear();
        _filterPANNumberC.clear();
        _filterAadhaarNumberC.clear();
        _filterSpecialityC.clear();
        _filterCityC.clear();
        _filterVillageC.clear();
        _searchC.clear();
        _selectedNoOfIBM.value = null;
        _selectedNoOfOBM.value = null;
        selectedDirection = null;
        _channelPartnerCubit.applyChannelPartnerFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _channelPartnerCubit.applyChannelPartnerFilterAndSort(
          context: context,
          fullName: _searchC.text.trim(),
          companyName: _filterCompanyNameC.text.trim(),
          designation: _filterDesignationC.text.trim(),
          firmType: _filterFirmTypeC.text.trim(),
          type: _filterTypeC.text.trim(),
          mobileNumber: _filterMobileNumberC.text.trim(),
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
          noOfIBM: _selectedNoOfIBM.value?['DisplayName'] ?? "",
          noOfOBM: _selectedNoOfOBM.value?['DisplayName'] ?? "",
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _searchC.clear();
      _filterCompanyNameC.clear();
      _filterDesignationC.clear();
      _filterFirmTypeC.clear();
      _filterTypeC.clear();
      _filterMobileNumberC.clear();
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
    return BlocListener<ChannelPartnerCubit, ChannelPartnerState>(
      listener: (context, state) {
        _filterCount.value = _channelPartnerCubit.updateFilterCount();
        if (state.searchText.trim().isEmpty) {
          _searchC.clear();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Channel Partner",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          filterCountNotifier: _filterCount,
          onSearchSubmit: (value) {
            _channelPartnerCubit.searchChannelPartner(context, value);
          },
          searchHintText: "Search By Full Name",
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addChannelPartner);
          },
          onExportCallback: (value) {
            if (_channelPartnerCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _channelPartnerCubit.exportExcelPdf(context, value);
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterChannelPartner(context);
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _channelPartnerCubit.searchChannelPartner(context, "");
          },
          child: BlocBuilder<ChannelPartnerCubit, ChannelPartnerState>(
            builder: (context, state) {
              if ((state.isLoading ?? true) &&
                  state.channelPartnerList.isEmpty) {
                return Center(child: loader());
              }
              if (state.channelPartnerList.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: getActualHeight(context) * .7,
                      child: Center(
                        child: noDataWidget(
                          message: "No Channel Partner found",
                        ),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount:
                    _channelPartnerCubit.state.channelPartnerList.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.channelPartnerList.length) {
                    return state.channelPartnerList.length <
                            state.totalNumberOfRecord
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
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 10,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () async {
                                  goRouter.pushNamed(
                                    AppRoutes.channelPartnerView,
                                    queryParameters: {
                                      "channelPartner":
                                          Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(channelPartner),
                                            ),
                                          ),
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
                            Row(
                              spacing: 10,
                              children: [
                                if (channelPartner.verifiedNonVerified
                                        .toLowerCase() !=
                                    'verified') ...[
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
                                if (_routeAuthorizationModel.isAction)
                                  CustomIconButton.edit(
                                    onPressed: () async {
                                      goRouter.pushNamed(
                                        AppRoutes.addChannelPartner,
                                        queryParameters: {
                                          "channelPartner":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(channelPartner),
                                                ),
                                              ),
                                          "index": index.toString(),
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                        buildRowTitleValue(
                          title: "CP Code  ",
                          value: channelPartner.systemGeneratedCode,
                          customValueWidget: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  channelPartner.systemGeneratedCode,
                                  style: AppTextStyle.ts14M(),
                                ),
                              ),
                              horizontalSpacing(width: 2),
                              InkWell(
                                onTap: () {
                                  copy(
                                    context: context,
                                    text: channelPartner.systemGeneratedCode,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        buildRowTitleValue(
                          title: "Company Name",
                          value: channelPartner.companyName,
                          singleLine: false,
                        ),
                        buildRowTitleValue(
                          title: "Mobile Number",
                          value: channelPartner.mobileNumber,
                          customValueWidget: CustomClickToContactText(
                            countryCode: channelPartner.mobileNumberCountryCode,
                            value: channelPartner.mobileNumber,
                          ),
                        ),
                        buildRowTitleValue(
                          title: "RERA Number",
                          value: channelPartner.reraNumber,
                          singleLine: false,
                        ),
                        buildRowTitleValue(
                          title: "No Of IBM",
                          value: channelPartner.noOfIbm.toString(),
                          singleLine: false,
                        ),
                        buildRowTitleValue(
                          title: "No Of OBM",
                          value: channelPartner.noOfObm.toString(),
                          singleLine: false,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
