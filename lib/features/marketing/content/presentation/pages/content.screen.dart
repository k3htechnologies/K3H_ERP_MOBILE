import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_folder.model.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_folder/content_folder_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  // CUBIT
  late ContentFolderCubit _marketingCubit;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _folderNameC, _filterByContentNameC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FILTER COUNT
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _marketingCubit = BlocProvider.of<ContentFolderCubit>(context);
    _initialiseTextController();
    _project = getProject();
    _onScroll();
    _marketingCubit.getMarketingFolderList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _filterByContentNameC.dispose();
    _folderNameC.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    _filterCount.dispose();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !(_marketingCubit.state.isLoading ?? false) &&
          _marketingCubit.state.marketingContentFolderList.length <
              _marketingCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _marketingCubit.getMarketingFolderList(
            context,
            _marketingCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  void _initialiseTextController() {
    _searchC = TextEditingController();
    _folderNameC = TextEditingController();
    _filterByContentNameC = TextEditingController();
  }

  void _clearDialogueToAddUpdateContentFolder() {
    _folderNameC.clear();
  }

  void _prefillDocumentDetails(ContentFolderModel contentModel) {
    _folderNameC.text = contentModel.marketingContentFolderName;
  }

  // DIALOGUE TO ADD/UPDATE CONTENT FOLDER
  Future<void> _showDialogToAddUpdateContentFolder({
    required BuildContext context,
    required ContentFolderState state,
    ContentFolderModel? contentModel,
    int? index,
  }) async {
    if (contentModel != null) {
      _prefillDocumentDetails(contentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      contentModel != null ? "Update Content" : "Add Content",
      contentWidget: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomTextField(
              title: 'Content Name',
              isRequired: true,
              hint: "Enter content name",
              textController: _folderNameC,
              inputFormatterList: [LengthLimitingTextInputFormatter(100)],
              validator: (string) {
                if (string == null || string.trim().isEmpty) {
                  return 'Content name is required.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomActions: CustomButton(
        leading: Icon(
          contentModel != null ? Icons.edit : Icons.add,
          size: 16,
          color: AppColor.white,
        ),
        text: contentModel != null ? "Update" : "Add",
        onPressed: () {
          _saveForm(contentFolderModel: contentModel, index: index);
          _searchC.clear();
        },
      ),
    );
    _clearDialogueToAddUpdateContentFolder();
  }

  // SUBMIT FORM
  void _saveForm({ContentFolderModel? contentFolderModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (contentFolderModel != null) {
      //Edit Name
      _marketingCubit.updateContentFolder(
        context: context,
        index: index!,
        uniqueKey: contentFolderModel.uniquekey,
        marketingContentFolderId: contentFolderModel.marketingContentFolderId,
        marketingContentFolderName: _folderNameC.text.trim(),
      );
    } else {
      _marketingCubit.addContentFolder(
        context: context,
        marketingContentFolderName: _folderNameC.text.trim(),
        projectId: _project.projectId,
      );
    }
  }

  // DIALOGUE TO CONTENT FOLDER
  Future<void> _showPopupToDeleteContentFolder(
    BuildContext context,
    ContentFolderModel obj,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Content Document ?',
      'Deleting this Content Document will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _marketingCubit.deleteContentFolder(
        context: context,
        marketingContentFolderId: obj.marketingContentFolderId,
        projectId: _project.projectId,
        uniqueKey: obj.uniquekey,
        pageNumber: 1,
        pageSize: 20,
      );
    }
  }

  Future<void> _showBottomSheetToFilterContentAllocation(
    BuildContext context,
  ) async {
    final state = _marketingCubit.state;
    String? selectedDirection =
        state.currentSortColumn == "Content Name"
            ? state.currentSortDirection
            : null;
    _searchC.text = state.searchText;
    _filterByContentNameC.text = state.searchText;

    final String initialName = _searchC.text;
    final String initialEmployeeName = _filterByContentNameC.text;

    final String? initialDirection = selectedDirection;

    bool manualClose = false;
    final ValueNotifier<bool> applyEnabled = ValueNotifier<bool>(false);
    bool applied = false;

    void updateApplyState(StateSetter innerState) {
      innerState(() {
        manualClose =
            (_searchC.text.trim() != initialEmployeeName) ||
            (_filterByContentNameC.text.trim() != initialName) ||
            (selectedDirection != initialDirection);
        applyEnabled.value = manualClose;
      });
    }

    DialogHelper.showCustomFilterBottomSheet(
      context,
      title: "Filter - Content",
      contentWidget: StatefulBuilder(
        builder: (context, innerState) {
          void selectDirection(String direction) {
            innerState(() {
              selectedDirection = direction;
            });
            updateApplyState(innerState);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Sort By Content Name", style: AppTextStyle.ts14M()),
                verticalSpacing(),
                Row(
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
                  title: "Content Name",
                  hint: "Enter Content Name",
                  textController: _searchC,
                  onChangeFunction: (_) => updateApplyState(innerState),
                ),
              ],
            ),
          );
        },
      ),

      onClear: () {
        _searchC.clear();
        _filterByContentNameC.clear();

        _marketingCubit.applyMarketingFolderFilterAndSort(
          context: context,
          isClear: true,
        );
      },

      onApply: () {
        applied = true;

        _marketingCubit.applyMarketingFolderFilterAndSort(
          context: context,
          employeeName: _searchC.text.trim(),

          sortColumn: selectedDirection != null ? "Content Name" : null,
          sortDirection: selectedDirection,
        );
      },

      isApplyEnabled: applyEnabled.value,
      applyEnabledNotifier: applyEnabled,
    );

    // IF BOTTOM SHEET CLOSE WITHOUT APPLYING
    if (!applied && manualClose) {
      _filterByContentNameC.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentFolderCubit, ContentFolderState>(
      listener: (context, state) {
        _filterCount.value = _marketingCubit.updateMarketingFolderFilterCount(
          state,
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: 'Content',
          authorization: AuthorizationModel(isAction: true),
          textController: _searchC,
          searchHintText: "Search by Content Name",
          onSearchSubmit: (value) {
            _marketingCubit.searchContentFolder(
              context,
              value,
              _project.projectId,
            );
          },
          onProjectChangeCallback: (value) {
            _project = value;
            _searchC.clear();
            _filterByContentNameC.clear();
            _marketingCubit.searchContentFolder(
              context,
              "",
              _project.projectId,
            );
            _marketingCubit.getMarketingFolderList(
              context,
              1,
              _project.projectId,
            );
          },
          isFilterOn: true,
          onFilterTap: () {
            _showBottomSheetToFilterContentAllocation(context);
          },
          filterCountNotifier: _filterCount,
          extraHeight: 20,
          secondaryBuilder:
              (_) => BlocBuilder<ContentFolderCubit, ContentFolderState>(
                builder: (context, state) {
                  final list = state.marketingContentFolderList;
                  if (list.isNotEmpty) {
                    return CustomButton(
                      text: "Add",
                      onPressed: () {
                        _showDialogToAddUpdateContentFolder(
                          context: context,
                          state: state,
                        );
                      },
                      backgroundColor: AppColor.primary,
                      leading: Icon(Icons.add, size: 16, color: AppColor.white),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _searchC.clear();
            _marketingCubit.searchContentFolder(
              context,
              "",
              _project.projectId,
            );
          },
          child: BlocBuilder<ContentFolderCubit, ContentFolderState>(
            builder: (context, state) {
              if ((state.isLoading ?? false) &&
                  state.marketingContentFolderList.isEmpty) {
                return Center(child: loader());
              }
              if (state.marketingContentFolderList.isEmpty) {
                return Center(
                  child: noDataWidget(message: "No Content Folder Found"),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shrinkWrap: true,
                itemCount:
                    _marketingCubit.state.marketingContentFolderList.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.marketingContentFolderList.length) {
                    return state.marketingContentFolderList.length <
                            state.totalNumberOfRecord
                        ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }
                  var folder =
                      _marketingCubit.state.marketingContentFolderList[index];
                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: commonCardDecoration(),
                    child: Column(
                      children: [
                        Row(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  await goRouter.pushNamed(
                                    AppRoutes.contentDocument,
                                    queryParameters: {
                                      "marketingContentFolderId":
                                          Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                state
                                                    .marketingContentFolderList[index]
                                                    .marketingContentFolderId,
                                              ),
                                            ),
                                          ),
                                      "marketingContentFolderName":
                                          folder.marketingContentFolderName,
                                    },
                                  );

                                  // If document was added/deleted, refresh the folder list
                                  if (context.mounted) {
                                    _marketingCubit.getMarketingFolderList(
                                      context,
                                      1,
                                      _project.projectId,
                                    );
                                  }
                                },
                                child: Text(
                                  folder.marketingContentFolderName,
                                  style: AppTextStyle.ts14M(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (folder.numberOfMarketingContent > 0) ...{
                                  CustomIconButton(
                                    onPressed: () {
                                      _marketingCubit.exportZip(
                                        context,
                                        _project.projectId,
                                        folder.marketingContentFolderId,
                                        folder.marketingContentFolderName
                                            .toString(),
                                        1,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.file_download_outlined,
                                      size: 16,
                                      color: AppColor.primary,
                                    ),
                                  ),
                                } else ...{
                                  CustomIconButton.delete(
                                    onPressed: () {
                                      _showPopupToDeleteContentFolder(
                                        context,
                                        state.marketingContentFolderList[index],
                                      );
                                    },
                                  ),
                                },
                                horizontalSpacing(),
                                CustomIconButton.edit(
                                  onPressed: () {
                                    _showDialogToAddUpdateContentFolder(
                                      context: context,
                                      contentModel: folder,
                                      state: state,
                                      index: index,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        verticalSpacing(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  folder.numberOfMarketingContent.toString(),
                                  style: AppTextStyle.ts14M(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
