import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DesignationMasterScreen extends StatefulWidget {
  const DesignationMasterScreen({super.key});

  @override
  State<DesignationMasterScreen> createState() =>
      _DesignationMasterScreenState();
}

class _DesignationMasterScreenState extends State<DesignationMasterScreen> {
  // CUBIT
  late DesignationMasterCubit _designationMasterCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _designationC, _noticePeriodC;

  @override
  void initState() {
    super.initState();
    _designationMasterCubit = BlocProvider.of<DesignationMasterCubit>(context);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.designationMaster]!;
    _initializeTextEditingController();
    _onScroll();
    _designationMasterCubit.getDesignationList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _designationC.dispose();
    _noticePeriodC.dispose();
  }

  // <---- INITIALIZING TEXT CONTROLLERS ---->
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _designationC = TextEditingController();
    _noticePeriodC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    // SCROLL LISTENER
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_designationMasterCubit.state.isLoading! &&
          _designationMasterCubit.state.designationList.length <
              _designationMasterCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _designationMasterCubit.getDesignationList(
            context,
            _designationMasterCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE DESIGNATION ---->
  Future<void> _showPopupToDeleteDesignationMaster(
    int designationMasterId,
    String uniqueKey,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      "You are about to delete a designation?",
      "Deleting this designation will permanently remove its contents.",
    );
    if (result && mounted) {
      _designationMasterCubit.deleteDesignationMaster(
        context: context,
        designationMasterId: designationMasterId,
        uniqueKey: uniqueKey,
        pageNumber: _designationMasterCubit.state.currentPage,
        pageSize: 10,
        index: index,
      );
    }
  }

  // DESIGNATION FILTER
  Future<void> _showBottomSheetToFilterDesignationMaster(
    BuildContext context,
  ) async {
    final state = _designationMasterCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Designation Name"
            ? state.currentSortDirection
            : null;
    final String? initialDirection = selectedDirection;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Designation Master",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            applyEnabled.value =
                selectedDirection != null &&
                selectedDirection != initialDirection;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sort By Designation Name", style: AppTextStyle.ts14M()),
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
            ],
          );
        },
      ),
      onClear: () {
        _designationMasterCubit.sortDesignation(
          context,
          "Created Date",
          "DESC",
        );
      },
      onApply: () {
        if (selectedDirection != null &&
            selectedDirection != initialDirection) {
          _designationMasterCubit.sortDesignation(
            context,
            "Designation Name",
            selectedDirection!,
          );
        }
      },
      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Designation Master',
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          if (_designationMasterCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _designationMasterCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addDesignation);
          if (context.mounted) {
            _designationMasterCubit.getDesignationList(context, 1);
          }
        },
        searchHintText: "Search by Designation Name",
        onSearchSubmit: (value) {
          _designationMasterCubit.searchDesignation(context, value);
        },
        textController: _searchC,
        onSortOptionCallback: (value) async {
          _designationMasterCubit.sortDesignation(context, value, "DESC");
        },
        isFilterOn: true,
        onFilterTap: () {
          _showBottomSheetToFilterDesignationMaster(context);
        },
      ),
      body: BlocBuilder<DesignationMasterCubit, DesignationMasterState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.designationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.designationList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _designationMasterCubit.state.designationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.designationList.length) {
                return state.designationList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var designation = state.designationList[index];
              return Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 10),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Flexible(
                          child: Text(
                            designation.designationName,
                            style: AppTextStyle.ts14R(),
                          ),
                        ),
                        horizontalSpacing(),
                        Row(
                          spacing: 5,
                          children: [
                            designation.numberOfEmployee<=0?SizedBox():
                            CustomIconButton(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.employeeModuleAccess,
                                  queryParameters: {
                                    "designation": Uri.encodeComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(designation.toJson()),
                                      ),
                                    ),
                                  },
                                );
                                if (context.mounted) {
                                  _designationMasterCubit.getDesignationList(
                                    context,
                                    1,
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.key,
                                size: 16,
                                color:designation.isSetAccessModule==true?  AppColor.primary:AppColor.grey,
                              ),
                              backgroundColor: designation.isSetAccessModule==true?AppColor.lightBlue:AppColor.grey10,
                            ),
                            if(_routeAuthorizationModel.isAction)...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconButton(
                                    onPressed: () async {
                                      await goRouter.pushNamed(
                                        AppRoutes.addDesignation,
                                        queryParameters: {
                                          'designation': Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(designation.toJson()),
                                            ),
                                          ),
                                          'index': index.toString(),
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: AppColor.grey,
                                    ),
                                    backgroundColor: AppColor.grey10,
                                  ),
                                  if(designation.numberOfEmployee==0)...[
                                    horizontalSpacing(width: 5),
                                    CustomIconButton(
                                      onPressed: () {
                                        _showPopupToDeleteDesignationMaster(
                                          designation.designationMasterId,
                                          designation.uniquekey,
                                          index,
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        AppAssets.deleteIcon2,
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          AppColor.error,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      backgroundColor: AppColor.lightRed,
                                    ),
                                  ]
                                ],
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.grey10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Notice Period: ",
                            style: AppTextStyle.ts12R(color: AppColor.grey),
                          ),
                          Text(
                            designation.noticePeriod.toString(),
                            style: AppTextStyle.ts14R(),
                          ),
                        ],
                      ),
                    ),
                    verticalSpacing(),

                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "No. of Employee: ",
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColor.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                designation.numberOfEmployee.toString(),
                                style: AppTextStyle.ts14R(
                                  color: AppColor.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Text(
                              "Probation  Period: ",
                              style: AppTextStyle.ts12R(color: AppColor.grey),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColor.purple.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                designation.probationPeriod.toString(),
                                style: AppTextStyle.ts14R(
                                  color: AppColor.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 5),
                    buildRowTitleValue(
                      title: "Created By",
                      singleLine: false,

                      value: designation.createdBy,
                    ),
                    buildRowTitleValue(
                      title: "Created Date",
                      value: formatDate(designation.createdDate),
                    ),
                    buildRowTitleValue(
                      title: "Modified By",
                      singleLine: false,
                      value: designation.modifiedBy,
                    ),
                    buildRowTitleValue(
                      title: "Modified Date",
                      value:
                          designation.modifiedDate == null
                              ? '-'
                              : formatDate(
                                designation.modifiedDate!,
                              ),
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
