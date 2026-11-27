import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/project_setup_status.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_chip_for_status_widget.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AddMaterialRequisitionScreen extends StatefulWidget {
  final MaterialRequisitionModel? materialRequisitionModel;
  final int? index;

  const AddMaterialRequisitionScreen({
    super.key,
    required this.materialRequisitionModel,
    required this.index,
  });

  @override
  State<AddMaterialRequisitionScreen> createState() =>
      _AddMaterialRequisitionScreenState();
}

class _AddMaterialRequisitionScreenState
    extends State<AddMaterialRequisitionScreen> {
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late TextEditingController _remarkC;
  final ValueNotifier<Map<String, dynamic>?> _selectedProject = ValueNotifier(
    null,
  );
  final ValueNotifier<ProjectSetupStatusModel?> _projectSetupStatus =
      ValueNotifier(null);
  //EDIT MODE
  bool get _isEditMode => widget.materialRequisitionModel != null;

  MultiFilePickerModel selectedDocuments = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int get _projectId =>
      _selectedProject.value?['zAttributesId'] ??
      widget.materialRequisitionModel?.projectId ??
      0;
  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _remarkC = TextEditingController();
    _prefill();
  }

  void _prefill() {
    if (!_isEditMode) return;
    final model = widget.materialRequisitionModel!;

    _selectedProject.value = projectList.firstWhere(
      (e) => e['zAttributesId'] == model.projectId,
      orElse: () => {'zAttributesId': model.projectId, 'DisplayName': ''},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _projectSetupStatus.value = await _materialRequisitionCubit
          .fetchProjectSetupStatus(
            context: context,
            projectId: model.projectId,
          );
    });
    selectedDocuments.fileNameList =
        model.attachmentsURL.isNotEmpty ? model.attachmentsURL.split(',') : [];
    _materialRequisitionCubit.initializeMaterialList(
      model.materialRequisitionDetailData,
    );
    _remarkC.text = model.remarks;
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_materialRequisitionCubit.state.materialList.isEmpty) {
      showErrorMessage(context, 'Error', "At least one material is required");

      return;
    }

    if (_isEditMode) {
      _materialRequisitionCubit.updateMaterialRequisition(
        materialRequisitionId:
            widget.materialRequisitionModel!.materialRequisitionId,
        uniqueKey: widget.materialRequisitionModel!.uniquekey,
        index: widget.index!,
        attachments: selectedDocuments,
        context: context,
        materialRequisitionDetailJSON:
            _materialRequisitionCubit.state.materialList,
        projectId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .projectId,
        remarks: _remarkC.text.trim(),
      );
    } else {
      _materialRequisitionCubit.addMaterialRequisition(
        attachments: selectedDocuments,
        context: context,
        materialRequisitionDetailJSON:
            _materialRequisitionCubit.state.materialList,
        projectId: _projectId,
        remarks: _remarkC.text.trim(),
      );
    }
  }

  Future<void> _showPopupToDeleteMaterial(
    BuildContext context,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a material?',
      'Deleting this material will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _materialRequisitionCubit.deleteMaterial(index);
    }
  }

  @override
  void dispose() {
    _remarkC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_selectedProject, _projectSetupStatus]),
        builder: (context, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode
                        ? "Update Material Requisition"
                        : "Add Material Requisition",
                    style: AppTextStyle.ts14M(),
                  ),
                  verticalSpacing(),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: commonCardDecoration(),
                    child: CustomDropDownWidget(
                      dataList: projectList,
                      title: "Project",
                      initialValue: _selectedProject.value,
                      hintText: "Select Project",
                      onSelected: (value) async {
                        if (_selectedProject.value?['zAttributesId'] ==
                            value['zAttributesId']) {
                          return;
                        }
                        _selectedProject.value = value;
                        _projectSetupStatus.value = null;
                        final status = await _materialRequisitionCubit
                            .fetchProjectSetupStatus(
                              context: context,
                              projectId: value['zAttributesId'],
                            );
                        if (_selectedProject.value?['zAttributesId'] ==
                            value['zAttributesId']) {
                          _projectSetupStatus.value = status;
                        }
                      },
                      isRequired: true,
                      validator: (value) {
                        if (value == null) {
                          return "Project is required.";
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_selectedProject.value != null &&
                      (_projectSetupStatus.value?.isAllComplete ?? false)) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(),
                        BlocBuilder<
                          MaterialRequisitionCubit,
                          MaterialRequisitionState
                        >(
                          builder: (context, state) {
                            return Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: commonCardDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Material Details",
                                        style: AppTextStyle.ts14M(
                                          color: AppColor.black,
                                        ),
                                      ),
                                      CustomButton(
                                        text: "Add",
                                        onPressed: () async {
                                          await goRouter.pushNamed(
                                            AppRoutes.addMaterial,
                                            queryParameters: {
                                              'projectId':
                                                  _projectId.toString(),
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  if (state.materialList.isNotEmpty)
                                    SizedBox(
                                      height:
                                          state.materialList.length > 1
                                              ? 350.h
                                              : 250.h,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: state.materialList.length,
                                        itemBuilder: (context, index) {
                                          final material =
                                              state.materialList[index];
                                          return infoCard(
                                            bgColor: AppColor.white,
                                            borderColor: AppColor.primary,
                                            titleWidget: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildColumnTitleValue(
                                                  title: "Material Name",
                                                  value: material.materialName,
                                                  titleTextStyle:
                                                      AppTextStyle.ts12M(
                                                        color: AppColor.grey,
                                                      ),
                                                ),
                                                Row(
                                                  spacing: 10.w,
                                                  children: [
                                                    CustomIconButton.edit(
                                                      onPressed: () async {
                                                        goRouter.pushNamed(
                                                          AppRoutes.addMaterial,
                                                          queryParameters: {
                                                            "material": Uri.encodeQueryComponent(
                                                              EncryptionManager.encryptData(
                                                                jsonEncode(
                                                                  material
                                                                      .toJson(),
                                                                ),
                                                              ),
                                                            ),
                                                            'index':
                                                                index
                                                                    .toString(),
                                                            'projectId':
                                                                _projectId
                                                                    .toString(),
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    CustomIconButton.delete(
                                                      onPressed: () {
                                                        _showPopupToDeleteMaterial(
                                                          context,
                                                          index,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            [
                                              {
                                                "title": "Sub Material Name",
                                                "value":
                                                    material.subMaterialName,
                                              },
                                              {
                                                "title": "UOM",
                                                "value": material.uomCode,
                                              },
                                              {
                                                "title": "Quantity",
                                                "value":
                                                    material.materialQuantity
                                                        .addCommas(),
                                              },
                                              {
                                                "title": "Required Date",
                                                "value":
                                                    formatDateTimeAsDDMMMYYYY(
                                                      material.requiredDate,
                                                    ),
                                              },
                                              {
                                                "title": "Remark",
                                                "value": material.remark,
                                              },
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        verticalSpacing(),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: commonCardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Document Details",
                                style: AppTextStyle.ts14M(
                                  color: AppColor.black,
                                ),
                              ),

                              verticalSpacing(),

                              CustomMultiFilePicker(
                                title: "Document",
                                isRequired: true,
                                filePickType: FilePickType.both,
                                initialFileList: selectedDocuments.fileNameList,

                                onFilePickedCallback: (
                                  bytesList,
                                  fileNameList,
                                ) {
                                  selectedDocuments.fileNameList = fileNameList;
                                  selectedDocuments.fileBytesList = bytesList;
                                },

                                onFileDeleteCallback: (
                                  fileBytesList,
                                  fileNameList,
                                  deletedFile,
                                ) {
                                  selectedDocuments.fileNameList = fileNameList;
                                  selectedDocuments.fileBytesList =
                                      fileBytesList;
                                  selectedDocuments.deletedFileList =
                                      deletedFile;
                                },
                                validator: (fileList) {
                                  if (fileList == null || fileList.isEmpty) {
                                    return "Document is required.";
                                  }
                                  return null;
                                },
                              ),

                              verticalSpacing(),

                              /// Remark
                              CustomTextField(
                                title: "Remark",
                                hint: "Enter Remark",
                                textController: _remarkC,
                                minLines: 3,
                                maxLines: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (_projectSetupStatus.value != null &&
                      _projectSetupStatus.value?.isAllComplete == false) ...[
                    verticalSpacing(),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: commonCardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10.h,
                        children: [
                          Text(
                            'Project Setup Status',
                            style: AppTextStyle.ts14M(color: AppColor.grey),
                          ),
                          _setupItem(
                            'Company is linked to the project',
                            _projectSetupStatus.value?.isCompanyId ?? false,
                          ),
                          _setupItem(
                            'GST details are entered',
                            _projectSetupStatus.value?.isGstNumber ?? false,
                          ),
                          _setupItem(
                            'Bank account details are configured',
                            _projectSetupStatus.value?.isBank ?? false,
                          ),
                          _setupItem(
                            'Approval workflow is set up',
                            _projectSetupStatus.value?.isApproval ?? false,
                          ),
                          _contactHodBanner(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: Listenable.merge([_selectedProject, _projectSetupStatus]),
        builder: (context, child) {
          final showCancel =
              _selectedProject.value == null ||
              _projectSetupStatus.value?.isAllComplete == false;
          return SafeArea(
            child: Container(
              height: 70,
              padding: EdgeInsets.all(16),
              color: AppColor.white,
              child: CustomButton(
                backgroundColor:
                    showCancel ? AppColor.grey30 : AppColor.primary,
                text: showCancel ? "Cancel" : "Save",
                textColor: showCancel ? AppColor.grey : AppColor.white,
                onPressed: showCancel ? () => goRouter.pop() : _saveForm,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _setupItem(String title, bool status) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border.all(color: AppColor.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: AppTextStyle.ts14M())),
          SizedBox(width: 8.w),
          _status(status: status),
        ],
      ),
    );
  }

  Widget _contactHodBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        border: Border.all(color: const Color(0xFFBFD7FF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please contact your HOD to complete the Project Setup first.',
            style: AppTextStyle.ts14M(color: AppColor.darkBlue),
          ),
          SizedBox(height: 4.h),
          Text(
            'Once all pending setup activities are completed, you can add the Material Requisition.',
            style: AppTextStyle.ts14R(
              color: AppColor.darkBlue.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _status({required bool status}) {
    switch (status) {
      case true:
        return statusChip(
          'Completed',
          AppColor.green20.withValues(alpha: 0.1),
          AppColor.green,
          leading: Icon(
            LucideIcons.circleCheck,
            color: AppColor.green,
            size: 16,
          ),
        );

      case false:
        return statusChip(
          'Pending',
          AppColor.lightRed,
          AppColor.red,
          leading: Icon(LucideIcons.clock, color: AppColor.red, size: 16),
        );
    }
  }
}
