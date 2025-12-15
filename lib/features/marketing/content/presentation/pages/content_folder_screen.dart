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
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ContentFolderScreen extends StatefulWidget {
  const ContentFolderScreen({super.key});

  @override
  State<ContentFolderScreen> createState() => _ContentFolderScreenState();
}

class _ContentFolderScreenState extends State<ContentFolderScreen> {
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

  // DIALOGUE TO ADD/UPDATE CONTENT FOLDER
  Future<void> _showDialogToAddUpdateContentFolder(
    BuildContext context,
    ContentFolderState state,
  ) async {
    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Content",
      Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomTextField(
                title: 'Content Name',
                isRequired: true,
                textController: _folderNameC,
                inputFormatterList: [LengthLimitingTextInputFormatter(100)],
                validator: (string) {
                  if (string == null || string.trim().isEmpty) {
                    return 'Content name is required';
                  }
                  return null;
                },
              ),
              Spacer(),
              CustomButton.save(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _marketingCubit.addContentFolder(
                      context: context,
                      projectId: _project.projectId,
                      marketingContentFolderName: _folderNameC.text,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    _clearDialogueToAddUpdateContentFolder();
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
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBar(
        screenTitle: 'Marketing - Content',
        authorization: AuthorizationModel(isAction: true),
        onSearchSubmit: (value) {
          _marketingCubit.searchContentFolder(
            context,
            value,
            _project.projectId,
          );
        },
        textController: _searchC,
      ),
      body: BlocBuilder<ContentFolderCubit, ContentFolderState>(
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
            return noDataWidget();
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              const double cardWidth = 140.0;
              const double spacing = 16.0;

              final columns =
                  (constraints.maxWidth / (cardWidth + spacing)).floor();

              return GridView.builder(
                shrinkWrap: true,
                primary: false,
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 140 / 80,
                ),
                itemCount: state.marketingContentFolderList.length,
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap: () async {
                        final result = await goRouter.pushNamed(
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
                          },
                        );

                        // If document was added/deleted, refresh the folder list
                        if (result == true && context.mounted) {
                          _marketingCubit.getMarketingFolderList(
                            context,
                            1,
                            1000,
                            _project.projectId,
                          );
                        }
                      },
                      onLongPress: () {
                        _showPopupToDeleteContentFolder(
                          context,
                          state.marketingContentFolderList[index],
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColor.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Image.asset(AppAssets.folderImage, height: 60),
                                Text(
                                  state
                                      .marketingContentFolderList[index]
                                      .marketingContentFolderName,
                                  maxLines: 1,
                                  style: AppTextStyle.ts14R().copyWith(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 8,
                              ),
                              child: Text(
                                state
                                    .marketingContentFolderList[index]
                                    .numberOfMarketingContent
                                    .toString(),
                                style: AppTextStyle.ts12R(
                                  color: AppColor.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 40, bottom: 40),
        child: FloatingActionButton(
          onPressed: () async {
            _showDialogToAddUpdateContentFolder(context, _marketingCubit.state);
          },
          backgroundColor: AppColor.green,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: AppColor.white),
        ),
      ),
    );
  }
}
