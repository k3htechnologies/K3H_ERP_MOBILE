import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';
import 'package:collection/collection.dart';
import 'package:shimmer/shimmer.dart';

class AddressParsedResult {
  final Map<int, Map<int, Map<int, List<CityModel>>>> addressTree;
  final List<Map<String, dynamic>> stateList;

  AddressParsedResult({required this.addressTree, required this.stateList});
}

///  Background parse
AddressParsedResult processAddressData(String rawJson) {
  final decoded = jsonDecode(rawJson);

  final list =
      decoded is Map<String, dynamic>
          ? decoded['CountryStateCityDistrictVillageData']
          : decoded;

  final dataList = (list as List).map((e) => CityModel.fromJson(e)).toList();

  final Map<int, Map<int, Map<int, List<CityModel>>>> tree = {};

  for (var item in dataList) {
    tree
        .putIfAbsent(item.stateMasterId, () => {})
        .putIfAbsent(item.districtMasterId, () => {})
        .putIfAbsent(item.cityMasterId, () => [])
        .add(item);
  }

  final stateList =
      tree.entries.map((e) {
        final first = e.value.values.first.values.first.first;
        return {"zAttributesId": e.key, "DisplayName": first.stateName};
      }).toList();

  return AddressParsedResult(addressTree: tree, stateList: stateList);
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
  ///  Optimized tree
  Map<int, Map<int, Map<int, List<CityModel>>>> addressTree = {};

  List<Map<String, dynamic>> stateList = [];

  final ValueNotifier<List<Map<String, dynamic>>> districtList = ValueNotifier(
    [],
  );
  final ValueNotifier<List<Map<String, dynamic>>> cityList = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> villageList = ValueNotifier(
    [],
  );

  final ValueNotifier<int?> stateId = ValueNotifier(null);
  final ValueNotifier<int?> districtId = ValueNotifier(null);
  final ValueNotifier<int?> cityId = ValueNotifier(null);
  final ValueNotifier<int?> villageId = ValueNotifier(null);

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAddressFromCache();
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

  ///  LOAD WITH RETRY (IMPORTANT)
  Future<void> loadAddressFromCache() async {
    final utilsRepository = serviceLocator<UtilsRepository>();

    final result = await utilsRepository.getAddressMaster();

    result.fold(
      (failure) {
        debugPrint("Error: ${failure.message}");
      },
      (parsed) {
        addressTree = parsed.addressTree;

        setState(() {
          stateList = parsed.stateList;
          isLoading = false;
        });
        _applyPrefill();
      },
    );
  }

  ///  PROCESS DATA
  AddressParsedResult processAddressData(String rawJson) {
    final decoded = jsonDecode(rawJson);

    final list =
        decoded is Map<String, dynamic>
            ? decoded['CountryStateCityDistrictVillageData']
            : decoded;

    final dataList = (list as List).map((e) => CityModel.fromJson(e)).toList();

    final Map<int, Map<int, Map<int, List<CityModel>>>> tree = {};

    for (var item in dataList) {
      tree
          .putIfAbsent(item.stateMasterId, () => {})
          .putIfAbsent(item.districtMasterId, () => {})
          .putIfAbsent(item.cityMasterId, () => [])
          .add(item);
    }

    final stateList =
        tree.entries.map((e) {
          final first = e.value.values.first.values.first.first;
          return {"zAttributesId": e.key, "DisplayName": first.stateName};
        }).toList();

    return AddressParsedResult(addressTree: tree, stateList: stateList);
  }

  /// ---------------- STATE ----------------
  void handleStateChange(int stateIdF) {
    final districts = addressTree[stateIdF];

    if (districts == null) {
      districtList.value = [];
      cityList.value = [];
      villageList.value = [];
      return;
    }

    districtList.value =
        districts.entries.map((e) {
          final first = e.value.values.first.first;
          return {"zAttributesId": e.key, "DisplayName": first.districtName};
        }).toList();

    cityList.value = [];
    villageList.value = [];
  }

  /// ---------------- DISTRICT ----------------
  void handleDistrictChange(int districtIdF) {
    final cities = addressTree[stateId.value]?[districtIdF];

    if (cities == null) {
      cityList.value = [];
      villageList.value = [];
      return;
    }

    cityList.value =
        cities.entries.map((e) {
          final first = e.value.first;
          return {"zAttributesId": e.key, "DisplayName": first.cityName};
        }).toList();

    villageList.value = [];
  }

  /// ---------------- CITY ----------------
  void handleCityChange(int cityIdF) {
    final villages = addressTree[stateId.value]?[districtId.value]?[cityIdF];

    if (villages == null) {
      villageList.value = [];
      return;
    }

    villageList.value =
        villages.map((e) {
          return {
            "zAttributesId": e.villageMasterId,
            "DisplayName": e.villageName,
          };
        }).toList();
  }

  /// PREFILL
  void _applyPrefill() {
    final sId = widget.incomingStateId;
    final dId = widget.incomingDistrictId;
    final cId = widget.incomingCityId;
    final vId = widget.incomingVillageId;

    if (sId == null) return;

    if (!stateList.any((e) => e['zAttributesId'] == sId)) return;

    stateId.value = sId;
    handleStateChange(sId);

    int? resolvedDistrictId = dId;

    if (resolvedDistrictId == null && cId != null) {
      final districts = addressTree[sId];
      if (districts != null) {
        for (var entry in districts.entries) {
          if (entry.value.values.any(
            (list) => list.any((e) => e.cityMasterId == cId),
          )) {
            resolvedDistrictId = entry.key;
            break;
          }
        }
      }
    }

    if (resolvedDistrictId != null) {
      districtId.value = resolvedDistrictId;
      handleDistrictChange(resolvedDistrictId);
    } else {
      return;
    }

    if (cId != null) {
      cityId.value = cId;
      handleCityChange(cId);
    }

    if (vId != null) {
      villageId.value = vId;
    }
  }

  /// SHIMMER UI
  Widget _shimmer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _box()),
            const SizedBox(width: 16),
            Expanded(child: _box()),
          ],
        ),
        const SizedBox(height: 16),
        _box(),
        const SizedBox(height: 16),
        if (widget.villageChange != null) _box(),
      ],
    );
  }

  Widget _box() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) return _shimmer();

    return Column(
      children: [
        Row(
          spacing: horizontalSpacingMeasure(width: 16),
          children: [
            Expanded(
              child: ValueListenableBuilder<int?>(
                valueListenable: stateId,
                builder: (_, val, __) {
                  return CustomDropDownWidget(
                    key: ValueKey(val),
                    initialValue:
                        val == null
                            ? null
                            : stateList.firstWhereOrNull(
                              (e) => e['zAttributesId'] == val,
                            ),
                    title: "State",
                    hintText: "Select State",
                    isRequired: true,
                    dataList: stateList,
                    onSelected: (map) {
                      stateId.value = map['zAttributesId'];
                      districtId.value = null;
                      cityId.value = null;
                      villageId.value = null;
                      handleStateChange(stateId.value!);
                      widget.stateChange(map);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'State is required';
                      }
                      return null;
                    },
                    onValueClear: () {
                      stateId.value = null;
                      districtId.value = null;
                      cityId.value = null;
                      villageId.value = null;
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: districtList,
                builder: (_, list, __) {
                  return ValueListenableBuilder<int?>(
                    valueListenable: districtId,
                    builder: (_, val, __) {
                      return CustomDropDownWidget(
                        key: ValueKey('$val${list.length}'),
                        initialValue:
                            val == null
                                ? null
                                : list.firstWhereOrNull(
                                  (e) => e['zAttributesId'] == val,
                                ),
                        title: "District",
                        hintText: "Select District",
                        isRequired: true,
                        dataList: list,
                        onSelected: (map) {
                          districtId.value = map['zAttributesId'];
                          cityId.value = null;
                          villageId.value = null;
                          handleDistrictChange(districtId.value!);
                          widget.districtChange(map);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'District is required';
                          }
                          return null;
                        },
                        onValueClear: () {
                          districtId.value = null;
                          cityId.value = null;
                          villageId.value = null;
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
          builder: (_, list, __) {
            return ValueListenableBuilder<int?>(
              valueListenable: cityId,
              builder: (_, val, __) {
                return CustomDropDownWidget(
                  key: ValueKey('$val${list.length}'),
                  initialValue:
                      val == null
                          ? null
                          : list.firstWhereOrNull(
                            (e) => e['zAttributesId'] == val,
                          ),
                  title: "City",
                  hintText: "Select City",
                  isRequired: true,
                  dataList: list,
                  onSelected: (map) {
                    cityId.value = map['zAttributesId'];
                    villageId.value = null;
                    handleCityChange(cityId.value!);
                    widget.cityChange(map);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'City is required';
                    }
                    return null;
                  },
                  onValueClear: () {
                    cityId.value = null;
                    villageId.value = null;
                  },
                );
              },
            );
          },
        ),

        if (widget.villageChange != null)
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: villageList,
            builder: (_, list, __) {
              return ValueListenableBuilder<int?>(
                valueListenable: villageId,
                builder: (_, val, __) {
                  return CustomDropDownWidget(
                    key: ValueKey('$val${list.length}'),
                    initialValue:
                        val == null
                            ? null
                            : list.firstWhereOrNull(
                              (e) => e['zAttributesId'] == val,
                            ),
                    title: "Village",
                    hintText: "Select Village",
                    isRequired: true,
                    dataList: list,
                    onSelected: (map) {
                      villageId.value = map['zAttributesId'];
                      widget.villageChange!(map);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Village is required';
                      }
                      return null;
                    },
                    onValueClear: () {
                      villageId.value = null;
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
