import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_more_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BuildingDocumentView extends StatefulWidget {
  final RedevelopmentBuildingModel building;

  const BuildingDocumentView({super.key, required this.building});

  @override
  State<BuildingDocumentView> createState() => _BuildingDocumentViewState();
}

class _BuildingDocumentViewState extends State<BuildingDocumentView> {
  late TextEditingController _newDocumentTitleController, _searchDocumentNameC;
  late AuthorizationModel _routeAuthorizationModel;
  late BuildingCubit _buildingCubit;
  late ProjectModel _project;
  final ValueNotifier<Map<int, List<BuildingDocumentModel>>> _childDocuments =
      ValueNotifier({});

  final ValueNotifier<Map<int, bool>> _loadingChildren = ValueNotifier({});
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    _buildingCubit = context.read<BuildingCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.building] ??
        AuthorizationModel();

    _project = getProject();
    _searchDocumentNameC = TextEditingController();
    _newDocumentTitleController = TextEditingController();
    _onScroll();
    super.initState();
  }

  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_buildingCubit.state.isLoading! &&
          _buildingCubit.state.buildingDocumentList.length <
              _buildingCubit.state.totalNumberOfRecordDocument) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _buildingCubit.getBuildingDocumentList(
            context: context,
            projectId: _project.projectId,
            buildingId: widget.building.buildingId,
            pageNumber: _buildingCubit.state.currentPageDocument + 1,
          );
        });
      }
    });
  }

  Future<void> _showAddDocumentBottomSheet({
    BuildingDocumentModel? document,
  }) async {
    final isEditMode = document != null;
    if (isEditMode) {
      _newDocumentTitleController.text = document.documentName;
    } else {
      _newDocumentTitleController.clear();
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      isEditMode ? "Update Document" : "Add Document",
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            textController: _newDocumentTitleController,
            title: "Document title",
            hint: "Enter document title",
          ),
        ],
      ),
      bottomActions: CustomButton(
        text: isEditMode ? "Update Document" : "Add Document",
        onPressed: () async {
          final title = _newDocumentTitleController.text.trim();
          if (title.isEmpty) {
            showErrorMessage(context, "Error", "Please enter document title");
            return;
          }

          if (!isEditMode) {
            await _buildingCubit.addBuildingParentDocument(
              context: context,
              projectId: _project.projectId,
              buildingId: widget.building.buildingId,
              documentName: title,
            );
          } else {
            await _buildingCubit.updateBuildingParentDocument(
              context: context,
              projectId: document.projectId,
              buildingId: document.buildingId,
              documentName: _newDocumentTitleController.text.trim(),
              buildingDocumentId: document.buildingDocumentId,
              uniquekey: document.uniquekey,
            );
          }

          if (!mounted) return;
          _newDocumentTitleController.clear();
        },
      ),
    );
  }

  Future _showPopupToDeleteDocument({
    required BuildingDocumentModel document,
    required BuildContext context,
  }) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a document ?',
      'Deleting this document will permanently remove all associated data.',
    );

    if (result && context.mounted) {
      _buildingCubit.deleteBuildingDocument(
        document: document,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: SearchWidget(
                  onSubmit: (v) {
                    _buildingCubit.searchDocument(
                      buildingId: widget.building.buildingId,
                      context: context,
                      projectId: widget.building.projectId,
                      value: v,
                    );
                  },
                  hintText: "Search By Document Name",
                  textController: _searchDocumentNameC,
                ),
              ),
              IntrinsicWidth(
                child: CustomButton(
                  isDisable: !_routeAuthorizationModel.isAction,
                  text: "Add",
                  onPressed: _showAddDocumentBottomSheet,
                ),
              ),
            ],
          ),

          Expanded(
            child: BlocBuilder<BuildingCubit, BuildingState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.buildingDocumentList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.buildingDocumentList.isEmpty) {
                  return Center(child: noDataWidget());
                }

                final documents = state.buildingDocumentList;

                return ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  itemCount: documents.length + 1,
                  itemBuilder: (context, index) {
                    if (index == state.buildingDocumentList.length) {
                      return state.buildingDocumentList.length <
                              state.totalNumberOfRecordDocument
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    final doc = documents[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: commonCardDecoration(),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),

                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          expandedAlignment: Alignment.topCenter,
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          onExpansionChanged: (expanded) async {
                            if (!expanded) return;

                            _loadingChildren.value = {
                              ..._loadingChildren.value,
                              doc.buildingDocumentId: true,
                            };

                            try {
                              final children = await _buildingCubit
                                  .getBuildingChildDocuments(
                                    context,
                                    _project.projectId,
                                    widget.building.buildingId,
                                    doc.buildingDocumentId,
                                  );

                              _childDocuments.value = {
                                ..._childDocuments.value,
                                doc.buildingDocumentId: children,
                              };
                            } finally {
                              _loadingChildren.value = {
                                ..._loadingChildren.value,
                                doc.buildingDocumentId: false,
                              };
                            }
                          },
                          showTrailingIcon: false,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.documentName,
                                      style: AppTextStyle.ts14M(),
                                    ),
                                    Text(
                                      "Document: ${doc.uploadedBuildingDocumentCount.addCommas()}",
                                      style: AppTextStyle.ts14R(
                                        color: AppColor.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 10,
                                children: [
                                  CustomIconButton.add(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () async {
                                      final result = await goRouter.pushNamed(
                                        AppRoutes.addUpdateBuildingDoc,
                                        queryParameters: {
                                          "document": Uri.encodeComponent(
                                            EncryptionManager.encryptData(
                                              jsonEncode(doc.toJson()),
                                            ),
                                          ),
                                        },
                                      );
                                      if (result == true) {
                                        final children = await _buildingCubit
                                            .getBuildingChildDocuments(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              _project.projectId,
                                              widget.building.buildingId,
                                              doc.buildingDocumentId,
                                            );

                                        _childDocuments.value = {
                                          ..._childDocuments.value,
                                          doc.buildingDocumentId: children,
                                        };
                                      }
                                    },
                                  ),
                                  CustomIconButton.edit(
                                    isDisabled:
                                        !_routeAuthorizationModel.isAction,
                                    onPressed: () {
                                      _showAddDocumentBottomSheet(
                                        document: doc,
                                      );
                                    },
                                  ),
                                  CustomIconButton.delete(
                                    isDisabled:
                                        (!_routeAuthorizationModel.isAction ||
                                            doc.uploadedBuildingDocumentCount >
                                                0),
                                    onPressed: () {
                                      _showPopupToDeleteDocument(
                                        context: context,
                                        document: doc,
                                      );
                                    },
                                  ),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            ValueListenableBuilder<Map<int, bool>>(
                              valueListenable: _loadingChildren,
                              builder: (context, loadingMap, _) {
                                final isLoading =
                                    loadingMap[doc.buildingDocumentId] ?? false;

                                if (isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                return ValueListenableBuilder<
                                  Map<int, List<BuildingDocumentModel>>
                                >(
                                  valueListenable: _childDocuments,
                                  builder: (context, childMap, _) {
                                    final childDocs =
                                        childMap[doc.buildingDocumentId] ??
                                        <BuildingDocumentModel>[];

                                    if (childDocs.isEmpty) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: noDataWidget(iconSize: 100),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children:
                                          childDocs
                                              .map(
                                                (child) => _buildDocumentItem(
                                                  context,
                                                  document: doc,
                                                  subDocument: child,
                                                ),
                                              )
                                              .toList(),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context, {
    required BuildingDocumentModel document,
    required BuildingDocumentModel subDocument,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.lightGreyBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10.w,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(subDocument.documentName, style: AppTextStyle.ts14R()),

                  CustomIconButton(
                    onPressed: () {
                      showFilePreviewDialog(
                        title: subDocument.documentName,
                        context,
                        subDocument.documentURL.split(","),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: AppColor.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),

              CustomMoreButton(
                isDisabled: !_routeAuthorizationModel.isAction,
                items: [
                  CustomMoreItem(
                    child: CustomIconButton.edit(
                      isDisabled: !_routeAuthorizationModel.isAction,
                      onPressed: () async {
                        final result = await goRouter.pushNamed(
                          AppRoutes.addUpdateBuildingDoc,
                          queryParameters: {
                            "document": Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(document.toJson()),
                              ),
                            ),
                            "subDocument": Uri.encodeComponent(
                              EncryptionManager.encryptData(
                                jsonEncode(subDocument.toJson()),
                              ),
                            ),
                          },
                        );
                        if (result == true) {
                          final children = await _buildingCubit
                              .getBuildingChildDocuments(
                                // ignore: use_build_context_synchronously
                                context,
                                _project.projectId,
                                widget.building.buildingId,
                                document.buildingDocumentId,
                              );

                          _childDocuments.value = {
                            ..._childDocuments.value,
                            document.buildingDocumentId: children,
                          };
                        }
                      },
                    ),
                    onTap: () async {
                      final result = await goRouter.pushNamed(
                        AppRoutes.addUpdateBuildingDoc,
                        queryParameters: {
                          "document": Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(document.toJson()),
                            ),
                          ),
                          "subDocument": Uri.encodeComponent(
                            EncryptionManager.encryptData(
                              jsonEncode(subDocument.toJson()),
                            ),
                          ),
                        },
                      );
                      if (result == true) {
                        final children = await _buildingCubit
                            .getBuildingChildDocuments(
                              // ignore: use_build_context_synchronously
                              context,
                              _project.projectId,
                              widget.building.buildingId,
                              document.buildingDocumentId,
                            );

                        _childDocuments.value = {
                          ..._childDocuments.value,
                          document.buildingDocumentId: children,
                        };
                      }
                    },
                  ),
                  CustomMoreItem(
                    child: CustomIconButton.delete(
                      isDisabled: !_routeAuthorizationModel.isAction,
                      onPressed: () async {
                        await _showPopupToDeleteDocument(
                          context: context,
                          document: subDocument,
                        );
                        final children = await _buildingCubit
                            .getBuildingChildDocuments(
                              // ignore: use_build_context_synchronously
                              context,
                              _project.projectId,
                              widget.building.buildingId,
                              document.buildingDocumentId,
                            );

                        _childDocuments.value = {
                          ..._childDocuments.value,
                          document.buildingDocumentId: children,
                        };
                      },
                    ),
                    onTap: () async {
                      await _showPopupToDeleteDocument(
                        context: context,
                        document: subDocument,
                      );
                      final children = await _buildingCubit
                          .getBuildingChildDocuments(
                            // ignore: use_build_context_synchronously
                            context,
                            _project.projectId,
                            widget.building.buildingId,
                            document.buildingDocumentId,
                          );

                      _childDocuments.value = {
                        ..._childDocuments.value,
                        document.buildingDocumentId: children,
                      };
                    },
                  ),
                ],
              ),
            ],
          ),
          buildRowWrapper(
            child: buildColumnTitleValue(
              title: "Remark",
              value: subDocument.documentRemark,
            ),
          ),
          buildRowWrapper(
            child: buildColumnTitleValue(
              title: "Uploaded By / Date",
              value:
                  subDocument.modifiedBy.isNotEmpty
                      ? "${subDocument.modifiedBy} / ${formatDate(subDocument.modifiedDate)}"
                      : "${subDocument.createdBy} / ${formatDate(subDocument.createdDate)}",
            ),
          ),
        ],
      ),
    );
  }
}
