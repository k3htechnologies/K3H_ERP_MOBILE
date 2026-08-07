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
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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

  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  // PROJECT
  late ProjectModel _project;

  @override
  void initState() {
    super.initState();
    _approvedBankCubit = BlocProvider.of<ApprovedBankFolderCubit>(context);
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.approvedBank]!;
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
      'You are about to delete a Bank?',
      'Deleting this bank will permanently remove its contents.',
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
        searchHintText: "Search by Bank Name",
        onSearchSubmit: (value) {
          _approvedBankCubit.searchFolder(context, value, _project.projectId);
        },
        textController: _searchC,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addBankScreen);
          if (context.mounted) {
            _approvedBankCubit.getApprovedBankFolderList(
              context,
              1,
              1000,
              _project.projectId,
            );
          }
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _approvedBankCubit.searchFolder(context, "", value.projectId);
        },
      ),
      body: SafeArea(
        child: BlocBuilder<ApprovedBankFolderCubit, ApprovedBankFolderState>(
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
              return Center(
                child: noDataWidget(message: "No Approved Bank Found"),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shrinkWrap: true,
              itemCount: _approvedBankCubit.state.approvedBankFolderList.length,
              itemBuilder: (_, index) {
                var folder =
                    _approvedBankCubit.state.approvedBankFolderList[index];
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
                                final result = await goRouter.pushNamed(
                                  AppRoutes.approvedBankFile,
                                  queryParameters: {
                                    "approvedBankFolderId":
                                        Uri.encodeQueryComponent(
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
                                if (result == true && context.mounted) {
                                  _approvedBankCubit.getApprovedBankFolderList(
                                    context,
                                    1,
                                    1000,
                                    _project.projectId,
                                  );
                                }
                              },
                              child: Text(
                                folder.bankName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          if (_routeAuthorizationModel.isAction)
                            CustomIconButton.delete(
                              isDisabled:
                                  state
                                      .approvedBankFolderList[index]
                                      .numberOfApprovedBankFile >
                                  0,
                              onPressed: () {
                                _showPopupToDeleteApprovedBankFile(
                                  context,
                                  state.approvedBankFolderList[index],
                                  1,
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
                                folder.numberOfApprovedBankFile.toString(),
                                style: AppTextStyle.ts14M(),
                              ),
                            ],
                          ),
                          if (_routeAuthorizationModel.isExport)
                            CustomIconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.file_download_outlined,
                                size: 16,
                                color: AppColor.primary,
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
