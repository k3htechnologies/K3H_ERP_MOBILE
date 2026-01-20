import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/data/model/lien_to_society_details.model.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_offer/presentation/cubit/proposed_offer_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/input_validator.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class LienToSocietyDetails extends StatefulWidget {
  final int projectId;
  final int buildingId;

  const LienToSocietyDetails({
    super.key,
    required this.projectId,
    required this.buildingId,
  });

  @override
  State<LienToSocietyDetails> createState() => _LienToSocietyDetailsState();
}

class _LienToSocietyDetailsState extends State<LienToSocietyDetails> {
  // CUBIT
  late ProposedOfferCubit _cubit;

  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // TEXT EDITING CONTROLLERS
  late TextEditingController _residentialAreaController;
  late TextEditingController _commercialAreaController;
  late TextEditingController _residentialUnitsController;
  late TextEditingController _commercialUnitsController;
  final List<Map<String, dynamic>> _lienTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select'},
    {'zAttributesId': 1, 'DisplayName': 'Residential'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial'},
  ];

  final ValueNotifier<List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>> _lienListNotifier =
      ValueNotifier<List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>>([]);
  
  List<ProposedOfferLienToSocietyDetailsWithPaymentStageData> get _lienList => _lienListNotifier.value;

  // LIEN FORM CONTROLLERS
  final ValueNotifier<Map<String, dynamic>?> _selectedLienType = ValueNotifier<Map<String, dynamic>?>(null);
  late TextEditingController _stageController;
  late TextEditingController _carpetAreaController;
  final ValueNotifier<bool> _isRelease = ValueNotifier<bool>(false);
  final GlobalKey<FormState> _lienFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProposedOfferCubit>();
    _initializeControllers();
    _cubit.pullLienToSocietyDetails(
      projectId: widget.projectId,
      buildingId: widget.buildingId,
    );
  }

  @override
  void dispose() {
    _residentialAreaController.dispose();
    _commercialAreaController.dispose();
    _residentialUnitsController.dispose();
    _commercialUnitsController.dispose();
    _stageController.dispose();
    _carpetAreaController.dispose();
    _lienListNotifier.dispose();
    _selectedLienType.dispose();
    _isRelease.dispose();
    super.dispose();
  }

  // INITIALIZE CONTROLLERS
  void _initializeControllers() {
    _residentialAreaController = TextEditingController();
    _commercialAreaController = TextEditingController();
    _residentialUnitsController = TextEditingController(text: "0");
    _commercialUnitsController = TextEditingController(text: "0");
    _stageController = TextEditingController();
    _carpetAreaController = TextEditingController();
  }

  // UPDATE LIEN UNIT COUNTS
  void _updateLienUnitCounts() {
    final residentialCount =
        _lienList
            .where((item) => item.type.toLowerCase() == 'residential')
            .length;

    final commercialCount =
        _lienList
            .where((item) => item.type.toLowerCase() == 'commercial')
            .length;

    _residentialUnitsController.text = residentialCount.toString();
    _commercialUnitsController.text = commercialCount.toString();
  }

  // FILL DATA
  void fillData() {
    var lienDetailsModel = _cubit.state.lienToSocietyDetails!;
    _residentialAreaController.text =
        lienDetailsModel.residentialAreaSqFt.toString();
    _commercialAreaController.text =
        lienDetailsModel.commercialAreaSqFt.toString();
    _residentialUnitsController.text =
        lienDetailsModel.numberOfResidentialLienUnits.toString();
    _commercialUnitsController.text =
        lienDetailsModel.numberOfCommercialLienUnits.toString();

    _lienListNotifier.value = List.from(
      lienDetailsModel.proposedOfferLienToSocietyDetailsWithPaymentStageData,
    );
  }

  // SAVE
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
        residentialAreaSqFt: double.parse(_residentialAreaController.text),
        commercialAreaSqFt: double.parse(_commercialAreaController.text),
        numberOfResidentialLienUnits: int.parse(
          _residentialUnitsController.text,
        ),
        numberOfCommercialLienUnits: int.parse(_commercialUnitsController.text),
        paymentStageList: _lienList,
      );
    }
  }

  // LIEN BOTTOM SHEET
  Future<void> _showLienBottomSheet({
    ProposedOfferLienToSocietyDetailsWithPaymentStageData? lien,
    int? index,
  }) async {
    if (lien != null) {
      _prefillBottomSheet(lien);
    }

    await DialogHelper.showCustomBottomSheet(
      context,
      "Add Lien to Society Details",
      SingleChildScrollView(
        child: ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: _selectedLienType,
          builder: (context, selectedLienType, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: _isRelease,
              builder: (context, isRelease, __) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _lienFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// TYPE
                        CustomDropDownWidget(
                          isRequired: true,
                          initialValue: selectedLienType,
                          dataList: _lienTypeList,
                          onSelected: (value) {
                            _selectedLienType.value = value;
                          },
                          title: "Type*",
                          validator: (value) {
                            if (value == null || value['zAttributesId'] == -1) {
                              return "Type is required";
                            }
                            return null;
                          },
                        ),

                    /// STAGE
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
                          return "Stage is required";
                        }
                        return null;
                      },
                    ),

                    // CARPET AREA
                    CustomTextField(
                      title: "Carpet Area (Sq Ft)",
                      isRequired: true,
                      hint: "Enter Carpet Area",
                      textController: _carpetAreaController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Carpet area is required";
                        }
                        if (double.parse(value) <= 0) {
                          return "Carpet area should be greater than 0";
                        }

                        final selectedType = selectedLienType?['DisplayName'];
                        if (selectedType == null) {
                          return "Type is required";
                        }

                        final newArea = double.tryParse(value) ?? 0;

                        double existingTotal = _lienList
                            .where(
                              (l) =>
                                  l.type.toLowerCase() ==
                                  selectedType.toLowerCase(),
                            )
                            .fold(
                              0.0,
                              (sum, item) => sum + item.carpetAreaSqFt,
                            );

                        if (lien != null &&
                            lien.type.toLowerCase() ==
                                selectedType.toLowerCase()) {
                          existingTotal -= lien.carpetAreaSqFt;
                        }

                        double allowedArea = 0;
                        if (selectedType.toLowerCase() == 'residential') {
                          allowedArea =
                              double.tryParse(
                                _residentialAreaController.text,
                              ) ??
                              0;
                        } else if (selectedType.toLowerCase() == 'commercial') {
                          allowedArea =
                              double.tryParse(_commercialAreaController.text) ??
                              0;
                        }

                        if (existingTotal + newArea > allowedArea) {
                          return "$selectedType carpet area exceeds allowed total of "
                              "${allowedArea.toStringAsFixed(2)} Sq Ft.";
                        }

                        return null;
                      },
                    ),

                    // RELEASE CHECKBOX
                    Row(
                      children: [
                        Checkbox(
                          activeColor: AppColor.green,
                          value: isRelease,
                          onChanged: (value) {
                            _isRelease.value = value ?? false;
                          },
                        ),
                        const Text("Is Release"),
                      ],
                    ),

                    verticalSpacing(height: 25),

                        // SAVE
                        CustomButton(
                          text: "Save",
                          onPressed: () {
                            if (_lienFormKey.currentState!.validate()) {
                              final newList = List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>.from(_lienList);
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

                              Navigator.pop(context);
                            }
                          },
                        ),

                        verticalSpacing(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    _clearDialog();
  }

  // PREFILL BOTTOM ShEET
  void _prefillBottomSheet(
    ProposedOfferLienToSocietyDetailsWithPaymentStageData lien,
  ) {
    _selectedLienType.value = _lienTypeList.firstWhere(
      (e) => e['DisplayName'] == lien.type,
      orElse: () => _lienTypeList.first,
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

  void _handleResidentialAreaChange(double value) {
    // This method can be used if you want to recalculate something when residential area changes
  }

  void _handleCommercialAreaChange(double value) {
    // This method can be used if you want to recalculate something when commercial area changes
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocConsumer<ProposedOfferCubit, ProposedOfferState>(
        listener: (context, state) {
          if (state.lienToSocietyDetails != null) {
            fillData();
          } else {
            _residentialAreaController.clear();
            _commercialAreaController.clear();
            _residentialUnitsController.clear();
            _commercialUnitsController.clear();
            _selectedLienType.value = null;
            _lienListNotifier.value = [];
            _stageController.clear();
            _carpetAreaController.clear();
            _isRelease.value = false;
            _updateLienUnitCounts();
          }
        },
        builder: (context, state) {
          if (state.isLoading == true) {
            return loader();
          }
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: commonCardDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lien To Society Details",
                      style: AppTextStyle.ts16M(),
                    ),
                    verticalSpacing(height: 15),
                    CustomTextField(
                      title: "Residential Area (Sq Ft)",
                      isRequired: true,
                      hint: "Enter Residential Area (Sq Ft)",
                      textController: _residentialAreaController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Residential area is required";
                        }
                        if (double.parse(value) < 0) {
                          return "Area should be positive";
                        }
                        return null;
                      },
                      onChangeFunction: (value) {
                        _handleResidentialAreaChange(
                          double.tryParse(value) ?? 0,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Commercial Area (Sq Ft)",
                      isRequired: true,
                      hint: "Enter Commercial Area (Sq Ft)",
                      textController: _commercialAreaController,
                      keyboardType: TextInputType.number,
                      inputFormatterList:
                          inputFormatterListForDecimalValuesFixedToTwo(10),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Commercial area is required";
                        }
                        if (double.parse(value) < 0) {
                          return "Area should be positive";
                        }
                        return null;
                      },
                      onChangeFunction: (value) {
                        _handleCommercialAreaChange(
                          double.tryParse(value) ?? 0,
                        );
                      },
                    ),
                    CustomTextField(
                      title: "Number of Residential Lien Units",
                      readOnly: true,
                      textController: _residentialUnitsController,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Number of residential units is required";
                        }
                        if (int.parse(value) < 0) {
                          return "Units should be positive";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Number of Commercial Lien Units",
                      readOnly: true,
                      textController: _commercialUnitsController,
                      keyboardType: TextInputType.number,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Number of commercial units is required";
                        }
                        if (int.parse(value) < 0) {
                          return "Units should be positive";
                        }
                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButton(
                          onPressed: () => _showLienBottomSheet(),
                          text: "Add Lien To Society",
                          leading: Icon(Icons.add, color: AppColor.white),
                        ),
                      ],
                    ),
                    verticalSpacing(height: 20),
                    ValueListenableBuilder<List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>>(
                      valueListenable: _lienListNotifier,
                      builder: (context, lienList, _) {
                        if (lienList.isNotEmpty) {
                          return Column(
                            children: List.generate(lienList.length, (index) {
                              final lien = lienList[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColor.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColor.grey.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      /// HEADER (TYPE + ACTIONS)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            lien.type,
                                            style: AppTextStyle.ts16M(),
                                          ),

                                          Row(
                                            children: [
                                              CustomIconButton.edit(
                                                onPressed: () {
                                                  _showLienBottomSheet(
                                                    lien: lien,
                                                    index: index,
                                                  );
                                                },
                                              ),

                                              const SizedBox(width: 12),

                                              CustomIconButton.delete(
                                                onPressed: () {
                                                  final newList = List<ProposedOfferLienToSocietyDetailsWithPaymentStageData>.from(lienList);
                                                  newList.removeAt(index);
                                                  _lienListNotifier.value = newList;
                                                  _updateLienUnitCounts();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      Divider(
                                        color: AppColor.grey.withValues(alpha: 0.4),
                                      ),

                                      _buildLienInfoRow("Stage", lien.stage),

                                      _buildLienInfoRow(
                                        "Carpet Area",
                                        "${lien.carpetAreaSqFt.toStringAsFixed(2)} Sq Ft",
                                      ),

                                      _buildLienInfoRow(
                                        "Is Release",
                                        lien.isRelease ? "Yes" : "No",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No details added',
                                style: AppTextStyle.ts16R(color: AppColor.grey),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    verticalSpacing(height: 30),
                    CustomButton(text: "Save", onPressed: _onSave),
                    verticalSpacing(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // HELPER METHODS
  Widget _buildLienInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: AppTextStyle.ts14M(color: AppColor.grey)),
          ),
          const Text(": "),
          Expanded(child: Text(value, style: AppTextStyle.ts14R())),
        ],
      ),
    );
  }
}
