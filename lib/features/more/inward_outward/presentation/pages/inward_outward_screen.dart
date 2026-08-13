import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_from_to_date_picker.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class InwardOutwardScreen extends StatefulWidget {
  const InwardOutwardScreen({super.key});

  @override
  State<InwardOutwardScreen> createState() => _InwardOutwardScreenState();
}

class _InwardOutwardScreenState extends State<InwardOutwardScreen>
    with TickerProviderStateMixin {
  late AuthorizationModel _inwardOutwardRouteAuthorizationModel;

  late InwardOutwardCubit _inwardOutwardCubit;

  late TabController _tabController;
  late TextEditingController _searchC,
      _senderNameC,
      _receiverNameC,
      _documentTypeC,
      _documentTitleC,
      _statusC,
      _senderMobileNumberC,
      _receiverMobileNumberC;

  DateTime? _selectedFromDate, _selectedToDate;

  late ScrollController _inwardOutwardScrollController;
  Timer? _inwardOutwardDebounce;

  final ValueNotifier<int> _filterCount = ValueNotifier(0);
List<String> inwardOutwardTabs = const ['All', 'Inward', 'Outward'];

  @override
  void initState() {
    _inwardOutwardRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.inwardOutward]!;
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _inwardOutwardCubit.resetState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => _handleTabChange());
    _initializeTextEditingController();
    _initializePagination();
    _inwardOutwardCubit.getInwardOutwardList(context, 1);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();

    _searchC.dispose();
    _senderNameC.dispose();
    _receiverNameC.dispose();
    _documentTypeC.dispose();
    _documentTitleC.dispose();
    _statusC.dispose();
    _senderMobileNumberC.dispose();
    _receiverMobileNumberC.dispose();
    _inwardOutwardScrollController.dispose();

    _inwardOutwardDebounce?.cancel();

    _filterCount.dispose();
    super.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _senderNameC = TextEditingController();
    _receiverNameC = TextEditingController();
    _documentTypeC = TextEditingController();
    _documentTitleC = TextEditingController();
    _statusC = TextEditingController();
    _senderMobileNumberC = TextEditingController();
    _receiverMobileNumberC = TextEditingController();
  }

  void _handleTabChange() async {
    if (!_tabController.indexIsChanging) {
      _searchC.clear();
      _documentTypeC.clear();
      _senderNameC.clear();
      _receiverNameC.clear();
      _inwardOutwardCubit.handleTabChange(
        context: context,
        currentTabIndex: _tabController.index,
      );
    }
  }

  void _initializePagination() {
    _inwardOutwardScrollController = ScrollController();

    _setupInwardOutwardPagination();
  }

  void _setupInwardOutwardPagination() {
    _inwardOutwardScrollController.addListener(() {
      final state = _inwardOutwardCubit.state;
      if (_inwardOutwardScrollController.position.pixels >=
              _inwardOutwardScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.inwardOutwardList.length < state.inwardOutwardTotalRecords) {
        if (_inwardOutwardDebounce?.isActive ?? false) {
          _inwardOutwardDebounce?.cancel();
        }

        _inwardOutwardDebounce = Timer(const Duration(milliseconds: 300), () {
          _inwardOutwardCubit.getInwardOutwardList(
            context,
            state.inwardOutwardCurrentPage + 1,
          );
        });
      }
    });
  }

  Future<void> _showBottomSheetToFilterInwardOutward(
    BuildContext context,
  ) async {
    final state = _inwardOutwardCubit.state;

    final initialDocumentId = state.searchText;
    final initialDocumentType = state.filterByDocumentType;
    final initialSenderName = state.filterBySenderName;
    final initialReceiverName = state.filterByReceiverName;
    final initialDocumentTitle = state.filterByDocumentTitle;
    final initialStatus = state.filterByStatus;
    final initialSenderMobileNumber = state.filterBySenderMobileNumber;
    final initialReceiverMobileNumber = state.filterByReceiverMobileNumber;
    final initialFromDate = state.filterByFromDate;
    final initialToDate = state.filterByToDate;

    final String? initialDirection =
        state.currentSortColumn == "Document Id"
            ? state.currentSortDirection
            : null;

    _searchC.text = initialDocumentId;
    _documentTypeC.text = initialDocumentType;
    _senderNameC.text = initialSenderName;
    _receiverNameC.text = initialReceiverName;
    _documentTitleC.text = initialDocumentTitle;
    _statusC.text = initialStatus;
    _senderMobileNumberC.text = initialSenderMobileNumber;
    _receiverMobileNumberC.text = initialReceiverMobileNumber;
    _selectedFromDate = initialFromDate;
    _selectedToDate = initialToDate;

    String? selectedDirection = initialDirection;

    bool applied = false;
    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState() {
      final bool onlyOneDateSet =
          (_selectedFromDate != null && _selectedToDate == null) ||
          (_selectedToDate != null && _selectedFromDate == null);
      manualClose =
          (_searchC.text.trim() != initialDocumentId) ||
          (_senderNameC.text.trim() != initialSenderName) ||
          (_receiverNameC.text.trim() != initialReceiverName) ||
          (_documentTypeC.text.trim() != initialDocumentType) ||
          (_documentTitleC.text.trim() != initialDocumentTitle) ||
          (_statusC.text.trim() != initialStatus) ||
          (_senderMobileNumberC.text.trim() != initialSenderMobileNumber) ||
          (_receiverMobileNumberC.text.trim() != initialReceiverMobileNumber) ||
          (_selectedFromDate != initialFromDate) ||
          (_selectedToDate != initialToDate) ||
          (selectedDirection != initialDirection);

      applyEnabled.value = manualClose && !onlyOneDateSet;
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Inward Outward",

      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
              updateApplyState();
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Document Id", style: AppTextStyle.ts14M()),

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
                          border: Border.all(color: AppColor.grey, width: 0.5),
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
                          border: Border.all(color: AppColor.grey, width: 0.5),
                        ),
                        child: Text("Z-A", style: AppTextStyle.ts12R()),
                      ),
                    ),
                  ],
                ),

                verticalSpacing(height: 20),

                CustomTextField(
                  textController: _searchC,
                  title: "Document Id",
                  hint: "Enter Document Id",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _senderNameC,
                  title: "Sender Name",
                  hint: "Enter Sender Name",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _receiverNameC,
                  title: "Receiver Name",
                  hint: "Enter Receiver Name",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                if (_tabController.index == 0)
                  CustomTextField(
                    textController: _documentTypeC,
                    title: "Document Type",
                    hint: "Enter Document Type",
                    onChangeFunction: (_) => updateApplyState(),
                  ),

                CustomTextField(
                  textController: _documentTitleC,
                  title: "Document Title",
                  hint: "Enter Document Title",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _statusC,
                  title: "Status",
                  hint: "Enter Status",
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _senderMobileNumberC,
                  title: "Sender Mobile Number",
                  hint: "Enter Sender Mobile Number",
                  inputFormatterList: InputValidator.digit(10),
                  keyboardType: TextInputType.number,
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomTextField(
                  textController: _receiverMobileNumberC,
                  title: "Receiver Mobile Number",
                  hint: "Enter Receiver Mobile Number",
                  keyboardType: TextInputType.number,
                  inputFormatterList: InputValidator.digit(10),
                  onChangeFunction: (_) => updateApplyState(),
                ),

                CustomFromToDatePicker(
                  fromDateTitle: "From Date",
                  toDateTitle: "To Date",
                  initialFromDate: _selectedFromDate,
                  initialToDate: _selectedToDate,
                  onToDateChanged: (DateTime? fromDate, DateTime? toDate) {
                    innerState(() {
                      _selectedFromDate = fromDate;
                      _selectedToDate = toDate;
                      updateApplyState();
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),

      onClear: () async {
        _searchC.clear();
        _documentTypeC.clear();
        _senderNameC.clear();
        _receiverNameC.clear();
        _documentTitleC.clear();
        _statusC.clear();
        _senderMobileNumberC.clear();
        _receiverMobileNumberC.clear();

        _selectedFromDate = null;
        selectedDirection = null;

        await _inwardOutwardCubit.applyInwardOutwardFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _inwardOutwardCubit.applyInwardOutwardFilterAndSort(
          context: context,
          documentId: _searchC.text.trim(),
          senderName: _senderNameC.text.trim(),
          receiverName: _receiverNameC.text.trim(),
          documentType: _documentTypeC.text.trim(),
          documentTitle: _documentTitleC.text.trim(),
          status: _statusC.text.trim(),
          senderMobileNumber: _senderMobileNumberC.text.trim(),
          receiverMobileNumber: _receiverMobileNumberC.text.trim(),
          fromDate: _selectedFromDate,
          toDate: _selectedToDate,
          sortColumn: selectedDirection != null ? "Document Id" : "",
          sortDirection: selectedDirection ?? "",
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    if (!applied && manualClose) {
      _searchC.clear();
      _documentTypeC.clear();
      _senderNameC.clear();
      _receiverNameC.clear();
      _documentTitleC.clear();
      _statusC.clear();
      _senderMobileNumberC.clear();
      _receiverMobileNumberC.clear();

      _selectedFromDate = null;
      selectedDirection = null;
    }
  }

  void _showPopupToDeleteInwardOutward({
    required int index,
    required int inwardOutwardId,
    required String uniqueKey,
    required BuildContext context,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete this Inward Outward ?',
      'Deleting this Inward Outward will permanently remove its contents.',
    );

    if (result && context.mounted) {
      _inwardOutwardCubit.deleteInwardOutward(
        index: index,
        inwardOutwardId: inwardOutwardId,
        uniqueKey: uniqueKey,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InwardOutwardCubit, InwardOutwardState>(
      listener: (context, state) {
        _filterCount.value = _inwardOutwardCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Inward Outward",
          authorization: _inwardOutwardRouteAuthorizationModel,
          searchHintText: "Search By Document Id",
          textController: _searchC,
          filterCountNotifier: _filterCount,
          isFilterOn: true,
          onFilterTap: () => _showBottomSheetToFilterInwardOutward(context),
          onSearchSubmit: (v) {
            _inwardOutwardCubit.searchInwardOutward(context, v);
          },
          onExportCallback: (v) {
            if (context
                .read<InwardOutwardCubit>()
                .state
                .inwardOutwardList
                .isEmpty) {
              showErrorMessage(context, "Error", "No Data Found.");
              return;
            }
            _inwardOutwardCubit.exportExcelPdf(context, v);
          },
          onAddCallback: () {
            goRouter.pushNamed(AppRoutes.addInwardOutward);
          },
        ),
        body: Column(
          children: [
            ChipStyleTabBar(
              controller: _tabController,
              tabs: inwardOutwardTabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  inwardOutwardSection(),
                  inwardSection(),
                  outwardSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget inwardOutwardSection() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.inwardOutwardList.isEmpty) {
          return Center(child: loader());
        }
        if (state.inwardOutwardList.isEmpty) {
          return Center(
            child: noDataWidget(message: "No Inward Outward Data Found"),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            _inwardOutwardCubit.handleTabChange(
              context: context,
              currentTabIndex: _tabController.index,
            );
          },
          child: ListView.separated(
            controller: _inwardOutwardScrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            separatorBuilder: (context, index) => verticalSpacing(height: 12),
            itemCount: state.inwardOutwardList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.inwardOutwardList.length) {
                return state.inwardOutwardList.length <
                        state.inwardOutwardTotalRecords
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }

              final inwardOutward = state.inwardOutwardList[index];
              final documentModeStyle =
                  inwardOutward.documentType.toLowerCase() == 'inward'
                      ? AppTextStyle.ts14B(color: AppColor.darkBlue29)
                      : AppTextStyle.ts14B(color: AppColor.darkRed);
              final disable =
                  !_inwardOutwardRouteAuthorizationModel.isAction ||
                  (inwardOutward.deliveryStatus.isNotEmpty);
              return inwardOutwardCard(
                disable: disable,
                index: index,
                inwardOutward: inwardOutward,
                documentModeStyle: documentModeStyle,
              );
            },
          ),
        );
      },
    );
  }

  Widget inwardSection() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.inwardOutwardList.isEmpty) {
          return Center(child: loader());
        }
        if (state.inwardOutwardList.isEmpty) {
          return Center(child: noDataWidget(message: "No Inward Data Found"));
        }
        return RefreshIndicator(
          onRefresh: () async {
            _inwardOutwardCubit.handleTabChange(
              context: context,
              currentTabIndex: _tabController.index,
            );
          },
          child: ListView.separated(
            controller: _inwardOutwardScrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            separatorBuilder: (context, index) => verticalSpacing(height: 12),
            itemCount: state.inwardOutwardList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.inwardOutwardList.length) {
                return state.inwardOutwardList.length <
                        state.inwardOutwardTotalRecords
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }

              final inward = state.inwardOutwardList[index];
              final documentModeStyle =
                  inward.documentType.toLowerCase() == 'inward'
                      ? AppTextStyle.ts14B(color: AppColor.darkBlue29)
                      : AppTextStyle.ts14B(color: AppColor.darkRed);
              final disable =
                  !_inwardOutwardRouteAuthorizationModel.isAction ||
                  (inward.deliveryStatus.isNotEmpty);
              return inwardOutwardCard(
                disable: disable,
                inwardOutward: inward,
                documentModeStyle: documentModeStyle,
                index: index,
              );
            },
          ),
        );
      },
    );
  }

  Widget outwardSection() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.inwardOutwardList.isEmpty) {
          return Center(child: loader());
        }
        if (state.inwardOutwardList.isEmpty) {
          return Center(child: noDataWidget(message: "No Outward Data Found"));
        }
        return RefreshIndicator(
          onRefresh: () async {
            _inwardOutwardCubit.handleTabChange(
              context: context,
              currentTabIndex: _tabController.index,
            );
          },
          child: ListView.separated(
            controller: _inwardOutwardScrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            separatorBuilder: (context, index) => verticalSpacing(height: 12),
            itemCount: state.inwardOutwardList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.inwardOutwardList.length) {
                return state.inwardOutwardList.length <
                        state.inwardOutwardTotalRecords
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }

              final outward = state.inwardOutwardList[index];
              final documentModeStyle =
                  outward.documentType.toLowerCase() == 'inward'
                      ? AppTextStyle.ts14B(color: AppColor.darkBlue29)
                      : AppTextStyle.ts14B(color: AppColor.darkRed);
              final disable =
                  !_inwardOutwardRouteAuthorizationModel.isAction ||
                  (outward.deliveryStatus.isNotEmpty);
              return inwardOutwardCard(
                disable: disable,
                index: index,
                inwardOutward: outward,
                documentModeStyle: documentModeStyle,
              );
            },
          ),
        );
      },
    );
  }

  Widget inwardOutwardCard({
    required InwardOutwardModel inwardOutward,
    required bool disable,
    required TextStyle documentModeStyle,
    required int index,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: commonCardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    goRouter.pushNamed(
                      AppRoutes.viewInwardOutward,
                      queryParameters: {
                        'inwardOutward': Uri.encodeComponent(
                          EncryptionManager.encryptData(
                            jsonEncode(inwardOutward.toJson()),
                          ),
                        ),
                      },
                    );
                  },
                  child: Text(
                    inwardOutward.systemGeneratedCode,
                    style: AppTextStyle.ts16M(color: AppColor.primary),
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  CustomIconButton.edit(
                    isDisabled: disable,
                    onPressed: () async {
                      goRouter.pushNamed(
                        AppRoutes.addInwardOutward,
                        queryParameters: {
                          'inwardOutward': Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(inwardOutward.toJson()),
                            ),
                          ),
                          'index': index.toString(),
                        },
                      );
                    },
                  ),
                  CustomIconButton.delete(
                    isDisabled: disable,
                    onPressed:
                        () => _showPopupToDeleteInwardOutward(
                          context: context,
                          index: index,
                          inwardOutwardId: inwardOutward.inwardOutwardId,
                          uniqueKey: inwardOutward.uniqueKey,
                        ),
                  ),
                  CustomIconButton(
                    isDisable: !_inwardOutwardRouteAuthorizationModel.isAction,
                    onPressed: () {
                      goRouter.pushNamed(
                        AppRoutes.revertInwardOutward,
                        queryParameters: {
                          "inwardOutwardId": Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(
                              inwardOutward.inwardOutwardId.toString(),
                            ),
                          ),
                          "uniquekey": Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(
                              inwardOutward.uniqueKey,
                            ),
                          ),
                          "index": Uri.encodeQueryComponent(
                            EncryptionManager.encryptData(index.toString()),
                          ),
                        },
                      );
                    },
                    backgroundColor: AppColor.lightGreen,
                    icon: Icon(
                      Icons.refresh,
                      size: 16,
                      color:
                          _inwardOutwardRouteAuthorizationModel.isAction
                              ? AppColor.darkGreen
                              : AppColor.grey2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          buildRowTitleValue(
            title: "Document Type",
            value: inwardOutward.documentType,
            valueTextStyle: documentModeStyle,
          ),
          buildRowTitleValue(
            title: "Document Title",
            value: inwardOutward.documentTitle,
          ),
          buildRowTitleValue(
            title: "Status",
            value: inwardOutward.deliveryStatus,
            customValueWidget: inwardOutwarDeliveryStatusWidget(
              inwardOutward.deliveryStatus,
            ),
          ),
        ],
      ),
    );
  }
}
