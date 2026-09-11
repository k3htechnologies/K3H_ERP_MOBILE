import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_file.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewApprovedBankScreen extends StatefulWidget {
  final int approvedBankFolderId;
  final String approvedBankName;
  const ViewApprovedBankScreen({
    super.key,
    required this.approvedBankFolderId,
    required this.approvedBankName,
  });

  @override
  State<ViewApprovedBankScreen> createState() => _ViewApprovedBankScreenState();
}

class _ViewApprovedBankScreenState extends State<ViewApprovedBankScreen> {
  // CUBIT
  late ApprovedBankFolderCubit _approvedBankFileCubit;
  late AuthorizationModel _routeAuthorizationModel;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _titleC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  MultiFilePickerModel documentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final ValueNotifier<int> _filterCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _project = getProject();
    _approvedBankFileCubit = context.read<ApprovedBankFolderCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.approvedBank] ??
        AuthorizationModel();
    _onScroll();
    _approvedBankFileCubit.getApprovedBankFileList(
      context,
      1,
      _project.projectId,
      widget.approvedBankFolderId,
      clearSearch: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _titleC.dispose();
    _filterCount.dispose();
  }

  void _initializeTextControllers() {
    _searchC = TextEditingController();
    _titleC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_approvedBankFileCubit.state.isLoading! &&
          _approvedBankFileCubit.state.approvedBankFileList.length <
              _approvedBankFileCubit.state.totalNumberOfRecordBankFile) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _approvedBankFileCubit.getApprovedBankFileList(
            context,
            _approvedBankFileCubit.state.currentPageBankFile + 1,
            _project.projectId,
            widget.approvedBankFolderId,
          );
        });
      }
    });
  }

  // CLEAR DIALOGUE
  void _clearDialogue() {
    _titleC.clear();
    documentFile.fileNameList = [];
  }

  _prefillDialogue(ApprovedBankFileModel approvedBankFileModel) {
    _titleC.text = approvedBankFileModel.approvedBankFileName;
    documentFile.fileNameList =
        approvedBankFileModel.approvedBankFileUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  // API CALLS TO ADD/UPDATE APPROVED BANK FILE
  Future<void> _addUpdateApprovedBankFile(
    BuildContext context,
    ApprovedBankFileModel? approvedBankFileModel,
    int index,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (approvedBankFileModel != null) {
        // Updating existing file
        _approvedBankFileCubit.updateApprovedBankFile(
          context: context,
          approvedBankFileId:
              approvedBankFileModel.approvedBankFileId.toString(),
          uniqueKey: approvedBankFileModel.uniquekey,
          projectId: _project.projectId.toString(),
          approvedBankFolderId:
              approvedBankFileModel.approvedBankFolderId.toString(),
          approvedBankFileName: _titleC.text,
          documentFile: documentFile,
          index: index,
        );
      } else {
        // Adding new file
        _approvedBankFileCubit.addApprovedBankFile(
          context: context,
          projectId: _project.projectId.toString(),
          approvedBankFolderId: widget.approvedBankFolderId.toString(),
          approvedBankFileName: _titleC.text,
          documentFile: documentFile,
        );
      }
    }
  }

  // DIALOGUE TO ADD/ UPDATE APPROVED BANK FILES
  Future<void> _showDialogToAddUpdateApprovedBankFile({
    ApprovedBankFileModel? doc,
    int? index,
  }) async {
    _clearDialogue();
    if (doc != null) _prefillDialogue(doc);
    await DialogHelper.showCustomBottomSheet(
      context,
      "${doc != null ? 'Update' : 'Add'} Bank Documents",
      contentWidget: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              title: 'Title',
              textController: _titleC,
              hint: "Enter Title",
              isRequired: true,
              inputFormatterList: [LengthLimitingTextInputFormatter(100)],
              validator: (string) {
                if (string == null || string.trim().isEmpty) {
                  return 'Title is required.';
                }
                return null;
              },
            ),
            CustomMultiFilePicker(
              title: 'Files',
              isRequired: true,
              maxFiles: 5,
              filePickType: FilePickType.kycDocument,
              initialFileList: documentFile.fileNameList,
              onFilePickedCallback: (bytesList, fileNameList) {
                documentFile.fileNameList = fileNameList;
                documentFile.fileBytesList = bytesList;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Attachment* is required.";
                }
                return null;
              },
              onFileDeleteCallback: (fileBytesList, fileNameList, deletedFile) {
                documentFile.fileNameList = fileNameList;
                documentFile.fileBytesList = fileBytesList;
                documentFile.deletedFileList = deletedFile;
              },
            ),
            verticalSpacing(height: 16),
          ],
        ),
      ),
      bottomActions: CustomButton(
        padding: EdgeInsets.symmetric(vertical: 8),
        leading: Icon(
          doc == null ? Icons.add : Icons.edit,
          size: 18,
          color: AppColor.white,
        ),
        text: doc == null ? 'Add' : 'Update',
        onPressed: () async {
          _addUpdateApprovedBankFile(context, doc, index ?? 0);
        },
      ),
    );
  }

  // DIALOGUE TO DELETE APPROVED BANK FILE
  Future<void> _showPopupToDeleteApprovedBankFile(
    BuildContext context,
    ApprovedBankFileModel obj,
    int currentPage,
    int? index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Approved Bank Document ?',
      'Deleting this Approved Bank Document will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      _approvedBankFileCubit.deleteApprovedBankFile(
        context: context,
        approvedBankFileId: obj.approvedBankFileId,
        approvedBankFolderId: obj.approvedBankFolderId,
        projectId: _project.projectId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        pageSize: 20,
        index: index,
      );
    }
  }

  Future<void> _showBottomSheetToFilterBankFileMaster(
    BuildContext context,
  ) async {
    final state = _approvedBankFileCubit.state;

    _searchC.text = state.searchTextFolder;

    String? selectedDirection =
        state.currentSortColumnBankFolder == "ApprovedBankFileName"
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
      title: "Filter - Approved Bank Documents",
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
                textController: _searchC,
                hint: "Enter Title",
                title: "Title",
                onChangeFunction: (_) => updateApplyState(innerState),
              ),
            ],
          );
        },
      ),

      onClear: () {
        applied = true;

        _searchC.clear();

        _approvedBankFileCubit.applyFilterAndSortApprovedBankFile(
          context: context,
          column: "Created Date",
          direction: "DESC",
          title: '',
          projectId: _project.projectId,
          approvedBankFolderId: widget.approvedBankFolderId,
        );
      },

      onApply: () {
        applied = true;

        _approvedBankFileCubit.applyFilterAndSortApprovedBankFile(
          context: context,
          column:
              selectedDirection != null
                  ? "ApprovedBankFileName"
                  : "Created Date",
          direction: selectedDirection ?? "DESC",
          title: _searchC.text.trim(),
          projectId: _project.projectId,
          approvedBankFolderId: widget.approvedBankFolderId,
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
        _filterCount.value = _approvedBankFileCubit.updateFilterCountFile(
          state,
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(
          screenTitle: 'Approved Bank Document',
          textController: _searchC,
          searchHintText: "Search By Title",
          showMenuIcon: false,
          authorization: _routeAuthorizationModel,
          extraHeight: 10,
          isFilterOn: true,
          filterCountNotifier: _filterCount,
          onFilterTap: () {
            _showBottomSheetToFilterBankFileMaster(context);
          },
          onSearchSubmit: (value) {
            _approvedBankFileCubit.searchFile(
              context,
              value,
              _project.projectId,
              widget.approvedBankFolderId,
            );
          },
          onAddCallback: () async {
            await _showDialogToAddUpdateApprovedBankFile();
          },
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                widget.approvedBankName,
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              Expanded(
                child: BlocBuilder<
                  ApprovedBankFolderCubit,
                  ApprovedBankFolderState
                >(
                  builder: (context, state) {
                    if ((state.isLoading ?? true) &&
                        state.approvedBankFileList.isEmpty) {
                      return Center(child: loader());
                    }
                    if (state.approvedBankFileList.isEmpty) {
                      return Center(
                        child: noDataWidget(
                          message: "No Approved Bank File Found",
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      separatorBuilder:
                          (context, index) => verticalSpacing(height: 16),
                      itemCount:
                          _approvedBankFileCubit
                              .state
                              .approvedBankFileList
                              .length +
                          1,
                      itemBuilder: (context, index) {
                        if (index == state.approvedBankFileList.length) {
                          return state.approvedBankFileList.length <
                                  state.totalNumberOfRecordBankFile
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var doc = state.approvedBankFileList[index];
                        return Container(
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  top: 16,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.lightBluebg.withValues(
                                    alpha: 0.5,
                                  ),
                                  border: Border.all(color: AppColor.lightBlue),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doc.approvedBankFileName,
                                        style: AppTextStyle.ts14M(),
                                      ),
                                    ),
                                    Row(
                                      spacing: 10,
                                      children: [
                                        CustomIconButton(
                                          isDisable:
                                              doc.approvedBankFileUrl.isEmpty,
                                          onPressed: () {
                                            showFilePreviewDialog(
                                              title: doc.approvedBankFileName,
                                              context,
                                              doc.approvedBankFileUrl.split(
                                                ",",
                                              ),
                                            );
                                          },
                                          backgroundColor: Colors.transparent,
                                          icon: Icon(
                                            Icons.remove_red_eye_outlined,
                                            color:
                                                doc.approvedBankFileUrl.isEmpty
                                                    ? AppColor.grey2
                                                    : AppColor.primary,
                                            size: 18,
                                          ),
                                        ),
                                        CustomIconButton.edit(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () {
                                            _showDialogToAddUpdateApprovedBankFile(
                                              doc: doc,
                                              index: index,
                                            );
                                          },
                                        ),
                                        CustomIconButton.delete(
                                          isDisabled:
                                              !_routeAuthorizationModel
                                                  .isAction,
                                          onPressed: () {
                                            _showPopupToDeleteApprovedBankFile(
                                              context,
                                              doc,
                                              state.currentPageBankFile,
                                              index,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  left: 16,
                                  bottom: 16,
                                ),
                                child: Column(
                                  children: [
                                    buildRowTitleValue(
                                      title: "Document Count",
                                      fixesWidth: 140.w,
                                      value:
                                          doc.approvedBankFileUrl
                                              .split(',')
                                              .length
                                              .toString(),
                                    ),
                                    buildRowTitleValue(
                                      title: "Modified By / Date",
                                      fixesWidth: 140.w,
                                      singleLine: false,
                                      value:
                                          doc.modifiedDate == null
                                              ? '${doc.createdBy} / ${formatDate(doc.createdDate)}'
                                              : '${doc.modifiedBy} / ${formatDate(doc.modifiedDate)}',
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}
