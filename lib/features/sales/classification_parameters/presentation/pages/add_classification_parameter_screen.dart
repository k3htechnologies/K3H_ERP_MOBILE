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
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedCommercialLeasingNotifier = ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedBudgetInCr =
      ValueNotifier(null);

  List<Map<String, dynamic>> _selectedLocations = [];

  final ValueNotifier<Map<String, dynamic>?> _selectedPossessionNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedTimelineNotifier =
      ValueNotifier(null);
  // STATIC LISTS
  final List<Map<String, dynamic>> possessionType = [
    {'zAttributesId': 1, 'DisplayName': 'RTMI'},
    {'zAttributesId': 2, 'DisplayName': 'Under 1 Year'},
    {'zAttributesId': 3, 'DisplayName': '1 Years To 2 Years'},
    {'zAttributesId': 4, 'DisplayName': '2 Years To 3 Years'},
    {'zAttributesId': 5, 'DisplayName': '3 Years & Above'},
  ];
  final List<Map<String, dynamic>> residentialType = [
    {'zAttributesId': 1, 'DisplayName': '1 RK'},
    {'zAttributesId': 2, 'DisplayName': '1 BHK'},
    {'zAttributesId': 3, 'DisplayName': '2 BHK'},
    {'zAttributesId': 4, 'DisplayName': '3 BHK'},
    {'zAttributesId': 5, 'DisplayName': '4 BHK'},
    {'zAttributesId': 6, 'DisplayName': '5 BHK'},
    {'zAttributesId': 7, 'DisplayName': '6 BHK'},
    {'zAttributesId': 8, 'DisplayName': '7 BHK'},
    {'zAttributesId': 9, 'DisplayName': '8 BHK'},
    {'zAttributesId': 10, 'DisplayName': '9 BHK'},
    {'zAttributesId': 11, 'DisplayName': '10 BHK'},
    {'zAttributesId': 12, 'DisplayName': '1 + 1 JODI'},
    {'zAttributesId': 13, 'DisplayName': '2 + 1 JODI'},
    {'zAttributesId': 14, 'DisplayName': '2 + 2 JODI'},
    {'zAttributesId': 15, 'DisplayName': '2 + 3 JODI'},
    {'zAttributesId': 16, 'DisplayName': 'DUPLEX'},
    {'zAttributesId': 17, 'DisplayName': 'PENTHOUSE'},
  ];

  final List<Map<String, dynamic>> requirementType = [
    {'zAttributesId': 1, 'DisplayName': 'Commercial'},
    {'zAttributesId': 2, 'DisplayName': 'Commercial Leasing'},
    {'zAttributesId': 3, 'DisplayName': 'Residential'},
  ];
  final List<Map<String, dynamic>> commercialUnitTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'OFFICE'},
    {'zAttributesId': 2, 'DisplayName': 'SHOP'},
  ];
  final List<Map<String, dynamic>> timelineTypeList = [
    {'zAttributesId': 1, 'DisplayName': 'Within 1 Month'},
    {'zAttributesId': 2, 'DisplayName': 'Beyond 1 Month'},
  ];
  String get selectedVillages => _selectedLocations
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  final List<Map<String, dynamic>> budgetInCrList = [
    {'zAttributesId': 1, 'DisplayName': '<1'},
    {'zAttributesId': 2, 'DisplayName': '1.5'},
    {'zAttributesId': 3, 'DisplayName': '2'},
    {'zAttributesId': 4, 'DisplayName': '2.5'},
    {'zAttributesId': 5, 'DisplayName': '3'},
    {'zAttributesId': 6, 'DisplayName': '3.5'},
    {'zAttributesId': 7, 'DisplayName': '4'},
    {'zAttributesId': 8, 'DisplayName': '4.5'},
    {'zAttributesId': 9, 'DisplayName': '5'},
    {'zAttributesId': 10, 'DisplayName': '5.5'},
    {'zAttributesId': 11, 'DisplayName': '6'},
    {'zAttributesId': 12, 'DisplayName': '6.5'},
    {'zAttributesId': 13, 'DisplayName': '7'},
    {'zAttributesId': 14, 'DisplayName': '7.5'},
    {'zAttributesId': 15, 'DisplayName': '8'},
    {'zAttributesId': 16, 'DisplayName': '8.5'},
    {'zAttributesId': 17, 'DisplayName': '9'},
    {'zAttributesId': 18, 'DisplayName': '9.5'},
    {'zAttributesId': 19, 'DisplayName': '10'},
    {'zAttributesId': 20, 'DisplayName': '10.5'},
    {'zAttributesId': 21, 'DisplayName': '11'},
    {'zAttributesId': 22, 'DisplayName': '11.5'},
    {'zAttributesId': 23, 'DisplayName': '12'},
    {'zAttributesId': 24, 'DisplayName': '12.5'},
    {'zAttributesId': 25, 'DisplayName': '15'},
    {'zAttributesId': 26, 'DisplayName': '15.5'},
    {'zAttributesId': 27, 'DisplayName': '20'},
    {'zAttributesId': 28, 'DisplayName': '20.5'},
    {'zAttributesId': 29, 'DisplayName': '25+'},
  ];

  @override
  void initState() {
    super.initState();
    _classificationParametersCubit =
        context.read<ClassificationParametersCubit>();
    // SET PROJECT ID
    projectId = getProject();
    if (_isEditMode) {
      _populateForm(widget.classificationParamterModel!);
    }
  }

  @override
  void dispose() {
    _selectedBudgetInCr.dispose();

    // VALUE NOTIFIERS
    _selectedRequirementNotifier.dispose();
    _selectedResidentialTypeNotifier.dispose();
    _selectedCommercialTypeNotifier.dispose();
    _selectedCommercialLeasingNotifier.dispose();
    _selectedPossessionNotifier.dispose();
    _selectedTimelineNotifier.dispose();

    super.dispose();
  }

  // PREFILL
  void _populateForm(ClassificationParameterModel model) async {
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
    _selectedPossessionNotifier.value = findItem(
      possessionType,
      model.possessionType,
    );
    _selectedTimelineNotifier.value = findItem(
      timelineTypeList,
      model.timeLine,
    );

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

    // BUDGET
    if (model.minBudget.isNotEmpty) {
      final raw = model.minBudget.trim();

      final match = budgetInCrList.firstWhere(
        (e) => e["DisplayName"].toString() == raw,
        orElse:
            () => budgetInCrList.firstWhere(
              (e) => e["DisplayName"] == "<1",
              orElse: () => budgetInCrList.first,
            ),
      );

      _selectedBudgetInCr.value = match;
    }
  }

  String getDisplayOrEmpty(Map<String, dynamic>? item) {
    if (item == null) return "";
    return item["DisplayName"] ?? "";
  }

  ValueNotifier<Map<String, dynamic>?> _getDependentNotifier(String? req) {
    if (req == "Residential") return _selectedResidentialTypeNotifier;
    if (req == "Commercial") return _selectedCommercialTypeNotifier;
    if (req == "Commercial Leasing") return _selectedCommercialLeasingNotifier;
    return ValueNotifier(null); // fallback (won’t be used)
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
      final timeline = getDisplayOrEmpty(_selectedTimelineNotifier.value);
      final payload = {
        "ClassificationParameterId":
            _isEditMode
                ? widget.classificationParamterModel!.classificationParameterId
                : 0,
        if (_isEditMode)
          "Uniquekey": widget.classificationParamterModel!.uniquekey,
        "ProjectId": projectId.projectId,
        "MinBudget": _selectedBudgetInCr.value?["DisplayName"] ?? "",
        "PossessionType": getDisplayOrEmpty(_selectedPossessionNotifier.value),
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
                    CustomDropDownWidget(
                      title: "Budget (In Cr)",
                      hintText: "Select Budget(In Cr)",
                      initialValue: _selectedBudgetInCr.value,
                      dataList: budgetInCrList,
                      onSelected: (value) {
                        _selectedBudgetInCr.value = value;
                      },
                    ),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedPossessionNotifier,
                      builder: (context, value, _) {
                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Possession Type",
                          hintText: "Select Possession Type",
                          initialValue: value,
                          dataList: possessionType,
                          onSelected:
                              (v) => _selectedPossessionNotifier.value = v,
                          onValueClear:
                              () => _selectedPossessionNotifier.value = null,
                          validator: (value) {
                            if (value == null) {
                              return 'Possession Type is required';
                            }
                            return null;
                          },
                        );
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
                              hintText: "Select Requirement",
                              initialValue: selectedRequirement,
                              dataList: requirementType,
                              onSelected: (v) {
                                _selectedRequirementNotifier.value = v;

                                _selectedResidentialTypeNotifier.value = null;
                                _selectedCommercialTypeNotifier.value = null;
                                _selectedCommercialLeasingNotifier.value = null;
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Requirement is required';
                                }
                                return null;
                              },
                              onValueClear: () {
                                _selectedRequirementNotifier.value = null;

                                _selectedResidentialTypeNotifier.value = null;
                                _selectedCommercialTypeNotifier.value = null;
                                _selectedCommercialLeasingNotifier.value = null;
                              },
                            ),
                            verticalSpacing(),
                            if (dependentList.isNotEmpty)
                              ValueListenableBuilder<Map<String, dynamic>?>(
                                valueListenable: _getDependentNotifier(
                                  selectedRequirement?["DisplayName"],
                                ),
                                builder: (context, selectedValue, _) {
                                  return CustomDropDownWidget(
                                    isRequired: true,
                                    title:
                                        "${selectedRequirement?["DisplayName"]} Type",
                                    hintText:
                                        "Select ${selectedRequirement?["DisplayName"]} Type",
                                    initialValue: selectedValue,
                                    dataList: dependentList,

                                    onSelected: (v) {
                                      _getDependentNotifier(
                                            selectedRequirement?["DisplayName"],
                                          ).value =
                                          v;
                                    },

                                    validator: (value) {
                                      if (value == null) {
                                        return '${selectedRequirement?["DisplayName"]} is required';
                                      }
                                      return null;
                                    },

                                    onValueClear: () {
                                      _getDependentNotifier(
                                            selectedRequirement?["DisplayName"],
                                          ).value =
                                          null;
                                    },
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    CustomMultipleSelectPopup(
                      title: 'Location',
                      hintText: 'Select Location',
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
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: _selectedTimelineNotifier,
                      builder: (context, value, _) {
                        return CustomDropDownWidget(
                          isRequired: true,
                          title: "Timeline of Purchase",
                          hintText: "Select Timeline of Purchase",
                          initialValue: value,
                          dataList: timelineTypeList,
                          onSelected:
                              (v) => _selectedTimelineNotifier.value = v,
                          onValueClear:
                              () => _selectedTimelineNotifier.value = null,
                          validator: (value) {
                            if (value == null) {
                              return 'Timeline of Purchase is required';
                            }
                            return null;
                          },
                        );
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
