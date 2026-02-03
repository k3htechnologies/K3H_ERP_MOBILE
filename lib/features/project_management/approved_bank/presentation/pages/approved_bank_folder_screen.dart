import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_folder.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_folder/approved_bank_folder_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApprovedBankFolderScreen extends StatefulWidget {
  const ApprovedBankFolderScreen({super.key});

  @override
  State<ApprovedBankFolderScreen> createState() =>
      _ApprovedBankFolderScreenState();
}

class _ApprovedBankFolderScreenState extends State<ApprovedBankFolderScreen> {
  // CUBIT
  late ApprovedBankFolderCubit _approvedBankCubit;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _approvedBankCubit = BlocProvider.of<ApprovedBankFolderCubit>(context);
    _project = getProject();
    _searchC = TextEditingController();
    _approvedBankCubit.getApprovedBankFolderList(
      context,
      1,
      1000,
      _project.projectId,
    );
  }

  // DIALOGUE TO DELETE APPROVED BANK FILE
  Future<void> _showPopupToDeleteApprovedBankFile(
    BuildContext context,
    ApprovedBankFolderModel obj,
    int currentPage,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a Folder?',
      'Deleting this folder will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _approvedBankCubit.deleteApprovedBankFolder(
        context: context,
        approvedBankFolderId: obj.approvedBankFolderId,
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
        screenTitle: 'Approved Bank',
        authorization: AuthorizationModel(isAction: true),
        onSearchSubmit: (value) {
          _approvedBankCubit.searchFolder(context, value, _project.projectId);
        },
        textController: _searchC,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addBankScreen);
        },
      ),
      body: BlocBuilder<ApprovedBankFolderCubit, ApprovedBankFolderState>(
        buildWhen:
            (previous, current) =>
                previous.approvedBankFolderList !=
                    current.approvedBankFolderList ||
                previous.isLoading != current.isLoading,
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          if (state.approvedBankFolderList.isEmpty) {
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
                itemCount: state.approvedBankFolderList.length,
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap: () async {
                        final result = await goRouter.pushNamed(
                          AppRoutes.approvedBankFile,
                          queryParameters: {
                            "approvedBankFolderId": Uri.encodeQueryComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(
                                  state
                                      .approvedBankFolderList[index]
                                      .approvedBankFolderId,
                                ),
                              ),
                            ),
                          },
                        );

                        // If files were added/deleted, refresh the folder list
                        if (result == true && context.mounted) {
                          _approvedBankCubit.getApprovedBankFolderList(
                            context,
                            1,
                            1000,
                            _project.projectId,
                          );
                        }
                      },
                      onLongPress: () {
                        _showPopupToDeleteApprovedBankFile(
                          context,
                          state.approvedBankFolderList[index],
                          1,
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
                                  state.approvedBankFolderList[index].bankName,
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
                                    .approvedBankFolderList[index]
                                    .numberOfApprovedBankFile
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
    );
  }
}
