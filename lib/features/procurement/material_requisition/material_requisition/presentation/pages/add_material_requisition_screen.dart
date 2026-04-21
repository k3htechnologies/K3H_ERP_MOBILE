import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/model/material_requisition.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class AddMaterialRequisitionScreen extends StatefulWidget {
  final MaterialRequisitionModel? materialRequisitionModel;
  final int index;

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
  final TextEditingController _remarkC = TextEditingController();

  MultiFilePickerModel selectedDocuments = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  //EDIT MODE
  bool get _isEditMode => widget.materialRequisitionModel != null;

  void _save() {}

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
      body: Padding(
        padding: EdgeInsets.all(16.w),
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
                          await goRouter.pushNamed(
                            AppRoutes.addMaterial,
                            // queryParameters: {
                            //   if (widget.materialRequisitionModel != null)
                            //     "materialRequisition": Uri.encodeQueryComponent(
                            //       EncryptionManager.encryptData(
                            //         jsonEncode(
                            //           widget.materialRequisitionModel!.materialRequisitionDetailData.toJson(),
                            //         ),
                            //       ),
                            //     ),
                            //   if (widget.materialRequisitionModel != null)
                            //     'index': widget.index.toString(),
                            // },
                          );
                        },
                      ),
                    ],
                  ),
                  infoCard(
                    bgColor: AppColor.white,
                    borderColor: AppColor.primary,
                    [
                      {"title": "Hi", "value": "1232"},
                      {"title": "Hi", "value": "1232"},
                    ],
                  ),
                ],
              ),
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
                    validator: (v) {
                      if (v == null) {
                        return "Challan document is required";
                      }
                    },
                  ),

                  verticalSpacing(),

                  /// Remark
                  CustomTextField(
                    title: "Remark",
                    hint: "Enter Remark",
                    textController: _remarkC,
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: CustomButton(text: "Save", onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }
}
