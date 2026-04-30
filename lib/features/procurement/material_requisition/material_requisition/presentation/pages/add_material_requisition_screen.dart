import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
  // CUBIT
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late TextEditingController _remarkC;
  //EDIT MODE
  bool get _isEditMode => widget.materialRequisitionModel != null;

  MultiFilePickerModel selectedDocuments = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _remarkC = TextEditingController();
    _prefill();
  }

  void _prefill() {
    if (!_isEditMode) return;
    selectedDocuments.fileNameList =
        widget.materialRequisitionModel!.attachmentsURL.isNotEmpty
            ? widget.materialRequisitionModel!.attachmentsURL.split(',')
            : [];
    _materialRequisitionCubit.initializeMaterialList(
      widget.materialRequisitionModel!.materialRequisitionDetailData,
    );
    _remarkC.text = widget.materialRequisitionModel!.remarks;
  }

  void _save() {
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
        projectId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .projectId,
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
      body: SingleChildScrollView(
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
              BlocBuilder<MaterialRequisitionCubit, MaterialRequisitionState>(
                builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: commonCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Material Details",
                              style: AppTextStyle.ts14M(color: AppColor.black),
                            ),
                            CustomButton(
                              text: "Add Material",
                              onPressed: () async {
                                await goRouter.pushNamed(AppRoutes.addMaterial);
                              },
                            ),
                          ],
                        ),

                        if (state.materialList.isNotEmpty)
                          SizedBox(
                            height:
                                state.materialList.length > 1 ? 350.h : 250.h,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.materialList.length,
                              itemBuilder: (context, index) {
                                final material = state.materialList[index];
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
                                      ),
                                      Row(
                                        spacing: 10.w,
                                        children: [
                                          CustomIconButton.edit(
                                            onPressed: () async {
                                              goRouter.pushNamed(
                                                AppRoutes.addMaterial,
                                                queryParameters: {
                                                  "material":
                                                      Uri.encodeQueryComponent(
                                                        EncryptionManager.encryptData(
                                                          jsonEncode(
                                                            material.toJson(),
                                                          ),
                                                        ),
                                                      ),
                                                  'index': index.toString(),
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
                                      "value": material.subMaterialName,
                                    },
                                    {"title": "UOM", "value": material.uomCode},
                                    {
                                      "title": "Quantity",
                                      "value": addCommasToInteger(
                                        material.materialQuantity,
                                        withoutSign: true,
                                      ),
                                    },
                                    {
                                      "title": "Required Date",
                                      "value": formatDateTimeAsDDMMMYYYY(
                                        material.requiredDate,
                                      ),
                                    },
                                    {
                                      "title": "Remark",
                                      "value": material.remarks,
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
                      style: AppTextStyle.ts14M(color: AppColor.black),
                    ),

                    verticalSpacing(),

                    CustomMultiFilePicker(
                      title: "Document",
                      isRequired: true,
                      filePickType: FilePickType.both,
                      initialFileList: selectedDocuments.fileNameList,

                      onFilePickedCallback: (bytesList, fileNameList) {
                        selectedDocuments.fileNameList = fileNameList;
                        selectedDocuments.fileBytesList = bytesList;
                      },

                      onFileDeleteCallback: (
                        fileBytesList,
                        fileNameList,
                        deletedFile,
                      ) {
                        selectedDocuments.fileNameList = fileNameList;
                        selectedDocuments.fileBytesList = fileBytesList;
                        selectedDocuments.deletedFileList = deletedFile;
                      },
                      validator: (fileList) {
                        if (fileList == null || fileList.isEmpty) {
                          return "Document is required";
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
                      maxLines: 3,
                      minLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          color: AppColor.white,
          child: CustomButton(text: "Save", onPressed: _save),
        ),
      ),
    );
  }
}
