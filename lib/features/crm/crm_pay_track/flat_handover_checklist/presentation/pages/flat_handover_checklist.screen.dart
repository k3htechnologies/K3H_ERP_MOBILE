import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/model/flat_handover_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/cubit/flat_handover_checklist_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FlatHandoverChecklistScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  final String? bookingApprovalStatus;
  const FlatHandoverChecklistScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
    this.bookingApprovalStatus,
  });

  @override
  State<FlatHandoverChecklistScreen> createState() =>
      _FlatHandoverChecklistScreenState();
}

class _FlatHandoverChecklistScreenState
    extends State<FlatHandoverChecklistScreen>
    with TickerProviderStateMixin {
  late FlatHandoverChecklistCubit _flatHandoverChecklistCubit;
  late TabController _tabController;
  late AuthorizationModel _flatHandoverChecklistAuthorization;
  final TextEditingController _sectionC = TextEditingController();
  final TextEditingController _itemsC = TextEditingController();
  final TextEditingController _remarkC = TextEditingController();
  final GlobalKey<FormState> _statusFormKey = GlobalKey<FormState>();
  // DROPDOWNS
  late ValueNotifier<List<Map<String, dynamic>>> _selectedStatusNotifier;
  final List<Map<String, dynamic>> _statusList = [
    {"zAttributesId": 1, "DisplayName": "Yes"},
    {"zAttributesId": 2, "DisplayName": "No"},
    {"zAttributesId": 3, "DisplayName": "Pending"},
    {"zAttributesId": 4, "DisplayName": "N/A"},
  ];
  @override
  void initState() {
    super.initState();
    _flatHandoverChecklistAuthorization =
        Authorization.routeAuthorizationMap[AppRoutes.flatHandoverChecklist] ??
        AuthorizationModel();
    _flatHandoverChecklistCubit = context.read<FlatHandoverChecklistCubit>();
    _selectedStatusNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabChange);
    _flatHandoverChecklistCubit.getFlatHandoverCheckList(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
    );
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging) return;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _remarkC.dispose();
    _sectionC.dispose();
    _itemsC.dispose();
    _selectedStatusNotifier.dispose();
    super.dispose();
  }

  Future<void> _showAddUpdateFlatHandoverChecklistBottomSheet(
    BuildContext context, {
    FlatHandoverChecklistModel? flatHandoverChecklistModel,
    int? index,
  }) async {
    if (flatHandoverChecklistModel != null) {
      _sectionC.text = flatHandoverChecklistModel.section;
      _itemsC.text = flatHandoverChecklistModel.items;
      _remarkC.text = flatHandoverChecklistModel.remark;

      final selectedStatus = _statusList.firstWhere(
        (e) =>
            e['DisplayName'].toString().toLowerCase() ==
            flatHandoverChecklistModel.status.toLowerCase(),
        orElse: () => {},
      );

      if (selectedStatus.isNotEmpty) {
        _selectedStatusNotifier.value = [selectedStatus];
      }
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Handover Checklist",
      contentWidget: StatefulBuilder(
        builder: (context, innerBottomsheetState) {
          return Form(
            key: _statusFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  title: "Section",
                  hint: "Section",
                  textController: _sectionC,
                  readOnly: true,
                  isRequired: true,
                ),
                CustomTextField(
                  title: "Items",
                  hint: "Items",
                  textController: _itemsC,
                  readOnly: true,
                  isRequired: true,
                ),
                verticalSpacing(),
                ValueListenableBuilder(
                  valueListenable: _selectedStatusNotifier,
                  builder: (context, selectedStatus, child) {
                    return CustomDropDownWidget(
                      title: "Status",
                      hintText: "Select Status",
                      isRequired: true,
                      dataList: _statusList,
                      initialValue:
                          selectedStatus.isNotEmpty
                              ? selectedStatus.first
                              : null,
                      onSelected: (value) {
                        _selectedStatusNotifier.value = [value];
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Status is required";
                        }
                        return null;
                      },
                      onValueClear: () {
                        _selectedStatusNotifier.value = [];
                      },
                    );
                  },
                ),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedStatusNotifier,
                  builder: (context, selectedStatus, child) {
                    final isPending =
                        selectedStatus.isNotEmpty &&
                        selectedStatus.first['DisplayName']
                                .toString()
                                .toLowerCase() ==
                            'pending';

                    return CustomTextField(
                      title: 'Remark',
                      hint: "Enter remark",
                      isRequired: isPending,
                      textController: _remarkC,
                      maxLines: 10,
                      minLines: 3,
                      validator: (value) {
                        if (isPending &&
                            (value == null || value.trim().isEmpty)) {
                          return "Remark is required";
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomActions:
          _flatHandoverChecklistAuthorization.isAction
              ? CustomButton(
                padding: EdgeInsets.symmetric(vertical: 10),
                text: index != null ? "Update" : "Save",
                onPressed: () {
                  if (!_statusFormKey.currentState!.validate()) return;

                  _submitForm(
                    flatHandoverChecklistModel: flatHandoverChecklistModel,
                    index: index,
                  );
                },
              )
              : SizedBox.shrink(),
    );

    _clearStatusSheet();
  }

  void _submitForm({
    FlatHandoverChecklistModel? flatHandoverChecklistModel,
    int? index,
  }) {
    if (!_statusFormKey.currentState!.validate()) return;

    if (flatHandoverChecklistModel == null) return;

    final updatedItem = FlatHandoverChecklistModel(
      flatHandOverCheckListId:
          flatHandoverChecklistModel.flatHandOverCheckListId,
      uniqueKey: flatHandoverChecklistModel.uniqueKey,
      projectId: flatHandoverChecklistModel.projectId,
      bookingId: flatHandoverChecklistModel.bookingId,
      section: flatHandoverChecklistModel.section,
      items: flatHandoverChecklistModel.items,
      status: _selectedStatusNotifier.value.first['DisplayName'],
      remark: _remarkC.text,
      createdById: flatHandoverChecklistModel.createdById,
      createdBy: flatHandoverChecklistModel.createdBy,
      createdDate: flatHandoverChecklistModel.createdDate,
      modifiedById: flatHandoverChecklistModel.modifiedById,
      modifiedBy: flatHandoverChecklistModel.modifiedBy,
      modifiedDate: DateTime.now(),
    );

    _flatHandoverChecklistCubit.addUpdateFlatHandoverChecklist(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      checklist: [updatedItem],
    );

    Navigator.pop(context);
  }

  void _clearStatusSheet() {
    _sectionC.clear();
    _itemsC.clear();
    _remarkC.clear();
    _selectedStatusNotifier.value = [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlatHandoverChecklistCubit, FlatHandoverChecklistState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.flatHandoverCheckList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections =
            state.flatHandoverCheckList.map((e) => e.section).toSet().toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (_tabController.length != sections.length) {
          _tabController.dispose();

          _tabController = TabController(length: sections.length, vsync: this);

          _tabController.addListener(_handleTabChange);
        }
        final bool isBookingCancelledOrRefund =
            widget.bookingApprovalStatus?.toUpperCase() == "CANCEL" ||
            widget.bookingApprovalStatus?.toUpperCase() == "REFUND";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),

            ChipStyleTabBar(
              controller: _tabController,
              tabs:
                  sections.map((section) {
                    final pendingCount =
                        state.flatHandoverCheckList
                            .where(
                              (e) =>
                                  e.section == section &&
                                  e.status.toLowerCase() == "pending",
                            )
                            .length;
                    return "$section ($pendingCount)";
                  }).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    sections.map((section) {
                      final sectionItems =
                          state.flatHandoverCheckList
                              .where((e) => e.section == section)
                              .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: sectionItems.length,
                        itemBuilder: (context, index) {
                          final item = sectionItems[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: commonCardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Item",
                                      value: item.items,
                                    ),
                                    horizontalSpacing(),
                                    if (_flatHandoverChecklistAuthorization
                                            .isAction &&
                                        !isBookingCancelledOrRefund)
                                      CustomIconButton.edit(
                                        onPressed: () {
                                          _showAddUpdateFlatHandoverChecklistBottomSheet(
                                            context,
                                            flatHandoverChecklistModel: item,
                                            index: index,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Status",
                                      value: item.status,
                                      customValueWidget:
                                          flatHandoverChecklistStatusWidget(
                                            item.status,
                                          ),
                                    ),
                                    horizontalSpacing(),
                                    buildColumnTitleValue(
                                      title: "Remark",
                                      value: item.remark,
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildColumnTitleValue(
                                      title: "Last Modified By",
                                      value:
                                          item.modifiedBy.trim().isEmpty
                                              ? item.createdBy
                                              : item.modifiedBy,
                                    ),
                                    horizontalSpacing(),
                                    buildColumnTitleValue(
                                      title: "Last Modified Date",
                                      value: formatDate(
                                        item.modifiedDate ?? item.createdDate,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
