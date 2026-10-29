import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/building_summary.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area.model.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/presentation/cubit/construction_area_cubit.dart';

import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class WingSection extends StatefulWidget {
  final WingGroup wing;
  final bool initiallyExpanded;
  const WingSection({
    super.key,
    required this.wing,
    this.initiallyExpanded = false,
  });

  @override
  State<WingSection> createState() => _WingSectionState();
}

class _WingSectionState extends State<WingSection> {
  late final ValueNotifier<bool> _expanded = ValueNotifier(
    widget.initiallyExpanded,
  );

  @override
  Widget build(BuildContext context) {
    final wing = widget.wing;

    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      color: AppColor.lightBluebg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _expanded.value = !_expanded.value,
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: Row(
                children: [
                  Expanded(child: _label("WING", wing.wing)),
                  Expanded(child: _label("UNIT", wing.flats.length.toString())),
                  ValueListenableBuilder<bool>(
                    valueListenable: _expanded,
                    builder:
                        (_, open, __) => Icon(
                          open
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20.sp,
                          color: AppColor.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1.sp, color: AppColor.dividerColor),
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Expanded(
                  child: _info(
                    "FTF Height (Mt)",
                    _fmt(wing.ftfHeight, zero: "0"),
                  ),
                ),
                Expanded(
                  child: _info(
                    "Cumulative Height (Mt)",
                    _fmt(wing.cumulativeHeight, zero: "0"),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _expanded,
            builder: (_, open, __) {
              if (!open) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.fromLTRB(12.sp, 0, 12.sp, 12.sp),
                child: Column(
                  children: [
                    for (int i = 0; i < wing.flats.length; i++)
                      UnitCard(index: i + 1, flat: wing.flats[i]),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyle.ts12M(color: AppColor.primary)),
      Text(value, style: AppTextStyle.ts14M()),
    ],
  );
}

class UnitCard extends StatefulWidget {
  final int index;
  final ConstructionAreaModel flat;
  const UnitCard({super.key, required this.index, required this.flat});

  @override
  State<UnitCard> createState() => UnitCardState();
}

class UnitCardState extends State<UnitCard> {
  late final ConstructionAreaCubit _cubit;
  late final TextEditingController _areaC, _multiplierC, _heightC, _remarkC;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ConstructionAreaCubit>();
    _areaC = TextEditingController();
    _multiplierC = TextEditingController();
    _heightC = TextEditingController();
    _remarkC = TextEditingController();
  }

  @override
  void dispose() {
    _areaC.dispose();
    _multiplierC.dispose();
    _heightC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  Future<void> _showUpdateSheet() async {
    final f = widget.flat;
    final formKey = GlobalKey<FormState>();
    String text(double v) =>
        v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
    _areaC.text = text(f.areaByPlLineSqMt);
    _multiplierC.text = text(f.multiplierForAreaPercentage);
    _heightC.text =
        f.floorToFloorHeightMt == 0 ? "" : text(f.floorToFloorHeightMt);
    _remarkC.text = f.remark;
    await DialogHelper.showCustomBottomSheet(
      context,
      "Update Construction Area",
      contentWidget: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                style: AppTextStyle.ts12M(color: AppColor.grey),
                children: [
                  const TextSpan(text: "Unit No : "),
                  TextSpan(text: f.flat),
                ],
              ),
            ),
            infoCard([
              {"title": "Building Number", "value": f.buildingNumber},
              {"title": "Wing", "value": f.wing},
              {"title": "Floor", "value": f.floor},
              {"title": "Unit Type", "value": f.flatType},
              {"title": "Unit Configuration", "value": f.flatConfiguration},
              {"title": "Unit", "value": f.flat},
            ]),
            verticalSpacing(),
            CustomTextField(
              textController: _areaC,
              isRequired: true,
              title: "Area By PL Line (SqMt)",
              hint: "Enter Area By PL Line",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatterList: InputValidator.digitWithDecimal(
                maxDigitsBeforeDecimal: 16,
              ),
              validator: (v) {
                final n = double.tryParse(v ?? "");
                return (n == null || n <= 0)
                    ? "Area By PL Line is required"
                    : null;
              },
            ),
            CustomTextField(
              textController: _multiplierC,
              isRequired: true,
              title: "Multiplier For Area (%)",
              hint: "Enter Multiplier For Area",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatterList: InputValidator.digitWithDecimal(
                maxDigitsBeforeDecimal: 3,
              ),
              validator: (v) {
                final n = double.tryParse(v ?? "");
                if (n == null || n <= 0) {
                  return "Multiplier For Area is required";
                }
                if (n > 100) return "Enter a valid percentage";
                return null;
              },
            ),
            CustomTextField(
              textController: _heightC,
              title: "Height (Mt)",
              hint: "Enter Height",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatterList: InputValidator.digitWithDecimal(
                maxDigitsBeforeDecimal: 6,
              ),
            ),
            CustomTextField(
              textController: _remarkC,
              title: "Remark",
              hint: "Enter Remark",
              minLines: 3,
              maxLines: 10,
            ),
          ],
        ),
      ),
      bottomActions: CustomButton(
        leading: Icon(Icons.edit, color: AppColor.white, size: 18),
        text: "Update",
        onPressed: () async {
          if (!formKey.currentState!.validate()) return;

          await _cubit.updateConstructionArea(
            context: context,
            constructionAreaId: f.constructionAreaId,
            uniquekey:
                f.uniqueKey.isEmpty
                    ? "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                    : f.uniqueKey,
            projectId: f.projectId,
            areaByPLLineSqMt: double.parse(_areaC.text),
            floorToFloorHeightMt: double.tryParse(_heightC.text) ?? 0,
            inventoryFlatId: f.inventoryFlatId,
            multiplierForAreaPercentage: double.parse(_multiplierC.text),
            remark: _remarkC.text.trim(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flat;
    final modifiedBy = f.modifiedBy.isNotEmpty ? f.modifiedBy : f.createdBy;
    final modifiedDate = f.modifiedDate ?? f.createdDate;

    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10.sp),
        border: Border.all(color: AppColor.grey10),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "UNIT ${widget.index.toString().padLeft(2, '0')}",
                        style: AppTextStyle.ts12M(color: AppColor.primary),
                      ),
                      Text(f.flat, style: AppTextStyle.ts14SB()),
                    ],
                  ),
                ),
                CustomIconButton.edit(onPressed: _showUpdateSheet),
              ],
            ),
          ),
          _divider(),
          _row(
            _info("Unit Type", f.flatType),
            _info("Configuration", f.flatConfiguration, chip: true),
          ),
          _divider(),
          _row(
            _info("Area by PL Line (SqMt)", _fmt(f.areaByPlLineSqMt)),
            _info("Multiplier (%)", _fmt(f.multiplierForAreaPercentage)),
          ),
          _divider(),
          _row(
            _info("Total Area (SqMt)", _fmt(f.totalAreaSqMt)),
            _info("Total Area (SqFt)", _fmt(f.totalAreaSqFt)),
          ),
          _divider(),
          _row(_info("Remarks", f.remark.isEmpty ? "—" : f.remark), null),
          _divider(),
          _row(
            _info("Last Modified By", modifiedBy.isEmpty ? "—" : modifiedBy),
            _info(
              "Last Modified Date",
              DateFormat('dd MMM yy').format(modifiedDate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Widget left, Widget? right) => Padding(
    padding: EdgeInsets.all(12.sp),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        Expanded(child: right ?? const SizedBox.shrink()),
      ],
    ),
  );

  Widget _divider() =>
      Divider(height: 1, thickness: 1.sp, color: AppColor.dividerColor);
}

class UpdateConstructionAreaForm extends StatefulWidget {
  final ConstructionAreaModel flat;
  final ConstructionAreaCubit cubit;
  const UpdateConstructionAreaForm({
    super.key,
    required this.flat,
    required this.cubit,
  });

  @override
  State<UpdateConstructionAreaForm> createState() =>
      _UpdateConstructionAreaFormState();
}

class _UpdateConstructionAreaFormState
    extends State<UpdateConstructionAreaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _areaC, _multiplierC, _heightC, _remarkC;

  // 0 -> "" so the hint shows; 1000.0 -> "1000"
  String _text(double v) =>
      v == 0
          ? ""
          : (v == v.truncateToDouble() ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    final f = widget.flat;
    _areaC = TextEditingController(text: _text(f.areaByPlLineSqMt));
    _multiplierC = TextEditingController(
      text: _text(f.multiplierForAreaPercentage),
    );
    _heightC = TextEditingController(text: _text(f.floorToFloorHeightMt));
    _remarkC = TextEditingController(text: f.remark);
  }

  @override
  void dispose() {
    _areaC.dispose();
    _multiplierC.dispose();
    _heightC.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final constructionArea = widget.flat;
    await widget.cubit.updateConstructionArea(
      context: context,
      constructionAreaId: constructionArea.constructionAreaId,
      uniquekey: constructionArea.uniqueKey,
      projectId: constructionArea.projectId,
      areaByPLLineSqMt: constructionArea.areaByPlLineSqMt,
      floorToFloorHeightMt: constructionArea.floorToFloorHeightMt,
      inventoryFlatId: constructionArea.inventoryFlatId,
      multiplierForAreaPercentage: constructionArea.multiplierForAreaPercentage,
      remark: constructionArea.remark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flat;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyle.ts12M(color: AppColor.grey),
              children: [
                const TextSpan(text: "Unit No : "),
                TextSpan(text: f.flat),
              ],
            ),
          ),
          infoCard([
            {"title": "Building Number", "value": f.buildingNumber},
            {"title": "Wing", "value": f.wing},
            {"title": "Floor", "value": f.floor},
            {"title": "Unit Type", "value": f.flatType},
            {"title": "Unit Configuration", "value": f.flatConfiguration},
            {"title": "Unit", "value": f.flat},
          ]),
          verticalSpacing(),
          CustomTextField(
            title: "Area By PL Line (SqMt)",
            hint: "Enter Area By PL Line",
            isRequired: true,
            textController: _areaC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatterList: InputValidator.digitWithDecimal(
              maxDigitsBeforeDecimal: 16,
            ),
            validator: (v) {
              final n = double.tryParse(v ?? "");
              return (n == null || n <= 0)
                  ? "Area By PL Line is required"
                  : null;
            },
          ),
          CustomTextField(
            title: "Multiplier For Area (%)",
            hint: "Enter Multiplier For Area",
            isRequired: true,
            textController: _multiplierC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatterList: InputValidator.digitWithDecimal(
              maxDigitsBeforeDecimal: 3,
            ),
            validator: (v) {
              final n = double.tryParse(v ?? "");
              if (n == null || n <= 0) return "Multiplier For Area is required";
              if (n > 100) return "Enter a valid percentage";
              return null;
            },
          ),
          CustomTextField(
            title: "Height (Mt)",
            hint: "Enter Height",
            textController: _heightC,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatterList: InputValidator.digitWithDecimal(
              maxDigitsBeforeDecimal: 6,
            ),
          ),
          CustomTextField(
            title: "Remark",
            hint: "Enter Remark",
            minLines: 3,
            maxLines: 10,
            textController: _remarkC,
          ),
          verticalSpacing(),
          CustomButton(
            leading: Icon(Icons.edit, color: AppColor.white, size: 18),
            text: "Update",
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

Widget _info(String title, String value, {bool chip = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyle.ts12R(color: AppColor.grey)),
      SizedBox(height: 4.sp),
      chip && value.isNotEmpty
          ? Container(
            padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 2.sp),
            decoration: BoxDecoration(
              color: AppColor.lightBlue,
              borderRadius: BorderRadius.circular(20.sp),
              border: Border.all(
                color: AppColor.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              value,
              style: AppTextStyle.ts12M(color: AppColor.primary),
            ),
          )
          : Text(value.isEmpty ? "—" : value, style: AppTextStyle.ts14M()),
    ],
  );
}

String _fmt(double v, {String zero = "—"}) =>
    v == 0
        ? zero
        : (v == v.truncateToDouble() ? v.toInt().toString() : v.toString());
