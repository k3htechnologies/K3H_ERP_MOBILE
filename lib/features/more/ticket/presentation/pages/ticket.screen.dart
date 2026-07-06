import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late TicketCubit _ticketCubit;
  late AuthorizationModel _routeAuthorizationModel;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterTicketId,
      _filterPlatform,
      _filterModule,
      _filterPriority,
      _filterDepartmentName,
      _filterStatus;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.ticket]!;
    _ticketCubit = context.read<TicketCubit>();
    _initializeTextEditingController();
    _ticketCubit.getTicketList(context, 1);
    _onScroll();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    _searchC.dispose();
    _filterTicketId.dispose();
    _filterPlatform.dispose();
    _filterModule.dispose();
    _filterPriority.dispose();
    _filterDepartmentName.dispose();
    _filterStatus.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterTicketId = TextEditingController();
    _filterPlatform = TextEditingController();
    _filterModule = TextEditingController();
    _filterPriority = TextEditingController();
    _filterDepartmentName = TextEditingController();
    _filterStatus = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_ticketCubit.state.isLoading! &&
          _ticketCubit.state.ticketList.length <
              _ticketCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _ticketCubit.getTicketList(
            context,
            _ticketCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // TICKET FILTER
  Future<void> _showBottomSheetToTicket(BuildContext context) async {
    final state = _ticketCubit.state;
    _searchC.text = state.searchText;
    _filterTicketId.text = state.filterTicketId;
    _filterPlatform.text = state.filterPlatform;
    _filterModule.text = state.filterModule;
    _filterPriority.text = state.filterPriority;
    _filterDepartmentName.text = state.filterDepartment;
    _filterStatus.text = state.filterStatus;
    String? selectedDirection =
        state.currentSortColumn == "Platform"
            ? state.currentSortDirection
            : null;

    final String initialTicketId = _filterTicketId.text;
    final String initialPlatform = _filterPlatform.text;
    final String initialModule = _filterModule.text;
    final String initialPriority = _filterPriority.text;
    final String initialDepartmentName = _filterDepartmentName.text;
    final String initialStatus = _filterStatus.text;
    final String? initialDirection = selectedDirection;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool manualClose = false;
    bool applied = false;
    final filterFormKey = GlobalKey<FormState>();
    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterTicketId.text.trim() != initialTicketId) ||
            (_filterPlatform.text.trim() != initialPlatform) ||
            (_filterModule.text.trim() != initialModule) ||
            (_filterPriority.text.trim() != initialPriority) ||
            (_filterDepartmentName.text.trim() != initialDepartmentName) ||
            (_filterStatus.text.trim() != initialStatus) ||
            (selectedDirection != initialDirection);

        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Ticket",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  title: "Ticket ID",
                  hint: "Enter Ticket ID",
                  textController: _filterTicketId,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
                CustomTextField(
                  title: "Platform",
                  hint: "Enter Platform",
                  textController: _filterPlatform,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
                CustomTextField(
                  title: "Module",
                  hint: "Enter Module",
                  textController: _filterModule,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
                CustomTextField(
                  title: "Priority",
                  hint: "Enter Priority",
                  textController: _filterPriority,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
                CustomTextField(
                  title: "Department",
                  hint: "Enter Department",
                  textController: _filterDepartmentName,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
                CustomTextField(
                  title: "Status",
                  hint: "Enter Status",
                  textController: _filterStatus,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(height: 5),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterTicketId.clear();
        _filterPlatform.clear();
        _filterModule.clear();
        _filterPriority.clear();
        _filterDepartmentName.clear();
        _filterStatus.clear();
        _ticketCubit.applyFilterAndSort(
          context: context,
          ticketId: '',
          platform: '',
          module: '',
          priority: '',
          department: '',
          status: '',
        );
      },
      onApply: () {
        if (filterFormKey.currentState?.validate() ?? false) {
          _ticketCubit.applyFilterAndSort(
            context: context,
            ticketId: _filterTicketId.text.trim(),
            platform: _filterPlatform.text.trim(),
            module: _filterModule.text.trim(),
            priority: _filterPriority.text.trim(),
            department: _filterDepartmentName.text.trim(),
            status: _filterStatus.text.trim(),
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterPlatform.clear();
      _filterModule.clear();
      _filterPriority.clear();
      _filterDepartmentName.clear();
      _filterStatus.clear();
    }
  }

  // DELETE TICKET
  Future<void> _showPopupToDeleteDepartmentMaster(
    BuildContext context,
    TicketModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a ticket?',
      'Deleting this department will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _ticketCubit.deleteTicket(
        context: context,
        ticketId: obj.ticketId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketCubit, TicketState>(
      builder: (context, state) {
        if ((state.isLoading ?? true) && state.ticketList.isEmpty) {
          return Center(child: loader());
        }
        final bool showAddButton =
            _routeAuthorizationModel.isAction &&
            !state.ticketList.any((e) => e.canAction);

        return Scaffold(
          appBar: CustomAppBar(
            screenTitle: "Ticket",
            authorization: _routeAuthorizationModel,
            searchHintText: "Search by Ticket ID",
            onSearchSubmit: (value) {
              _ticketCubit.searchTicket(context, value);
            },
            textController: _searchC,
            onAddCallback:
                showAddButton
                    ? () {
                      goRouter.pushNamed(AppRoutes.addTicket);
                    }
                    : null,
            onExportCallback: (value) {
              if (_ticketCubit.state.totalNumberOfRecord == 0) {
                showErrorMessage(context, "Error", "No Data Found");
                return;
              }
              _ticketCubit.exportExcelPdf(context, value);
            },
            isFilterOn: true,
            onFilterTap: () {
              _showBottomSheetToTicket(context);
            },
          ),
          body:
              state.ticketList.isNotEmpty
                  ? ListView.builder(
                    controller: scrollController,
                    itemCount:
                        state.ticketList.length +
                        (state.ticketList.length < state.totalNumberOfRecord
                            ? 1
                            : 0),
                    padding: EdgeInsets.all(20.0),
                    itemBuilder: (context, index) {
                      if (index == state.ticketList.length) {
                        return state.ticketList.length <
                                state.totalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      final tickets = state.ticketList[index];
                      final historyList = tickets.assignTicketHistory;

                      final String displayStatus =
                          historyList.isNotEmpty
                              ? historyList.last.assignedStatus
                              : "Open";
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            goRouter.pushNamed(
                                              AppRoutes.viewTicket,
                                              extra: tickets,
                                              queryParameters: {
                                                "ticketId":
                                                    tickets.ticketId.toString(),
                                                "systemGeneratedCode":
                                                    Uri.encodeComponent(
                                                      EncryptionManager.encryptData(
                                                        tickets
                                                            .systemGeneratedCode,
                                                      ),
                                                    ),
                                              },
                                            );
                                          },
                                          child: Text(
                                            tickets.systemGeneratedCode,
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      horizontalSpacing(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            displayStatus,
                                          ).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          displayStatus,
                                          style: AppTextStyle.ts14M(
                                            color: _statusColor(displayStatus),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Row(
                                  children: [
                                    if (_routeAuthorizationModel.isAction &&
                                        tickets.canAction) ...[
                                      _routeAuthorizationModel.isAction &&
                                              tickets.canAction
                                          ? horizontalSpacing()
                                          : SizedBox.shrink(),
                                      CustomIconButton(
                                        onPressed: () {
                                          goRouter.pushNamed(
                                            AppRoutes.assignTicket,
                                            extra: tickets,
                                            queryParameters: {
                                              'index': index.toString(),
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.task_alt_rounded,
                                        ),
                                      ),
                                    ],
                                    if (_routeAuthorizationModel.isAction &&
                                        !tickets.canAction) ...[
                                      horizontalSpacing(),
                                      CustomIconButton.edit(
                                        onPressed: () {
                                          goRouter.pushNamed(
                                            AppRoutes.addTicket,
                                            extra: tickets,
                                          );
                                        },
                                      ),

                                      horizontalSpacing(),

                                      CustomIconButton.delete(
                                        onPressed: () {
                                          _showPopupToDeleteDepartmentMaster(
                                            context,
                                            tickets,
                                            state.currentPage,
                                            index,
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            buildRowTitleValue(
                              title: "Platform",
                              value: tickets.platform,
                            ),
                            buildRowTitleValue(
                              title: "Module",
                              value: tickets.module,
                            ),
                            buildRowTitleValue(
                              title: "Raised By",
                              value: tickets.createdBy,
                              singleLine: false,
                            ),
                            buildRowTitleValue(
                              title: "Department",
                              value: tickets.departmentName,
                              singleLine: false,
                            ),
                            buildRowTitleValue(
                              title: "Priority",
                              value: tickets.priority,
                              valueTextStyle: AppTextStyle.ts14M(
                                color: _priorityColor(tickets.priority),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  : Center(child: noDataWidget()),
        );
      },
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "low":
        return AppColor.green20;
      case "medium":
        return AppColor.yellow;
      case "high":
        return AppColor.missingInformationRed;
      default:
        return Colors.black.withValues(alpha: 0.5);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return AppColor.green20;
      case "assigned":
        return AppColor.primary;
      case "closed":
        return AppColor.missingInformationRed;
      case "inprogress":
        return Color(0xffFF9F2D);
      case "resolved":
        return AppColor.yellow;
      case "reopen":
        return AppColor.mediumBlue;
      default:
        return Colors.black.withValues(alpha: 0.5);
    }
  }
}
