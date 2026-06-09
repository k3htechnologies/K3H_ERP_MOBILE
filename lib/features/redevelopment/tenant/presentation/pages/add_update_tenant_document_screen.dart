import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/employee_master/presentation/widgets/employee_document_dialog.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/data/model/tenant_document.model.dart';
import 'package:k3h_erp_app/features/redevelopment/tenant/presentation/cubit/tenant_cubit.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddUpdateTenantDocumentScreen extends StatefulWidget {
  final TenantModel tenant;

  const AddUpdateTenantDocumentScreen({super.key, required this.tenant});

  @override
  State<AddUpdateTenantDocumentScreen> createState() =>
      _AddUpdateTenantDocumentScreenState();
}

class _AddUpdateTenantDocumentScreenState
    extends State<AddUpdateTenantDocumentScreen> {
  late TenantCubit _tenantCubit;
  late TextEditingController _newDocumentTitleController;

  bool _isLoading = true;
  List<TenantDocumentModel> _documents = [];

  // Files for new document (CustomMultiFilePicker)
  MultiFilePickerModel _newDocumentFiles = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );

  @override
  void initState() {
    super.initState();
    _tenantCubit = context.read<TenantCubit>();
    _newDocumentTitleController = TextEditingController();
    _loadDocuments();
  }

  @override
  void dispose() {
    _newDocumentTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    await _tenantCubit.getTenantDocumentList(
      context: context,
      projectId: widget.tenant.projectId,
      buildingId: widget.tenant.buildingId,
      tenantId: widget.tenant.tenantId,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _documents = List<TenantDocumentModel>.from(
        _tenantCubit.state.tenantDocumentList,
      );
    });
  }

  Future<void> _showAddDocumentBottomSheet() async {
    // Reset files for new document
    _newDocumentFiles = MultiFilePickerModel(
      fileBytesList: [],
      fileNameList: [],
      deletedFileList: "",
    );

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Document",
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            textController: _newDocumentTitleController,
            title: "Document title",
            hint: "Enter document title",
          ),
          verticalSpacing(height: 12),
          CustomMultiFilePicker(
            title: "Files",
            isRequired: true,
            initialFileList: _newDocumentFiles.fileNameList,
            onFilePickedCallback: (bytesList, fileNameList) {
              _newDocumentFiles.fileBytesList = bytesList;
              _newDocumentFiles.fileNameList = fileNameList;
            },
            onFileDeleteCallback: (fileBytesList, fileNameList, deleted) {
              _newDocumentFiles.fileBytesList = fileBytesList;
              _newDocumentFiles.fileNameList = fileNameList;
              _newDocumentFiles.deletedFileList = deleted;
            },
          ),
          verticalSpacing(height: 16),
        ],
      ),
      bottomActions: CustomButton(
        text: "Add Document",
        onPressed: () async {
          final title = _newDocumentTitleController.text.trim();
          if (title.isEmpty) {
            showErrorMessage(context, "Error", "Please enter document title");
            return;
          }
          if (_newDocumentFiles.fileNameList.isEmpty) {
            showErrorMessage(
              context,
              "Error",
              "Please select at least one file",
            );
            return;
          }

          await _tenantCubit.addTenantDocument(
            context: context,
            tenantId: widget.tenant.tenantId,
            projectId: widget.tenant.projectId,
            buildingId: widget.tenant.buildingId,
            documentName: title,
            files: _newDocumentFiles,
          );
          if (!mounted) return;
          Navigator.of(context).pop();
          _newDocumentTitleController.clear();
          await _loadDocuments();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Tenant Document",
        authorization: AuthorizationModel(),
      ),
      body:
          _isLoading
              ? Center(child: loader())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: SizedBox(
                      width: 160,
                      child: CustomButton(
                        leading: Icon(
                          Icons.add,
                          size: 18,
                          color: AppColor.white,
                        ),
                        text: "Add Document",
                        onPressed: _showAddDocumentBottomSheet,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _documents.isEmpty
                            ? Center(child: noDataWidget())
                            : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final doc = _documents[index];
                                final urls =
                                    doc.documentUrl.isEmpty
                                        ? <String>[]
                                        : doc.documentUrl.split(',');
                                final isFresh = urls.isEmpty;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: commonCardDecoration(),
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
                                      CustomIconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder:
                                                (_) => EmployeeDocumentDialog(
                                                  title: doc.documentName,
                                                  urls: urls,
                                                  isFreshAdd: isFresh,
                                                  addDocument: (
                                                    pickedFiles,
                                                  ) async {
                                                    final files =
                                                        MultiFilePickerModel(
                                                          fileNameList:
                                                              pickedFiles
                                                                  .map(
                                                                    (e) =>
                                                                        e.name,
                                                                  )
                                                                  .toList(),
                                                          fileBytesList:
                                                              pickedFiles
                                                                  .where(
                                                                    (e) =>
                                                                        e.bytes !=
                                                                        null,
                                                                  )
                                                                  .map(
                                                                    (e) =>
                                                                        e.bytes!,
                                                                  )
                                                                  .toList(),
                                                          deletedFileList: "",
                                                        );
                                                    await _tenantCubit
                                                        .updateTenantDocument(
                                                          context: context,
                                                          tenantDocumentId:
                                                              doc.tenantDocumentId,
                                                          uniqueKey:
                                                              doc.uniquekey,
                                                          projectId:
                                                              doc.projectId,
                                                          buildingId:
                                                              doc.buildingId,
                                                          documentName:
                                                              doc.documentName,
                                                          tenantId:
                                                              doc.tenantId,
                                                          files: files,
                                                        );
                                                    if (mounted) {
                                                      goRouter.pop();
                                                      await _loadDocuments();
                                                    }
                                                  },
                                                  deleteDocument: (
                                                    removeUrl,
                                                  ) async {
                                                    final files =
                                                        MultiFilePickerModel(
                                                          fileNameList: [],
                                                          fileBytesList: [],
                                                          deletedFileList:
                                                              removeUrl,
                                                        );
                                                    await _tenantCubit
                                                        .updateTenantDocument(
                                                          context: context,
                                                          tenantDocumentId:
                                                              doc.tenantDocumentId,
                                                          uniqueKey:
                                                              doc.uniquekey,
                                                          projectId:
                                                              doc.projectId,
                                                          buildingId:
                                                              doc.buildingId,
                                                          documentName:
                                                              doc.documentName,
                                                          tenantId:
                                                              doc.tenantId,
                                                          files: files,
                                                        );
                                                    if (mounted) {
                                                      goRouter.pop();
                                                      await _loadDocuments();
                                                    }
                                                  },
                                                ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_red_eye,
                                          size: 16,
                                          color:
                                              isFresh
                                                  ? AppColor.grey
                                                  : AppColor.primary,
                                        ),
                                        backgroundColor:
                                            isFresh
                                                ? AppColor.lightGrey
                                                : AppColor.lightBlue,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
