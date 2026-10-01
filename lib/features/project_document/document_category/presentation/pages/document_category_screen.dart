import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/cubit/document_category_cubit.dart';
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

class DocumentCategoryScreen extends StatefulWidget {
  const DocumentCategoryScreen({super.key});

  @override
  State<DocumentCategoryScreen> createState() => _DocumentCategoryScreenState();
}

class _DocumentCategoryScreenState extends State<DocumentCategoryScreen> {
  //CUBIT
  late DocumentCategoryCubit _documentCategoryCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //PROJECT ID
  late ValueNotifier<ProjectModel> _selectedProjectNotifier;

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _documentCategoryCubit = context.read<DocumentCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.category]!;

    _initializeTextEditingController();
    _onScroll();
    _selectedProjectNotifier = ValueNotifier<ProjectModel>(getProject());
    _documentCategoryCubit.getDocumentCategoryList(
      context,
      1,
      _selectedProjectNotifier.value.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterCount.dispose();
    _debounce?.cancel();
    scrollController.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_documentCategoryCubit.state.isLoading! &&
          _documentCategoryCubit.state.documentCategoryList.length <
              _documentCategoryCubit.state.totalNumberOfRecord) {
        if (_selectedProjectNotifier.value.projectId != 0) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            _documentCategoryCubit.getDocumentCategoryList(
              context,
              _documentCategoryCubit.state.currentPage + 1,
              _selectedProjectNotifier.value.projectId,
            );
          });
        }
      }
    });
  }

  // DELETE DOCUMENT CATEGORY
  Future<void> _showPopupToDeleteDocumentCategory(
    BuildContext context,
    DocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a project document category ?',
      'Deleting this project document category will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _documentCategoryCubit.deleteDocumentCategory(
        _selectedProjectNotifier.value.projectId,
        obj,
        context,
      );
    }
  }

  Future<void> _showBottomSheetToFilterDocumentCategoryMaster(
    BuildContext context,
  ) async {
    final state = _documentCategoryCubit.state;

    _searchC.text = state.searchText;

    String? selectedDirection =
        state.currentSortColumn == "Project Document Category"
            ? state.currentSortDirection
            : null;

    final String initialDocumentCategoryName = _searchC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialDocumentCategoryName ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter -  Project Document Category",
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
              Text(
                "Sort By Project Document Category Name",
                style: AppTextStyle.ts14M(),
              ),
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
                hint: "Enter Project Document Category Name",
                title: "Project Document Category Name",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _documentCategoryCubit.applyFilterAndSortProjectDocumentCategory(
          context: context,
          column: "",
          direction: "",
          categoryName: '',
          projectId: _selectedProjectNotifier.value.projectId,
        );
      },

      onApply: () {
        applied = true;

        _documentCategoryCubit.applyFilterAndSortProjectDocumentCategory(
          context: context,
          column: selectedDirection != null ? "Project Document Category" : "",
          direction: selectedDirection ?? "",
          categoryName: _searchC.text.trim(),
          projectId: _selectedProjectNotifier.value.projectId,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialDocumentCategoryName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentCategoryCubit, DocumentCategoryState>(
      listener: (context, state) {
        _filterCount.value = _documentCategoryCubit.updateFilterCount(state);
      },
      child: BlocBuilder<DocumentCategoryCubit, DocumentCategoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              screenTitle: "Project Document Category",
              authorization: _routeAuthorizationModel,
              onSearchSubmit: (value) {
                if (_selectedProjectNotifier.value.projectId != 0) {
                  _documentCategoryCubit.searchCategory(
                    context,
                    _selectedProjectNotifier.value.projectId,
                    value,
                  );
                }
              },
              textController: _searchC,
              searchHintText: "Search by Project Document Category",
              filterCountNotifier: _filterCount,
              isFilterOn: true,
              onFilterTap: () {
                if (_selectedProjectNotifier.value.projectId == 0) {
                  showErrorMessage(context, 'Error', 'Please select a project');
                  return;
                }
                _showBottomSheetToFilterDocumentCategoryMaster(context);
              },

              onAddCallback: () {
                if (_selectedProjectNotifier.value.projectId == 0) {
                  showErrorMessage(context, 'Error', 'Please select a project');
                  return;
                }
                goRouter.pushNamed(AppRoutes.addDocumentCategory);
              },
              onProjectChangeCallback: (value) {
                _selectedProjectNotifier.value = value;
                _searchC.clear();
                _documentCategoryCubit.resetSearch();
                if (context.mounted) {
                  _documentCategoryCubit.getDocumentCategoryList(
                    context,
                    1,
                    value.projectId,
                  );
                }
              },
              onExportCallback: (value) {
                if (_documentCategoryCubit.state.totalNumberOfRecord == 0) {
                  showErrorMessage(context, "Error", "No data found");
                  return;
                }
                _documentCategoryCubit.exportExcelPdf(
                  context,
                  value,
                  _selectedProjectNotifier.value.projectId,
                );
              },
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: _selectedProjectNotifier,
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: showSiteSelectedWidget(),
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<
                    DocumentCategoryCubit,
                    DocumentCategoryState
                  >(
                    bloc: _documentCategoryCubit,
                    builder: (context, state) {
                      if ((state.isLoading ?? true) &&
                          state.documentCategoryList.isEmpty) {
                        return Center(child: loader());
                      }
                      if (state.documentCategoryList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Project Document Category Data Found",
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          _searchC.clear();
                          _documentCategoryCubit.searchCategory(
                            context,
                            _selectedProjectNotifier.value.projectId,
                            "",
                          );
                        },
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: state.documentCategoryList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.documentCategoryList.length) {
                              return state.documentCategoryList.length <
                                      state.totalNumberOfRecord
                                  ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : const SizedBox.shrink();
                            }
                            var category = state.documentCategoryList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 10,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () {
                                            goRouter.pushNamed(
                                              AppRoutes.viewDocumentCategory,
                                              queryParameters: {
                                                "documentCategory":
                                                    Uri.encodeQueryComponent(
                                                      EncryptionManager.encryptData(
                                                        jsonEncode(
                                                          category.toJson(),
                                                        ),
                                                      ),
                                                    ),
                                              },
                                            );
                                          },
                                          child: Text(
                                            category
                                                .projectDocumentCategoryName,
                                            style: AppTextStyle.ts14M(
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          CustomIconButton.edit(
                                            isDisabled:
                                                !_routeAuthorizationModel
                                                    .isAction,
                                            onPressed: () async {
                                              if (_selectedProjectNotifier
                                                      .value
                                                      .projectId ==
                                                  0) {
                                                showErrorMessage(
                                                  context,
                                                  'Error',
                                                  'Please select a project',
                                                );
                                                return;
                                              }
                                              await goRouter.pushNamed(
                                                AppRoutes.addDocumentCategory,
                                                queryParameters: {
                                                  "documentCategory":
                                                      Uri.encodeQueryComponent(
                                                        EncryptionManager.encryptData(
                                                          jsonEncode(
                                                            category.toJson(),
                                                          ),
                                                        ),
                                                      ),
                                                  'index': index.toString(),
                                                },
                                              );
                                            },
                                          ),
                                          horizontalSpacing(),
                                          CustomIconButton.delete(
                                            isDisabled:
                                                (!_routeAuthorizationModel
                                                        .isAction ||
                                                    category.documentCount > 0),
                                            onPressed: () {
                                              _showPopupToDeleteDocumentCategory(
                                                context,
                                                category,
                                                state.currentPage,
                                                index,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  verticalSpacing(height: 8),
                                  buildRowTitleValue(
                                    title: "Sequence",
                                    value: category.orderBy.toString(),
                                  ),
                                  buildRowTitleValue(
                                    title: "Document Count",
                                    value: category.documentCount.toString(),
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
          );
        },
      ),
    );
  }
}
