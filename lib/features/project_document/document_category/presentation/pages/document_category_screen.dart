import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/project_master/data/repository/project_master.repository.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/cubit/document_category_cubit.dart';
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

class DocumentCategoryScreen extends StatefulWidget {
  const DocumentCategoryScreen({super.key});

  @override
  State<DocumentCategoryScreen> createState() => _DocumentCategoryScreenState();
}

class _DocumentCategoryScreenState extends State<DocumentCategoryScreen> {
  //CUBIT
  late DocumentCategoryCubit _documentCategoryCubit;
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
    _documentCategoryCubit = context.read<DocumentCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.category]!;

    _initializeTextEditingController();
    _onScroll();
    //SET PROJECT ID
    projectId = getProject().projectId;
    _documentCategoryCubit.getDocumentCategoryList(context, 1, projectId);
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_documentCategoryCubit.state.isLoading! &&
          _documentCategoryCubit.state.documentCategoryList.length <
              _documentCategoryCubit.state.totalNumberOfRecord) {
        if (projectId != 0) {
          _documentCategoryCubit.getDocumentCategoryList(
            context,
            _documentCategoryCubit.state.currentPage + 1,

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

  // DELETE BUILDING
  Future<void> _showPopupToDeleteBuilding(
    BuildContext context,
    DocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document category?',
      'Deleting this document category will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _documentCategoryCubit.deleteDocumentCategory(projectId, obj, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Category",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          if (projectId != 0) {
            _documentCategoryCubit.searchCategory(context, projectId, value);
          }
        },
        textController: _searchC,
        onAddCallback: () {
          if (projectId == 0) {
            showErrorMessage(context, 'Error', 'Please select a project');
            return;
          }
          goRouter.pushNamed(AppRoutes.addDocumentCategory);
        },
      ),
      body: BlocBuilder<DocumentCategoryCubit, DocumentCategoryState>(
        bloc: _documentCategoryCubit,
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.documentCategoryList.isEmpty) {
            return Center(child: loader());
          }
          if (state.documentCategoryList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.documentCategoryList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.documentCategoryList.length) {
                return state.documentCategoryList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var category = state.documentCategoryList[index];
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
                                AppRoutes.viewDocumentCategory,
                                queryParameters: {
                                  "documentCategory": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(category.toJson()),
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
                                category.projectDocumentCategoryName,
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
                                  AppRoutes.addDocumentCategory,
                                  queryParameters: {
                                    "documentCategory":
                                        Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(category.toJson()),
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
                                _showPopupToDeleteBuilding(
                                  context,
                                  category,
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
                      value: category.orderBy.toString(),
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
