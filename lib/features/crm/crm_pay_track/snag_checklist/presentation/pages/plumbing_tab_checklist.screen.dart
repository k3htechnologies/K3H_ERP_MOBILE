import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/data/model/snag_checklist.model.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/cubit/snag_checklist_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class PlumbingTabChecklistScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;
  const PlumbingTabChecklistScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<PlumbingTabChecklistScreen> createState() =>
      _PlumbingTabChecklistScreenState();
}

class _PlumbingTabChecklistScreenState
    extends State<PlumbingTabChecklistScreen> {
  late SnagChecklistCubit _snagChecklistCubit;
  final Map<int, ValueNotifier<bool>> _checkboxNotifiers = {};

  @override
  void initState() {
    super.initState();
    _snagChecklistCubit = context.read<SnagChecklistCubit>();
  }

  @override
  void dispose() {
    for (final notifier in _checkboxNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SnagChecklistCubit, SnagChecklistState>(
      builder: (context, state) {
        if (state.isLoading ?? true && state.snagChecklist.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        final groupedData = <String, List<SnagChecklistModel>>{};

        for (var item in state.snagChecklist) {
          final key = "${item.subCategoryName}__${item.title}";
          if (groupedData.containsKey(key)) {
            groupedData[key]!.add(item);
          } else {
            groupedData[key] = [item];
          }
        }

        final groupedList = groupedData.entries.toList();
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupedList.length,
                        itemBuilder: (context, groupIndex) {
                          final group = groupedList[groupIndex];

                          final splitData = group.key.split("__");

                          final subCategoryName = splitData[0];
                          final checklistTitle = splitData[1];
                          final items = group.value;
                          final pendingCount =
                              items.where((e) => e.isCheck == false).length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 10.0),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColor.lightBlue,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: buildColumnTitleValueNormal(
                                            title: "Sub-Category",
                                            value: subCategoryName,
                                          ),
                                        ),
                                        horizontalSpacing(),
                                        buildColumnTitleValueNormal(
                                          title: "Pending",
                                          value: pendingCount.toString(),
                                        ),
                                      ],
                                    ),
                                    verticalSpacing(),
                                    buildColumnTitleValueNormal(
                                      title: "Checklist Title",
                                      value: checklistTitle,
                                    ),
                                    verticalSpacing(),
                                    buildColumnTitleValueNormal(
                                      title: "Tags",
                                      value: items.first.tags,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.0),
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    width: 0.6,
                                    color: AppColor.black.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14.0,
                                        horizontal: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.greyBackground,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              "Check For",
                                              style: AppTextStyle.ts14SB(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ListView.separated(
                                      itemBuilder: (context, index) {
                                        final snag = items[index];
                                        final uniqueIndex =
                                            snag.snagCheckListId;
                                        if (_checkboxNotifiers.containsKey(
                                          uniqueIndex,
                                        )) {
                                          _checkboxNotifiers[uniqueIndex]!
                                              .value = snag.isCheck;
                                        } else {
                                          _checkboxNotifiers[uniqueIndex] =
                                              ValueNotifier<bool>(snag.isCheck);
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 16.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  snag.checkFor,
                                                  style: AppTextStyle.ts14M(),
                                                ),
                                              ),
                                              horizontalSpacing(),
                                              ValueListenableBuilder(
                                                valueListenable:
                                                    _checkboxNotifiers[uniqueIndex]!,
                                                builder: (
                                                  context,
                                                  isInactive,
                                                  child,
                                                ) {
                                                  return Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: CustomCheckBox(
                                                      isSelected: isInactive,
                                                      onChanged: (value) {
                                                        final updatedValue =
                                                            value;

                                                        _checkboxNotifiers[uniqueIndex]!
                                                                .value =
                                                            updatedValue;

                                                        snag.isCheck =
                                                            updatedValue;
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      separatorBuilder:
                                          (context, index) => Divider(
                                            height: 1,
                                            thickness: 0.6,
                                            color: AppColor.black.withValues(
                                              alpha: 0.15,
                                            ),
                                          ),
                                      itemCount: items.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: "Save",
                onPressed: () {
                  _snagChecklistCubit.addUpdateSnagChecklist(
                    context,
                    projectId: widget.projectId,
                    bookingId: widget.bookingId,
                    snagChecklist: state.snagChecklist,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
