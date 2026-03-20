import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/document/data/model/document.model.dart';
import 'package:k3h_erp_app/features/project_document/document/presentation/cubit/document_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with TickerProviderStateMixin {
  // CUBIT
  late DocumentCubit _documentCubit;

  // AUTHORIZATION MODEL
  late AuthorizationModel _routeAuthorizationModel;

  // TAB CONTROLLERS
  TabController? _categoryTabController;

  // PROJECT ID
  late int projectId;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC, _documentC;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.document]!;
    _documentCubit = context.read<DocumentCubit>();
    projectId = getProject().projectId;
    _documentCubit.getCategoryList(context, 1, projectId);
    _initControllers();
    _onScroll();
  }

  @override
  void dispose() {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
    _documentC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_documentCubit.state.isLoading! &&
          _documentCubit.state.documentList.length <
              _documentCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _documentCubit.getProjectDocumentList(
            context: context,
            pageNumber: _documentCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // CATEGORY TAB
  void _onBuildingTabChanged() {
    if (!_categoryTabController!.indexIsChanging && mounted) {
      _documentCubit.onTabChanged(_categoryTabController!.index, context);
    }
  }

  // CATEGORY CONTROLLER
  void _initCategoryController(DocumentState state) {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();

    _categoryTabController = TabController(
      length: state.documentCategoryModelList.length,
      vsync: this,
      initialIndex: state.categoryIndex,
    );

    _categoryTabController!.addListener(_onBuildingTabChanged);
  }

  // SUBMIT FORM
  void _submitForm({DocumentModel? documentModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (documentModel != null) {
      //Edit Name
      _documentCubit.updateDocumentNameInCategory(
        context: context,
        index: index!,
        uniqueKey: documentModel.uniquekey,
        projectDocumentId: documentModel.projectDocumentId,
        projectDocumentCategoryId: documentModel.projectDocumentCategoryId,
        projectDocumentName: _documentC.text.trim(),
      );
    } else {
      //Create New Parent Doc
      _documentCubit.addDocumentToCategory(
        context: context,
        projectDocumentName: _documentC.text.trim(),
      );
    }
  }

  void _prefillDocumentDetails(DocumentModel documentModel) {
    _documentC.text = documentModel.projectDocumentName;
  }

  // DELETE DOCUMENT FROM CATEGORY
  Future<void> _showPopupToDeleteDocument(
    BuildContext context,
    DocumentModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _documentCubit.deleteDocument(obj, context, index);
    }
  }

  // ADD/UPDATE DOCUMENT
  Future<void> _showPopUpToAddUpdateDocument({
    DocumentModel? documentModel,
    int? index,
  }) async {
    if (documentModel != null) {
      _prefillDocumentDetails(documentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      documentModel != null ? 'Update Document Name' : 'Add Document Name',
      Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),

          child: Column(
            children: [
              CustomTextField(
                title: "Document Name",
                hint: "Enter Document Name",
                textController: _documentC,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Document Name is required";
                  }
                  return null;
                },
              ),
              Spacer(),
              Container(
                height: 70,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CustomButton(
                  leading: Icon(
                    documentModel != null ? Icons.edit : Icons.add,
                    size: 16,
                    color: AppColor.white,
                  ),
                  text:
                      documentModel != null
                          ? "Update Document Name"
                          : "Add Document Name",
                  onPressed: () {
                    _submitForm(documentModel: documentModel, index: index);
                    _searchC.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _clearDialogueToAddUpdateDocument();
  }

  // CLEAR TEXT CONTROLLER
  void _clearDialogueToAddUpdateDocument() {
    _documentC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Project Document",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search by Document Name",
        onSearchSubmit: (value) {
          _documentCubit.searchDocument(value, context);
        },
        onProjectChangeCallback: (project) {
          projectId = project.projectId;
          if (context.mounted) {
            _documentCubit.getCategoryList(context, 1, projectId);
          }
        },
        onExportCallback: (value) {
          if (_documentCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _documentCubit.exportExcelPdf(context, value, projectId);
        },
        extraHeight: 20,
        secondaryBuilder:
            (_) => BlocBuilder<DocumentCubit, DocumentState>(
              builder: (context, state) {
                final list = state.documentCategoryModelList;

                if (list.isNotEmpty) {
                  return CustomButton(
                    text: "Add",
                    onPressed: () {
                      _showPopUpToAddUpdateDocument();
                    },
                    backgroundColor: AppColor.primary,
                    leading: Icon(Icons.add, size: 16, color: AppColor.white),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
      ),
      body: SafeArea(
        child: BlocListener<DocumentCubit, DocumentState>(
          listener: (context, state) {
            if (!mounted) return;
            if (!state.isLoading! &&
                state.documentCategoryModelList.isNotEmpty) {
              if (_categoryTabController == null ||
                  _categoryTabController!.length !=
                      state.documentCategoryModelList.length) {
                _initCategoryController(state);
              }
            }
          },
          child: BlocBuilder<DocumentCubit, DocumentState>(
            builder: (context, state) {
              if (state.isLoading! && state.documentCategoryModelList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.documentCategoryModelList.isEmpty) {
                return Center(
                  child: noDataWidget(
                    message: "No Project Document Data Found",
                  ),
                );
              }

              if (_categoryTabController == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // CATEGORY TAB
                  _buildCategoryTab(state),
                  verticalSpacing(),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _categoryTabController,
                      children:
                          state.documentCategoryModelList.map((category) {
                            return (state.documentList.isEmpty &&
                                    state.isLoading!)
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : RefreshIndicator(
                                  onRefresh: () async {
                                    _searchC.clear();
                                    _documentCubit.searchDocument("", context);
                                  },
                                  child: _buildDocumentListForCategory(state),
                                );
                          }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // CATEGORY TAB
  Widget _buildCategoryTab(DocumentState state) {
    if (_categoryTabController == null) {
      return const SizedBox.shrink();
    }

    if (_categoryTabController!.length !=
        state.documentCategoryModelList.length) {
      return const SizedBox.shrink();
    }

    return ChipStyleTabBar(
      controller: _categoryTabController!,
      tabs:
          state.documentCategoryModelList
              .map((e) => e.projectDocumentCategoryName)
              .toList(),
    );
  }

  // BUILD DOCUMENT LIST FOR CATEGORY
  Widget _buildDocumentListForCategory(DocumentState state) {
    if (state.documentList.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Project Document Data Found"),
      );
    }

    return BlocBuilder<DocumentCubit, DocumentState>(
      builder: (context, state) {
        return ListView.builder(
          controller: scrollController,
          itemCount: state.documentList.length + 1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemBuilder: (context, index) {
            // Pagination loader
            if (index == state.documentList.length) {
              return state.documentList.length < state.totalNumberOfRecord
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final document = state.documentList[index];

            return Container(
              padding: EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 10),

              decoration: commonCardDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () async {
                            await goRouter.pushNamed(
                              AppRoutes.viewDocument,
                              queryParameters: {
                                "document": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(document.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                            if (context.mounted) {
                              _documentCubit.getProjectDocumentList(
                                context: context,
                                pageNumber: 1,
                              );
                            }
                          },
                          child: Text(
                            document.projectDocumentName,
                            style: AppTextStyle.ts16M(
                              color: AppColor.primary,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                          ),
                        ),
                      ),
                      if (_routeAuthorizationModel.isAction) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton(
                              icon: Icon(
                                Icons.add,
                                size: 16,
                                color: AppColor.primary,
                              ),
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addDocument,
                                  queryParameters: {
                                    "document": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(document.toJson()),
                                      ),
                                    ),
                                    "index": index.toString(),

                                    "isEdit": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        false.toString(),
                                      ),
                                    ),
                                  },
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.edit(
                              onPressed: () async {
                                _showPopUpToAddUpdateDocument(
                                  documentModel: document,
                                  index: index,
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              isDisabled:
                                  document.uploadedProjectDocumentCount == 0
                                      ? false
                                      : true,
                              onPressed: () {
                                _showPopupToDeleteDocument(
                                  context,
                                  document,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Pending Approval",
                    value:
                        document.approvalPendingProjectDocumentCount.toString(),
                  ),
                  buildRowTitleValue(
                    title: "Document Count",
                    value: document.uploadedProjectDocumentCount.toString(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
