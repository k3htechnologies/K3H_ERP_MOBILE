import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_document.model.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_document/content_document_cubit.dart';
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

class ContentDocumentScreen extends StatefulWidget {
  final int marketingContentFolderId;
  final String marketingContentFolderName;
  const ContentDocumentScreen({
    super.key,
    required this.marketingContentFolderId,
    required this.marketingContentFolderName,
  });

  @override
  State<ContentDocumentScreen> createState() => _ContentDocumentScreenState();
}

class _ContentDocumentScreenState extends State<ContentDocumentScreen> {
  // CUBIT
  late ContentDocumentCubit _contentDocumentCubit;

  // PROJECT
  late ProjectModel _project;

  // FORM KEY
  final _contentDocumentAddUpdateKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _marketingTitleC, _marketingRemarkC, _searchC;

  // ATTACHMENT
  MultiFilePickerModel marketingContentAttachment = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _project = getProject();
    _contentDocumentCubit = BlocProvider.of<ContentDocumentCubit>(context);
    _onScroll();
    _contentDocumentCubit.getContentDocumentList(
      context,
      1,
      10,
      _project.projectId,
      widget.marketingContentFolderId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _marketingTitleC.dispose();
    _marketingRemarkC.dispose();
    _searchC.dispose();
  }

  void _initializeTextControllers() {
    _marketingTitleC = TextEditingController();
    _marketingRemarkC = TextEditingController();
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          (_contentDocumentCubit.state.isLoading != true) &&
          _contentDocumentCubit.state.marketingContentDocumentList.length <
              _contentDocumentCubit.state.totalNumberOfRecord) {
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _contentDocumentCubit.getContentDocumentList(
            context,
            _contentDocumentCubit.state.currentPage + 1,
            10,
            _project.projectId,
            widget.marketingContentFolderId,
          );
        });
      }
    });
  }

  void prefillContentDocument(ContentDocumentModel contentDocumentModel) {
    _marketingTitleC.text = contentDocumentModel.title;
    _marketingRemarkC.text = contentDocumentModel.remark;
    // Reset attachment so we don't carry stale fileBytesList/deletedFileList from previous use
    marketingContentAttachment.fileBytesList = [];
    marketingContentAttachment.deletedFileList = "";
    marketingContentAttachment.fileNameList =
        contentDocumentModel.marketingContentURL
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  // CLEAR DEPARTMENT MASTER
  void _clearDialogueToAddUpdateContentDocument() {
    _marketingTitleC.clear();
    _marketingRemarkC.clear();
    marketingContentAttachment = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );
  }

  Future<void> _showPopUpToAddUpdateContentDocument({
    ContentDocumentModel? contentDocumentModel,
    int? index,
  }) async {
    if (contentDocumentModel != null) {
      prefillContentDocument(contentDocumentModel);
    } else {
      _clearDialogueToAddUpdateContentDocument();
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      'Content Document',
      contentWidget: Form(
        key: _contentDocumentAddUpdateKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              textController: _marketingTitleC,
              title: 'Title',
              isRequired: true,
              hint: "Enter title",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Title is required.";
                }
                return null;
              },
            ),
            CustomTextField(
              textController: _marketingRemarkC,
              title: 'Remark',
              minLines: 3,
              maxLines: 10,
              isRequired: true,
              hint: "Enter remark",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Remark is required.";
                }
                return null;
              },
            ),
            CustomMultiFilePicker(
              initialFileList: marketingContentAttachment.fileNameList,
              title: "Attachment",
              isRequired: true,
              onFilePickedCallback: (bytes, fileName) {
                marketingContentAttachment.fileBytesList = bytes;
                marketingContentAttachment.fileNameList = fileName;
              },
              onFileDeleteCallback: (bytes, fileName, deletedFiles) {
                marketingContentAttachment.fileBytesList = bytes;
                marketingContentAttachment.fileNameList = fileName;
                marketingContentAttachment.deletedFileList = deletedFiles;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Attachment is required.";
                }
                return null;
              },
            ),
          ],
        ),
      ),

      bottomActions: CustomButton(
        text: "Save",
        onPressed: () {
          if (_contentDocumentAddUpdateKey.currentState!.validate()) {
            if (contentDocumentModel == null) {
              // Adding new document
              _contentDocumentCubit.addMarketingContent(
                context,
                projectId: _project.projectId,
                marketingContentFolderId: widget.marketingContentFolderId,
                title: _marketingTitleC.text,
                remark: _marketingRemarkC.text,
                marketingContentDocument: marketingContentAttachment,
              );
            } else {
              // Updating existing document
              _contentDocumentCubit.updateMarketingContent(
                context,
                projectId: _project.projectId,
                marketingContentFolderId: widget.marketingContentFolderId,
                marketingContentId: contentDocumentModel.marketingContentId,
                uniqueKey: contentDocumentModel.uniquekey,
                title: _marketingTitleC.text,
                remark: _marketingRemarkC.text,
                marketingContentDocument: marketingContentAttachment,
                index: index!,
              );
            }
          }
        },
      ),
    );
    _clearDialogueToAddUpdateContentDocument();
  }

  // DIALOGUE TO DELETE DOCUMENT
  Future<void> _showPopupToDeleteDocument(
    BuildContext context,
    ContentDocumentModel obj,
    int currentPage,
    int? index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _contentDocumentCubit.deleteMarketingContent(
        context: context,
        marketingContentId: obj.marketingContentId,
        marketingContentFolderId: obj.marketingContentFolderId,
        projectId: obj.projectId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        pageSize: 20,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Content Document',
        searchHintText: "Search by Title",
        onSearchSubmit: (value) {
          _contentDocumentCubit.searchContentDocument(
            context,
            value,
            _project.projectId,
            widget.marketingContentFolderId,
          );
        },
        textController: _searchC,
        showMenuIcon: false,
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () async {
          await _showPopUpToAddUpdateContentDocument();
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              widget.marketingContentFolderName,
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            Expanded(
              child: BlocBuilder<ContentDocumentCubit, ContentDocumentState>(
                builder: (context, state) {
                  if ((state.isLoading ?? true) &&
                      state.marketingContentDocumentList.isEmpty) {
                    return Center(child: loader());
                  }
                  if (state.marketingContentDocumentList.isEmpty) {
                    return Center(
                      child: noDataWidget(message: "No Content Data Found"),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    separatorBuilder:
                        (context, index) => verticalSpacing(height: 16),
                    itemCount: state.marketingContentDocumentList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.marketingContentDocumentList.length) {
                        return state.marketingContentDocumentList.length <
                                state.totalNumberOfRecord
                            ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox.shrink();
                      }

                      var files = state.marketingContentDocumentList[index];
                      return Container(
                        decoration: commonCardDecoration(),
                        child: Column(
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
                                      files.title,
                                      style: AppTextStyle.ts14M(),
                                    ),
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      CustomIconButton(
                                        isDisable:
                                            files.marketingContentURL.isEmpty,
                                        onPressed: () {
                                          showFilePreviewDialog(
                                            title:
                                                files
                                                    .marketingContentFolderName,
                                            context,
                                            files.marketingContentURL.split(
                                              ",",
                                            ),
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        icon: Icon(
                                          Icons.remove_red_eye_outlined,
                                          color:
                                              files.marketingContentURL.isEmpty
                                                  ? AppColor.grey2
                                                  : AppColor.primary,
                                          size: 18,
                                        ),
                                      ),
                                      CustomIconButton.edit(
                                        onPressed: () {
                                          _showPopUpToAddUpdateContentDocument(
                                            contentDocumentModel: files,
                                            index: index,
                                          );
                                        },
                                      ),
                                      CustomIconButton.delete(
                                        onPressed: () {
                                          _showPopupToDeleteDocument(
                                            context,
                                            files,
                                            state.currentPage,
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
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildRowTitleValue(
                                    title: "Remark",
                                    value:
                                        files.remark.trim().isEmpty
                                            ? "-"
                                            : files.remark.trim(),
                                    customValueWidget:
                                        files.remark.isNotEmpty
                                            ? GestureDetector(
                                              onTap: () {
                                                DialogHelper.showNoteDialog(
                                                  context,
                                                  title: "Remark",
                                                  note: files.remark,
                                                );
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: 10.w,
                                                ),
                                                child: Icon(
                                                  Icons.info_outline,
                                                  size: 18,
                                                  color: AppColor.primary,
                                                ),
                                              ),
                                            )
                                            : null,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified By",
                                    singleLine: false,
                                    value:
                                        files.modifiedBy.isEmpty
                                            ? files.createdBy
                                            : files.modifiedBy,
                                  ),
                                  buildRowTitleValue(
                                    title: "Last Modified Date",
                                    singleLine: false,
                                    value:
                                        files.modifiedDate == null
                                            ? formatDate(files.createdDate)
                                            : formatDate(files.modifiedDate),
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
    );
  }
}
