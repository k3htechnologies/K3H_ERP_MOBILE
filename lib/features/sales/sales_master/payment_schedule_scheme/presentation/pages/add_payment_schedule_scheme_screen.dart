import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/data/model/payment_schedule_scheme.model.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_state.dart';
import 'package:k3h_erp_app/features/sales/sales_master/payment_schedule_scheme/presentation/cubit/payment_schedule_scheme_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/functions/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddPaymentScheduleSchemeScreen extends StatefulWidget {
  final PaymentScheduleSchemeModel? paymentScheduleSchemeModel;
  final int? index;

  const AddPaymentScheduleSchemeScreen({
    super.key,
    this.paymentScheduleSchemeModel,
    this.index,
  });

  @override
  State<AddPaymentScheduleSchemeScreen> createState() =>
      _AddPaymentScheduleSchemeScreenState();
}

class _AddPaymentScheduleSchemeScreenState
    extends State<AddPaymentScheduleSchemeScreen> {
  late PaymentScheduleSchemeCubit _schemeCubit;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _schemeNameC;

  bool get isEditMode => widget.paymentScheduleSchemeModel != null;

  int? _selectedBuildingId;
  int? _selectedWingId;

  @override
  void initState() {
    super.initState();

    _schemeCubit = context.read<PaymentScheduleSchemeCubit>();
    _schemeNameC = TextEditingController();

    _schemeCubit.getProjectInventoryStructure(
      context,
      1,
      getProject().projectId,
    );

    if (isEditMode) {
      final model = widget.paymentScheduleSchemeModel!;
      _schemeNameC.text = model.paymentScheduleSchemeName;
      _selectedBuildingId = model.inventoryBuildingId;
      _selectedWingId = model.inventoryFlatFloorBasementPodiumWingId;
    }
  }

  @override
  void dispose() {
    _schemeNameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: isEditMode ? "Update Scheme" : "Add Scheme",
        authorization: AuthorizationModel(),
      ),
      body: BlocBuilder<PaymentScheduleSchemeCubit, PaymentScheduleSchemeState>(
        builder: (context, state) {
          /// BUILDING LIST MAP
          final buildingListMap =
              state.buildingList
                  .map(
                    (e) => {
                      "zAttributesId": e.inventoryBuildingId,
                      "DisplayName": e.buildingNumber,
                    },
                  )
                  .toList();

          final selectedBuildingMap = buildingListMap.firstWhereOrNull(
            (e) => e["zAttributesId"] == _selectedBuildingId,
          );

          /// FILTER WINGS LOCALLY
          final filteredWingList =
              state.projectInventoryList
                  .where((e) => e.inventoryBuildingId == _selectedBuildingId)
                  .toList();

          final Map<int, dynamic> uniqueWings = {};

          for (var item in filteredWingList) {
            uniqueWings[item.inventoryFlatFloorBasementPodiumWingId] = item;
          }

          final wingListMap =
              uniqueWings.values
                  .map(
                    (e) => {
                      "zAttributesId": e.inventoryFlatFloorBasementPodiumWingId,
                      "DisplayName": e.wing,
                    },
                  )
                  .toList();

          final selectedWingMap = wingListMap.firstWhereOrNull(
            (e) => e["zAttributesId"] == _selectedWingId,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ---------------- BUILDING DROPDOWN ----------------
                    CustomDropDownWidget(
                      title: "Select Building",
                      isRequired: true,
                      isDisabled:
                          (widget.paymentScheduleSchemeModel != null &&
                              widget
                                  .paymentScheduleSchemeModel!
                                  .isExistsPaymentScheduleScheme),
                      dataList: buildingListMap,
                      initialValue: selectedBuildingMap,
                      onSelected: (value) {
                        setState(() {
                          _selectedBuildingId = value["zAttributesId"];
                          _selectedWingId = null; // reset wing
                        });
                      },
                      validator:
                          (value) =>
                              selectedBuildingMap == null
                                  ? "Building is required"
                                  : null,
                      onValueClear: () {
                        _selectedBuildingId = null;
                        _selectedWingId = null;
                      },
                    ),

                    /// ---------------- WING DROPDOWN ----------------
                    CustomDropDownWidget(
                      title: "Select Wing",
                      isRequired: true,
                      isDisabled:
                          (widget.paymentScheduleSchemeModel != null &&
                              widget
                                  .paymentScheduleSchemeModel!
                                  .isExistsPaymentScheduleScheme),
                      dataList: wingListMap,
                      initialValue: selectedWingMap,
                      onSelected: (value) {
                        setState(() {
                          _selectedWingId = value["zAttributesId"];
                        });
                      },
                      validator:
                          (value) =>
                              selectedWingMap == null
                                  ? "Wing is required"
                                  : null,
                      onValueClear: () {
                        _selectedWingId = null;
                      },
                    ),

                    /// ---------------- SCHEME NAME ----------------
                    CustomTextField(
                      title: "Scheme",
                      hint: "Enter Scheme",
                      isRequired: true,
                      textController: _schemeNameC,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Scheme name is required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      /// ---------------- SAVE BUTTON ----------------
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: isEditMode ? "Update" : "Add",
            onPressed: _saveForm,
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (isEditMode) {
        _schemeCubit.updatePaymentScheduleScheme(
          paymentScheduleSchemeId:
              widget.paymentScheduleSchemeModel!.paymentScheduleSchemeMasterId,
          uniqueKey: widget.paymentScheduleSchemeModel!.uniquekey,
          context: context,
          schemeName: _schemeNameC.text.trim(),
          buildingId: _selectedBuildingId!,
          wingId: _selectedWingId!,
          index: widget.index!,
        );
      } else {
        _schemeCubit.addPaymentScheduleScheme(
          context: context,
          projectId: getProject().projectId,
          schemeName: _schemeNameC.text.trim(),
          orderBy: 1,
          buildingId: _selectedBuildingId!,
          wingId: _selectedWingId!,
        );
      }
    }
  }
}
