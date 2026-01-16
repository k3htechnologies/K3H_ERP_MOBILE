import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/data/model/rera_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document_category/presentation/cubit/rera_document_category_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class RERADocumentCategoryScreen extends StatefulWidget {
  const RERADocumentCategoryScreen({super.key});

  @override
  State<RERADocumentCategoryScreen> createState() =>
      _RERADocumentCategoryScreenState();
}

class _RERADocumentCategoryScreenState
    extends State<RERADocumentCategoryScreen> {
  //CUBIT
  late RERADocumentCategoryCubit _reraDocumentCategoryCubit;
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //PROJECT ID
  late int projectId;

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _reraDocumentCategoryCubit = context.read<RERADocumentCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.reraCategory]!;

    _initializeTextEditingController();
    _onScroll();
    //SET PROJECT ID
    projectId = getProject().projectId;
    _reraDocumentCategoryCubit.getRERADocumentCategoryList(
      context,
      1,
      projectId,
    );
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_reraDocumentCategoryCubit.state.isLoading! &&
          _reraDocumentCategoryCubit.state.reraDocumentCategoryList.length <
              _reraDocumentCategoryCubit.state.totalNumberOfRecord) {
        if (projectId != 0) {
          _reraDocumentCategoryCubit.getRERADocumentCategoryList(
            context,
            _reraDocumentCategoryCubit.state.currentPage + 1,

            projectId,
          );
        }
      }
    });
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // DELETE DOCUMENT CATEGORY
  Future<void> _showPopupToDeleteDocumentCategory(
    BuildContext context,
    RERADocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a RERA document category?',
      'Deleting this RERA document category will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _reraDocumentCategoryCubit.deleteRERADocumentCategory(
        projectId,
        obj,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "RERA Category",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          if (projectId != 0) {
            _reraDocumentCategoryCubit.searchCategory(
              context,
              projectId,
              value,
            );
          }
        },
        textController: _searchC,
        onAddCallback: () {
          if (projectId == 0) {
            showErrorMessage(context, 'Error', 'Please select a project');
            return;
          }
          goRouter.pushNamed(AppRoutes.addReraDocumentCategory);
        },
      ),
      body: BlocBuilder<RERADocumentCategoryCubit, RERADocumentCategoryState>(
        bloc: _reraDocumentCategoryCubit,
        builder: (context, state) {
          if ((state.isLoading ?? true) &&
              state.reraDocumentCategoryList.isEmpty) {
            return Center(child: loader());
          }
          if (state.reraDocumentCategoryList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.reraDocumentCategoryList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.reraDocumentCategoryList.length) {
                return state.reraDocumentCategoryList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var reraCategory = state.reraDocumentCategoryList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewReraDocumentCategory,
                                queryParameters: {
                                  "reraDocumentCategory":
                                      Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(reraCategory.toJson()),
                                        ),
                                      ),
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColor.primary),
                                ),
                              ),
                              child: Text(
                                reraCategory.projectRERADocumentCategoryName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                if (projectId == 0) {
                                  showErrorMessage(
                                    context,
                                    'Error',
                                    'Please select a project',
                                  );
                                  return;
                                }
                                await goRouter.pushNamed(
                                  AppRoutes.addReraDocumentCategory,
                                  queryParameters: {
                                    "reraDocumentCategory":
                                        Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(reraCategory.toJson()),
                                          ),
                                        ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteDocumentCategory(
                                  context,
                                  reraCategory,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 8),
                    _buildRowTitleValue(
                      title: "Sequencce",
                      value: reraCategory.orderBy.toString(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // BUILD ROW TITLE VALUE
  Widget _buildRowTitleValue({required String title, required String value}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          SizedBox(
            width: 120,
            child: Text(title, style: AppTextStyle.ts14R(color: AppColor.grey)),
          ),

          // COLON
          SizedBox(
            width: 20,
            child: Text(
              ":",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.grey),
            ),
          ),

          // VALUE
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
