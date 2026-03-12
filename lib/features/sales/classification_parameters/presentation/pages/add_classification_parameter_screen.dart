// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/model/classification_paramerter.model.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/presentation/cubit/classification_parameters_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AddClassificationParameterScreen extends StatefulWidget {
  final ClassificationParameterModel? classificationParamterModel;
  final int index;
  const AddClassificationParameterScreen({
    super.key,
    this.classificationParamterModel,
    required this.index,
  });

  @override
  State<AddClassificationParameterScreen> createState() =>
      _AddClassificationParameterScreenState();
}

class _AddClassificationParameterScreenState
    extends State<AddClassificationParameterScreen> {
  // CUBIT
  late ClassificationParametersCubit _classificationParametersCubit;
  // EDIT MODE
  bool get _isEditMode => widget.classificationParamterModel != null;
  // PROJECT MODEL
  late ProjectModel projectId;
  // FORM KEY
  final GlobalKey<FormState> _classificationParameterAddUpdateKey =
      GlobalKey<FormState>();
  final List<int> budgetOptions = [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 25];
  // BUDGET INITIAL VALUE
  late ValueNotifier<int> _budgetValueNotifier;
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedCommercialLeasingNotifier = ValueNotifier(null);

  late TextEditingController _budgetC;

  List<Map<String, dynamic>> _selectedLocations = [];

  Map<String, dynamic>? _selectedPossessionType;
  Map<String, dynamic>? _selectedTimeline;
  // STATIC LISTS
  final List<Map<String, dynamic>> possessionType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Possession Type'},
    {'zAttributesId': 1, 'DisplayName': 'RTMI'},
    {'zAttributesId': 2, 'DisplayName': 'Under 1 Year'},
    {'zAttributesId': 3, 'DisplayName': '1 Years To 2 Years'},
    {'zAttributesId': 4, 'DisplayName': '2 Years To 3 Years'},
    {'zAttributesId': 5, 'DisplayName': '3 Years & Above'},
  ];
  final List<Map<String, dynamic>> residentialType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Unit Type'},
    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 7, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 8, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 9, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 10, 'DisplayName': 'PENTHOUSE'},
  ];
  final List<Map<String, dynamic>> requirementType = [
    {'zAttributesId': -1, 'DisplayName': 'Select Requirement'},
    {'zAttributesId': 1, 'DisplayName': 'Commercial'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial Leasing'},
    {'zAttributesId': 3, 'DisplayName': 'Residential'},
  ];
  final List<Map<String, dynamic>> commercialUnitTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Type'},
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];
  final List<Map<String, dynamic>> timelineTypeList = [
    {'zAttributesId': -1, 'DisplayName': 'Select Timeline'},
    {'zAttributesId': 1, 'DisplayName': 'Within 1 Month'},
    {'zAttributesId': 2, 'DisplayName': 'Beyond 1 Month'},
  ];
  String get selectedVillages => _selectedLocations
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  @override
  void initState() {
    super.initState();
    _classificationParametersCubit =
        context.read<ClassificationParametersCubit>();
    _budgetValueNotifier = ValueNotifier<int>(1);
    _budgetC = TextEditingController();
    // SET PROJECT ID
    projectId = getProject();
    if (_isEditMode) {
      _populateForm(widget.classificationParamterModel!);
    } else {
      _budgetC.text = ">1";
    }
  }

  @override
  void dispose() {
    // TEXT CONTROLLERS
    _budgetC.dispose();
    _budgetValueNotifier.dispose();

    // VALUE NOTIFIERS
    _selectedRequirementNotifier.dispose();
    _selectedResidentialTypeNotifier.dispose();
    _selectedCommercialTypeNotifier.dispose();
    _selectedCommercialLeasingNotifier.dispose();

    super.dispose();
  }

  // PREFILL
  void _populateForm(ClassificationParameterModel model) async {
    // TEXT CONTROLLER
    _budgetC.text = model.minBudget;

    // HELPER: Find item in list by DisplayName
    Map<String, dynamic> findItem(
      List<Map<String, dynamic>> list,
      String value,
    ) {
      return list.firstWhere(
        (e) =>
            e["DisplayName"].toString().toLowerCase().trim() ==
            value.toLowerCase().trim(),
        orElse: () => list.first,
      );
    }

    // DROPDOWNS - NOTIFIER

    _selectedRequirementNotifier.value = findItem(
      requirementType,
      model.requirement,
    );

    // DROPDOWNS - PLAIN VARIABLES
    _selectedPossessionType = findItem(possessionType, model.possessionType);
    _selectedTimeline = findItem(timelineTypeList, model.timeLine);

    // DEPENDENT REQUIREMENT TYPE DROPDOWNS
    final reqDisplay = model.requirement;
    if (reqDisplay == "Residential") {
      _selectedResidentialTypeNotifier.value = findItem(
        residentialType,
        model.requirementType,
      );
    } else if (reqDisplay == "Commercial") {
      _selectedCommercialTypeNotifier.value = findItem(
        commercialUnitTypeList,
        model.requirementType,
      );
    } else if (reqDisplay == "Commercial Leasing") {
      _selectedCommercialLeasingNotifier.value = findItem(
        commercialUnitTypeList,
        model.requirementType,
      );
    }

    // PREFILL LOCATIONS
    if (model.villageMasterId != null &&
        model.villageMasterId.toString().isNotEmpty) {
      final villageIdsRaw = model.villageMasterId.toString();
      final villageNamesRaw = model.villageName;

      final villageIds =
          villageIdsRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .map((e) => int.parse(e))
              .toList();

      final villageNames =
          villageNamesRaw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final maxLength =
          villageIds.length < villageNames.length
              ? villageIds.length
              : villageNames.length;

      _selectedLocations = List.generate(maxLength, (index) {
        return {
          "zAttributesId": villageIds[index],
          "DisplayName": villageNames[index],
          "VillageName": villageNames[index],
        };
      });
    }

    // BUDGET SLIDER
    if (model.minBudget.isNotEmpty) {
      final cleaned = model.minBudget.replaceAll("+", "").replaceAll(">", "");
      final value = int.tryParse(cleaned);
      if (value != null && budgetOptions.contains(value)) {
        _budgetValueNotifier.value = value;
      }
    }
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    if (item["zAttributesId"] == -1) return "";
    return item["DisplayName"] ?? "";
  }

  void _classificationParameterData() async {
    if (_classificationParameterAddUpdateKey.currentState!.validate()) {
      // REQUIREMENT TYPE FROM CASCADING DROPDOWN
      final req = _selectedRequirementNotifier.value?["DisplayName"] ?? "";
      final String requirementTypeValue;
      if (req == "Residential") {
        requirementTypeValue =
            _selectedResidentialTypeNotifier.value?["DisplayName"] ?? "";
      } else if (req == "Commercial") {
        requirementTypeValue =
            _selectedCommercialTypeNotifier.value?["DisplayName"] ?? "";
      } else if (req == "Commercial Leasing") {
        requirementTypeValue =
            _selectedCommercialLeasingNotifier.value?["DisplayName"] ?? "";
      } else {
        requirementTypeValue = "";
      }
      final timeline = getDisplayOrEmpty(_selectedTimeline);
      final payload = {
        "ClassificationParameterId":
            _isEditMode
                ? widget.classificationParamterModel!.classificationParameterId
                : 0,
        if (_isEditMode)
          "Uniquekey": widget.classificationParamterModel!.uniquekey,
        "ProjectId": projectId.projectId,
        "MinBudget": _budgetC.text.trim(),
        "PossessionType": getDisplayOrEmpty(_selectedPossessionType),
        "Requirement": getDisplayOrEmpty(_selectedRequirementNotifier.value),
        "RequirementType": requirementTypeValue,
        "VillageMasterId": selectedVillages,
        "TimeLine": timeline,
      };
      //  SUBMIT CLASSIFICATION PARAMETER
      await _classificationParametersCubit.addUpdateClassificationParameters(
        context: context,
        body: payload,
        index: _isEditMode ? widget.index : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Classification Parameter",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _classificationParameterAddUpdateKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.classificationParamterModel != null
                    ? "Update Classification Parameter"
                    : "Add Classification Parameter",
                style: AppTextStyle.ts16SB(),
              ),
              verticalSpacing(),
              Container(
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Budget (In Cr)", style: AppTextStyle.ts14R()),
                    SizedBox(
                      width: double.infinity,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _budgetValueNotifier,
                        builder: (context, selectedValue, child) {
                          return SfSlider(
                            min: 0,
                            max: (budgetOptions.length - 1).toDouble(),
                            value:
                                budgetOptions.indexOf(selectedValue).toDouble(),
                            interval: 1,
                            showTicks: false,
                            showLabels: true,
                            enableTooltip: false,
                            activeColor: AppColor.primary,
                            inactiveColor: AppColor.primary.withValues(
                              alpha: 0.25,
                            ),
                            minorTicksPerInterval: 0,

                            labelFormatterCallback: (
                              actualValue,
                              formattedText,
                            ) {
                              int index = actualValue.round();
                              int val = budgetOptions[index];

                              return val == 1
                                  ? ">1"
                                  : val == 25
                                  ? "25+"
                                  : "$val";
                            },

                            onChanged: (dynamic value) {
                              int index = value.round();
                              int val = budgetOptions[index];

                              _budgetValueNotifier.value = val;
                              _budgetC.text =
                                  val == 1
                                      ? ">1"
                                      : val == 25
                                      ? "25+"
                                      : val.toString();
                            },
                          );
                        },
                      ),
                    ),
                    verticalSpacing(height: 20),
                    CustomDropDownWidget(
                      isRequired: true,
                      title: "Possession Type",
                      initialValue:
                          _selectedPossessionType ?? possessionType.first,
                      dataList: possessionType,
                      onSelected: (v) => _selectedPossessionType = v,
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Possession Type is required';
                        }
                        return null;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedRequirementNotifier,
                      builder: (context, selectedRequirement, child) {
                        List<Map<String, dynamic>> dependentList = [];
                        if (selectedRequirement != null) {
                          final reqVal =
                              selectedRequirement["DisplayName"] ?? "";
                          if (reqVal == "Residential") {
                            dependentList = residentialType;
                          } else if (reqVal == "Commercial" ||
                              reqVal == "Commercial Leasing") {
                            dependentList = commercialUnitTypeList;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropDownWidget(
                              isRequired: true,
                              title: "Requirement",
                              initialValue:
                                  selectedRequirement ?? requirementType.first,
                              dataList: requirementType,
                              onSelected: (v) {
                                _selectedRequirementNotifier.value = v;
                                if (v["DisplayName"] == "Residential") {
                                  _selectedResidentialTypeNotifier.value =
                                      residentialType.first;
                                } else if (v["DisplayName"] == "Commercial") {
                                  _selectedCommercialTypeNotifier.value =
                                      commercialUnitTypeList.first;
                                } else if (v["DisplayName"] ==
                                    "Commercial Leasing") {
                                  _selectedCommercialLeasingNotifier.value =
                                      commercialUnitTypeList.first;
                                }
                              },
                              validator: (value) {
                                if (value == null ||
                                    value["zAttributesId"] == -1) {
                                  return 'Requirement is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            if (dependentList.isNotEmpty)
                              CustomDropDownWidget(
                                isRequired: true,
                                title:
                                    "${selectedRequirement?["DisplayName"]} Type",
                                initialValue: () {
                                  if (selectedRequirement?["DisplayName"] ==
                                      "Residential") {
                                    return _selectedResidentialTypeNotifier
                                        .value;
                                  } else if (selectedRequirement?["DisplayName"] ==
                                      "Commercial") {
                                    return _selectedCommercialTypeNotifier
                                        .value;
                                  } else if (selectedRequirement?["DisplayName"] ==
                                      "Commercial Leasing") {
                                    return _selectedCommercialLeasingNotifier
                                        .value;
                                  }
                                  return dependentList.first;
                                }(),
                                dataList: dependentList,
                                onSelected: (v) {
                                  if (selectedRequirement?["DisplayName"] ==
                                      "Residential") {
                                    _selectedResidentialTypeNotifier.value = v;
                                  } else if (selectedRequirement?["DisplayName"] ==
                                      "Commercial") {
                                    _selectedCommercialTypeNotifier.value = v;
                                  } else if (selectedRequirement?["DisplayName"] ==
                                      "Commercial Leasing") {
                                    _selectedCommercialLeasingNotifier.value =
                                        v;
                                  }
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value["zAttributesId"] == -1) {
                                    return '${selectedRequirement?["DisplayName"]} is required';
                                  }
                                  return null;
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: 'Location',
                      isRequired: true,
                      isMultiSelect: true,
                      initialValue: _selectedLocations,
                      dataList: const [],
                      dataFetchCallBack:
                          _classificationParametersCubit.fetchVillages,
                      onSelected: (value) => _selectedLocations = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      isRequired: true,
                      title: "Timeline",
                      initialValue: _selectedTimeline ?? timelineTypeList.first,
                      dataList: timelineTypeList,
                      onSelected: (v) => _selectedTimeline = v,
                      validator: (value) {
                        if (value == null || value["zAttributesId"] == -1) {
                          return 'Timeline is required';
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
          color: AppColor.white,
          height: 70,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(
              _isEditMode ? Icons.edit : Icons.add,
              color: AppColor.white,
              size: 18,
            ),
            text: _isEditMode ? 'Update' : 'Add',
            backgroundColor: AppColor.primary,
            onPressed: _classificationParameterData,
          ),
        ),
      ),
    );
  }
}
