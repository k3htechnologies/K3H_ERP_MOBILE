import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/data/model/test_document_category.model.dart';
import 'package:k3h_erp_app/features/project_document/test_document_category/presentation/cubit/test_document_category_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TestDocumentCategoryScreen extends StatefulWidget {
  const TestDocumentCategoryScreen({super.key});

  @override
  State<TestDocumentCategoryScreen> createState() =>
      _TestDocumentCategoryScreenState();
}

class _TestDocumentCategoryScreenState
    extends State<TestDocumentCategoryScreen> {
  //CUBIT
  late TestDocumentCategoryCubit _testDocumentCategoryCubit;

  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  //PROJECT
  late ProjectModel _project;

  // SCROLL CONTROLLER
  final ScrollController scrollController = ScrollController();

  // TEXT EDITING CONTROLLER
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _testDocumentCategoryCubit = context.read<TestDocumentCategoryCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.testDocumentCategory]!;
    _onScroll();
    _initializeTextEditingController();
    //SET PROJECT ID
    _project = getProject();
    _testDocumentCategoryCubit.getTestDocumentCategoryList(
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
          !_testDocumentCategoryCubit.state.isLoading! &&
          _testDocumentCategoryCubit
                  .state
                  .testDocumentCategoryModelList
                  .length <
              _testDocumentCategoryCubit.state.totalNumberOfRecord) {
        if (_project.projectId != 0) {
          _testDocumentCategoryCubit.getTestDocumentCategoryList(
            context,
            _testDocumentCategoryCubit.state.currentPage + 1,

            _project.projectId,
          );
        }
      }
    });
  }

  // DELETE DOCUMENT CATEGORY
  Future<void> _showPopupToDeleteTestDocumentCategory(
    BuildContext context,
    TestDocumentCategoryModel obj,
    int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a test document category ?',
      'Deleting this test document category will permanently remove all associated data.',
    );

    if (shouldDelete && context.mounted) {
      _testDocumentCategoryCubit.deleteTestDocumentCategory(
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
        screenTitle: "Test Document Category",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search By Test Document Category",
        onSearchSubmit: (value) {
          if (_project.projectId != 0) {
            _testDocumentCategoryCubit.searchCategory(
              context,
              _project.projectId,
              value,
            );
          }
        },
        textController: _searchC,
        onAddCallback: () async {
          if (_project.projectId == 0) {
            showErrorMessage(context, 'Error', 'Please select a project');
            return;
          }
          _searchC.clear();
          await _testDocumentCategoryCubit.resetSearch();
          goRouter.pushNamed(AppRoutes.addTestDocumentCategory).then((_) {
            if (context.mounted) {
              _testDocumentCategoryCubit.getTestDocumentCategoryList(
                context,
                1,
                _project.projectId,
              );
            }
          });
        },
        onExportCallback: (value) {
          if (_testDocumentCategoryCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _testDocumentCategoryCubit.exportExcelPdf(
            context,
            value,
            _project.projectId,
          );
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _testDocumentCategoryCubit.getTestDocumentCategoryList(
            context,
            1,
            _project.projectId,
          );
        },
      ),
      body: BlocBuilder<TestDocumentCategoryCubit, TestDocumentCategoryState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) &&
              state.testDocumentCategoryModelList.isEmpty) {
            return Center(child: loader());
          }
          if (state.testDocumentCategoryModelList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: noDataWidget(
                  message: "No Test Document Category Data Found",
                ),
              ),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.testDocumentCategoryModelList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.testDocumentCategoryModelList.length) {
                return state.testDocumentCategoryModelList.length <
                        state.totalNumberOfRecord
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var testDocumentCategory =
                  state.testDocumentCategoryModelList[index];
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
                                AppRoutes.viewTestDocumentCategory,
                                queryParameters: {
                                  "testDocumentCategory":
                                      Uri.encodeQueryComponent(
                                        EncryptionManager.encryptData(
                                          jsonEncode(
                                            testDocumentCategory.toJson(),
                                          ),
                                        ),
                                      ),
                                },
                              );
                            },
                            child: Text(
                              testDocumentCategory.testDocumentCategoryName,
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        if (_routeAuthorizationModel.isAction)
                          Row(
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
                                    AppRoutes.addTestDocumentCategory,
                                    queryParameters: {
                                      "testDocumentCategory":
                                          Uri.encodeQueryComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(
                                                testDocumentCategory.toJson(),
                                              ),
                                            ),
                                          ),
                                      'index': index.toString(),
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              CustomIconButton.delete(
                                isDisabled:
                                    testDocumentCategory.documentCount == 0
                                        ? false
                                        : true,
                                onPressed: () {
                                  _showPopupToDeleteTestDocumentCategory(
                                    context,
                                    testDocumentCategory,
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
                    buildRowTitleValue(
                      title: "Sequencce",
                      value: testDocumentCategory.orderBy.toString(),
                    ),
                    buildRowTitleValue(
                      title: "Document Count",
                      value: testDocumentCategory.documentCount.toString(),
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
}
