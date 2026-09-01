import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/features/business_development/proposed_offer/presentation/pages/widgets/proposed_offer_info_card.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/card_header_tile.dart';
import 'package:k3h_erp_app/widgets/checkbox/custom_checkbox.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/section_card.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LienToSocietyDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;
  final ValueChanged<VoidCallback> onSave;
  final AuthorizationModel routeAuthorizationModel;
  const LienToSocietyDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
    required this.onSave,
    required this.routeAuthorizationModel,
  });
  @override
  State<LienToSocietyDetails> createState() => _LienToSocietyDetailsState();
}

class _LienToSocietyDetailsState extends State<LienToSocietyDetails> {
  late ProposedOfferCubit _cubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _residentialAreaC,
      _commercialAreaC,
      _residentialUnitsC,
      _commercialUnitsC,
      _remarkC,
      _stageController,
      _carpetAreaController;
  bool get disableAction => !widget.routeAuthorizationModel.isAction;
  final ValueNotifier<
    List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>
  >
  _lienListNotifier = ValueNotifier<
    List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>
  >([]);
  List<ProposedOfferLienToSocietyDetailsWithPaymentStageData> get _lienList =>
      _lienListNotifier.value;
  final ValueNotifier<Map<String, dynamic>?> _selectedLienType =
      ValueNotifier<Map<String, dynamic>?>(null);
  final ValueNotifier<bool> _isRelease = ValueNotifier<bool>(false);
  final GlobalKey<FormState> _lienFormKey = GlobalKey<FormState>();
  final ValueNotifier<List<Map<String, dynamic>>> _flatLits = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _selectResidentialLienUnits =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _selectCommercialLienUnits =
      ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeTextEditingControllers();
    _loadData();
    widget.onSave(_onSave);
  }

  @override
  void dispose() {
    _residentialAreaC.dispose();
    _commercialAreaC.dispose();
    _residentialUnitsC.dispose();
    _commercialUnitsC.dispose();
    _stageController.dispose();
    _carpetAreaController.dispose();
    _lienListNotifier.dispose();
    _selectedLienType.dispose();
    _isRelease.dispose();
    _remarkC.dispose();
    super.dispose();
  }

  void _loadData() async {
    await _cubit.pullLienToSocietyDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
    var lienDetailsModel = _cubit.state.lienToSocietyDetails;
    if (lienDetailsModel == null) return;
    if (lienDetailsModel.commercialInventoryFlatId.isNotEmpty) {
      final commercialIds =
          lienDetailsModel.commercialInventoryFlatId
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toSet();
      _selectCommercialLienUnits.value =
          _flatLits.value
              .where((e) => commercialIds.contains(e['zAttributesId']))
              .toList();
    }
    if (lienDetailsModel.residentialInventoryFlatId.isNotEmpty) {
      final residentialIds =
          lienDetailsModel.residentialInventoryFlatId
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toSet();
      _selectResidentialLienUnits.value =
          _flatLits.value
              .where((e) => residentialIds.contains(e['zAttributesId']))
              .toList();
    }
  }

  void _initializeTextEditingControllers() {
    _residentialAreaC = TextEditingController();
    _commercialAreaC = TextEditingController();
    _residentialUnitsC = TextEditingController();
    _commercialUnitsC = TextEditingController();
    _stageController = TextEditingController();
    _carpetAreaController = TextEditingController();
    _remarkC = TextEditingController();
  }

  void _updateLienUnitCounts() {
    final residentialCount =
        _lienList
            .where((item) => item.type.toLowerCase() == 'residential')
            .length;
    final commercialCount =
        _lienList
            .where((item) => item.type.toLowerCase() == 'commercial')
            .length;
    _residentialUnitsC.text = residentialCount.toString();
    _commercialUnitsC.text = commercialCount.toString();
  }

  void _populateFormFields() async {
    var lienDetailsModel = _cubit.state.lienToSocietyDetails!;
    _residentialAreaC.text = lienDetailsModel.residentialAreaSqFt.toString();
    _commercialAreaC.text = lienDetailsModel.commercialAreaSqFt.toString();
    if (lienDetailsModel.numberOfResidentialLienUnits > 0) {
      _residentialUnitsC.text =
          lienDetailsModel.numberOfResidentialLienUnits.toString();
    }
    if (lienDetailsModel.numberOfCommercialLienUnits > 0) {
      _commercialUnitsC.text =
          lienDetailsModel.numberOfCommercialLienUnits.toString();
    }
    _lienListNotifier.value = List.from(
      lienDetailsModel.proposedOfferLienToSocietyDetailsWithPaymentStageData,
    );
    _remarkC.text = lienDetailsModel.remark;
    if (lienDetailsModel.residentialInventoryFlatId.toString().isNotEmpty) {
      _selectResidentialLienUnits.value = await _cubit
          .fetchResidentialUnitsById(
            flatIds: lienDetailsModel.residentialInventoryFlatId,
          );
    }
    if (lienDetailsModel.commercialInventoryFlatId.toString().isNotEmpty) {
      _selectCommercialLienUnits.value = await _cubit.fetchCommercialUnitsById(
        flatIds: lienDetailsModel.commercialInventoryFlatId,
      );
    }
    _cubit.closeLienToSocietyLoader();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_lienList.isEmpty) {
        showErrorMessage(
          context,
          'Error',
          'Please add at least one lien detail.',
        );
        return;
      }
      _cubit.addUpdateLienToSocietyDetails(
        context,
        buildingId: widget.buildingId,
        projectId: widget.projectId,
        residentialAreaSqFt: double.parse(_residentialAreaC.text),
        commercialAreaSqFt: double.parse(_commercialAreaC.text),
        numberOfResidentialLienUnits:
            int.tryParse(_residentialUnitsC.text) ?? 0,
        numberOfCommercialLienUnits: int.tryParse(_commercialUnitsC.text) ?? 0,
        paymentStageList: _lienList,
        commercialInventoryFlatId: selectedCommercialLienUnits,
        residentialInventoryFlatId: selectedResidentialLienUnits,
        remark: _remarkC.text.trim(),
      );
    }
  }

  String get selectedResidentialLienUnits => _selectResidentialLienUnits.value
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");
  String get selectedCommercialLienUnits => _selectCommercialLienUnits.value
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");
  Future<void> _showLienBottomSheet({
    ProposedOfferLienToSocietyDetailsWithPaymentStageData? lien,
    int? index,
  }) async {
    if (lien != null) {
      _prefillBottomSheet(lien);
    } else {
      _clearDialog();
    }
    await DialogHelper.showCustomBottomSheet(
      context,
      "${lien != null ? 'Update' : 'Add'} Lien to Society Payment Stage",
      contentWidget: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedLienType,
        builder: (context, selectedLienType, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isRelease,
            builder: (context, isRelease, __) {
              return Form(
                key: _lienFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropDownWidget(
                      isRequired: true,
                      initialValue: selectedLienType,
                      dataList:
                          ((double.tryParse(_residentialAreaC.text) ?? 0) !=
                                      0 &&
                                  (double.tryParse(_commercialAreaC.text) ??
                                          0) !=
                                      0)
                              ? propertyTypeList
                              : (List<Map<String, dynamic>>.from(
                                propertyTypeList,
                              )..removeAt(
                                (double.tryParse(_commercialAreaC.text) ?? 0) ==
                                        0
                                    ? 1
                                    : 0,
                              )),
                      onSelected: (value) {
                        _selectedLienType.value = value;
                      },
                      title: "Type",
                      validator: (value) {
                        if (value == null) {
                          return "Type is required.";
                        }
                        return null;
                      },
                      onValueClear: () => _selectedLienType.value = null,
                    ),
                    CustomTextField(
                      title: "Stage",
                      isRequired: true,
                      hint: "Enter Stage",
                      textController: _stageController,
                      inputFormatterList: [
                        LengthLimitingTextInputFormatter(150),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Stage is required.";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Carpet Area (SqFt)",
                      isRequired: true,
                      hint: "Enter Carpet Area",
                      textController: _carpetAreaController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            double.parse(value) <= 0) {
                          return "Carpet Area is required.";
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        CustomCheckBox(
                          isSelected: isRelease,
                          title: "Is Release",
                          onChanged: (value) {
                            _isRelease.value = value;
                          },
                        ),
                      ],
                    ),
                    verticalSpacing(height: 15),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomActions: ValueListenableBuilder<Map<String, dynamic>?>(
        valueListenable: _selectedLienType,
        builder: (context, selectedLienType, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: _isRelease,
            builder: (context, isRelease, __) {
              return CustomButton(
                text: "Save",
                onPressed: () {
                  if (_lienFormKey.currentState!.validate()) {
                    final newList = List<
                      ProposedOfferLienToSocietyDetailsWithPaymentStageData
                    >.from(_lienList);
                    if (lien == null) {
                      newList.add(
                        ProposedOfferLienToSocietyDetailsWithPaymentStageData(
                          proposedOfferLienToSocietyDetailsWithPaymentStageId:
                              0,
                          uniquekey: '',
                          buildingId: widget.buildingId,
                          projectId: widget.projectId,
                          type: selectedLienType!['DisplayName'],
                          stage: _stageController.text,
                          carpetAreaSqFt: double.parse(
                            _carpetAreaController.text,
                          ),
                          isRelease: isRelease,
                          createdById: 1,
                          createdBy: 'Current User',
                          createdDate: DateTime.now(),
                          modifiedById: 0,
                          modifiedBy: '',
                          modifiedDate: null,
                        ),
                      );
                    } else {
                      newList[index!] =
                          ProposedOfferLienToSocietyDetailsWithPaymentStageData(
                            proposedOfferLienToSocietyDetailsWithPaymentStageId:
                                lien.proposedOfferLienToSocietyDetailsWithPaymentStageId,
                            uniquekey: lien.uniquekey,
                            buildingId: lien.buildingId,
                            projectId: lien.projectId,
                            type: selectedLienType!['DisplayName'],
                            stage: _stageController.text,
                            carpetAreaSqFt: double.parse(
                              _carpetAreaController.text,
                            ),
                            isRelease: isRelease,
                            createdById: lien.createdById,
                            createdBy: lien.createdBy,
                            createdDate: lien.createdDate,
                            modifiedById: lien.modifiedById,
                            modifiedBy: lien.modifiedBy,
                            modifiedDate: lien.modifiedDate,
                          );
                    }
                    _lienListNotifier.value = newList;
                    _updateLienUnitCounts();
                    goRouter.pop();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _prefillBottomSheet(
    ProposedOfferLienToSocietyDetailsWithPaymentStageData lien,
  ) {
    _selectedLienType.value = propertyTypeList.firstWhere(
      (e) => e['DisplayName'] == lien.type,
      orElse: () => propertyTypeList.first,
    );
    _stageController.text = lien.stage;
    _carpetAreaController.text = lien.carpetAreaSqFt.toString();
    _isRelease.value = lien.isRelease;
  }

  void _clearDialog() {
    _selectedLienType.value = null;
    _stageController.clear();
    _carpetAreaController.clear();
    _isRelease.value = false;
  }

  Future<void> _showPopupToDeleteLienToSocietyPaymentStage(int index) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a lien to society payment stage ?',
      'Deleting this lien to society payment stage will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      final newList =
          List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>.from(
            _lienList,
          );
      newList.removeAt(index);
      _lienListNotifier.value = newList;
      _updateLienUnitCounts();
      showSuccessMessage(
        // ignore: use_build_context_synchronously
        context,
        subTitle: 'Lien to Society Payment Stage Removed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.lienToSocietyDetails != null) {
            _populateFormFields();
          } else {
            _residentialAreaC.clear();
            _commercialAreaC.clear();
            _residentialUnitsC.clear();
            _commercialUnitsC.clear();
            _selectedLienType.value = null;
            _lienListNotifier.value = [];
            _stageController.clear();
            _carpetAreaController.clear();
            _isRelease.value = false;
            _selectResidentialLienUnits.value = [];
            _selectCommercialLienUnits.value = [];
            _remarkC.clear();
            _updateLienUnitCounts();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: commonCardDecoration(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardHeaderTile(
                          svgIcon: AppAssets.lienToSocietyIcon,
                          title: "Lien To Society Area Details",
                        ),
                        verticalSpacing(height: 15),
                        CustomTextField(
                          title: "Residential Area (SqFt)",
                          isRequired: true,
                          readOnly: disableAction,
                          hint: "Enter Residential Area (SqFt)",
                          textController: _residentialAreaC,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digitWithDecimal(
                            maxDigitsBeforeDecimal: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Residential area is required.";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Number of Residential Lien Units",
                          hint: "Enter Number of Residential Lien Units",
                          readOnly: disableAction,
                          textController: _residentialUnitsC,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digit(4),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectResidentialLienUnits,
                          builder: (
                            context,
                            selectResidentialLienUnits,
                            child,
                          ) {
                            return CustomMultipleSelectPopup(
                              title: "Residential Lien Units",
                              isMultiSelect: true,
                              isReadOnly: disableAction,
                              initialValue: selectResidentialLienUnits,
                              dataList: _flatLits.value,
                              onSelected: (value) {
                                _selectResidentialLienUnits.value = value;
                              },
                              dataFetchCallBack: _cubit.fetchResidentialUnits,
                              hintText: "Select Residential Lien Units",
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (_residentialUnitsC.text.isEmpty ||
                                      (int.tryParse(_residentialUnitsC.text) ??
                                              0) ==
                                          0) {
                                    return "Residential Lien Units are required.";
                                  }
                                  if ((int.tryParse(_residentialUnitsC.text) ??
                                          0) !=
                                      value.length) {
                                    return "${int.tryParse(_residentialUnitsC.text)} Residential Lien Units are required.";
                                  }
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          title: "Commercial Area (SqFt)",
                          hint: "Enter Commercial Area (SqFt)",
                          isRequired: true,
                          readOnly: disableAction,
                          textController: _commercialAreaC,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digitWithDecimal(
                            maxDigitsBeforeDecimal: 16,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Commercial area is required.";
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          title: "Number of Commercial Lien Units",
                          hint: "Enter of Commercial Lien Units",
                          readOnly: disableAction,
                          textController: _commercialUnitsC,
                          keyboardType: TextInputType.number,
                          inputFormatterList: InputValidator.digit(4),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _selectCommercialLienUnits,
                          builder: (context, selectCommercialLienUnits, child) {
                            return CustomMultipleSelectPopup(
                              title: "Commercial Lien Units",
                              hintText: "Select Commercial Lien Units",
                              isReadOnly: disableAction,
                              initialValue: selectCommercialLienUnits,
                              isMultiSelect: true,
                              dataList: _flatLits.value,
                              onSelected: (value) {
                                _selectCommercialLienUnits.value = value;
                              },
                              dataFetchCallBack: _cubit.fetchCommercialUnits,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (_commercialUnitsC.text.isEmpty ||
                                      (int.tryParse(_commercialUnitsC.text) ??
                                              0) ==
                                          0) {
                                    return "Commercial Lien Units are required.";
                                  }
                                  if ((int.tryParse(_commercialUnitsC.text) ??
                                          0) !=
                                      value.length) {
                                    return "${int.tryParse(_commercialUnitsC.text)} Commercial Lien Units are required.";
                                  }
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        CustomTextField(
                          title: 'Remark',
                          hint: 'Enter Remark',
                          textController: _remarkC,
                          readOnly: disableAction,
                          minLines: 3,
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lien to Society List',
                              style: AppTextStyle.ts14M(color: AppColor.grey),
                            ),
                            CustomIconButton.add(
                              isDisabled: disableAction,
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                _showLienBottomSheet();
                              },
                            ),
                          ],
                        ),
                        verticalSpacing(height: 20),
                        ValueListenableBuilder<
                          List<
                            ProposedOfferLienToSocietyDetailsWithPaymentStageData
                          >
                        >(
                          valueListenable: _lienListNotifier,
                          builder: (context, lienList, _) {
                            if (lienList.isNotEmpty) {
                              return Column(
                                children: List.generate(lienList.length, (
                                  index,
                                ) {
                                  final lien = lienList[index];
                                  return ProposedOfferInfoCard(
                                    title: lien.stage,
                                    tag: lien.type,
                                    disable: disableAction,
                                    onEdit: () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      _showLienBottomSheet(
                                        lien: lien,
                                        index: index,
                                      );
                                    },
                                    onDelete: () {
                                      _showPopupToDeleteLienToSocietyPaymentStage(
                                        index,
                                      );
                                    },
                                    child: Column(
                                      spacing: 10,
                                      children: [
                                        Row(
                                          spacing: 10,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildColumnTitleValue(
                                              title: "Carpet Area (SqFt)",
                                              value: lien.carpetAreaSqFt
                                                  .toStringAsFixed(2),
                                            ),
                                            buildColumnTitleValue(
                                              title: "Is Release",
                                              value:
                                                  lien.isRelease == true
                                                      ? 'Yes'
                                                      : 'No',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            } else {
                              return Container(
                                padding: const EdgeInsets.all(40),
                                child: Center(
                                  child: noDataWidget(
                                    iconSize: 100,
                                    message: 'No Lien to Society Details Found',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SectionCard(
                  title: 'Action Details',
                  titleTextColor: AppColor.black,
                  headerBackgroundColor: AppColor.grey20,
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Created By",
                          value: state.lienToSocietyDetails?.createdBy,
                        ),
                        buildColumnTitleValue(
                          title: "Created Date",
                          value: formatDate(
                            state.lienToSocietyDetails?.createdDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildColumnTitleValue(
                          title: "Modified By",
                          value: state.lienToSocietyDetails?.modifiedBy,
                        ),
                        buildColumnTitleValue(
                          title: "Modified Date",
                          value: formatDate(
                            state.lienToSocietyDetails?.modifiedDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
