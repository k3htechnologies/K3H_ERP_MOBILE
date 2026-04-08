import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/channel_partner/data/model/channel_partner.model.dart';
import 'package:k3h_erp_app/features/channel_partner/presentation/cubit/channel_partner_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_click_to_contact_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
      _filterMobileNumberC,
      _filterVillageC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.channelPartner]!;
    _initControllers();
    _channelPartnerCubit = context.read<ChannelPartnerCubit>();
    _onScroll();
    _channelPartnerCubit.getChannelPartnerList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterCompanyNameC.dispose();
    _filterMobileNumberC.dispose();
    _filterVillageC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
    _filterCompanyNameC = TextEditingController();
    _filterMobileNumberC = TextEditingController();
    _filterVillageC = TextEditingController();
  }

  // <---- PAGINATION ---->
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

    _filterCompanyNameC.text = state.filterByCompanyName;
    _filterMobileNumberC.text = state.filterByMobileNumber;
    _filterVillageC.text = state.filterByVillage;

    String? selectedDirection =
        state.currentSortColumn == "Full Name"
            ? state.currentSortDirection
            : null;

    final String initialCompanyName = _filterCompanyNameC.text;
    final String initialMobileNumber = _filterMobileNumberC.text;
    final String initialVillage = _filterVillageC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterCompanyNameC.text.trim() != initialCompanyName) ||
            (_filterVillageC.text.trim() != initialVillage) ||
            (_filterMobileNumberC.text.trim() != initialMobileNumber) ||
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
            padding: EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Full Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  title: "Company Name",
                  hint: "Enter Company Name",
                  textController: _filterCompanyNameC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Mobile Number",
                  hint: "Enter Mobile Number",
                  textController: _filterMobileNumberC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
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
        _filterVillageC.clear();
        _filterMobileNumberC.clear();
        _channelPartnerCubit.applyChannelPartnerFilterAndSort(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        _channelPartnerCubit.applyChannelPartnerFilterAndSort(
          context: context,
          companyName: _filterCompanyNameC.text.trim(),
          village: _filterVillageC.text.trim(),
          mobileNumber: _filterMobileNumberC.text.trim(),
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
      _filterVillageC.clear();
      _filterMobileNumberC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Channel Partner",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
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
            if ((state.isLoading ?? true) && state.channelPartnerList.isEmpty) {
              return Center(child: loader());
            }
            if (state.channelPartnerList.isEmpty) {
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: getActualHeight(context) * .7,
                    child: Center(
                      child: noDataWidget(message: "No Channel Partner found"),
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
                                    "channelPartner": Uri.encodeQueryComponent(
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
                              if(_routeAuthorizationModel.isAction)
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
                        title: "CP Code",
                        value: channelPartner.systemGeneratedCode,
                        singleLine: false,
                      ),
                      buildRowTitleValue(
                        title: "Company Name",
                        value: channelPartner.companyName,
                      ),
                      buildRowTitleValue(
                        title: "Mobile Number",
                        value: channelPartner.mobileNumber,
                        customValueWidget: CustomClickToContactText(
                          value: channelPartner.mobileNumber,
                        ),
                      ),
                      buildRowTitleValue(
                        title: "RERA Number",
                        value: channelPartner.reraNumber,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
