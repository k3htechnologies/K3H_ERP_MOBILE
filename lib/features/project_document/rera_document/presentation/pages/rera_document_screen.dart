import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/data/model/rera_document.model.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_cubit.dart';
import 'package:k3h_erp_app/features/project_document/rera_document/presentation/cubit/rera_document_state.dart';
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

class RERADocumentScreen extends StatefulWidget {
  const RERADocumentScreen({super.key});

  @override
  State<RERADocumentScreen> createState() => _RERADocumentScreenState();
}

class _RERADocumentScreenState extends State<RERADocumentScreen>
    with TickerProviderStateMixin {
  // AuthorizationModel
  late AuthorizationModel _routeAuthorizationModel;
  //CUBIT
  late RERADocumentCubit _reraDocumentCubit;
  // TAB CONTROLLERS
  TabController? _categoryTabController;

  late int projectId;

  //PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC, _reraDocumentC;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.rera]!;
    _reraDocumentCubit = context.read<RERADocumentCubit>();
    projectId = getProject().projectId;
    _reraDocumentCubit.getCategoryList(context, 1, projectId);
    _initControllers();
    _onScroll();
  }

  @override
  void dispose() {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
    _reraDocumentC = TextEditingController();
  }

  // PAGINATION
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_reraDocumentCubit.state.isLoading! &&
          _reraDocumentCubit.state.reraDocumentList.length <
              _reraDocumentCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _reraDocumentCubit.getRERADocumentList(
            context: context,
            pageNumber: _reraDocumentCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // CATEGORY TAB
  void _onBuildingTabChanged() {
    if (!_categoryTabController!.indexIsChanging && mounted) {
      _reraDocumentCubit.onTabChanged(_categoryTabController!.index, context);
    }
  }

  // CATEGORY CONTROLLER
  void _initCategoryController(RERADocumentState state) {
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
  void _submitForm({RERADocumentModel? documentModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (documentModel != null) {
      // EDIT NAME
      _reraDocumentCubit.updateRERADocumentNameInCategory(
        context: context,
        index: index!,
        uniqueKey: documentModel.uniquekey,
        projectRERADocumentId: documentModel.projectRERADocumentId,
        projectRERADocumentCategoryId:
            documentModel.projectRERADocumentCategoryId,
        projectRERADocumentName: _reraDocumentC.text.trim(),
      );
    } else {
      // CREATE NEW PARENT DOC
      _reraDocumentCubit.addRERADocumentToCategory(
        context: context,
        projectRERADocumentName: _reraDocumentC.text.trim(),
      );
    }
  }

  // PREFILL DOCUMENT DETAILS
  void _prefillDocumentDetails(RERADocumentModel documentModel) {
    _reraDocumentC.text = documentModel.projectRERADocumentName;
  }

  // SHOW POPUP TO ADD/UPDATE DOCUMENT
  Future<void> _showPopUpToAddUpdateRERADocument({
    RERADocumentModel? documentModel,
    int? index,
  }) async {
    if (documentModel != null) {
      _prefillDocumentDetails(documentModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      documentModel != null ? 'Update Document Name' : 'Add Document Name',
      contentWidget: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              title: "Document Name",
              hint: "Enter Document Name",
              isRequired: true,
              textController: _reraDocumentC,
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
        },
      ),
    );
    _clearDialogueToAddUpdateDocument();
  }

  // CLEAR DIALOGUE TO ADD/UPDATE DOCUMENT
  void _clearDialogueToAddUpdateDocument() {
    _reraDocumentC.clear();
  }

  // DELETE RERA DOCUMENT
  Future<void> _showPopupToDeleteRERADocument(
    BuildContext context,
    RERADocumentModel obj,

    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to RERA delete a document?',
      'Deleting this RERA document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _reraDocumentCubit.deleteDocument(
        obj,
        obj.projectRERADocumentCategoryId,
        context,
        index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "RERA Document",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        searchHintText: "Search By Document Name",
        onSearchSubmit: (value) {
          _reraDocumentCubit.searchDocument(value, context);
        },
        onProjectChangeCallback: (project) {
          projectId = project.projectId;
          _reraDocumentCubit.getCategoryList(context, 1, projectId);
        },
      ),
      body: SafeArea(
        child: BlocListener<RERADocumentCubit, RERADocumentState>(
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
          child: BlocBuilder<RERADocumentCubit, RERADocumentState>(
            builder: (context, state) {
              if (state.isLoading! && state.documentCategoryModelList.isEmpty) {
                return Center(child: loader());
              }

              if (state.documentCategoryModelList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: noDataWidget(
                      message: "No Project RERA Document Category Data Found",
                    ),
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
                            final documentsForCategory =
                                state.reraDocumentList
                                    .where(
                                      (d) =>
                                          d.projectRERADocumentCategoryId ==
                                          category
                                              .projectRERADocumentCategoryId,
                                    )
                                    .toList();

                            return (state.reraDocumentList.isEmpty &&
                                    state.isLoading!)
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : RefreshIndicator(
                                  onRefresh: () async {
                                    await _reraDocumentCubit.getCategoryList(
                                      context,
                                      1,
                                      projectId,
                                    );
                                  },
                                  child: _buildDocumentListForCategory(
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
  Widget _buildCategoryTab(RERADocumentState state) {
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
              .map((b) => b.projectRERADocumentCategoryName)
              .toList(),
    );
  }

  // DOCUMENT LIST FOR CATEGORY
  Widget _buildDocumentListForCategory(List<RERADocumentModel> documents) {
    if (documents.isEmpty) {
      return Center(
        child: noDataWidget(message: "No RERA Document Data Found"),
      );
    }

    return BlocBuilder<RERADocumentCubit, RERADocumentState>(
      builder: (context, state) {
        return ListView.builder(
          controller: scrollController,
          itemCount: documents.length + 1,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),

          itemBuilder: (context, index) {
            if (index == documents.length) {
              return state.isLoading! &&
                      state.reraDocumentList.length < state.totalNumberOfRecord
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
                              AppRoutes.viewReraDocument,
                              queryParameters: {
                                "reraDocument": Uri.encodeQueryComponent(
                                  EncryptionManager.encryptData(
                                    jsonEncode(document.toJson()),
                                  ),
                                ),
                                "index": index.toString(),
                              },
                            );

                            if (context.mounted) {
                              _reraDocumentCubit.getRERADocumentList(
                                context: context,
                                pageNumber: 1,
                              );
                            }
                          },
                          child: Text(
                            document.projectRERADocumentName,
                            style: AppTextStyle.ts16M(
                              color: AppColor.primary,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColor.primary,
                            ),
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
                                  AppRoutes.addReraDocument,
                                  queryParameters: {
                                    "reraDocument": Uri.encodeQueryComponent(
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
                                _showPopUpToAddUpdateRERADocument(
                                  documentModel: document,
                                  index: index,
                                );
                              },
                            ),
                            horizontalSpacing(),
                            CustomIconButton.delete(
                              isDisabled:
                                  document.uploadedProjectRERADocumentCount == 0
                                      ? false
                                      : true,
                              onPressed: () {
                                _showPopupToDeleteRERADocument(
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
                        document.approvalPendingProjectRERADocumentCount
                            .toString(),
                  ),
                  buildRowTitleValue(
                    title: "Document Count",
                    value: document.uploadedProjectRERADocumentCount.toString(),
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
