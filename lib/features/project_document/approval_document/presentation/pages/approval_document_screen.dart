import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/data/model/approval_document.model.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/approval_document/presentation/cubit/approval_document_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApprovalDocumentScreen extends StatefulWidget {
  const ApprovalDocumentScreen({super.key});

  @override
  State<ApprovalDocumentScreen> createState() => _ApprovalDocumentScreenState();
}

class _ApprovalDocumentScreenState extends State<ApprovalDocumentScreen>
    with TickerProviderStateMixin {
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;

  late ApprovalDocumentCubit _documentCubit;
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
        Authorization.routeAuthorizationMap[AppRoutes.approvalDocument]!;
    _documentCubit = context.read<ApprovalDocumentCubit>();
    projectId = getProject().projectId;
    _documentCubit.getCategoryList(context, 1, projectId);
    _initControllers();
    _onScroll();
  }

  // PAGINATION
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
          _documentCubit.getProjectApprovalDocumentList(
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
  void _initCategoryController(ApprovalDocumentState state) {
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

  void _submitForm({ApprovalDocumentModel? documentModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (documentModel != null) {
      //Edit Name
      _documentCubit.updateApprovalDocumentNameInCategory(
        context: context,
        index: index!,
        uniqueKey: documentModel.uniquekey,
        approvalDocumentId: documentModel.approvalDocumentId,
        approvalDocumentCategoryId: documentModel.approvalDocumentCategoryId,
        approvalDocumentName: _documentC.text.trim(),
      );
    } else {
      //Create New Parent Doc
      _documentCubit.addApprovalDocumentToCategory(
        context: context,
        approvalDocumentName: _documentC.text.trim(),
      );
    }
  }

  void _prefillApprovalDocumentDetails(ApprovalDocumentModel documentModel) {
    _documentC.text = documentModel.approvalDocumentName;
  }

  // DELETE DOCUMENT FROM CATEGORY
  Future<void> _showPopupToDeleteApprovalDocument(
    BuildContext context,
    ApprovalDocumentModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document?',
      'Deleting this document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _documentCubit.deleteApprovalDocument(obj, context, index);
    }
  }

  Future<void> _showPopUpToAddUpdateApprovalDocument({
    ApprovalDocumentModel? documentModel,
    int? index,
    BuildContext? context,
  }) async {
    if (documentModel != null) {
      _prefillApprovalDocumentDetails(documentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context!,
      documentModel != null ? 'Update Document Name' : 'Add Document Name',
      contentWidget: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              title: "Document Name",
              hint: "Enter Document Name",
              isRequired: true,
              textController: _documentC,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Document Name is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
      bottomActions: CustomButton(
        text: documentModel != null ? "Update Document" : "Add Document",
        onPressed: () {
          _submitForm(documentModel: documentModel, index: index);
          _searchC.clear();
        },
      ),
    );
    _clearDialogueToAddUpdateApprovalDocument();
  }

  void _clearDialogueToAddUpdateApprovalDocument() {
    _documentC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Approval Document",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search By Document Name",
        onSearchSubmit: (value) {
          _documentCubit.searchApprovalDocument(value, context);
        },
        onProjectChangeCallback: (project) {
          projectId = project.projectId;
          if (context.mounted) {
            _documentCubit.getCategoryList(context, 1, projectId);
          }
        },
        extraHeight: 20,
        secondaryBuilder:
            (_) => BlocBuilder<ApprovalDocumentCubit, ApprovalDocumentState>(
              builder: (context, state) {
                final list = state.documentCategoryModelList;

                if (list.isNotEmpty) {
                  return CustomButton(
                    text: "Add",
                    onPressed: () {
                      _showPopUpToAddUpdateApprovalDocument(context: context);
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
        child: BlocListener<ApprovalDocumentCubit, ApprovalDocumentState>(
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
          child: BlocBuilder<ApprovalDocumentCubit, ApprovalDocumentState>(
            builder: (context, state) {
              // 1. Initial loading
              if (state.isLoading! && state.documentCategoryModelList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Loaded but no categories
              if (state.documentCategoryModelList.isEmpty) {
                return Center(
                  child: noDataWidget(
                    message: "No Approval Document Data Found",
                  ),
                );
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
                            final documentsForCategory =
                                state.documentList
                                    .where(
                                      (d) =>
                                          d.approvalDocumentCategoryId ==
                                          category.approvalDocumentCategoryId,
                                    )
                                    .toList();

                            return (state.documentList.isEmpty &&
                                    state.isLoading!)
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : RefreshIndicator(
                                  onRefresh: () async {
                                    _searchC.clear();
                                    _documentCubit.searchApprovalDocument(
                                      "",
                                      context,
                                    );
                                  },
                                  child: _buildApprovalDocumentListForCategory(
                                    documentsForCategory,
                                  ),
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
  Widget _buildCategoryTab(ApprovalDocumentState state) {
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
              .map((b) => b.approvalDocumentCategoryName)
              .toList(),
    );
  }

  Widget _buildApprovalDocumentListForCategory(
    List<ApprovalDocumentModel> documents,
  ) {
    if (documents.isEmpty) {
      return Center(
        child: noDataWidget(message: "No Approval Document Data Found"),
      );
    }

    return BlocBuilder<ApprovalDocumentCubit, ApprovalDocumentState>(
      builder: (context, state) {
        return ListView.builder(
          controller: scrollController,
          itemCount: documents.length + 1,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemBuilder: (context, index) {
            // Pagination loader
            if (index == documents.length) {
              return state.documentList.length < state.totalNumberOfRecord
                  ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : const SizedBox.shrink();
            }

            final document = documents[index];

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
                              AppRoutes.viewApprovalDocument,
                              queryParameters: {
                                "approvalDocument": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(document.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );
                            if (context.mounted) {
                              _documentCubit.getProjectApprovalDocumentList(
                                context: context,
                                pageNumber: 1,
                              );
                            }
                          },
                          child: Text(
                            document.approvalDocumentName,
                            style: AppTextStyle.ts16M(
                              color: AppColor.primary,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (_routeAuthorizationModel.isAction)
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
                                  AppRoutes.addApprovalDocument,
                                  queryParameters: {
                                    "approvalDocument":
                                        Uri.encodeQueryComponent(
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
                                _showPopUpToAddUpdateApprovalDocument(
                                  documentModel: document,
                                  index: index,
                                  context: context,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              isDisabled:
                                  document.uploadedApprovalDocumentCount == 0
                                      ? false
                                      : true,
                              onPressed: () {
                                _showPopupToDeleteApprovalDocument(
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
                    title: "Pending Approval",
                    value:
                        document.approvalPendingApprovalDocumentCount
                            .toString(),
                  ),
                  buildRowTitleValue(
                    title: "Document Count",
                    value: document.uploadedApprovalDocumentCount.toString(),
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
