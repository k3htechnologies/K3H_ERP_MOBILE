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
  late TextEditingController _searchC;

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

    String? selectedDirection =
        state.currentSortColumn == "Full Name"
            ? state.currentSortDirection
            : null;

    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose = (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Channel Partner Sourcing",
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
                Text("Sort By CP Code", style: AppTextStyle.ts14M()),
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
              ],
            ),
          );
        },
      ),
      onClear: () {
        _sourcingCubit.applyChannelPartnerSourcingFilterAndSort(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        _sourcingCubit.applyChannelPartnerSourcingFilterAndSort(
          context: context,
          sortColumn: selectedDirection != null ? "Full Name" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
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
                        value: channelPartner.mobileNumber,
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
                      singleLine: false
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
