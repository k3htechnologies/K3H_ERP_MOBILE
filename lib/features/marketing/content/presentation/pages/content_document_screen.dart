import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ContentDocumentScreen extends StatefulWidget {
  final int marketingContentFolderId;
  const ContentDocumentScreen({
    super.key,
    required this.marketingContentFolderId,
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
                  return "Title is required";
                }
                return null;
              },
            ),
            CustomTextField(
              textController: _marketingRemarkC,
              title: 'Remark',
              minLines: 2,
              maxLines: 2,
              isRequired: true,
              hint: "Enter remark",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Remark is required";
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
                  return "Attachment is required";
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
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Content Document',
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () async {
          await _showPopUpToAddUpdateContentDocument();
        },
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchWidget(
              isFilterOn: false,
              hintText: "Search by Title",
              onSubmit: (value) {
                _contentDocumentCubit.searchContentDocument(
                  context,
                  value,
                  _project.projectId,
                  widget.marketingContentFolderId,
                );
              },
              textController: _searchC,
            ),
          ),
          Expanded(
            child: BlocBuilder<ContentDocumentCubit, ContentDocumentState>(
              builder: (context, state) {
                final loading = state.isLoading ?? true;
                final list = state.marketingContentDocumentList;
                final empty = list.isEmpty;
                // Always use one ListView to avoid parentDataDirty when swapping Center vs ListView inside Expanded
                final itemCount =
                    (loading && empty) || empty ? 1 : list.length + 1;
                final hasListData = itemCount > 1;
                return ListView.builder(
                  controller: hasListData ? scrollController : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final viewportHeight = MediaQuery.sizeOf(context).height;
                    final boundedHeight =
                        viewportHeight > 200 ? viewportHeight - 200 : 300.0;
                    if (loading && empty) {
                      return SizedBox(
                        height: boundedHeight,
                        child: Center(child: loader()),
                      );
                    }
                    if (empty) {
                      return SizedBox(
                        height: boundedHeight,
                        child: Center(
                          child: noDataWidget(message: "No Content Data Found"),
                        ),
                      );
                    }
                    if (index == list.length) {
                      return list.length < state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var files = list[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 16,
                              left: 16,
                              right: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        files.title,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    CustomIconButton(
                                      onPressed: () {
                                        if (files.marketingContentURL.isEmpty) {
                                          showErrorMessage(
                                            context,
                                            "Image Error",
                                            "No Image Found",
                                          );
                                        }
                                        showFilePreviewDialog(
                                          context,
                                          title: files.title,
                                          files.marketingContentURL.split(","),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                      backgroundColor: AppColor.lightBlue,
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildRowTitleValue(
                                        title: "Remark",
                                        value:
                                            files.remark.isEmpty
                                                ? ""
                                                : files.remark,
                                      ),
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          buildRowTitleValue(
                                            title: "Modified By",
                                            value:
                                                files.modifiedBy.isEmpty
                                                    ? files.createdBy
                                                    : files.modifiedBy,
                                          ),
                                          buildRowTitleValue(
                                            title: "Modified Date",
                                            value:
                                                files.modifiedDate == null
                                                    ? formatDate(
                                                      files.createdDate,
                                                    )
                                                    : formatDate(
                                                      files.modifiedDate!,
                                                    ),
                                            singleLine: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 10,
                                      children: [
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
    );
  }
}
