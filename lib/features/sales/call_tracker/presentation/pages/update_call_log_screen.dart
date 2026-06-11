import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/data/model/call_log.model.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class UpdateCallLogScreen extends StatefulWidget {
  final CallLogModel callLogModel;
  final int index;
  const UpdateCallLogScreen({
    super.key,
    required this.callLogModel,
    required this.index,
  });

  @override
  State<UpdateCallLogScreen> createState() => _UpdateCallLogScreenState();
}

class _UpdateCallLogScreenState extends State<UpdateCallLogScreen> {
  late CallTrackerCubit _callTrackerCubit;

  DateTime? selectedRescheduleDate;
  DateTime? siteVisitProposedDate;
  final ValueNotifier<Map<String, dynamic>?> _selectedCallStatus =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedBudgetInCr =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedRequirementNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedResidentialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?> _selectedCommercialTypeNotifier =
      ValueNotifier(null);
  final ValueNotifier<Map<String, dynamic>?>
  _selectedCommercialLeasingNotifier = ValueNotifier(null);
  List<Map<String, dynamic>> _selectedLocations = [];
  late TextEditingController _remarkC;
  final _formKey = GlobalKey<FormState>();

  String get selectedVillages => _selectedLocations
      .map((v) => v["zAttributesId"].toString())
      .toSet()
      .join(",");

  @override
  void initState() {
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _remarkC = TextEditingController();
    _populateForm();
    super.initState();
  }

  void _populateForm() {
    final callLog = widget.callLogModel;
    final reqDisplay = callLog.requirement;
    if (reqDisplay.isNotEmpty) {
      _selectedRequirementNotifier.value = findItem(
        requirementType,
        callLog.requirement,
      );
      if (reqDisplay == "Residential") {
        _selectedResidentialTypeNotifier.value = findItem(
          residentialType,
          callLog.requirementType,
        );
      } else if (reqDisplay == "Commercial") {
        _selectedCommercialTypeNotifier.value = findItem(
          commercialUnitTypeList,
          callLog.requirementType,
        );
      } else if (reqDisplay == "Commercial Leasing") {
        _selectedCommercialLeasingNotifier.value = findItem(
          commercialLeasingTypeList,
          callLog.requirementType,
        );
      }
    }
    // PREFILL LOCATIONS
    if (callLog.villageMasterId.toString().isNotEmpty) {
      final villageIdsRaw = callLog.villageMasterId.toString();
      final villageNamesRaw = callLog.villageName;

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
    if (callLog.budget.isNotEmpty) {
      _selectedBudgetInCr.value = budgetInCrList.firstWhere(
        (e) => e["DisplayName"].toString() == callLog.budget,
        orElse: () => budgetInCrList.first,
      );
    }
    if (callLog.status.isNotEmpty) {
      _selectedCallStatus.value = callStatus.firstWhere(
        (e) => e["DisplayName"].toString() == callLog.status,
        orElse: () => callStatus.first,
      );
    }

    _remarkC.text = callLog.remark;
    selectedRescheduleDate = callLog.rescheduleDate;
    siteVisitProposedDate = callLog.siteVisitProposedDate;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _callTrackerCubit.updateCallLog(
        context: context,
        callLogId: widget.callLogModel.callLogId,
        projectId: widget.callLogModel.projectId,
        uniqueKey: widget.callLogModel.uniquekey,
        remark: _remarkC.text,
        villageIds: selectedVillages,
        rescheduleDate: selectedRescheduleDate,
        status: _selectedCallStatus.value!['DisplayName'],
        budget: _selectedBudgetInCr.value?['DisplayName'] ?? "",
        requirement: _selectedRequirementNotifier.value?['DisplayName'] ?? "",
        residentialType: getRequirementType(),
        siteVisitProposedDate: siteVisitProposedDate,
        index: widget.index,
      );
    }
  }

  String getRequirementType() {
    final requirement =
        (_selectedRequirementNotifier.value?['DisplayName'] ?? "")
            .toString()
            .toLowerCase();
    switch (requirement) {
      case "residential":
        return _selectedResidentialTypeNotifier.value?['DisplayName'] ?? "";
      case "commercial":
        return _selectedCommercialTypeNotifier.value?['DisplayName'] ?? "";
      case "commercial leasing":
        return _selectedCommercialLeasingNotifier.value?['DisplayName'] ?? "";

      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Call Log",
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update Call Log",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomDropDownWidget(
                      title: "Call Status",
                      hintText: "Select Call Status",
                      initialValue: _selectedCallStatus.value,
                      isRequired: true,
                      dataList: callStatus,
                      onSelected: (value) {
                        _selectedCallStatus.value = value;
                      },
                      onValueClear: () {
                        _selectedCallStatus.value = null;
                      },
                      validator: (value) {
                        if (value == null || value.toString().trim().isEmpty) {
                          return "Status is required";
                        }
                        return null;
                      },
                    ),
                    CustomDropDownWidget(
                      title: "Budget (In Cr)",
                      hintText: "Select Budget(In Cr)",
                      initialValue: _selectedBudgetInCr.value,
                      dataList: budgetInCrList,
                      onSelected: (value) {
                        _selectedBudgetInCr.value = value;
                      },
                      onValueClear: () => _selectedBudgetInCr.value = null,
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
                          } else if (reqVal == "Commercial") {
                            dependentList = commercialUnitTypeList;
                          } else if (reqVal == "Commercial Leasing") {
                            dependentList = commercialLeasingTypeList;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropDownWidget(
                              title: "Requirement",
                              hintText: "Select Requirement",
                              initialValue: selectedRequirement,
                              dataList: requirementType,
                              onSelected: (v) {
                                _selectedRequirementNotifier.value = v;
                              },
                              onValueClear: () {
                                _selectedRequirementNotifier.value = null;
                                _selectedResidentialTypeNotifier.value = null;
                                _selectedCommercialTypeNotifier.value = null;
                                _selectedCommercialLeasingNotifier.value = null;
                              },
                            ),
                            if (dependentList.isNotEmpty)
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _selectedResidentialTypeNotifier,
                                  _selectedCommercialTypeNotifier,
                                  _selectedCommercialLeasingNotifier,
                                ]),
                                builder: (context, child) {
                                  return CustomDropDownWidget(
                                    key: ValueKey(
                                      selectedRequirement?["DisplayName"],
                                    ),
                                    title:
                                        "${selectedRequirement?["DisplayName"]} Type",
                                    hintText:
                                        "Select ${selectedRequirement?["DisplayName"]}",
                                    isRequired: true,
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
                                      return null;
                                    }(),
                                    dataList: dependentList,
                                    onSelected: (v) {
                                      if (selectedRequirement?["DisplayName"] ==
                                          "Residential") {
                                        _selectedResidentialTypeNotifier.value =
                                            v;
                                      } else if (selectedRequirement?["DisplayName"] ==
                                          "Commercial") {
                                        _selectedCommercialTypeNotifier.value =
                                            v;
                                      } else if (selectedRequirement?["DisplayName"] ==
                                          "Commercial Leasing") {
                                        _selectedCommercialLeasingNotifier
                                            .value = v;
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.toString().trim().isEmpty) {
                                        return "${selectedRequirement?["DisplayName"]} Type is required";
                                      }
                                      return null;
                                    },
                                    onValueClear: () {
                                      if (selectedRequirement?["DisplayName"] ==
                                          "Residential") {
                                        _selectedResidentialTypeNotifier.value =
                                            null;
                                      } else if (selectedRequirement?["DisplayName"] ==
                                          "Commercial") {
                                        _selectedCommercialTypeNotifier.value =
                                            null;
                                      } else if (selectedRequirement?["DisplayName"] ==
                                          "Commercial Leasing") {
                                        _selectedCommercialLeasingNotifier
                                            .value = null;
                                      }
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
                      isMultiSelect: true,
                      initialValue: _selectedLocations,
                      dataList: const [],
                      dataFetchCallBack: _callTrackerCubit.fetchVillages,
                      onSelected: (value) => _selectedLocations = value,
                      onClear: () => _selectedLocations = [],
                    ),
                    CustomDatePicker(
                      title: "Site Visit Proposed Date",
                      initialDate: siteVisitProposedDate,
                      setValue: (value) {
                        siteVisitProposedDate = value;
                      },
                    ),
                    CustomTextField(
                      isRequired: true,
                      title: "Remark",
                      hint: "Enter Remark",
                      textController: _remarkC,
                      minLines: 3,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter remark";
                        }
                        return null;
                      },
                    ),
                    CustomDatePicker(
                      title: "Reschedule Date",
                      initialDate: selectedRescheduleDate,
                      setValue: (value) {
                        selectedRescheduleDate = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(text: "Save", onPressed: _submitForm),
        ),
      ),
    );
  }
}
