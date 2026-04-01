import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

List<CityModel> _parseAddressData(String rawJson) {
  final List decoded = jsonDecode(rawJson);
  return decoded.map((e) => CityModel.fromJson(e)).toList();
}

class AddressWidget extends StatefulWidget {
  final int? incomingStateId;
  final int? incomingDistrictId;
  final int? incomingCityId;
  final int? incomingVillageId;
  final Function(Map<String, dynamic>) stateChange;
  final Function(Map<String, dynamic>) districtChange;
  final Function(Map<String, dynamic>) cityChange;
  final Function(Map<String, dynamic>)? villageChange;
  final GlobalKey<FormState> formKey;
  const AddressWidget({
    super.key,
    this.incomingStateId,
    this.incomingDistrictId,
    this.incomingCityId,
    this.incomingVillageId,
    required this.stateChange,
    required this.districtChange,
    required this.cityChange,
    this.villageChange,
    required this.formKey,
  });

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  late BaseClient baseClient;

  List<Map<String, dynamic>> stateList = [];
  final ValueNotifier<List<Map<String, dynamic>>> districtList = ValueNotifier(
    [],
  );
  final ValueNotifier<List<Map<String, dynamic>>> cityList = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> villageList = ValueNotifier(
    [],
  );

  Map<int, List<CityModel>> groupedStateData = {};
  Map<int, List<CityModel>> districtMap = {};
  Map<int, List<CityModel>> cityMap = {};

  final ValueNotifier<int?> stateId = ValueNotifier(null);
  final ValueNotifier<int?> districtId = ValueNotifier(null);
  final ValueNotifier<int?> cityId = ValueNotifier(null);
  final ValueNotifier<int?> villageId = ValueNotifier(null);

  @override
  void initState() {
    baseClient = BaseClient();
    loadAddressFromCache();
    super.initState();
  }

  @override
  void dispose() {
    districtList.dispose();
    cityList.dispose();
    villageList.dispose();
    stateId.dispose();
    districtId.dispose();
    cityId.dispose();
    villageId.dispose();
    super.dispose();
  }


  Future<void> loadAddressFromCache() async {
    try {
      final storage = LocalStorageManager();
      String? cachedData = storage.getRawString(StorageKey.addressMasterData);

      if (cachedData == null || cachedData.isEmpty) {
        final utilsRepository = serviceLocator<UtilsRepository>();
        await utilsRepository.getAddressMaster();
        cachedData = storage.getRawString(StorageKey.addressMasterData);
      }

      if (cachedData == null) return;

      // 1. Background parsing
      final List<CityModel> dataList = await compute(_parseAddressData, cachedData);

      // 2. Grouping
      groupedStateData = groupBy(dataList, (e) => e.stateMasterId);

      // 3. Populate State List (This was missing logic)
      final List<Map<String, dynamic>> tempStates = [];
      groupedStateData.forEach((key, value) {
        if (value.isNotEmpty) {
          tempStates.add({
            "zAttributesId": key,
            "DisplayName": value[0].stateName,
          });
        }
      });

      if (mounted) {
        setState(() {
          stateList = tempStates; // Update the list
        });

        // 4. Run prefill ONLY after stateList is ready
        _applyPrefill();
      }

      debugPrint("Address cached data processed: ${stateList.length} states found");
    } catch (error) {
      debugPrint("Address Load Error: $error");
    }
  }

  void handleStateChange(int stateIdF) {
    if (!groupedStateData.containsKey(stateIdF)) {
      districtList.value = [];
      cityList.value = [];
      villageList.value = [];
      return;
    }

    districtMap = groupBy(
      groupedStateData[stateIdF]!,
          (e) => e.districtMasterId,
    );

    final newDistrictList = districtMap.entries.map((e) => {
      "zAttributesId": e.key,
      "DisplayName": e.value[0].districtName,
    }).toList();

    districtList.value = newDistrictList;

    // reset children
    cityList.value = [];
    villageList.value = [];
  }

  void handleDistrictChange(int districtIdF) {
    if (!districtMap.containsKey(districtIdF)) {
      cityList.value = [];
      villageList.value = [];
      return;
    }

    cityMap = groupBy(
      districtMap[districtIdF]!,
          (e) => e.cityMasterId,
    );

    final newCityList = cityMap.entries.map((e) => {
      "zAttributesId": e.key,
      "DisplayName": e.value[0].cityName,
    }).toList();

    cityList.value = newCityList;
    villageList.value = [];
  }

  void handleCityChange(int cityIdF) {
    if (!cityMap.containsKey(cityIdF)) {
      villageList.value = [];
      return;
    }

    final villageData = cityMap[cityIdF]!;

    final villageMap = groupBy(villageData, (e) => e.villageMasterId);

    final newVillageList = villageMap.entries.map((e) => {
      "zAttributesId": e.key,
      "DisplayName": e.value[0].villageName,
    }).toList();

    villageList.value = newVillageList;
  }

  void _applyPrefill() {
    final sId = widget.incomingStateId;
    final dId = widget.incomingDistrictId;
    final cId = widget.incomingCityId;
    final vId = widget.incomingVillageId;

    if (sId == null) return;

    /// ------------------ STATE ------------------
    final hasState = stateList.any((e) => e['zAttributesId'] == sId);
    if (!hasState) return;

    stateId.value = sId;
    handleStateChange(sId);

    /// ------------------ DISTRICT ------------------
    int? resolvedDistrictId = dId;

    // 🔥 AUTO-FIX: if district is null but city exists → find district
    if (resolvedDistrictId == null && cId != null) {
      for (var entry in districtMap.entries) {
        if (entry.value.any((e) => e.cityMasterId == cId)) {
          resolvedDistrictId = entry.key;
          break;
        }
      }
    }

    if (resolvedDistrictId != null &&
        districtList.value.any((e) => e['zAttributesId'] == resolvedDistrictId)) {
      districtId.value = resolvedDistrictId;
      handleDistrictChange(resolvedDistrictId);
    } else {
      return; // stop if no valid district
    }

    /// ------------------ CITY ------------------
    if (cId != null &&
        cityList.value.any((e) => e['zAttributesId'] == cId)) {
      cityId.value = cId;
      handleCityChange(cId);
    } else {
      return;
    }

    /// ------------------ VILLAGE ------------------
    if (vId != null &&
        villageList.value.any((e) => e['zAttributesId'] == vId)) {
      villageId.value = vId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: horizontalSpacingMeasure(width: 16.0),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ValueListenableBuilder<int?>(
                valueListenable: stateId,
                builder: (context, currentStateId, child) {
                  return CustomDropDownWidget(
                    key: ValueKey(currentStateId),
                    initialValue: currentStateId == null
                        ? null
                        : stateList.firstWhereOrNull((state) => state['zAttributesId'] == currentStateId),
                    title: "State",
                    hintText: "Select State",
                    isRequired: true,
                    dataList: stateList,
                    onSelected: (stateMap) {
                      districtId.value = null;
                      cityId.value = null;
                      villageId.value = null;
                      stateId.value = stateMap['zAttributesId'];
                      handleStateChange(stateId.value!);
                      widget.stateChange(stateMap);
                    },
                    validator: (s) {
                      if (s == null) {
                        return "State is required";
                      }
                      return null;
                    },
                  );
                },
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: districtList,
                builder: (context, currentDistrictList, child) {
                  return ValueListenableBuilder<int?>(
                    valueListenable: districtId,
                    builder: (context, currentDistrictId, child) {
                      return CustomDropDownWidget(
                        key: ValueKey(
                          '${currentDistrictId}_${currentDistrictList.length}',
                        ),
                        initialValue: currentDistrictId == null || currentDistrictList.isEmpty
                            ? null
                            : currentDistrictList.firstWhereOrNull((district) => district['zAttributesId'] == currentDistrictId),
                        title: "District",
                        hintText: "Select District",
                        isRequired: true,
                        dataList: currentDistrictList,
                        onSelected: (districtMap) {
                          districtId.value = districtMap['zAttributesId'];
                          cityId.value = null;
                          villageId.value = null;
                          handleDistrictChange(districtId.value!);
                          widget.districtChange(districtMap);
                        },
                        validator: (s) {
                          if (s == null) {
                            return "District is required";
                          }
                          return null;
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),

        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: cityList,
          builder: (context, currentCityList, child) {
            return ValueListenableBuilder<int?>(
              valueListenable: cityId,
              builder: (context, currentCityId, child) {
                return CustomDropDownWidget(
                  key: ValueKey('${currentCityId}_${currentCityList.length}'),
                  initialValue: currentCityId == null || currentCityList.isEmpty
                      ? null
                      : currentCityList.firstWhereOrNull((city) => city['zAttributesId'] == currentCityId),
                  title: "City",
                  hintText: "Select City",
                  isRequired: true,
                  dataList: currentCityList,
                  onSelected: (cityselectedmap) {
                    cityId.value = cityselectedmap['zAttributesId'];
                    villageId.value = null;
                    handleCityChange(cityId.value!);
                    widget.cityChange(cityselectedmap);
                  },
                  validator: (s) {
                    if (s == null) {
                      return "City is required";
                    }
                    return null;
                  },
                );
              },
            );
          },
        ),
        if (widget.villageChange != null)
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: villageList,
            builder: (context, currentVillageList, child) {
              return ValueListenableBuilder<int?>(
                valueListenable: villageId,
                builder: (context, currentVillageId, child) {
                  return CustomDropDownWidget(
                    key: ValueKey(
                      '${currentVillageId}_${currentVillageList.length}',
                    ),
                    initialValue:
                        currentVillageId == null || currentVillageList.isEmpty
                            ? null
                            : currentVillageList.any(
                              (village) =>
                                  village['zAttributesId'] == currentVillageId,
                            )
                                ? currentVillageList.firstWhere(
                                  (village) =>
                                      village['zAttributesId'] == currentVillageId,
                                )
                                : null,
                    title: "Village",
                    hintText: "Select Village",
                    isRequired: true,
                    dataList: currentVillageList,
                    onSelected: (villageselectedmap) {
                      villageId.value = villageselectedmap['zAttributesId'];
                      widget.villageChange!(villageselectedmap);
                    },
                    validator: (s) {
                      if (s == null) {
                        return "Village is required";
                      }
                      return null;
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
