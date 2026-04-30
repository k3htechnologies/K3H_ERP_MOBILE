import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/file_picker.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/model/grn.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_multi_file_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

import '../../../material_requisition/presentation/cubit/material_requisition_cubit.dart';

class AddGrnScreen extends StatefulWidget {
  final GRNModel? grnModel;
  final int? index;

  const AddGrnScreen({super.key, required this.grnModel, required this.index});

  @override
  State<AddGrnScreen> createState() => _AddGrnScreenState();
}

class _AddGrnScreenState extends State<AddGrnScreen> {
  // CUBIT
  late GrnCubit _grnCubit;
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late TextEditingController _challanNumberC, _vehicleNumberC, _remarkC;
  //EDIT MODE
  bool get _isEditMode => widget.grnModel != null;

  MultiFilePickerModel selectedDocuments = MultiFilePickerModel(
    fileBytesList: [],
    fileNameList: [],
    deletedFileList: "",
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _grnCubit = context.read<GrnCubit>();
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _challanNumberC = TextEditingController();
    _vehicleNumberC = TextEditingController();
    _remarkC = TextEditingController();
    _prefill();
  }

  void _prefill() {
    if (!_isEditMode) return;
    selectedDocuments.fileNameList =
        widget.grnModel!.uploadChallanUrl.isNotEmpty
            ? widget.grnModel!.uploadChallanUrl.split(',')
            : [];
    _grnCubit.initializeMaterialList(
      widget.grnModel!.materialRequisitionDetailGrnData,
    );
    _remarkC.text = widget.grnModel!.remarks;
    _challanNumberC.text = widget.grnModel!.challanNumber;
    _vehicleNumberC.text = widget.grnModel!.vehicleNumber;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_grnCubit.state.materialList.isEmpty) {
      showErrorMessage(context, 'Error', "At least one material is required");

      return;
    }

    if (_isEditMode) {
      _grnCubit.updateGRN(
        context: context,
        projectId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .projectId,
        materialRequisitionId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .materialRequisitionId,
        materialRequisitionGRNId: widget.grnModel!.materialRequisitionGrnId,
        materialRequisitionDetailGRNJSON: _grnCubit.state.materialList,
        challanNumber: _challanNumberC.text.trim(),
        vehicleNumber: _vehicleNumberC.text.trim(),
        remark: _remarkC.text.trim(),
        challan: selectedDocuments,
        materialRequisitonUniqueKey:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .uniquekey,
        index: widget.index!,
        uniquekey: widget.grnModel!.uniquekey,
      );
    } else {
      _grnCubit.addGRN(
        context: context,
        projectId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .projectId,
        materialRequisitionId:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .materialRequisitionId,
        materialRequisitionDetailGRNJSON: _grnCubit.state.materialList,
        challanNumber: _challanNumberC.text.trim(),
        vehicleNumber: _vehicleNumberC.text.trim(),
        remark: _remarkC.text.trim(),
        challan: selectedDocuments,
        materialRequisitonUniqueKey:
            _materialRequisitionCubit
                .state
                .materialRequisitionOverview!
                .uniquekey,
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
      _grnCubit.deleteMaterial(index);
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
        screenTitle: "Goods Receipt Note",
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
                _isEditMode ? "Update GRN Details" : "Add GRN Details",
                style: AppTextStyle.ts14M(),
              ),
              verticalSpacing(),
              BlocBuilder<GrnCubit, GrnState>(
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
                                await goRouter.pushNamed(
                                  AppRoutes.addGrnMaterial,
                                );
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
                                                AppRoutes.addGrnMaterial,
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
                                            isDisabled: _isEditMode,
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
                                      "title": "Total Quantity",
                                      "value": addCommasToInteger(
                                        material.materialQuantity,
                                        withoutSign: true,
                                      ),
                                    },
                                    {
                                      "title": "Received Quantity",
                                      "value": addCommasToInteger(
                                        material.totalReceivedMaterialQuantity,
                                        withoutSign: true,
                                      ),
                                    },
                                    {
                                      "title": "Quality Analyst Remark",
                                      "value": material.qualityAnalysisRemarks,
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

                    CustomTextField(
                      title: "Challan Number",
                      hint: "Enter Challan Number",
                      isRequired: true,
                      textController: _challanNumberC,
                      inputFormatterList:
                          InputValidator.challanInputFormatters(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Challan Number is required";
                        }

                        if (value.isNotEmpty) {
                          if (!InputValidator.isValidChallan(value)) {
                            return "Challan Number is invalid";
                          }
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Vehicle Number",
                      hint: "Enter Vehicle Number",
                      textController: _vehicleNumberC,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vehicle Number is required";
                        }

                        return null;
                      },
                    ),

                    CustomMultiFilePicker(
                      title: "Challan",
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
                          return "Challan Document is required";
                        }
                        return null;
                      },
                    ),

                    /// Remark
                    CustomTextField(
                      title: "Remark",
                      hint: "Enter Remark",
                      isRequired: true,
                      textController: _remarkC,
                      maxLines: 3,
                      minLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Remark is required";
                        }

                        return null;
                      },
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
