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
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  late DocumentCubit _documentCubit;
  // TAB CONTROLLERS
  TabController? _categoryTabController;

  late int projectId;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

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

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC, _documentC;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
    _documentC = TextEditingController();
  }

  @override
  void dispose() {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();
    scrollController.dispose();
    super.dispose();
  }

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
          padding: EdgeInsets.all(16),

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
                padding: EdgeInsets.all(16),
                child: CustomButton(
                  text:
                      documentModel != null
                          ? "Update Document"
                          : "Add Document",
                  onPressed: () {
                    _submitForm(documentModel: documentModel, index: index);
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

  void _clearDialogueToAddUpdateDocument() {
    _documentC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Document",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _documentCubit.searchDocument(value, context);
        },
        onProjectChangeCallback: (project) {
          projectId = project.projectId;
          if (context.mounted) {
            _documentCubit.getCategoryList(context, 1, projectId);
          }
        },
        extraHeight: 20,
        secondaryBuilder:
            (_) => CustomButton(
              text: "Add",
              onPressed: () {
                _showPopUpToAddUpdateDocument();
              },
              backgroundColor: AppColor.primary,
              leading: Icon(Icons.add, size: 16, color: AppColor.white),
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
              // 1. Initial loading
              if (state.isLoading! && state.documentCategoryModelList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Loaded but no categories
              if (state.documentCategoryModelList.isEmpty) {
                return noDataWidget();
              }

              // 3. Categories exist but controller not ready yet
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
                                : _buildDocumentListForCategory(state);
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

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          height: 35,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColor.grey.withValues(alpha: 0.2)),
          ),
          child: TabBar(
            controller: _categoryTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColor.primary,
            unselectedLabelColor: AppColor.grey,
            indicator: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyle.ts14M(),
            unselectedLabelStyle: AppTextStyle.ts14M(),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs:
                state.documentCategoryModelList
                    .map((b) => Tab(text: b.projectDocumentCategoryName))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentListForCategory(DocumentState state) {
    if (state.documentList.isEmpty) {
      return noDataWidget();
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
                              document.projectDocumentName,
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomIconButton(
                            icon: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColor.primary,
                            ),
                            onPressed: () async {
                              goRouter.pushNamed(
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
                          const SizedBox(width: 8),
                          CustomIconButton.edit(
                            onPressed: () async {
                              _showPopUpToAddUpdateDocument(
                                documentModel: document,
                                index: index,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          CustomIconButton.delete(
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
                  ),
                  verticalSpacing(height: 10),
                  buildRowTitleValue(
                    title: "Pending Approvals",
                    value:
                        document.approvalPendingProjectDocumentCount.toString(),
                  ),
                  buildRowTitleValue(
                    title: "Documents",
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
