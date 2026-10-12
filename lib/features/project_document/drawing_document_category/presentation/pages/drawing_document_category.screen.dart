import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/data/model/drawing_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document_category/presentation/cubit/drawing_document_category_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DrawingDocumentCategoryScreen extends StatefulWidget {
  const DrawingDocumentCategoryScreen({super.key});

  @override
  State<DrawingDocumentCategoryScreen> createState() =>
      _DrawingDocumentCategoryScreenState();
}

class _DrawingDocumentCategoryScreenState
    extends State<DrawingDocumentCategoryScreen> {
  //CUBIT
  late DrawingDocumentCategoryCubit _drawingDocumentCategoryCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

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
    _drawingDocumentCategoryCubit =
        context.read<DrawingDocumentCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.drawingDocumentCategory]!;
    _onScroll();
    _initializeTextEditingController();
    _selectedProjectNotifier = ValueNotifier<ProjectModel>(getProject());
    _drawingDocumentCategoryCubit.getDrawingDocumentCategoryList(
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
          !_drawingDocumentCategoryCubit.state.isLoading! &&
          _drawingDocumentCategoryCubit
                  .state
                  .drawingDocumentCategoryModelList
                  .length <
              _drawingDocumentCategoryCubit.state.totalNumberOfRecord) {
        if (_selectedProjectNotifier.value.projectId != 0) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            _drawingDocumentCategoryCubit.getDrawingDocumentCategoryList(
              context,
              _drawingDocumentCategoryCubit.state.currentPage + 1,

              _selectedProjectNotifier.value.projectId,
            );
          });
        }
      }
    });
  }

  // DELETE DOCUMENT CATEGORY
  Future<void> _showPopupToDeleteTestDocumentCategory(
    BuildContext context,
    DrawingDocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a drawing document category ?',
      'Deleting this drawing document category will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _drawingDocumentCategoryCubit.deleteDrawingDocumentCategory(
        _selectedProjectNotifier.value.projectId,
        obj,
        context,
      );
    }
  }

  // DRAWING DOCUMENT CATEGORY FILTER
  Future<void> _showBottomSheetToFilterDrawingDocument(
    BuildContext context,
  ) async {
    final state = _drawingDocumentCategoryCubit.state;

    _searchC.text = state.searchText;

    String? selectedDirection =
        state.currentSortColumn == "Drawing Document Category"
            ? state.currentSortDirection
            : null;

    final String initialTestDocumentCategory = _searchC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _searchC.text.trim() != initialTestDocumentCategory ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Drawing Document Category",
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
                "Sort By Drawing Document Category",
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
                hint: "Enter Drawing Document Category",
                title: "Approval Drawing Document Category",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _drawingDocumentCategoryCubit.applyFilterAndSortDrawingDocumentCategory(
          context: context,
          column: "",
          direction: "",
          testDocument: '',
        );
      },

      onApply: () {
        applied = true;

        _drawingDocumentCategoryCubit.applyFilterAndSortDrawingDocumentCategory(
          context: context,
          column: selectedDirection != null ? "Drawing Document Category" : "",
          direction: selectedDirection ?? "",
          testDocument: _searchC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _searchC.text = initialTestDocumentCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      DrawingDocumentCategoryCubit,
      DrawingDocumentCategoryState
    >(
      listener: (context, state) {
        _filterCount.value = _drawingDocumentCategoryCubit.updateFilterCount(
          state,
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Drawing Document Category",
          authorization: _routeAuthorizationModel,
          searchHintText: "Search By Drawing Document Category",
          onSearchSubmit: (value) {
            if (_selectedProjectNotifier.value.projectId != 0) {
              _drawingDocumentCategoryCubit.searchCategory(
                context,
                _selectedProjectNotifier.value.projectId,
                value,
              );
            }
          },
          isFilterOn: true,
          onFilterTap: () {
            if (_selectedProjectNotifier.value.projectId == 0) {
              showErrorMessage(context, "Error", "Please select a project");
              return;
            }
            _showBottomSheetToFilterDrawingDocument(context);
          },
          filterCountNotifier: _filterCount,
          textController: _searchC,
          onAddCallback: () async {
            if (_selectedProjectNotifier.value.projectId == 0) {
              showErrorMessage(context, 'Error', 'Please select a project');
              return;
            }
            _searchC.clear();
            await _drawingDocumentCategoryCubit.resetSearch();
            goRouter.pushNamed(AppRoutes.addDrawingDocumentCategory).then((_) {
              if (context.mounted) {
                _drawingDocumentCategoryCubit.getDrawingDocumentCategoryList(
                  context,
                  1,
                  _selectedProjectNotifier.value.projectId,
                );
              }
            });
          },
          onExportCallback: (value) {
            if (_drawingDocumentCategoryCubit.state.totalNumberOfRecord == 0) {
              showErrorMessage(context, "Error", "No Data Found");
              return;
            }
            _drawingDocumentCategoryCubit.exportExcelPdf(
              context,
              value,
              _selectedProjectNotifier.value.projectId,
            );
          },
          onProjectChangeCallback: (value) {
            _selectedProjectNotifier.value = value;
            _searchC.clear();
            _drawingDocumentCategoryCubit.resetSearch();
            _drawingDocumentCategoryCubit.getDrawingDocumentCategoryList(
              context,
              1,
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
                DrawingDocumentCategoryCubit,
                DrawingDocumentCategoryState
              >(
                builder: (context, state) {
                  if ((state.isLoading ?? true) &&
                      state.drawingDocumentCategoryModelList.isEmpty) {
                    return Center(child: loader());
                  }
                  if (state.drawingDocumentCategoryModelList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: noDataWidget(
                          message: "No Test Document Category Data Found",
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount:
                        state.drawingDocumentCategoryModelList.length + 1,
                    itemBuilder: (context, index) {
                      if (index ==
                          state.drawingDocumentCategoryModelList.length) {
                        return state.drawingDocumentCategoryModelList.length <
                                state.totalNumberOfRecord
                            ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }
                      var testDocumentCategory =
                          state.drawingDocumentCategoryModelList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: commonCardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      goRouter.pushNamed(
                                        AppRoutes.viewDrawingDocumentCategory,
                                        queryParameters: {
                                          "drawingDocumentCategory":
                                              Uri.encodeQueryComponent(
                                                EncryptionManager.encryptData(
                                                  jsonEncode(
                                                    testDocumentCategory
                                                        .toJson(),
                                                  ),
                                                ),
                                              ),
                                        },
                                      );
                                    },
                                    child: Text(
                                      testDocumentCategory
                                          .drawingDocumentCategoryName,
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
                                          !_routeAuthorizationModel.isAction,
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
                                          AppRoutes.addDrawingDocumentCategory,
                                          queryParameters: {
                                            "drawingDocumentCategory":
                                                Uri.encodeQueryComponent(
                                                  EncryptionManager.encryptData(
                                                    jsonEncode(
                                                      testDocumentCategory
                                                          .toJson(),
                                                    ),
                                                  ),
                                                ),
                                            'index': index.toString(),
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    CustomIconButton.delete(
                                      isDisabled:
                                          (!_routeAuthorizationModel.isAction ||
                                              testDocumentCategory
                                                      .documentCount >
                                                  0),
                                      onPressed: () {
                                        _showPopupToDeleteTestDocumentCategory(
                                          context,
                                          testDocumentCategory,
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
                              value: testDocumentCategory.orderBy.toString(),
                            ),
                            buildRowTitleValue(
                              title: "Document Count",
                              value:
                                  testDocumentCategory.documentCount.toString(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
