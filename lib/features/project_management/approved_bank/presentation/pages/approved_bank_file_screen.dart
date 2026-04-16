import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/data/model/approved_bank_file.model.dart';
import 'package:k3h_erp_app/features/project_management/approved_bank/presentation/cubit/approved_bank_file/approved_bank_file_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ApprovedBankFieScreen extends StatefulWidget {
  final int approvedBankFolderId;
  const ApprovedBankFieScreen({super.key, required this.approvedBankFolderId});

  @override
  State<ApprovedBankFieScreen> createState() => _ApprovedBankFieScreenState();
}

class _ApprovedBankFieScreenState extends State<ApprovedBankFieScreen> {
  // CUBIT
  late ApprovedBankFileCubit _approvedBankFileCubit;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _titleC;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  MultiFilePickerModel documentFile = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _initializeTextControllers();
    _project = getProject();
    _approvedBankFileCubit = BlocProvider.of<ApprovedBankFileCubit>(context);
    _onScroll();
    _approvedBankFileCubit.getApprovedBankFileList(
      context,
      1,
      10,
      _project.projectId,
      widget.approvedBankFolderId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _titleC.dispose();
  }

  void _initializeTextControllers() {
    _searchC = TextEditingController();
    _titleC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_approvedBankFileCubit.state.isLoading! &&
          _approvedBankFileCubit.state.approvedBankFileList.length <
              _approvedBankFileCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _approvedBankFileCubit.getApprovedBankFileList(
            context,
            _approvedBankFileCubit.state.currentPage + 1,
            10,
            _project.projectId,
            widget.approvedBankFolderId,
          );
        });
      }
    });
  }

  // CLEAR DIALOGUE
  void _clearDialogue() {
    _titleC.clear();
    documentFile.fileNameList = [];
  }

  _prefillDialogue(ApprovedBankFileModel approvedBankFileModel) {
    _titleC.text = approvedBankFileModel.approvedBankFileName;
    documentFile.fileNameList =
        approvedBankFileModel.approvedBankFileUrl
            .split(",")
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
  }

  // API CALLS TO ADD/UPDATE APPROVED BANK FILE
  Future<void> _addUpdateApprovedBankFile(
    BuildContext context,
    ApprovedBankFileModel? approvedBankFileModel,
    ApprovedBankFileState state,
    int index,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (approvedBankFileModel != null) {
        // Updating existing file
        _approvedBankFileCubit.updateApprovedBankFile(
          context: context,
          approvedBankFileId:
              approvedBankFileModel.approvedBankFileId.toString(),
          uniqueKey: approvedBankFileModel.uniquekey,
          projectId: _project.projectId.toString(),
          approvedBankFolderId:
              approvedBankFileModel.approvedBankFolderId.toString(),
          approvedBankFileName: _titleC.text,
          documentFile: documentFile,
          index: index,
        );
      } else {
        // Adding new file
        _approvedBankFileCubit.addApprovedBankFile(
          context: context,
          projectId: _project.projectId.toString(),
          approvedBankFolderId: widget.approvedBankFolderId.toString(),
          approvedBankFileName: _titleC.text,
          documentFile: documentFile,
        );
      }
    }
  }

  // DIALOGUE TO ADD/ UPDATE APPROVED BANK FILES
  Future<void> _showDialogToAddUpdateApprovedBankFile(
    BuildContext context,
    ApprovedBankFileState state, {
    ApprovedBankFileModel? approvedBankFileModel,
    int? index,
  }) async {
    if (approvedBankFileModel != null) {
      _prefillDialogue(approvedBankFileModel);
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "Add document",
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: 'Title',
                      textController: _titleC,
                      isRequired: true,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(100),
                      ],
                      validator: (string) {
                        if (string == null || string.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    CustomMultiFilePicker(
                      title: 'Attachment',
                      isRequired: true,
                      initialFileList: documentFile.fileNameList,
                      onFilePickedCallback: (bytesList, fileNameList) {
                        documentFile.fileNameList = fileNameList;
                        documentFile.fileBytesList = bytesList;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Attachment* is required";
                        }
                        return null;
                      },
                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        documentFile.fileNameList = fileNameList;
                        documentFile.fileBytesList = fileBytesList;
                        documentFile.deletedFileList = deletedFile;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            CustomButton.save(
              onPressed: () {
                _addUpdateApprovedBankFile(
                  context,
                  approvedBankFileModel,
                  state,
                  index ?? 0,
                );
              },
            ),
          ],
        ),
      ),
    );
    _clearDialogue();
  }

  // DIALOGUE TO DELETE APPROVED BANK FILE
  Future<void> _showPopupToDeleteApprovedBankFile(
    BuildContext context,
    ApprovedBankFileModel obj,
    int currentPage,
    int? index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a File?',
      'Deleting this file will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _approvedBankFileCubit.deleteApprovedBankFile(
        context: context,
        approvedBankFileId: obj.approvedBankFileId,
        approvedBankFolderId: obj.approvedBankFolderId,
        projectId: _project.projectId,
        uniqueKey: obj.uniquekey,
        pageNumber: currentPage,
        pageSize: 20,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.greyBackground,
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Approved Bank',
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () async {
          await _showDialogToAddUpdateApprovedBankFile(
            context,
            _approvedBankFileCubit.state,
          );
        },
      ),
      body: Column(
        children: [
          verticalSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SearchWidget(
              isFilterOn: false,
              hintText: "Search by Title",
              onSubmit: (value) {
                _approvedBankFileCubit.searchFile(
                  context,
                  value,
                  _project.projectId,
                  widget.approvedBankFolderId,
                );
              },
              textController: _searchC,
            ),
          ),
          Expanded(
            child: BlocBuilder<ApprovedBankFileCubit, ApprovedBankFileState>(
              builder: (context, state) {
                if ((state.isLoading ?? true) &&
                    state.approvedBankFileList.isEmpty) {
                  return Center(child: loader());
                }
                if (state.approvedBankFileList.isEmpty) {
                  return Center(
                    child: noDataWidget(message: "No Approved Bank File Found"),
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount:
                      _approvedBankFileCubit.state.approvedBankFileList.length +
                      1,
                  itemBuilder: (context, index) {
                    if (index == state.approvedBankFileList.length) {
                      return state.approvedBankFileList.length <
                              state.totalNumberOfRecord
                          ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                          : const SizedBox.shrink();
                    }
                    var files = state.approvedBankFileList[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: commonCardDecoration(),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 16,
                              left: 16,
                              right: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        files.approvedBankFileName,
                                        style: AppTextStyle.ts14R(
                                          color: AppColor.primary,
                                        ),
                                      ),
                                    ),
                                    horizontalSpacing(),
                                    CustomIconButton(
                                      onPressed: () {
                                        if (files.approvedBankFileUrl.isEmpty) {
                                          showErrorMessage(
                                            context,
                                            "Image Error",
                                            "No Image Found",
                                          );
                                        }
                                        showFilePreviewDialog(
                                          context,
                                          files.approvedBankFileUrl.split(","),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 16,
                                        color: AppColor.primary,
                                      ),
                                      backgroundColor: AppColor.lightBlue,
                                    ),
                                  ],
                                ),
                                verticalSpacing(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          buildRowTitleValue(
                                            title: "Modified By",
                                            value:
                                                files.modifiedBy.isEmpty
                                                    ? files.createdBy
                                                    : files.modifiedBy,
                                          ),
                                          buildRowTitleValue(
                                            title: "Modified Date",
                                            value:
                                                files.modifiedDate == null
                                                    ? formatDate(
                                                      files.createdDate,
                                                    )
                                                    : formatDate(
                                                      files.modifiedDate,
                                                    ),
                                            singleLine: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 10,
                                      children: [
                                        CustomIconButton.edit(
                                          onPressed: () {
                                            _showDialogToAddUpdateApprovedBankFile(
                                              context,
                                              state,
                                              approvedBankFileModel: files,
                                              index: index,
                                            );
                                          },
                                        ),
                                        CustomIconButton.delete(
                                          onPressed: () {
                                            _showPopupToDeleteApprovedBankFile(
                                              context,
                                              files,
                                              state.currentPage,
                                              index,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
