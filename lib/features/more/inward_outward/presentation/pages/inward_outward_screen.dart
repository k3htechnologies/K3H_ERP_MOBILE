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
  late AuthorizationModel _acknowlegmentRouteAuthorizationModel;
  late AuthorizationModel
  _inwardOutwardAdministrativeAccessRouteAuthorizationModel;
  late AuthorizationModel _routeAuthorizationModel;
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
        Authorization.routeAuthorizationMap[AppRoutes.inwardOutward] ??
        AuthorizationModel();
    _acknowlegmentRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .inwardOutwardAcknowledgement] ??
        AuthorizationModel();
    _inwardOutwardAdministrativeAccessRouteAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes
            .inwardOutwardAdministrativeAccess] ??
        AuthorizationModel();
    _routeAuthorizationModel = AuthorizationModel(
      isAction:
          _inwardOutwardAdministrativeAccessRouteAuthorizationModel.isAction ||
          _acknowlegmentRouteAuthorizationModel.isAction ||
          _inwardOutwardRouteAuthorizationModel.isAction,
      isExport:
          _inwardOutwardAdministrativeAccessRouteAuthorizationModel.isExport ||
          _acknowlegmentRouteAuthorizationModel.isExport ||
          _inwardOutwardRouteAuthorizationModel.isExport,
      isView:
          _inwardOutwardAdministrativeAccessRouteAuthorizationModel.isView ||
          _acknowlegmentRouteAuthorizationModel.isView ||
          _inwardOutwardRouteAuthorizationModel.isView,
    );
    _inwardOutwardCubit = context.read<InwardOutwardCubit>();
    _inwardOutwardCubit.resetState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => _handleTabChange());
    _initializeTextEditingController();
    _onScroll();
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

  void _onScroll() {
    _inwardOutwardScrollController = ScrollController();
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
          switch (_tabController.index) {
            case 0:
              _inwardOutwardCubit.getInwardOutwardList(
                context,
                state.inwardOutwardCurrentPage + 1,
              );
              break;
            case 1:
              _inwardOutwardCubit.getInwardList(
                context,
                state.inwardOutwardCurrentPage + 1,
              );
              break;
            case 2:
              _inwardOutwardCubit.getOutwardList(
                context,
                state.inwardOutwardCurrentPage + 1,
              );
              break;
          }
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
        state.currentSortColumn == "IO Code"
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
                Text("Sort By IO Code", style: AppTextStyle.ts14M()),
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
                  title: "IO Code",
                  hint: "Enter IO Code",
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
          sortColumn: selectedDirection != null ? "IO Code" : "",
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
          authorization: _routeAuthorizationModel,
          searchHintText: "Search By IO Code",
          textController: _searchC,
          filterCountNotifier: _filterCount,
          isFilterOn: true,
          onFilterTap: () => _showBottomSheetToFilterInwardOutward(context),
          onSearchSubmit:
              (v) => _inwardOutwardCubit.searchInwardOutward(context, v),
          onExportCallback: (v) {
            if (_inwardOutwardCubit.state.inwardOutwardList.isEmpty) {
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
            Expanded(child: _inwardOutwardSection()),
          ],
        ),
      ),
    );
  }

  Widget _inwardOutwardSection() {
    return BlocBuilder<InwardOutwardCubit, InwardOutwardState>(
      builder: (context, state) {
        final list = state.inwardOutwardList;
        if ((state.isLoading ?? true) && list.isEmpty) {
          return Center(child: loader());
        }
        if (list.isEmpty) {
          return Center(
            child: noDataWidget(
              message:
                  _tabController.index == 0
                      ? "No Inward Outward Data Found"
                      : _tabController.index == 1
                      ? "No Inward Data Found"
                      : "No Outward Data Found",
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => _inwardOutwardCubit.handleApiCall(context: context),
          child: ListView.separated(
            controller: _inwardOutwardScrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            separatorBuilder: (_, __) => verticalSpacing(height: 12),
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return list.length < state.inwardOutwardTotalRecords
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              final inwardOutward = list[index];
              final documentModeStyle =
                  inwardOutward.documentType.toLowerCase() == 'inward'
                      ? AppTextStyle.ts14B(color: AppColor.darkBlue29)
                      : AppTextStyle.ts14B(color: AppColor.darkRed);
              return inwardOutwardCard(
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

  Widget inwardOutwardCard({
    required InwardOutwardModel inwardOutward,
    required TextStyle documentModeStyle,
    required int index,
  }) {
    final disableRevert =
        !(_acknowlegmentRouteAuthorizationModel.isAction ||
            _inwardOutwardAdministrativeAccessRouteAuthorizationModel.isAction);
    final revertCount = inwardOutward.inwardOutwardRevertHistory.length;
    final disable =
        !_routeAuthorizationModel.isAction ||
        inwardOutward.deliveryStatus.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: commonCardDecoration(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
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
                    onPressed: () {
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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomIconButton(
                        isDisable: disableRevert,
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
                              disableRevert
                                  ? AppColor.grey2
                                  : AppColor.darkGreen,
                        ),
                      ),
                      if (revertCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color:
                                  disableRevert
                                      ? AppColor.red.withValues(alpha: 0.4)
                                      : AppColor.missingInformationRed
                                          .withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              revertCount > 99 ? '99+' : '$revertCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
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
            singleLine: false,
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
