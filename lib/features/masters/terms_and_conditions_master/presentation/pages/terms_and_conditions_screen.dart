import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen>
    with SingleTickerProviderStateMixin {
  // CUBIT
  late TermsAndConditionsCubit _termsAndConditionsCubit;

  // TEXT CONTROLLER
  late TextEditingController _searchC;

  // PROJECT
  late ProjectModel project;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // TAB CONTROLLER
  late TabController _tabController;

  // SCROLL CONTROLLERS
  late ScrollController _materialRequisitionScrollController;
  late ScrollController _bookingScrollController;

  // DEBOUNCE TIMER
  Timer? _materialRequisitionDebounce;
  Timer? _bookingDebounce;

  int _lastHandledTabIndex = 0;
  bool _isHandlingTabChange = false;

  @override
  void initState() {
    super.initState();
    _termsAndConditionsCubit = context.read<TermsAndConditionsCubit>();
    _searchC = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.termsAndConditions]!;
    project = getProject();

    // INITIALIZE SCROLL CONTROLLERS
    _materialRequisitionScrollController = ScrollController();
    _bookingScrollController = ScrollController();

    // ADD SCROLL LISTENER
    _materialRequisitionScrollController.addListener(
      _onMaterialRequisitionScroll,
    );
    _bookingScrollController.addListener(_onBookingScroll);

    // LOAD INITIAL DATA
    _termsAndConditionsCubit.getMaterialRequisitionTermsAndConditionList(
      context,
      1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchC.dispose();
    _materialRequisitionScrollController.dispose();
    _bookingScrollController.dispose();
    _materialRequisitionDebounce?.cancel();
    _bookingDebounce?.cancel();
    super.dispose();
  }

  // Same as Call Tracker: clear search, update state, call API once. Guard against double fire.
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_isHandlingTabChange) return;
    final index = _tabController.index;
    if (index == _lastHandledTabIndex) return;
    _isHandlingTabChange = true;
    _lastHandledTabIndex = index;
    _searchC.clear();
    _termsAndConditionsCubit.onTabChanged(index, context);
    if (index == 0) {
      _termsAndConditionsCubit.getMaterialRequisitionTermsAndConditionList(
        context,
        1,
        searchOverride: "",
      );
    } else if (index == 1) {
      _termsAndConditionsCubit.getBookingTermsAndConditionList(
        context,
        1,
        searchOverride: "",
      );
    }
    _isHandlingTabChange = false;
  }

  // PAGINATION - MATERIAL REQUISITION (only when on this tab, same as Call Tracker)
  void _onMaterialRequisitionScroll() {
    if (_tabController.index != 0) return;
    if (_materialRequisitionScrollController.position.pixels >=
            _materialRequisitionScrollController.position.maxScrollExtent -
                100 &&
        !_termsAndConditionsCubit.state.isLoading! &&
        _termsAndConditionsCubit
                .state
                .materialRequisitionTermsAndConditionsList
                .length <
            _termsAndConditionsCubit
                .state
                .materialRequisitionTotalNumberOfRecordTermsAndConditions) {
      if (_materialRequisitionDebounce?.isActive ?? false) {
        _materialRequisitionDebounce?.cancel();
      }
      _materialRequisitionDebounce = Timer(
        const Duration(milliseconds: 300),
        () {
          _termsAndConditionsCubit.getMaterialRequisitionTermsAndConditionList(
            context,
            _termsAndConditionsCubit
                    .state
                    .materialRequisitionCurrentPageTermsAndConditions +
                1,
          );
        },
      );
    }
  }

  // PAGINATION - BOOKING
  void _onBookingScroll() {
    if (_tabController.index != 1) return;
    if (_bookingScrollController.position.pixels >=
            _bookingScrollController.position.maxScrollExtent - 100 &&
        !_termsAndConditionsCubit.state.isLoading! &&
        _termsAndConditionsCubit.state.bookingTermsAndConditionsList.length <
            _termsAndConditionsCubit
                .state
                .bookingTotalNumberOfRecordTermsAndConditions) {
      if (_bookingDebounce?.isActive ?? false) {
        _bookingDebounce?.cancel();
      }
      _bookingDebounce = Timer(const Duration(milliseconds: 300), () {
        _termsAndConditionsCubit.getBookingTermsAndConditionList(
          context,
          _termsAndConditionsCubit.state.bookingCurrentPageTermsAndConditions +
              1,
        );
      });
    }
  }

  // DELETE DIALOG - MATERIAL REQUISITION
  Future<void> _showDeleteDialogMaterialRequisition(
    BuildContext context,
    TermsAndConditionsModel termsAndCondition,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a terms and condition?',
      'Deleting this terms and condition will permanently remove its contents.',
    );
    if (result == true && context.mounted) {
      _termsAndConditionsCubit.deleteMaterialRequisition(
        context: context,
        termsAndConditionsMasterId:
            termsAndCondition.termsAndConditionsMasterId,
        uniqueKey: termsAndCondition.uniquekey,
        pageNumber:
            _termsAndConditionsCubit
                .state
                .materialRequisitionCurrentPageTermsAndConditions,
        pageSize: 10,
        index: index,
      );
    }
  }

  // DELETE DIALOG - BOOKING
  Future<void> _showDeleteDialogBooking(
    BuildContext context,
    TermsAndConditionsModel termsAndCondition,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a terms and condition?',
      'Deleting this terms and condition will permanently remove its contents.',
    );
    if (result == true && context.mounted) {
      _termsAndConditionsCubit.deleteBooking(
        context: context,
        termsAndConditionsMasterId:
            termsAndCondition.termsAndConditionsMasterId,
        uniqueKey: termsAndCondition.uniquekey,
        pageNumber:
            _termsAndConditionsCubit.state.bookingCurrentPageTermsAndConditions,
        pageSize: 10,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        key: ValueKey<int>(_tabController.index),
        screenTitle: "Terms And Conditions Master",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search by Title",
        textController: _searchC,
        onSearchSubmit: (value) {
          if (_termsAndConditionsCubit.state.currentTabIndex == 0) {
            _termsAndConditionsCubit.searchMaterialRequisition(context, value);
          } else {
            _termsAndConditionsCubit.searchBooking(context, value);
          }
        },
        onAddCallback: () async {
          await goRouter.pushNamed(
            AppRoutes.addTermsAndConditions,
            queryParameters: {
              'tabIndex':
                  _termsAndConditionsCubit.state.currentTabIndex.toString(),
            },
          );
          if (context.mounted) {
            if (_termsAndConditionsCubit.state.currentTabIndex == 0) {
              _termsAndConditionsCubit
                  .getMaterialRequisitionTermsAndConditionList(context, 1);
            } else {
              _termsAndConditionsCubit.getBookingTermsAndConditionList(
                context,
                1,
              );
            }
          }
        },
        onExportCallback: (value) {
          if (_termsAndConditionsCubit.state.currentTabIndex == 0) {
            if (_termsAndConditionsCubit
                    .state
                    .materialRequisitionTotalNumberOfRecordTermsAndConditions ==
                0) {
              showErrorMessage(context, "Error", "No data found");
              return;
            }
            _termsAndConditionsCubit.exportExcelPdfMaterialRequisition(
              context,
              value,
            );
          } else {
            if (_termsAndConditionsCubit
                    .state
                    .bookingTotalNumberOfRecordTermsAndConditions ==
                0) {
              showErrorMessage(context, "Error", "No data found");
              return;
            }
            _termsAndConditionsCubit.exportExcelPdfBooking(context, value);
          }
        },
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
                      Tab(text: 'Material Requisition'),
                      Tab(text: 'Booking'),
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
                  // MATERIAL REQUISITION TAB
                  BlocBuilder<TermsAndConditionsCubit, TermsAndConditionsState>(
                    builder: (context, state) {
                      if ((state.isLoading ?? true) &&
                          state
                              .materialRequisitionTermsAndConditionsList
                              .isEmpty) {
                        return Center(child: loader());
                      }
                      if (state
                          .materialRequisitionTermsAndConditionsList
                          .isEmpty) {
                        return Center(child: noDataWidget(message: "No terms & conditions found"));
                      }
                      return ListView.builder(
                        controller: _materialRequisitionScrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount:
                            state
                                .materialRequisitionTermsAndConditionsList
                                .length +
                            1,
                        itemBuilder: (context, index) {
                          if (index ==
                              state
                                  .materialRequisitionTermsAndConditionsList
                                  .length) {
                            return state
                                        .materialRequisitionTermsAndConditionsList
                                        .length <
                                    state
                                        .materialRequisitionTotalNumberOfRecordTermsAndConditions
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }
                          var termsAndCondition =
                              state
                                  .materialRequisitionTermsAndConditionsList[index];
                          return _buildTermsAndConditionCard(
                            termsAndCondition: termsAndCondition,
                            index: index,
                            isMaterialRequisition: true,
                          );
                        },
                      );
                    },
                  ),
                  // BOOKING TAB
                  BlocBuilder<TermsAndConditionsCubit, TermsAndConditionsState>(
                    builder: (context, state) {
                      if ((state.isLoading ?? true) &&
                          state.bookingTermsAndConditionsList.isEmpty) {
                        return Center(child: loader());
                      }
                      if (state.bookingTermsAndConditionsList.isEmpty) {
                        return Center(child: noDataWidget(message: "No terms & conditions found"));
                      }
                      return ListView.builder(
                        controller: _bookingScrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount:
                            state.bookingTermsAndConditionsList.length + 1,
                        itemBuilder: (context, index) {
                          if (index ==
                              state.bookingTermsAndConditionsList.length) {
                            return state.bookingTermsAndConditionsList.length <
                                    state
                                        .bookingTotalNumberOfRecordTermsAndConditions
                                ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : const SizedBox.shrink();
                          }
                          var termsAndCondition =
                              state.bookingTermsAndConditionsList[index];
                          return _buildTermsAndConditionCard(
                            termsAndCondition: termsAndCondition,
                            index: index,
                            isMaterialRequisition: false,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditionCard({
    required TermsAndConditionsModel termsAndCondition,
    required int index,
    required bool isMaterialRequisition,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    goRouter.pushNamed(
                      AppRoutes.viewTermsAndConditions,
                      queryParameters: {
                        "tnc": Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(termsAndCondition),
                          ),
                        ),
                      },
                    );
                  },
                  child: Text(
                    termsAndCondition.title,
                    style: AppTextStyle.ts16M(color: AppColor.primary).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColor.primary,
                    ),
                  ),
                ),
              ),
              if(_routeAuthorizationModel.isAction)...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconButton.edit(
                      onPressed: () async {
                        await goRouter.pushNamed(
                          AppRoutes.addTermsAndConditions,
                          queryParameters: {
                            "termsAndCondition": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(termsAndCondition.toJson()),
                              ),
                            ),
                            'index': index.toString(),
                            'tabIndex': isMaterialRequisition ? '0' : '1',
                          },
                        );
                      },
                    ),
                    horizontalSpacing(),
                    CustomIconButton.delete(
                      onPressed: () {
                        if (isMaterialRequisition) {
                          _showDeleteDialogMaterialRequisition(
                            context,
                            termsAndCondition,
                            index,
                          );
                        } else {
                          _showDeleteDialogBooking(
                            context,
                            termsAndCondition,
                            index,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
