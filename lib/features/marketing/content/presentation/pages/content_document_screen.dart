import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/marketing/content/data/model/content_document.model.dart';
import 'package:k3h_erp_app/features/marketing/content/presentation/cubit/content_document/content_document_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_floating_action_button.dart';
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

  void _initializeTextControllers() {
    _marketingTitleC = TextEditingController();
    _marketingRemarkC = TextEditingController();
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_contentDocumentCubit.state.isLoading! &&
          _contentDocumentCubit.state.marketingContentDocumentList.length <
              _contentDocumentCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
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
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      'Content Document',
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Form(
              key: _contentDocumentAddUpdateKey,
              child: Column(
                children: [
                  CustomTextField(
                    textController: _marketingTitleC,
                    title: 'Title',
                    isRequired: true,
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
                    isRequired: true,
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

            Spacer(),
            CustomButton.save(
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
                      marketingContentId:
                          contentDocumentModel.marketingContentId,
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
          ],
        ),
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
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<ContentDocumentCubit, ContentDocumentState>(
        builder: (context, state) {
          return Column(
            children: [
              verticalSpacing(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SearchWidget(
                  isFilterOn: false,
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
              ((state.isLoading ?? true) &&
                      state.marketingContentDocumentList.isEmpty)
                  ? Expanded(child: Center(child: loader()))
                  : state.marketingContentDocumentList.isEmpty
                  ? Expanded(child: Center(child: noDataWidget()))
                  : Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount:
                          _contentDocumentCubit
                              .state
                              .marketingContentDocumentList
                              .length +
                          1,
                      itemBuilder: (context, index) {
                        if (index ==
                            state.marketingContentDocumentList.length) {
                          return state.marketingContentDocumentList.length <
                                  state.totalNumberOfRecord
                              ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        var files = state.marketingContentDocumentList[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            border: Border.all(
                              color: AppColor.grey.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 16,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Title :",
                                      style: AppTextStyle.ts12R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    Text(
                                      files.title,
                                      style: AppTextStyle.ts14R(),
                                    ),
                                    verticalSpacing(),
                                    Text(
                                      "Remark :",
                                      style: AppTextStyle.ts12R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    Text(
                                      files.remark,
                                      style: AppTextStyle.ts14R(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    verticalSpacing(),
                                    Text(
                                      "Modified By/Date :",
                                      style: AppTextStyle.ts12R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                    Text(
                                      "${files.modifiedBy.isNotEmpty ? files.modifiedBy : "-"} / ${files.modifiedDate != null ? formatDateTimeAsDDMMMYYYY(files.modifiedDate!) : '-'}",
                                      style: AppTextStyle.ts14R(),
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpacing(),
                              Container(
                                clipBehavior: Clip.hardEdge,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.grey.withValues(alpha: 0.05),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColor.grey.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _showPopUpToAddUpdateContentDocument(
                                          contentDocumentModel: files,
                                          index: index,
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.editIcon,
                                        height: 24,
                                      ),
                                    ),
                                    horizontalSpacing(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        _showPopupToDeleteDocument(
                                          context,
                                          files,
                                          state.currentPage,
                                          index,
                                        );
                                      },
                                      child: SvgPicture.asset(
                                        AppAssets.deleteIcon,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () async {
          await _showPopUpToAddUpdateContentDocument();
        },
      ),
    );
  }
}
