import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/model/flat_handover_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/cubit/flat_handover_checklist_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class FlatHandoverChecklistScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const FlatHandoverChecklistScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
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
    super.dispose();
    _tabController.dispose();
    _selectedStatusNotifier.dispose();
  }

  Future<void> _showAddUpdateEnquiryFollowUpBottomSheet(
    BuildContext context, {
    FlatHandoverChecklistModel? flatHandoverChecklistModel,
    int? index,
  }) async {
    if (flatHandoverChecklistModel != null) {
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
      index != null ? "Update Follow Up" : "Add Follow Up",
      StatefulBuilder(
        builder: (context, innerBottomsheetState) {
          return Form(
            key: _statusFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  CustomTextField(
                    title: 'Remark',
                    hint: "Enter remark",
                    isRequired: true,
                    textController: _remarkC,
                    maxLines: 10,
                    minLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Remark is required";
                      }
                      return null;
                    },
                  ),
                  CustomButton(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    text: index != null ? "Update" : "Save",
                    onPressed: () {
                      if (!_statusFormKey.currentState!.validate()) return;

                      _submitForm(
                        flatHandoverChecklistModel: flatHandoverChecklistModel,
                        index: index,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
    _remarkC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlatHandoverChecklistCubit, FlatHandoverChecklistState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.flatHandoverCheckList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections =
            state.flatHandoverCheckList.map((e) => e.section).toSet().toList();

        if (_tabController.length != sections.length) {
          _tabController.dispose();

          _tabController = TabController(length: sections.length, vsync: this);

          _tabController.addListener(_handleTabChange);
        }

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

                    return pendingCount > 0
                        ? "$section ($pendingCount)"
                        : section;
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
                          Color getStatusBackgroundColor(String status) {
                            switch (status.toLowerCase()) {
                              case "yes":
                                return AppColor.green20.withValues(alpha: 0.20);

                              case "pending":
                                return Colors.orange.withValues(alpha: 0.15);

                              case "no":
                                return Colors.red.withValues(alpha: 0.15);

                              case "n/a":
                              case "":
                              default:
                                return AppColor.lightGreyBackground;
                            }
                          }

                          Color getStatusTextColor(String status) {
                            switch (status.toLowerCase()) {
                              case "yes":
                                return AppColor.green;

                              case "pending":
                                return Colors.orange;

                              case "no":
                                return Colors.red;

                              case "n/a":
                              case "":
                              default:
                                return AppColor.black.withValues(alpha: 0.7);
                            }
                          }

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
                                    Expanded(
                                      child: buildColumnTitleValueNormal(
                                        title: "Item",
                                        value: item.items,
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    CustomIconButton.edit(
                                      onPressed: () {
                                        _showAddUpdateEnquiryFollowUpBottomSheet(
                                          context,
                                          flatHandoverChecklistModel: item,
                                          index: index,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                buildColumnTitleValueNormal(
                                  title: "Status",
                                  value: item.status,
                                  customValueWidget: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 10.0,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0),
                                      color: getStatusBackgroundColor(
                                        item.status,
                                      ),
                                    ),
                                    child: Text(
                                      item.status.isEmpty ? "N/A" : item.status,
                                      style: AppTextStyle.ts12M(
                                        color: getStatusTextColor(item.status),
                                      ),
                                    ),
                                  ),
                                ),
                                verticalSpacing(),
                                buildColumnTitleValueNormal(
                                  title: "Remark",
                                  value: item.remark,
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
