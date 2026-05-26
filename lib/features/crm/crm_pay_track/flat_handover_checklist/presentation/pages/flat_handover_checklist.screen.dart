import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/model/flat_handover_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/presentation/cubit/flat_handover_checklist_cubit.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _flatHandoverChecklistCubit = context.read<FlatHandoverChecklistCubit>();
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
  }

  // ADD UPDATE ENQUIRY FOLLOW UP BOTTOM SHEET
  Future<void> _showAddUpdateEnquiryFollowUpBottomSheet(
    BuildContext context, {
    FlatHandoverChecklistModel? flatHandoverChecklistModel,
    int? index,
  }) async {
    if (flatHandoverChecklistModel != null) {
      _remarkC.text = flatHandoverChecklistModel.remark;
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
                  CustomTextField(
                    title: 'Remark',
                    hint: "Enter remark",
                    isRequired: true,

                    textController: _remarkC,
                    maxLines: 10,
                    minLines: 3,
                    validator:
                        (val) =>
                            val == null || val.trim().isEmpty
                                ? "Remark is required"
                                : null,
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
      status:
          flatHandoverChecklistModel.status.isEmpty
              ? "Yes"
              : flatHandoverChecklistModel.status,
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

            ChipStyleTabBar(controller: _tabController, tabs: sections),

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
