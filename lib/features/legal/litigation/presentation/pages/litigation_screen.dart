import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_cubit.dart';
import 'package:k3h_erp_app/features/legal/litigation/presentation/cubit/litigation_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LitigationScreen extends StatefulWidget {
  const LitigationScreen({super.key});

  @override
  State<LitigationScreen> createState() => _LitigationScreenState();
}

class _LitigationScreenState extends State<LitigationScreen> {
  //CUBIT
  late LitigationCubit _litigationCubit;

  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _filterCaseNumber, _filterCourtName;
  @override
  void initState() {
    super.initState();
    _litigationCubit = context.read<LitigationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.litigation] ??
        AuthorizationModel();
    _onScroll();
    _initializeTextEditingController();
    _litigationCubit.getLitigationList(context: context, pageNumber: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterCaseNumber.dispose();
    _filterCourtName.dispose();
  }

  // INITIALISE TEXT EDITING CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _filterCaseNumber = TextEditingController();
    _filterCourtName = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_litigationCubit.state.isLoading ?? false) &&
          _litigationCubit.state.litigationList.length <
              _litigationCubit.state.litigationTotalRecords) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _litigationCubit.getLitigationList(
            context: context,
            pageNumber: _litigationCubit.state.litigationCurrentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE LIGATION ---->
  Future<void> _showPopupToDeleteLitigation(
    BuildContext context,
    LitigationModel obj,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Channel Partner?',
      'Deleting this Channel Partner will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _litigationCubit.deleteLitigation(index, obj, context);
    }
  }

  // LIGATION FILTER
  Future<void> _showBottomSheetToFilterLitigation(BuildContext context) async {
    final state = _litigationCubit.state;

    _filterCaseNumber.text = state.filterCaseNumber;
    _filterCourtName.text = state.filterByCourtName;

    String? selectedDirection =
        state.currentSortColumn == "Title" ? state.currentSortDirection : null;

    final String initialCaseNumber = _filterCaseNumber.text;
    final String initialCourtName = _filterCourtName.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_filterCaseNumber.text.trim() != initialCaseNumber) ||
            (_filterCourtName.text.trim() != initialCourtName) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Litigation",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Title", style: AppTextStyle.ts14M()),
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
                  title: "Case / Petition / Dispute Number",
                  hint: "Enter Case / Petition / Dispute Number",
                  textController: _filterCaseNumber,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
                verticalSpacing(),
                CustomTextField(
                  title: "Court Name",
                  hint: "Enter Court Name",
                  textController: _filterCourtName,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),
      onClear: () {
        _filterCaseNumber.clear();
        _filterCourtName.clear();
        _litigationCubit.applyLitigationFilterAndSort(
          context: context,
          isClear: true,
        );
      },
      onApply: () {
        applied = true;
        _litigationCubit.applyLitigationFilterAndSort(
          context: context,
          caseNumber: _filterCaseNumber.text.trim(),
          courtName: _filterCourtName.text.trim(),
          sortColumn: selectedDirection != null ? "Title" : null,
          sortDirection: selectedDirection,
        );
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterCaseNumber.clear();
      _filterCourtName.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Litigation",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search By Title",
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addLitigation);
          if (context.mounted) {
            _litigationCubit.searchLitigation("", context);
          }
        },
        onExportCallback: (value) {
          if (_litigationCubit.state.litigationTotalRecords == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _litigationCubit.exportExcelPdf(context, value);
        },
        onProjectChangeCallback: (value) {
          _litigationCubit.getLitigationList(context: context, pageNumber: 1);
        },
        textController: _searchC,
        onSearchSubmit: (value) {
          _litigationCubit.searchLitigation(value, context);
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterLitigation(context);
        },
      ),
      body: BlocBuilder<LitigationCubit, LitigationState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.litigationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.litigationList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Litigation Data found"),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.litigationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.litigationList.length) {
                return state.litigationList.length <
                        state.litigationTotalRecords
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var litigation = state.litigationList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await goRouter.pushNamed(
                                AppRoutes.viewLitigation,
                                queryParameters: {
                                  "litigation": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(litigation.toJson()),
                                    ),
                                  ),
                                  'index': index.toString(),
                                },
                              );
                              _litigationCubit.resetLitigationData();
                            },
                            child: Text(
                              litigation.title,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(litigation.status.toLowerCase()!="closed")
                            CustomButton(
                              backgroundColor: AppColor.lightBlue,
                              leading: const Icon(Icons.add, size: 18),
                              textColor: AppColor.primary,
                              text: 'Add Hearing',
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 8,
                              ),
                              onPressed: () {
                                goRouter.pushNamed(
                                  AppRoutes.addLitigationHearing,
                                  queryParameters: {
                                    'litigationId':
                                        litigation.litigationId.toString(),
                                  },
                                );
                              },
                            ),

                            const SizedBox(width: 8),
                            if (litigation.status.toLowerCase() != "closed")
                              CustomIconButton.edit(
                                onPressed: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.addLitigation,
                                    queryParameters: {
                                      "litigation": Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(litigation.toJson()),
                                        ),
                                      ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                            if (litigation.isDelete) ...[
                              const SizedBox(width: 6),
                              CustomIconButton.delete(
                                onPressed: () {
                                  _showPopupToDeleteLitigation(
                                    context,
                                    litigation,
                                    index,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),
                    buildRowTitleValue(
                      title: "Case / Petition / Dispute Number",
                      value: litigation.caseNumber,
                    ),
                    buildRowTitleValue(
                      title: "Status",
                      value: litigation.status,
                      valueTextStyle: AppTextStyle.ts14B(
                        color:
                            (litigation.status.toLowerCase() == 'open' ||
                                    litigation.status.toLowerCase() == 'reopen')
                                ? AppColor.green
                                : AppColor.red,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Case Type",
                      value: litigation.caseType,
                    ),
                    buildRowTitleValue(
                      title: "Project",
                      value: litigation.projectName,
                    ),
                    buildRowTitleValue(
                      title: "Date Off Filling",
                      value: formatDateTimeAsDDMMMYYYY(
                        litigation.dateOfFilling,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Hearing Date",
                      value:
                          litigation.hearingDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                litigation.hearingDate!,
                              )
                              : '-',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
