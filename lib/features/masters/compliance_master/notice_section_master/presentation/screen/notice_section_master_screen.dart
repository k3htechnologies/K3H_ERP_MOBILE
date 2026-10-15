import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/model/notice_section.model.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/presentation/cubit/notice_section_cubit.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/presentation/cubit/notice_section_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class NoticeSectionMasterScreen extends StatefulWidget {
  const NoticeSectionMasterScreen({super.key});

  @override
  State<NoticeSectionMasterScreen> createState() =>
      _NoticeSectionMasterScreenState();
}

class _NoticeSectionMasterScreenState extends State<NoticeSectionMasterScreen> {
  // CUBIT
  late NoticeSectionMasterCubit _noticeSectionMasterCubit;
  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;
  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC,
      _filterGovernmentComplianceC,
      _noticeSectionC;
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<Map<String, dynamic>?> _selectedGovernmentCompliance =
      ValueNotifier(null);
  @override
  void initState() {
    super.initState();
    _noticeSectionMasterCubit = context.read<NoticeSectionMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.noticeSectionMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _noticeSectionMasterCubit.getNoticeSectionList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterGovernmentComplianceC.dispose();
    _noticeSectionC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_noticeSectionMasterCubit.state.isLoading! &&
          _noticeSectionMasterCubit.state.noticeSectionList.length <
              _noticeSectionMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _noticeSectionMasterCubit.getNoticeSectionList(
            context,
            _noticeSectionMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterGovernmentComplianceC = TextEditingController();
    _noticeSectionC = TextEditingController();
  }

  Future<void> _showBottomSheetToFilterNoticeSectionMaster(
    BuildContext context,
  ) async {
    final state = _noticeSectionMasterCubit.state;

    _searchC.text = state.searchText;
    _filterGovernmentComplianceC.text = state.filterByGovernmentCompliance;

    String? selectedDirection =
        state.currentSortColumn == "Notice Section"
            ? state.currentSortDirection
            : null;

    final String initialNoticeSection = _searchC.text;
    final String initialGovernmentCompliance =
        _filterGovernmentComplianceC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialNoticeSection ||
            _filterGovernmentComplianceC.text.trim() !=
                initialGovernmentCompliance ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Notice Master",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });

            updateApplyState(innerState);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By Notice Section", style: AppTextStyle.ts14M()),
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

              verticalSpacing(height: 20),

              CustomTextField(
                textController: _filterGovernmentComplianceC,
                hint: "Enter Government Compliance",
                title: "Government Compliance",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
              CustomTextField(
                textController: _searchC,
                hint: "Enter Notice Section",
                title: "Notice Section",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _noticeSectionMasterCubit.applyFilterAndSortDepartment(
          context: context,
          column: '',
          direction: '',
          noticeSection: '',
          governmentCompliance: '',
        );
      },

      onApply: () {
        applied = true;

        _noticeSectionMasterCubit.applyFilterAndSortDepartment(
          context: context,
          column: selectedDirection != null ? "Notice Section" : "",
          direction: selectedDirection ?? "",
          noticeSection: _searchC.text.trim(),
          governmentCompliance: _filterGovernmentComplianceC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialNoticeSection;
    }
  }

  Future<void> _showBottomSheetToAddNoticeSection(
    BuildContext context, {
    NoticeSectionModel? noticeSection,
    int? index,
  }) async {
    if (noticeSection != null) {
      _noticeSectionC.text = noticeSection.noticeSection;
      _selectedGovernmentCompliance.value = noticeSectionTypeList.firstWhere(
        (item) => item["DisplayName"] == noticeSection.governmentCompliance,
        orElse: () => noticeSectionTypeList.first,
      );
    } else {
      _noticeSectionC.clear();
      _selectedGovernmentCompliance.value = null;
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "${noticeSection != null ? 'Update' : 'Add'} Notice Section",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: _selectedGovernmentCompliance,
                  builder: (context, selectedGovernmentComplianceV, child) {
                    return CustomDropDownWidget(
                      title: "Government Compliance",
                      hintText: "Select Government Compliance",
                      dataList: noticeSectionTypeList,
                      initialValue: selectedGovernmentComplianceV,
                      isRequired: true,
                      onSelected: (value) {
                        _selectedGovernmentCompliance.value = value;
                      },
                      onValueClear: () {
                        _selectedGovernmentCompliance.value = null;
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Government Compliance is required.";
                        }
                        return null;
                      },
                    );
                  },
                ),
                CustomTextField(
                  title: "Notice U/S",
                  hint: "Enter Notice U/S",
                  isRequired: true,
                  textController: _noticeSectionC,
                  inputFormatterList: [LengthLimitingTextInputFormatter(100)],
                  validator: (value) {
                    final text = value?.trim() ?? "";

                    if (text.isEmpty) {
                      return "Notice U/S is required.";
                    }

                    return null;
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomActions: CustomButton.add(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (noticeSection != null) {
              _noticeSectionMasterCubit.updateNoticeSectionMaster(
                context: context,
                noticeSectionMasterId: noticeSection.noticeSectionMasterId,
                uniqueKey: noticeSection.uniquekey,
                noticeSection: _noticeSectionC.text.trim(),
                governmentCompliance:
                    _selectedGovernmentCompliance.value?['DisplayName'] ?? "",
                index: index!,
              );
            } else {
              _noticeSectionMasterCubit.addNoticeSectionMaster(
                context: context,
                noticeSection: _noticeSectionC.text.trim(),
                governmentCompliance:
                    _selectedGovernmentCompliance.value?['DisplayName'] ?? "",
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _showDeleteNoticeSectionDialog(
    BuildContext context,
    NoticeSectionModel noticeSection,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Notice Section ?',
      'Deleting this Notice Section will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      await _noticeSectionMasterCubit.deleteNoticeSectiokn(
        context: context,
        noticeSectionMasterId: noticeSection.noticeSectionMasterId,
        uniqueKey: noticeSection.uniquekey,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Notice Section Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _noticeSectionMasterCubit.exportExcelPdf(context, value);
        },
        searchHintText: "Search by Notice Section",
        onSearchSubmit: (value) {
          _noticeSectionMasterCubit.searchNoticeSection(context, value);
        },
        textController: _searchC,
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterNoticeSectionMaster(context);
        },
        onAddCallback: () {
          _showBottomSheetToAddNoticeSection(context);
        },
      ),
      body: BlocBuilder<NoticeSectionMasterCubit, NoticeSectionMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? false) && state.noticeSectionList.isEmpty) {
            return Center(child: loader());
          } else if (state.noticeSectionList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Notice Section Data Found"),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                _searchC.clear();
                _noticeSectionMasterCubit.searchNoticeSection(context, "");
              },
              child: ListView.separated(
                controller: scrollController,
                itemCount: state.noticeSectionList.length + 1,
                padding: EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (context, index) => verticalSpacing(),
                itemBuilder: (context, index) {
                  if (index == state.noticeSectionList.length) {
                    return state.noticeSectionList.length <
                            state.totalNumberOfRecord
                        ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  final noticeSection = state.noticeSectionList[index];
                  return Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                noticeSection.noticeSection,
                                style: AppTextStyle.ts14M(),
                              ),
                            ),
                            Row(
                              spacing: 10,
                              children: [
                                CustomIconButton.edit(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () {
                                    _showBottomSheetToAddNoticeSection(
                                      context,
                                      noticeSection: noticeSection,
                                      index: index,
                                    );
                                  },
                                ),
                                CustomIconButton.delete(
                                  isDisabled:
                                      !_routeAuthorizationModel.isAction,
                                  onPressed: () {
                                    _showDeleteNoticeSectionDialog(
                                      context,
                                      noticeSection,
                                      index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        buildRowTitleValue(
                          title: "Government Compliance",
                          value: noticeSection.governmentCompliance,
                          singleLine: false,
                          fixesWidth: 110,
                        ),
                        buildRowTitleValue(
                          title: "Modifed By",
                          value:
                              noticeSection.modifiedBy.isEmpty
                                  ? noticeSection.createdBy
                                  : noticeSection.modifiedBy,
                          singleLine: false,
                          fixesWidth: 110,
                        ),
                        buildRowTitleValue(
                          title: "Modified Date",
                          value: formatDateTimeAsDDMMMYYYY(
                            noticeSection.modifiedDate ??
                                noticeSection.createdDate,
                          ),
                          singleLine: false,
                          fixesWidth: 110,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
