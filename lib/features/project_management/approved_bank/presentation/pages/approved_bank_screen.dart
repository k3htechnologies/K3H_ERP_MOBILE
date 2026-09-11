import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_folder.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApprovedBankScreen extends StatefulWidget {
  const ApprovedBankScreen({super.key});

  @override
  State<ApprovedBankScreen> createState() => _ApprovedBankScreenState();
}

class _ApprovedBankScreenState extends State<ApprovedBankScreen> {
  // CUBIT
  late ApprovedBankFolderCubit _approvedBankCubit;

  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PROJECT
  late ProjectModel _project;
  late ScrollController scrollController;
  Timer? _debounce;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _approvedBankCubit = context.read<ApprovedBankFolderCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.approvedBank] ??
        AuthorizationModel();
    _project = getProject();
    _searchC = TextEditingController();
    _onScroll();

    _approvedBankCubit.getApprovedBankFolderList(
      context,
      1,
      _project.projectId,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    _searchC.dispose();
    _filterCount.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_approvedBankCubit.state.isLoading! &&
          _approvedBankCubit.state.approvedBankFolderList.length <
              _approvedBankCubit.state.totalNumberOfRecordBankFolder) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _approvedBankCubit.getApprovedBankFolderList(
            context,
            _approvedBankCubit.state.currentPageBankFolder + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  // DIALOGUE TO DELETE APPROVED BANK FILE
  Future<void> _showPopupToDeleteApprovedBankFile(
    BuildContext context,
    ApprovedBankFolderModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Approved Bank ?',
      'Deleting this Approved Bank will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _approvedBankCubit.deleteApprovedBankFolder(
        context: context,
        approvedBankFolderId: obj.approvedBankFolderId,
        projectId: _project.projectId,
        uniqueKey: obj.uniquekey,
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterBankFolderMaster(
    BuildContext context,
  ) async {
    final state = _approvedBankCubit.state;

    _searchC.text = state.searchTextFolder;

    String? selectedDirection =
        state.currentSortColumnBankFolder == "BankName"
            ? state.currentSortDirectionBankFolder
            : null;

    final String initialMaterialName = _searchC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialMaterialName ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Approved Bank",
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
              Text("Sort By Bank Name", style: AppTextStyle.ts14M()),
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
                textController: _searchC,
                hint: "Enter Bank Name",
                title: "Bank Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _approvedBankCubit.applyFilterAndSortApprovedBankFolder(
          context: context,
          column: "Created Date",
          direction: "DESC",
          bankName: '',
          projectId: _project.projectId,
        );
      },

      onApply: () {
        applied = true;

        _approvedBankCubit.applyFilterAndSortApprovedBankFolder(
          context: context,
          column: selectedDirection != null ? "BankName" : "Created Date",
          direction: selectedDirection ?? "DESC",
          bankName: _searchC.text.trim(),
          projectId: _project.projectId,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialMaterialName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovedBankFolderCubit, ApprovedBankFolderState>(
      listener: (context, state) {
        _filterCount.value = _approvedBankCubit.updateFilterCountFolder(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: 'Approved Bank',
          authorization: _routeAuthorizationModel,
          searchHintText: "Search by Bank Name",
          onSearchSubmit: (value) {
            _approvedBankCubit.searchFolder(context, value, _project.projectId);
          },
          textController: _searchC,
          onAddCallback: () async {
            if (_project.projectId == 0) {
              showErrorMessage(context, "Error", "Please Select a Project");
              return;
            }
            await goRouter.pushNamed(AppRoutes.addBankScreen);
          },
          onProjectChangeCallback: (value) {
            _project = value;
            _approvedBankCubit.searchFolder(context, "", value.projectId);
          },
          filterCountNotifier: _filterCount,
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterBankFolderMaster(context);
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                BlocBuilder<ApprovedBankFolderCubit, ApprovedBankFolderState>(
                  builder: (context, state) {
                    return showSiteSelectedWidget(
                      projectName: _project.projectName,
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<
                    ApprovedBankFolderCubit,
                    ApprovedBankFolderState
                  >(
                    builder: (context, state) {
                      if ((state.isLoading == true) &&
                          state.approvedBankFolderList.isEmpty) {
                        return Center(child: loader());
                      }
                      if (state.approvedBankFolderList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Approved Bank Found",
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          _approvedBankCubit.searchFolder(
                            context,
                            "",
                            _project.projectId,
                          );
                          _searchC.clear();
                        },
                        child: ListView.builder(
                          controller: scrollController,

                          shrinkWrap: true,
                          itemCount: state.approvedBankFolderList.length + 1,
                          itemBuilder: (_, index) {
                            if (index == state.approvedBankFolderList.length) {
                              return state.approvedBankFolderList.length <
                                      state.totalNumberOfRecordBankFolder
                                  ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }
                            var folder = state.approvedBankFolderList[index];
                            return Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: commonCardDecoration(),
                              child: Column(
                                children: [
                                  Row(
                                    spacing: 10,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await goRouter.pushNamed(
                                              AppRoutes.approvedBankFile,
                                              queryParameters: {
                                                "approvedBankFolderId":
                                                    Uri.encodeQueryComponent(
                                                      EncryptionManager.encryptData(
                                                        jsonEncode(
                                                          state
                                                              .approvedBankFolderList[index]
                                                              .approvedBankFolderId,
                                                        ),
                                                      ),
                                                    ),
                                                "bankName": folder.bankName,
                                              },
                                            );
                                            if (context.mounted) {
                                              _approvedBankCubit
                                                  .getApprovedBankFolderList(
                                                    context,
                                                    1,
                                                    _project.projectId,
                                                  );
                                            }
                                          },
                                          child: Text(
                                            folder.bankName,
                                            style: AppTextStyle.ts16M(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      CustomIconButton.delete(
                                        isDisabled:
                                            folder.numberOfApprovedBankFile !=
                                                0 ||
                                            !_routeAuthorizationModel.isAction,
                                        onPressed: () {
                                          _showPopupToDeleteApprovedBankFile(
                                            context,
                                            state.approvedBankFolderList[index],
                                            1,
                                            index,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Document Count : ",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.grey,
                                            ),
                                          ),
                                          Text(
                                            folder.numberOfApprovedBankFile
                                                .toString(),
                                            style: AppTextStyle.ts14M(),
                                          ),
                                        ],
                                      ),
                                      CustomIconButton(
                                        isDisable:
                                            (!_routeAuthorizationModel
                                                    .isExport ||
                                                folder.numberOfApprovedBankFile ==
                                                    0),
                                        onPressed: () {
                                          _approvedBankCubit.exportZip(
                                            context,
                                            _project.projectId,
                                            folder.approvedBankFolderId,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.file_download_outlined,
                                          size: 16,
                                          color:
                                              (!_routeAuthorizationModel
                                                          .isExport ||
                                                      folder.numberOfApprovedBankFile ==
                                                          0)
                                                  ? AppColor.grey2
                                                  : AppColor.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
