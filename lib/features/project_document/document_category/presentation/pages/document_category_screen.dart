import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document_category/data/model/document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/document_category/presentation/cubit/document_category_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
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
  late ProjectModel _project;

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
    _project = getProject();
    _documentCategoryCubit.getDocumentCategoryList(
      context,
      1,
      _project.projectId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
  }

  // INITIALIZE TEXT EDITING CONTROLLER
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !_documentCategoryCubit.state.isLoading! &&
          _documentCategoryCubit.state.documentCategoryList.length <
              _documentCategoryCubit.state.totalNumberOfRecord) {
        if (_project.projectId != 0) {
          _documentCategoryCubit.getDocumentCategoryList(
            context,
            _documentCategoryCubit.state.currentPage + 1,

            _project.projectId,
          );
        }
      }
    });
  }

  // DELETE DOCUMENT CATEGORY
  Future<void> _showPopupToDeleteDocumentCategory(
    BuildContext context,
    DocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a project document category ?',
      'Deleting this project document category will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _documentCategoryCubit.deleteDocumentCategory(
        _project.projectId,
        obj,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Project Document Category",
        authorization: _routeAuthorizationModel,
        onSearchSubmit: (value) {
          if (_project.projectId != 0) {
            _documentCategoryCubit.searchCategory(
              context,
              _project.projectId,
              value,
            );
          }
        },
        textController: _searchC,
        searchHintText: "Search by Project Document Category",
        onAddCallback: () {
          if (_project.projectId == 0) {
            showErrorMessage(context, 'Error', 'Please select a project');
            return;
          }
          goRouter.pushNamed(AppRoutes.addDocumentCategory);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          if (context.mounted) {
            _documentCategoryCubit.getDocumentCategoryList(
              context,
              1,
              value.projectId,
            );
          }
        },
        onExportCallback: (value) {
          if (_documentCategoryCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No data found");
            return;
          }
          _documentCategoryCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
      ),
      body: BlocBuilder<DocumentCategoryCubit, DocumentCategoryState>(
        bloc: _documentCategoryCubit,
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.documentCategoryList.isEmpty) {
            return Center(child: loader());
          }
          if (state.documentCategoryList.isEmpty) {
            return Center(
              child: noDataWidget(
                message: "No Project Document Category Data Found",
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              _searchC.clear();
              _documentCategoryCubit.searchCategory(
                context,
                _project.projectId,
                "",
              );
            },
            child: ListView.builder(
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
                                    "documentCategory":
                                        Uri.encodeQueryComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(category.toJson()),
                                          ),
                                        ),
                                  },
                                );
                              },
                              child: Text(
                                category.projectDocumentCategoryName,
                                style: AppTextStyle.ts16M(
                                  color: AppColor.primary,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                          _routeAuthorizationModel.isAction
                              ? Row(
                                children: [
                                  CustomIconButton.edit(
                                    onPressed: () async {
                                      if (_project.projectId == 0) {
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
                                  horizontalSpacing(),
                                  CustomIconButton.delete(
                                    isDisabled:
                                        category.documentCount == 0
                                            ? false
                                            : true,
                                    onPressed: () {
                                      _showPopupToDeleteDocumentCategory(
                                        context,
                                        category,
                                        state.currentPage,
                                        index,
                                      );
                                    },
                                  ),
                                ],
                              )
                              : SizedBox.shrink(),
                        ],
                      ),
                      verticalSpacing(height: 8),
                      buildRowTitleValue(
                        title: "Sequence",
                        value: category.orderBy.toString(),
                      ),
                      buildRowTitleValue(
                        title: "Document Count",
                        value: category.documentCount.toString(),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
