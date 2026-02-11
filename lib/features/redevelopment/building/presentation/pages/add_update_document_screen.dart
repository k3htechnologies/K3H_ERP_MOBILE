import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/model/building_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddUpdateDocumentScreen extends StatefulWidget {
  final RedevelopmentBuildingModel building;
  const AddUpdateDocumentScreen({super.key, required this.building});

  @override
  State<AddUpdateDocumentScreen> createState() =>
      _AddUpdateDocumentScreenState();
}

class _AddUpdateDocumentScreenState extends State<AddUpdateDocumentScreen> {
  // TEXT EDITING CONTROLLER
  late TextEditingController _newDocumentTitleController;

  // CUBIT
  late BuildingCubit _buildingCubit;

  // PROJECT
  late ProjectModel _project;

  // LOCAL PARENT LIST + LOADING (so expand doesn’t refresh whole screen)
  bool _isLoading = true;
  List<BuildingDocumentModel> _parentDocuments = [];

  final ValueNotifier<Set<int>> _expandedDocumentIds = ValueNotifier<Set<int>>(
    {},
  );
  final ValueNotifier<Map<int, List<BuildingDocumentModel>>> _childDocuments =
      ValueNotifier<Map<int, List<BuildingDocumentModel>>>({});
  final ValueNotifier<Map<int, bool>> _loadingChildDocuments =
      ValueNotifier<Map<int, bool>>({});

  @override
  void initState() {
    super.initState();
    _newDocumentTitleController = TextEditingController();
    _buildingCubit = context.read<BuildingCubit>();
    _project = getProject();
    _loadParentDocuments();
  }

  @override
  void dispose() {
    _newDocumentTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadParentDocuments() async {
    setState(() {
      _isLoading = true;
    });
    await _buildingCubit.getBuildingDocumentList(
      context,
      _project.projectId,
      widget.building.buildingId,
      1,
      100,
      null,
    );
    if (!mounted) return;
    final state = _buildingCubit.state;
    setState(() {
      _isLoading = false;
      _parentDocuments = List<BuildingDocumentModel>.from(
        state.buildingDocumentList,
      );
    });
  }

  Future<void> _pickDocuments(BuildingDocumentModel doc) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    final multiFileModel = _convertToMultiFilePicker(result.files);

    await _buildingCubit.updateBuildingDocument(
      context: context,
      buildingDocumentId: doc.buildingDocumentId,
      uniqueKey: doc.uniquekey,
      projectId: doc.projectId,
      buildingId: doc.buildingId,
      documentName: doc.documentName,
      files: multiFileModel,
    );

    if (mounted) {
      final updatedExpanded = Set<int>.from(_expandedDocumentIds.value);
      updatedExpanded.remove(doc.buildingDocumentId);
      _expandedDocumentIds.value = updatedExpanded;

      final updatedChildren = Map<int, List<BuildingDocumentModel>>.from(
        _childDocuments.value,
      );
      updatedChildren.remove(doc.buildingDocumentId);
      _childDocuments.value = updatedChildren;
    }
  }

  MultiFilePickerModel _convertToMultiFilePicker(List<PlatformFile> files) {
    return MultiFilePickerModel(
      fileNameList: files.map((e) => e.name).toList(),
      fileBytesList: files.map((e) => e.bytes!).toList(),
      deletedFileList: "",
    );
  }

  // BOTTOM SHEET TO ADD TITLE
  Future<void> _showAddDocumentBottomSheet() async {
    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Document",
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                textController: _newDocumentTitleController,
                title: "Document title",
                hint: "Enter document title",
              ),
              verticalSpacing(height: 16),
              CustomButton(
                text: "Add Document",
                onPressed: () async {
                  final title = _newDocumentTitleController.text.trim();
                  if (title.isEmpty) {
                    showErrorMessage(
                      context,
                      "Error",
                      "Please enter document title",
                    );
                    return;
                  }

                  await _buildingCubit.addBuildingDocument(
                    context: context,
                    projectId: _project.projectId,
                    buildingId: widget.building.buildingId,
                    documentName: title,
                    files: MultiFilePickerModel(
                      fileNameList: const [],
                      fileBytesList: const [],
                      deletedFileList: "",
                    ),
                  );

                  if (!mounted) return;
                  Navigator.of(context).pop();
                  _newDocumentTitleController.clear();

                  // Refresh parent titles after adding new one
                  if (mounted) {
                    await _loadParentDocuments();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Building Document",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: CustomButton(
              text: "Add Document",
              onPressed: _showAddDocumentBottomSheet,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: loader())
                : _parentDocuments.isEmpty
                    ? Center(child: noDataWidget())
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        itemCount: _parentDocuments.length,
                        itemBuilder: (context, index) {
                          final doc = _parentDocuments[index];

                          return ValueListenableBuilder<Set<int>>(
                            valueListenable: _expandedDocumentIds,
                            builder: (context, expandedSet, _) {
                              final isExpanded = expandedSet.contains(
                                doc.buildingDocumentId,
                              );
                              final childDocs =
                                  _childDocuments.value[doc.buildingDocumentId] ??
                                      [];
                              final isLoadingChildren =
                                  _loadingChildDocuments
                                          .value[doc.buildingDocumentId] ??
                                      false;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: commonCardDecoration(),
                                child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  final currentExpanded = Set<int>.from(
                                    _expandedDocumentIds.value,
                                  );

                                  if (isExpanded) {
                                    // Collapse
                                    currentExpanded.remove(
                                      doc.buildingDocumentId,
                                    );
                                    _expandedDocumentIds.value =
                                        currentExpanded;
                                  } else {
                                    // Expand - call API if not already loaded
                                    currentExpanded.add(doc.buildingDocumentId);
                                    _expandedDocumentIds.value =
                                        currentExpanded;

                                    if (!_childDocuments.value.containsKey(
                                      doc.buildingDocumentId,
                                    )) {
                                      // Set loading true
                                      final loadingMap = Map<int, bool>.from(
                                        _loadingChildDocuments.value,
                                      );
                                      loadingMap[doc.buildingDocumentId] = true;
                                      _loadingChildDocuments.value = loadingMap;

                                      _buildingCubit
                                          .getBuildingDocumentList(
                                            context,
                                            _project.projectId,
                                            widget.building.buildingId,
                                            1,
                                            100,
                                            doc.buildingDocumentId,
                                          )
                                          .then((_) {
                                            if (!mounted) return;
                                            final currentState =
                                                _buildingCubit.state;

                                            // Update children map
                                            final childrenMap = Map<
                                              int,
                                              List<BuildingDocumentModel>
                                            >.from(_childDocuments.value);
                                            childrenMap[doc
                                                .buildingDocumentId] = List<
                                              BuildingDocumentModel
                                            >.from(
                                              currentState.buildingDocumentList,
                                            );
                                            _childDocuments.value = childrenMap;

                                            // Set loading false
                                            final loadingMapDone =
                                                Map<int, bool>.from(
                                                  _loadingChildDocuments.value,
                                                );
                                            loadingMapDone[doc
                                                    .buildingDocumentId] =
                                                false;
                                            _loadingChildDocuments.value =
                                                loadingMapDone;

                                            // Force row rebuild so loader hides
                                            final refreshedExpanded =
                                                Set<int>.from(
                                              _expandedDocumentIds.value,
                                            );
                                            _expandedDocumentIds.value =
                                                refreshedExpanded;
                                          });
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.documentName,
                                          style: AppTextStyle.ts14SB(),
                                        ),
                                      ),
                                      Row(
                                        spacing: 20,
                                        children: [
                                          CustomIconButton(
                                            onPressed:
                                                () => _pickDocuments(doc),
                                            icon: Icon(
                                              Icons.add,
                                              color: AppColor.darkGreen,
                                              size: 16,
                                            ),
                                            backgroundColor:
                                                AppColor.lightGreen,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColor.lightGrey,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isExpanded
                                                  ? Icons.arrow_drop_up
                                                  : Icons.arrow_drop_down,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isExpanded)
                                Builder(
                                  builder: (context) {
                                    if (isLoadingChildren) {
                                      return const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    if (childDocs.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Center(
                                          child: Text(
                                            "No documents found",
                                            style: AppTextStyle.ts14R(
                                              color: AppColor.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            childDocs.map((childDoc) {
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColor
                                                          .lightGreyBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        childDoc.documentName,
                                                        style:
                                                            AppTextStyle.ts14R(),
                                                      ),
                                                    ),
                                                    CustomIconButton(
                                                      onPressed: () {
                                                        showFilePreviewDialog(
                                                          context,
                                                          childDoc.documentURL
                                                              .split(","),
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        color: AppColor.primary,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    );
                                  },
                                ),
                            ],
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
}
