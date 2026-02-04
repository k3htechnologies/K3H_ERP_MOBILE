import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
                hint: "Enter content name",
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
              CustomButton(
                leading: Icon(Icons.add, size: 18, color: AppColor.white),
                text: "Add",
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
        onAddCallback: () {
          _showDialogToAddUpdateContentFolder(context, _marketingCubit.state);
        },
      ),
      body: SafeArea(
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
              return Center(child: noDataWidget());
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
                                  },
                                );

                                // If document was added/deleted, refresh the folder list
                                if ( context.mounted) {
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
                                style: AppTextStyle.ts14M().copyWith(
                                  color: AppColor.primary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          CustomIconButton.delete(
                            onPressed: () {
                              _showPopupToDeleteContentFolder(
                                context,
                                state.marketingContentFolderList[index],
                              );
                            },
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
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                              Text(
                                folder.numberOfMarketingContent.toString(),
                                style: AppTextStyle.ts14M(),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primary.withValues(alpha: .2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                SvgPicture.asset(
                                  AppAssets.downloadIcon,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    AppColor.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                Text(
                                  "Download",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.primary,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
