import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

import '../../data/model/material_requisition.model.dart';
import '../cubit/material_requisition_cubit.dart';

class CopyMaterialRequisitionScreen extends StatefulWidget {
  final MaterialRequisitionModel materialRequisitionModel;
  const CopyMaterialRequisitionScreen({
    super.key,
    required this.materialRequisitionModel,
  });

  @override
  State<CopyMaterialRequisitionScreen> createState() =>
      _CopyMaterialRequisitionScreenState();
}

class _CopyMaterialRequisitionScreenState
    extends State<CopyMaterialRequisitionScreen> {
  late MaterialRequisitionCubit _materialRequisitionCubit;
  late List<TextEditingController> _quantityControllers;
  late List<TextEditingController> _remarkControllers;
  late List<DateTime?> _selectedRequiredDates;
  // FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _materialRequisitionCubit = context.read<MaterialRequisitionCubit>();
    _quantityControllers =
        widget.materialRequisitionModel.materialRequisitionDetailData.map((m) {
          return TextEditingController(text: m.materialQuantity.toString());
        }).toList();
    _selectedRequiredDates =
        widget.materialRequisitionModel.materialRequisitionDetailData
            .map((m) => m.requiredDate)
            .toList();
    _remarkControllers =
        widget.materialRequisitionModel.materialRequisitionDetailData.map((m) {
          return TextEditingController(text: m.remark.toString());
        }).toList();
    super.initState();
  }

  Future _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    final finalMaterialRequisition =
        widget.materialRequisitionModel.materialRequisitionDetailData
            .mapIndexed((index, m) {
              return MaterialRequisitionDetailModel(
                materialRequisitionDetailId: m.materialRequisitionDetailId,
                uniquekey: m.uniquekey,
                materialMasterId: m.materialMasterId,
                materialName: m.materialName,
                subMaterialName: m.subMaterialName,
                subMaterialMasterId: m.subMaterialMasterId,
                materialQuantity: double.parse(
                  _quantityControllers[index].text,
                ),
                uomMasterId: m.uomMasterId,
                uomCode: m.uomCode,
                uom: m.uom,
                requiredDate: _selectedRequiredDates[index]!,
                materialReceivedQuantityTillDate: 0,
                remark: _remarkControllers[index].text,
                createdById: 0,
                createdBy: "",
                createdDate: DateTime.now(),
                modifiedById: 0,
                modifiedBy: '',
              );
            })
            .toList();
    await _materialRequisitionCubit.copyMaterialRequisition(
      context: context,
      materialRequisitionId:
          widget.materialRequisitionModel.materialRequisitionId,
      uniqueKey: widget.materialRequisitionModel.uniquekey,
      projectId: widget.materialRequisitionModel.projectId,
      remarks: widget.materialRequisitionModel.remarks,
      materialRequisitionDetailJSON: finalMaterialRequisition,
    );
  }

  @override
  void dispose() {
    for (var c in _quantityControllers) {
      c.dispose();
    }
    for (var r in _remarkControllers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Copy Material Requisition",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                widget.materialRequisitionModel.systemGeneratedCode,
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    widget
                        .materialRequisitionModel
                        .materialRequisitionDetailData
                        .length,
                itemBuilder: (context, index) {
                  final material =
                      widget
                          .materialRequisitionModel
                          .materialRequisitionDetailData[index];

                  return Container(
                    decoration: commonCardDecoration(),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        buildRowTitleValue(
                          title: "Material",
                          value: material.materialName,
                        ),
                        buildRowTitleValue(
                          title: "Sub-Material",
                          value: material.subMaterialName,
                        ),
                        buildRowTitleValue(
                          title: "UOM",
                          value: material.uomCode,
                        ),
                        CustomTextField(
                          textController: _quantityControllers[index],
                          title: "Quantity",
                          isRequired: true,
                          hint: "Enter Quantity",
                          inputFormatterList: InputValidator.decimal(2),
                          keyboardType: TextInputType.numberWithOptions(),
                          validator: (value) {
                            if (value == null || value == "") {
                              return "Quantity is required";
                            }
                            return null;
                          },
                        ),
                        CustomDatePicker(
                          isRequired: true,
                          title: "Required Date",
                          startDate: DateTime.now(),
                          initialDate: _selectedRequiredDates[index],
                          setValue: (DateTime? p1) {
                            _selectedRequiredDates[index] = p1;
                          },
                        ),
                        CustomTextField(
                          textController: _remarkControllers[index],
                          title: "Remark",
                          hint: "Enter Remark",
                          maxLines: 2,
                          minLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Save", onPressed: _saveForm),
        ),
      ),
    );
  }
}
