import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late AuthorizationModel _routeAuthorizationModel;

  late InwardOutwardCubit _inwardOutwardCubit;

  late TabController _tabController;
  late TextEditingController _searchC,
      _senderNameC,
      _receiverNameC,
      _documentTypeC;
  late ScrollController _inwardOutwardScrollController;
  Timer? _inwardOutwardDebounce;
  late ScrollController _inwardScrollController;
  Timer? _inwardDebounce;
  late ScrollController _outwardScrollController;
  Timer? _outwardDebounce;
  @override
  void initState() {
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.inwardOutward]!;
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => _handleTabChange());
    _initializeTextEditingController();
    _initializePagination();
    _inwardOutwardCubit.getInwardOutwardList(context, 1);
    super.initState();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _senderNameC = TextEditingController();
    _receiverNameC = TextEditingController();
    _documentTypeC = TextEditingController();
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
    _inwardScrollController = ScrollController();
    _outwardScrollController = ScrollController();
    _setupInwardOutwardPagination();
    _setupInwardPagination();
    _setupOutwardPagination();
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

  void _setupInwardPagination() {
    _inwardScrollController.addListener(() {
      final state = _inwardOutwardCubit.state;
      if (_inwardScrollController.position.pixels >=
              _inwardScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.inwardList.length < state.inwardTotalRecords) {
        if (_inwardDebounce?.isActive ?? false) {
          _inwardDebounce?.cancel();
        }

        _inwardDebounce = Timer(const Duration(milliseconds: 300), () {
          _inwardOutwardCubit.getInwardList(
            context,
            state.inwardCurrentPage + 1,
          );
        });
      }
    });
  }

  void _setupOutwardPagination() {
    _outwardScrollController.addListener(() {
      final state = _inwardOutwardCubit.state;
      if (_outwardScrollController.position.pixels >=
              _outwardScrollController.position.maxScrollExtent - 100 &&
          !(state.isLoading ?? false) &&
          state.outwardList.length < state.outwardTotalRecords) {
        if (_outwardDebounce?.isActive ?? false) {
          _outwardDebounce?.cancel();
        }

        _outwardDebounce = Timer(const Duration(milliseconds: 300), () {
          _inwardOutwardCubit.getOutwardList(
            context,
            state.outwardCurrentPage + 1,
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

    final String? initialDirection =
        state.currentSortColumn == "SystemGeneratedCode"
            ? state.currentSortDirection
            : null;
    _searchC.text = initialDocumentId;
    _documentTypeC.text = initialDocumentType;
    _senderNameC.text = initialSenderName;
    _receiverNameC.text = initialReceiverName;

    String? selectedDirection = initialDirection;

    bool applied = false;
    bool manualClose = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState() {
      manualClose =
          (_searchC.text.trim() != initialDocumentId) ||
          (_senderNameC.text.trim() != initialSenderName) ||
          (_receiverNameC.text.trim() != initialReceiverName) ||
          (_documentTypeC.text.trim() != initialDocumentType) ||
          (selectedDirection != initialDirection);

      applyEnabled.value = manualClose;
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter Inward Outward",

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
                CustomTextField(
                  textController: _documentTypeC,
                  title: "Document Type",
                  hint: "Enter Document Type",
                  onChangeFunction: (_) => updateApplyState(),
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
          documentType: _documentTypeC.text.trim(),
          receiverName: _receiverNameC.text.trim(),
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
      'You are about to delete this Inward Outward',
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
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Inward Outward",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search By Document Id",
        textController: _searchC,
        isFilterOn: true,
        onFilterTap: () => _showBottomSheetToFilterInwardOutward(context),
        onSearchSubmit: (v) {
          _inwardOutwardCubit.searchInwardOutward(context, v);
        },
        onExportCallback: (v) {
          _inwardOutwardCubit.exportExcelPdf(context, v);
        },
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addInwardOutward);
        },
      ),
      body: Column(
        children: [
          ChipStyleTabBar(controller: _tabController, tabs: inwardOutwardTabs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [inwardOutwardView(), inwardView(), outwardView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget inwardOutwardView() {
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
        return ListView.separated(
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
                    ? AppTextStyle.ts14B(color: const Color(0xFF13367A))
                    : AppTextStyle.ts14B(color: const Color(0xFFD32F2F));
            final disable =
                !_routeAuthorizationModel.isAction ||
                (inwardOutward.deliveryStatus.toLowerCase().contains(
                  'delivered',
                ));
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
                          onTap: () async {},
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
                            onPressed: () async {},
                          ),
                          CustomIconButton.delete(
                            isDisabled: disable,
                            onPressed:
                                () => _showPopupToDeleteInwardOutward(
                                  context: context,
                                  index: index,
                                  inwardOutwardId:
                                      inwardOutward.inwardOutwardId,
                                  uniqueKey: inwardOutward.uniqueKey,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildRowTitleValue(
                    title: "Document Mode",
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
          },
        );
      },
    );
  }

  Widget inwardView() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.inwardList.isEmpty) {
          return Center(child: loader());
        }
        if (state.inwardList.isEmpty) {
          return Center(child: noDataWidget(message: "No Inward Data Found"));
        }
        return ListView.separated(
          controller: _inwardScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          separatorBuilder: (context, index) => verticalSpacing(height: 12),
          itemCount: state.inwardList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.inwardList.length) {
              return state.inwardList.length < state.inwardTotalRecords
                  ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final inward = state.inwardList[index];
            final disable =
                !_routeAuthorizationModel.isAction ||
                (inward.deliveryStatus.toLowerCase().contains('delivered'));
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
                          onTap: () async {},
                          child: Text(
                            inward.systemGeneratedCode,
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          CustomIconButton.edit(
                            isDisabled: disable,
                            onPressed: () async {},
                          ),
                          CustomIconButton.delete(
                            isDisabled: disable,
                            onPressed:
                                () => _showPopupToDeleteInwardOutward(
                                  context: context,
                                  index: index,
                                  inwardOutwardId: inward.inwardOutwardId,
                                  uniqueKey: inward.uniqueKey,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildRowTitleValue(
                    title: "Document Mode",
                    value: inward.documentType,
                    valueTextStyle: AppTextStyle.ts14B(
                      color: const Color(0xFF13367A),
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Document Title",
                    value: inward.documentTitle,
                  ),
                  buildRowTitleValue(
                    title: "Status",
                    value: inward.deliveryStatus,
                    customValueWidget: inwardOutwarDeliveryStatusWidget(
                      inward.deliveryStatus,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget outwardView() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.outwardList.isEmpty) {
          return Center(child: loader());
        }
        if (state.outwardList.isEmpty) {
          return Center(child: noDataWidget(message: "No Outward Data Found"));
        }
        return ListView.separated(
          controller: _outwardScrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          separatorBuilder: (context, index) => verticalSpacing(height: 12),
          itemCount: state.outwardList.length + 1,
          itemBuilder: (context, index) {
            if (index == state.outwardList.length) {
              return state.outwardList.length < state.outwardTotalRecords
                  ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final outward = state.outwardList[index];
            final disable =
                !_routeAuthorizationModel.isAction ||
                (outward.deliveryStatus.toLowerCase().contains('delivered'));
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
                          onTap: () async {},
                          child: Text(
                            outward.systemGeneratedCode,
                            style: AppTextStyle.ts16M(color: AppColor.primary),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          CustomIconButton.edit(
                            isDisabled: disable,
                            onPressed: () async {},
                          ),
                          CustomIconButton.delete(
                            isDisabled: disable,
                            onPressed:
                                () => _showPopupToDeleteInwardOutward(
                                  context: context,
                                  index: index,
                                  inwardOutwardId: outward.inwardOutwardId,
                                  uniqueKey: outward.uniqueKey,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  buildRowTitleValue(
                    title: "Document Mode",
                    value: outward.documentType,
                    valueTextStyle: AppTextStyle.ts14B(
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                  buildRowTitleValue(
                    title: "Document Title",
                    value: outward.documentTitle,
                  ),
                  buildRowTitleValue(
                    title: "Status",
                    value: outward.deliveryStatus,
                    customValueWidget: inwardOutwarDeliveryStatusWidget(
                      outward.deliveryStatus,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
