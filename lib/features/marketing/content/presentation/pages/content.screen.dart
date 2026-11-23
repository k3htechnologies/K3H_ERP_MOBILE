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
  late TextEditingController _searchC, _folderNameC;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initialiseTextController();
    _project = getProject();
    _marketingCubit = BlocProvider.of<ContentFolderCubit>(context);
    _marketingCubit.getMarketingFolderList(
      context,
      1,
      1000,
      _project.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _folderNameC.dispose();
  }

  void _initialiseTextController() {
    _searchC = TextEditingController();
    _folderNameC = TextEditingController();
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
      _marketingCubit.updateDrawingDocumentNameInCategory(
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
      'You are about to delete a content folder?',
      'Deleting this content folder will permanently remove its contents.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: 'Content',
        authorization: AuthorizationModel(isAction: true),
        searchHintText: "Search by Content Name",
        onSearchSubmit: (value) {
          _marketingCubit.searchContentFolder(
            context,
            value,
            _project.projectId,
          );
        },
        textController: _searchC,
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
          _marketingCubit.searchContentFolder(context, "", _project.projectId);
        },
        child: SafeArea(
          child: BlocBuilder<ContentFolderCubit, ContentFolderState>(
            buildWhen:
                (previous, current) =>
                    previous.marketingContentFolderList !=
                        current.marketingContentFolderList ||
                    previous.isLoading != current.isLoading,
            builder: (context, state) {
              if (state.isLoading == true) {
                return loader();
              }
              if (state.marketingContentFolderList.isEmpty) {
                return Center(
                  child: noDataWidget(message: "No Content Folder Found"),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shrinkWrap: true,
                itemCount:
                    _marketingCubit.state.marketingContentFolderList.length,
                itemBuilder: (_, index) {
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
                                      1000,
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
