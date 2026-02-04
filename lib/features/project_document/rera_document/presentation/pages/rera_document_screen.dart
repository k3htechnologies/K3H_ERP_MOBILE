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
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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

  // <---- PAGINATION ---->
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

  // TEXT EDIT CONTROLLER
  late TextEditingController _searchC, _reraDocumentC;
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // INITIALIZE CONTROLLERS
  void _initControllers() {
    _searchC = TextEditingController();
    _reraDocumentC = TextEditingController();
  }

  @override
  void dispose() {
    _categoryTabController?.removeListener(_onBuildingTabChanged);
    _categoryTabController?.dispose();

    super.dispose();
  }

  void _submitForm({RERADocumentModel? documentModel, int? index}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (documentModel != null) {
      //Edit Name
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
      //Create New Parent Doc
      _reraDocumentCubit.addRERADocumentToCategory(
        context: context,
        projectRERADocumentName: _reraDocumentC.text.trim(),
      );
    }
  }

  void _prefillDocumentDetails(RERADocumentModel documentModel) {
    _reraDocumentC.text = documentModel.projectRERADocumentName;
  }

  // DELETE RERA DOCUMENT
  Future<void> _showPopupToDeleteRERADocument(
    BuildContext context,
    RERADocumentModel obj,
    // int page,
    int index,
  ) async {
    final shouldDelete = await DialogHelper.deleteDialog(
      context,
      'You are about to RERA delete a document?',
      'Deleting this RERA document will permanently remove its contents.',
    );

    if (shouldDelete && context.mounted) {
      _reraDocumentCubit.deleteDocument(obj, context, index);
    }
  }

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
      Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
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
    _reraDocumentC.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "RERA Document",
        authorization: _routeAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _reraDocumentCubit.searchDocument(value, context);
        },
        onProjectChangeCallback: (project) {
          projectId = project.projectId;
          _reraDocumentCubit.getCategoryList(context, 1, projectId);
        },
        extraHeight: 20,
        secondaryBuilder:
            (_) => CustomButton(
              text: "Add",
              onPressed: () {
                _showPopUpToAddUpdateRERADocument();
              },
              backgroundColor: AppColor.primary,
              leading: Icon(Icons.add, size: 16, color: AppColor.white),
            ),
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
                                : _buildDocumentListForCategory(
                                  documentsForCategory,
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
                    .map((b) => Tab(text: b.projectRERADocumentCategoryName))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentListForCategory(List<RERADocumentModel> documents) {
    if (documents.isEmpty) {
      return noDataWidget();
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
                              document.projectRERADocumentName,
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
                          const SizedBox(width: 8),
                          CustomIconButton.edit(
                            onPressed: () async {
                              _showPopUpToAddUpdateRERADocument(
                                documentModel: document,
                                index: index,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          CustomIconButton.delete(
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
                    title: "Pending Approvals",
                    value:
                        document.approvalPendingProjectRERADocumentCount
                            .toString(),
                  ),
                  buildRowTitleValue(
                    title: "Documents",
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
