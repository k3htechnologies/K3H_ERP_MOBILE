import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/data/model/drawing_document.model.dart';
import 'package:k3h_erp_app/features/project_document/drawing_document/presentation/cubit/drawing_document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DrawingDocumentScreen extends StatefulWidget {
  const DrawingDocumentScreen({super.key});

  @override
  State<DrawingDocumentScreen> createState() => _DrawingDocumentScreenState();
}

class _DrawingDocumentScreenState extends State<DrawingDocumentScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late DrawingDocumentCubit _drawingDocumentCubit;
  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC,
      _documentC,
      _buildingNumberC,
      _wingC,
      _floorC;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TAB CONTROLLERS
  TabController? _categoryTabController;

  late ValueNotifier<ProjectModel> _selectedProjectNotifier;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.drawingDocument]!;
    _selectedProjectNotifier = ValueNotifier<ProjectModel>(getProject());
    _drawingDocumentCubit = context.read<DrawingDocumentCubit>();
    _drawingDocumentCubit.getDrawingDocumentCategoryList(
      context,
      1,
      _selectedProjectNotifier.value.projectId,
    );
    _initControllers();
    _onScroll();
  }

  @override
  void dispose() {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();
    _searchC.dispose();
    _documentC.dispose();
    scrollController.dispose();
    _filterCount.dispose();
    _buildingNumberC.dispose();
    _wingC.dispose();
    _floorC.dispose();
    super.dispose();
  }

  void _initControllers() {
    _searchC = TextEditingController();
    _documentC = TextEditingController();
    _buildingNumberC = TextEditingController();
    _wingC = TextEditingController();
    _floorC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_drawingDocumentCubit.state.isLoading! &&
          _drawingDocumentCubit.state.drawingDocumentList.length <
              _drawingDocumentCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _drawingDocumentCubit.getDrawingDocumentList(
            context: context,
            pageNumber: _drawingDocumentCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // CATEGORY TAB
  void _onBuildingTabChanged() {
    if (!_categoryTabController!.indexIsChanging && mounted) {
      _searchC.clear();
      _drawingDocumentCubit.onTabChanged(
        _categoryTabController!.index,
        context,
      );
    }
  }

  // CATEGORY CONTROLLER
  void _initCategoryController(DrawingDocumentState state) {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();

    _categoryTabController = TabController(
      length: state.drawingDocumentCategoryModelList.length,
      vsync: this,
      initialIndex: state.categoryIndex,
    );

    _categoryTabController!.addListener(_onBuildingTabChanged);
  }

  // SUBMIT FORM
  void _saveForm({DrawingDocumentModel? documentModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (documentModel != null) {
      //Edit Name
      _drawingDocumentCubit.updateDrawingDocumentNameInCategory(
        context: context,
        index: index!,
        uniqueKey: documentModel.uniquekey,
        drawingDocumentId: documentModel.drawingDocumentId,
        drawingDocumentCategoryId: documentModel.drawingDocumentCategoryId,
        drawingDocumentName: _documentC.text.trim(),
      );
    } else {
      _drawingDocumentCubit.addDrawingDocumentToCategory(
        context: context,
        drawingDocumentName: _documentC.text.trim(),
      );
    }
  }

  void _prefillDocumentDetails(DrawingDocumentModel documentModel) {
    _documentC.text = documentModel.drawingDocumentName;
  }

  // DELETE DOCUMENT FROM CATEGORY
  Future<void> _showPopupToDeleteTestDocument(
    BuildContext context,
    DrawingDocumentModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document ?',
      'Deleting this document will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _drawingDocumentCubit.deleteDrawingDocument(obj, context, index);
    }
  }

  // ADD/UPDATE DOCUMENT
  Future<void> _showPopUpToAddUpdateDocument({
    DrawingDocumentModel? documentModel,
    int? index,
  }) async {
    if (documentModel != null) {
      _prefillDocumentDetails(documentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      documentModel != null ? 'Update Document Name' : 'Add Document Name',
      contentWidget: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              title: "Document Name",
              hint: "Enter Document Name",
              textController: _documentC,
              inputFormatterList: [LengthLimitingTextInputFormatter(100)],
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Document Name is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomActions: CustomButton(
        leading: Icon(
          documentModel != null ? Icons.edit : Icons.add,
          size: 16,
          color: AppColor.white,
        ),
        text: documentModel != null ? "Update Document" : "Add Document",
        onPressed: () {
          _saveForm(documentModel: documentModel, index: index);
          _searchC.clear();
        },
      ),
    );
    _clearDialogueToAddUpdateDocument();
  }

  // CLEAR TEXT CONTROLLER
  void _clearDialogueToAddUpdateDocument() {
    _documentC.clear();
  }

  // DRAWING DOCUMENT FILTER
  Future<void> _showBottomSheetToFilterDrawingDocument(
    BuildContext context,
  ) async {
    final state = _drawingDocumentCubit.state;

    _buildingNumberC.text = state.buildingNumberText;

    String? selectedDirection =
        state.currentSortColumn == "Drawing Document"
            ? state.currentSortDirection
            : null;

    final String initialBuildingNumber = _buildingNumberC.text;
    final String initialWing = _wingC.text;
    final String initialFloor = _floorC.text;
    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    bool applied = false;

    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            _buildingNumberC.text.trim() != initialBuildingNumber ||
            _wingC.text.trim() != initialWing ||
            _floorC.text.trim() != initialFloor ||
            selectedDirection != initialDirection;

        applyEnabled.value = manualClose;
      });
    }

    await DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Drawing Documentt",
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
              Text("Sort By Drawing Document", style: AppTextStyle.ts14M()),
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
                textController: _buildingNumberC,
                hint: "Enter Building Number",
                title: "Building Number",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
              CustomTextField(
                textController: _wingC,
                hint: "Enter Wing",
                title: "Wing",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
              CustomTextField(
                textController: _floorC,
                hint: "Enter Floor",
                title: "Floor",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _buildingNumberC.clear();
        _wingC.clear();
        _floorC.clear();

        _drawingDocumentCubit.applyFilterAndSortDrawingDocument(
          context: context,
          column: "",
          direction: "",
          buildingNumber: '',
          wing: "",
          floor: "",
        );
      },

      onApply: () {
        applied = true;

        _drawingDocumentCubit.applyFilterAndSortDrawingDocument(
          context: context,
          column: selectedDirection != null ? "Drawing Document" : "",
          direction: selectedDirection ?? "",
          buildingNumber: _buildingNumberC.text.trim(),
          wing: _wingC.text.trim(),
          floor: _floorC.text.trim(),
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // User closed bottom sheet without clicking Apply/Clear
    if (!applied && manualClose) {
      _buildingNumberC.text = initialBuildingNumber;
      _wingC.text = initialWing;
      _floorC.text = initialFloor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DrawingDocumentCubit, DrawingDocumentState>(
      listener: (context, state) {
        _filterCount.value = _drawingDocumentCubit.updateFilterCount(state);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: "Drawing Document",
          authorization: _routeAuthorizationModel,
          textController: _searchC,
          searchHintText: "Search By Document Name",
          onSearchSubmit: (value) {
            _drawingDocumentCubit.searchDocument(value, context);
          },
          onProjectChangeCallback: (value) {
            _selectedProjectNotifier.value = value;
            if (context.mounted) {
              _drawingDocumentCubit.getDrawingDocumentCategoryList(
                context,
                1,
                _selectedProjectNotifier.value.projectId,
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
          extraHeight: 20,
          secondaryBuilder:
              (_) => BlocBuilder<DrawingDocumentCubit, DrawingDocumentState>(
                builder: (context, state) {
                  final list = state.drawingDocumentCategoryModelList;
                  if (list.isNotEmpty) {
                    return CustomButton(
                      text: "Add",
                      onPressed: () {
                        _showPopUpToAddUpdateDocument();
                      },
                      backgroundColor: AppColor.primary,
                      leading: Icon(Icons.add, size: 16, color: AppColor.white),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
        ),
        body: SafeArea(
          child: Column(
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
                child: BlocListener<DrawingDocumentCubit, DrawingDocumentState>(
                  listener: (context, state) {
                    if (!mounted) return;
                    if (!state.isLoading! &&
                        state.drawingDocumentCategoryModelList.isNotEmpty) {
                      if (_categoryTabController == null ||
                          _categoryTabController!.length !=
                              state.drawingDocumentCategoryModelList.length) {
                        _initCategoryController(state);
                      }
                    }
                  },
                  child: BlocBuilder<
                    DrawingDocumentCubit,
                    DrawingDocumentState
                  >(
                    builder: (context, state) {
                      if (state.isLoading! &&
                          state.drawingDocumentCategoryModelList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.drawingDocumentCategoryModelList.isEmpty) {
                        return Center(
                          child: noDataWidget(
                            message: "No Test Document Data Found",
                          ),
                        );
                      }

                      if (_categoryTabController == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CATEGORY TAB
                          _buildCategoryTab(state),
                          verticalSpacing(),
                          Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              controller: _categoryTabController,
                              children:
                                  state.drawingDocumentCategoryModelList.map((
                                    category,
                                  ) {
                                    return (state.drawingDocumentList.isEmpty &&
                                            state.isLoading!)
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : RefreshIndicator(
                                          onRefresh: () async {
                                            _searchC.clear();
                                            _drawingDocumentCubit
                                                .searchDocument("", context);
                                          },
                                          child: _buildDocumentListForCategory(
                                            state,
                                          ),
                                        );
                                  }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CATEGORY TAB
  Widget _buildCategoryTab(DrawingDocumentState state) {
    if (_categoryTabController == null) {
      return const SizedBox.shrink();
    }

    if (_categoryTabController!.length !=
        state.drawingDocumentCategoryModelList.length) {
      return const SizedBox.shrink();
    }

    return ChipStyleTabBar(
      controller: _categoryTabController!,
      tabs:
          state.drawingDocumentCategoryModelList
              .map((e) => e.drawingDocumentCategoryName)
              .toList(),
    );
  }

  // BUILD DOCUMENT LIST FOR CATEGORY
  Widget _buildDocumentListForCategory(DrawingDocumentState state) {
    if (state.drawingDocumentList.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Test Document Data Found"),
      );
    }

    return BlocBuilder<DrawingDocumentCubit, DrawingDocumentState>(
      builder: (context, state) {
        return ListView.builder(
          controller: scrollController,
          itemCount: state.drawingDocumentList.length + 1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemBuilder: (context, index) {
            // Pagination loader
            if (index == state.drawingDocumentList.length) {
              return state.drawingDocumentList.length <
                      state.totalNumberOfRecord
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final document = state.drawingDocumentList[index];

            return Container(
              padding: EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),

              decoration: commonCardDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () async {
                            await goRouter.pushNamed(
                              AppRoutes.viewDrawingDocument,
                              queryParameters: {
                                "document": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(document.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                            if (context.mounted) {
                              _drawingDocumentCubit.getDrawingDocumentList(
                                context: context,
                                pageNumber: 1,
                              );
                            }
                          },
                          child: Text(
                            document.drawingDocumentName.toString(),
                            style: AppTextStyle.ts14M(color: AppColor.primary),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomIconButton.add(
                            isDisabled: !_routeAuthorizationModel.isAction,
                            onPressed: () async {
                              await goRouter.pushNamed(
                                AppRoutes.addDrawingDocument,
                                queryParameters: {
                                  "document": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(document.toJson()),
                                    ),
                                  ),
                                  "index": index.toString(),
                                  "isEdit": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      false.toString(),
                                    ),
                                  ),
                                },
                              );
                            },
                          ),
                          horizontalSpacing(),
                          CustomIconButton.edit(
                            isDisabled: !_routeAuthorizationModel.isAction,
                            onPressed: () async {
                              _showPopUpToAddUpdateDocument(
                                documentModel: document,
                                index: index,
                              );
                            },
                          ),
                          horizontalSpacing(),
                          CustomIconButton.delete(
                            isDisabled:
                                (!_routeAuthorizationModel.isAction ||
                                    document.uploadedApprovalDocumentCount > 0),
                            onPressed: () {
                              _showPopupToDeleteTestDocument(
                                context,
                                document,
                                index,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Pending Approval",
                    value:
                        document.approvalPendingApprovalDocumentCount
                            .toString(),
                  ),
                  buildRowTitleValue(
                    title: "Document Count",
                    value: document.uploadedApprovalDocumentCount.toString(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
