// address_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';

class AddressParsedResult {
  // country → state → district → city → [villages]
  final Map<int, Map<int, Map<int, Map<int, List<CityModel>>>>> addressTree;
  final List<Map<String, dynamic>> countryList;

  AddressParsedResult({required this.addressTree, required this.countryList});
}

// This is the ONLY thing that must change — the function compute() points to.
// It must be the updated 4-level version, not the old 3-level one.

AddressParsedResult processAddressData(String rawJson) {
  final decoded = jsonDecode(rawJson);

  final list =
      decoded is Map<String, dynamic>
          ? decoded['CountryStateCityDistrictVillageData']
          : decoded;

  final dataList = (list as List).map((e) => CityModel.fromJson(e)).toList();

  // 4-level tree: country → state → district → city → [villages]
  // NOTE: the leaf list can contain multiple rows per village (one per ward),
  // so village/ward dropdowns are derived from this list rather than the
  // tree growing a 5th level.
  final Map<int, Map<int, Map<int, Map<int, List<CityModel>>>>> tree = {};

  for (final item in dataList) {
    tree
        .putIfAbsent(item.countryMasterId, () => {})
        .putIfAbsent(item.stateMasterId, () => {})
        .putIfAbsent(item.districtMasterId, () => {})
        .putIfAbsent(item.cityMasterId, () => [])
        .add(item);
  }

  final countryList =
      tree.entries
          .map((e) {
            final stateMap = e.value;
            if (stateMap.isEmpty) return null;
            final districtMap = stateMap.values.first;
            if (districtMap.isEmpty) return null;
            final cityMap = districtMap.values.first;
            if (cityMap.isEmpty) return null;
            final items = cityMap.values.first;
            if (items.isEmpty) return null;
            return {
              'zAttributesId': e.key,
              'DisplayName': items.first.countryName,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();

  return AddressParsedResult(addressTree: tree, countryList: countryList);
}

class AddressWidget extends StatefulWidget {
  final int? incomingCountryId; // ← new
  final int? incomingStateId;
  final int? incomingDistrictId;
  final int? incomingCityId;
  final int? incomingVillageId;
  final int? incomingWardId;

  final Function(Map<String, dynamic>) countryChange;
  final Function(Map<String, dynamic>) stateChange;
  final Function(Map<String, dynamic>) districtChange;
  final Function(Map<String, dynamic>) cityChange;
  final Function(Map<String, dynamic>)? villageChange;
  final Function(Map<String, dynamic>)? wardChange;

  final GlobalKey<FormState> formKey;

  const AddressWidget({
    super.key,
    this.incomingCountryId = 1,
    this.incomingStateId,
    this.incomingDistrictId,
    this.incomingCityId,
    this.incomingVillageId,
    required this.countryChange,
    required this.stateChange,
    required this.districtChange,
    required this.cityChange,
    this.villageChange,
    required this.formKey,
    this.incomingWardId,
    this.wardChange,
  });

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  Map<int, Map<int, Map<int, Map<int, List<CityModel>>>>> addressTree = {};

  List<Map<String, dynamic>> countryList = [];

  final ValueNotifier<List<Map<String, dynamic>>> stateList = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> districtList = ValueNotifier(
    [],
  );
  final ValueNotifier<List<Map<String, dynamic>>> cityList = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> villageList = ValueNotifier(
    [],
  );
  final ValueNotifier<List<Map<String, dynamic>>> wardList = ValueNotifier([]);

  final ValueNotifier<int?> wardId = ValueNotifier(null);
  final ValueNotifier<int?> countryId = ValueNotifier(null);
  final ValueNotifier<int?> stateId = ValueNotifier(null);
  final ValueNotifier<int?> districtId = ValueNotifier(null);
  final ValueNotifier<int?> cityId = ValueNotifier(null);
  final ValueNotifier<int?> villageId = ValueNotifier(null);

  final ValueNotifier<int> _stateReset = ValueNotifier(0);
  final ValueNotifier<int> _districtReset = ValueNotifier(0);
  final ValueNotifier<int> _cityReset = ValueNotifier(0);
  final ValueNotifier<int> _villageReset = ValueNotifier(0);
  final ValueNotifier<int> _wardReset = ValueNotifier(0);

  // Raw rows for the currently selected city — kept around so ward options
  // can be re-derived whenever the village selection changes.
  List<CityModel> _cityRows = [];

  @override
  void initState() {
    super.initState();
    loadAddressFromCache();
  }

  @override
  void dispose() {
    stateList.dispose();
    districtList.dispose();
    cityList.dispose();
    villageList.dispose();
    countryId.dispose();
    stateId.dispose();
    districtId.dispose();
    cityId.dispose();
    villageId.dispose();
    _stateReset.dispose();
    _districtReset.dispose();
    _cityReset.dispose();
    _villageReset.dispose();
    wardList.dispose();
    wardId.dispose();
    _wardReset.dispose();
    super.dispose();
  }

  Future<void> loadAddressFromCache() async {
    final utilsRepository = serviceLocator<UtilsRepository>();
    final result = await utilsRepository.getAddressMaster();

    result.fold((failure) => debugPrint('Error: ${failure.message}'), (parsed) {
      addressTree = parsed.addressTree;
      setState(() {
        countryList = parsed.countryList;
      });
      _applyPrefill();
    });
  }

  void handleCountryChange(int cntId) {
    final states = addressTree[cntId];
    _stateReset.value++;
    _districtReset.value++;
    _cityReset.value++;
    _villageReset.value++;
    _wardReset.value++;
    _cityRows = [];
    if (states == null) {
      stateList.value = [];
      districtList.value = [];
      cityList.value = [];
      villageList.value = [];
      wardList.value = [];
      return;
    }
    stateList.value =
        states.entries.map((e) {
          final first = e.value.values.first.values.first.first;
          return {'zAttributesId': e.key, 'DisplayName': first.stateName};
        }).toList();
    districtList.value = [];
    cityList.value = [];
    villageList.value = [];
    wardList.value = [];
  }

  void handleStateChange(int sId) {
    final districts = addressTree[countryId.value]?[sId];
    _districtReset.value++;
    _cityReset.value++;
    _villageReset.value++;
    _wardReset.value++;
    _cityRows = [];
    if (districts == null) {
      districtList.value = [];
      cityList.value = [];
      villageList.value = [];
      wardList.value = [];
      return;
    }
    districtList.value =
        districts.entries.map((e) {
          final first = e.value.values.first.first;
          return {'zAttributesId': e.key, 'DisplayName': first.districtName};
        }).toList();
    cityList.value = [];
    villageList.value = [];
    wardList.value = [];
  }

  void handleDistrictChange(int dId) {
    final cities = addressTree[countryId.value]?[stateId.value]?[dId];
    _cityReset.value++;
    _villageReset.value++;
    _wardReset.value++;
    _cityRows = [];
    if (cities == null) {
      cityList.value = [];
      villageList.value = [];
      wardList.value = [];
      return;
    }
    cityList.value =
        cities.entries.map((e) {
          final first = e.value.first;
          return {'zAttributesId': e.key, 'DisplayName': first.cityName};
        }).toList();
    villageList.value = [];
    wardList.value = [];
  }

  void handleCityChange(int cId) {
    final villages =
        addressTree[countryId.value]?[stateId.value]?[districtId.value]?[cId];
    _villageReset.value++;
    _wardReset.value++;
    if (villages == null) {
      _cityRows = [];
      villageList.value = [];
      wardList.value = [];
      return;
    }
    _cityRows = villages;
    // A village can appear multiple times in this list (once per ward),
    // so dedupe by villageMasterId for the dropdown options.
    final seenVillages = <int>{};
    villageList.value =
        villages
            .where((e) => seenVillages.add(e.villageMasterId))
            .map(
              (e) => {
                'zAttributesId': e.villageMasterId,
                'DisplayName': e.villageName,
              },
            )
            .toList();
    wardList.value = [];
  }

  void handleVillageChange(int vId) {
    _wardReset.value++;
    final rowsForVillage =
        _cityRows.where((e) => e.villageMasterId == vId).toList();
    if (rowsForVillage.isEmpty) {
      wardList.value = [];
      return;
    }
    final seenWards = <int>{};
    wardList.value =
        rowsForVillage
            .where((e) => seenWards.add(e.wardMasterId))
            .map(
              (e) => {
                'zAttributesId': e.wardMasterId,
                'DisplayName': e.wardName,
              },
            )
            .toList();
  }

  void _applyPrefill() {
    final cntId = widget.incomingCountryId;
    final sId = widget.incomingStateId;
    final dId = widget.incomingDistrictId;
    final cId = widget.incomingCityId;
    final vId = widget.incomingVillageId;
    final wId = widget.incomingWardId;

    if (cntId == null) return;
    if (!countryList.any((e) => e['zAttributesId'] == cntId)) return;

    countryId.value = cntId;
    handleCountryChange(cntId);

    if (sId == null) return;
    if (!stateList.value.any((e) => e['zAttributesId'] == sId)) return;

    stateId.value = sId;
    handleStateChange(sId);

    int? resolvedDistrictId = dId;

    if (resolvedDistrictId == null && cId != null) {
      final states = addressTree[cntId];
      if (states != null) {
        outer:
        for (final sEntry in states.entries) {
          for (final dEntry in sEntry.value.entries) {
            if (dEntry.value.values.any(
              (list) => list.any((e) => e.cityMasterId == cId),
            )) {
              resolvedDistrictId = dEntry.key;
              break outer;
            }
          }
        }
      }
    }

    if (resolvedDistrictId == null) return;
    districtId.value = resolvedDistrictId;
    handleDistrictChange(resolvedDistrictId);

    if (cId != null) {
      cityId.value = cId;
      handleCityChange(cId);
    }

    if (vId != null) {
      villageId.value = vId;
      handleVillageChange(vId);
    }

    if (wId != null) {
      wardId.value = wId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Country
        ValueListenableBuilder<int?>(
          valueListenable: countryId,
          builder: (_, val, __) {
            return CustomDropDownWidget(
              key: ValueKey(val),
              initialValue:
                  val == null
                      ? null
                      : countryList.firstWhereOrNull(
                        (e) => e['zAttributesId'] == val,
                      ),
              title: 'Country',
              hintText: 'Select Country',
              isRequired: true,
              dataList: countryList,
              onSelected: (map) {
                countryId.value = map['zAttributesId'];
                stateId.value = null;
                districtId.value = null;
                cityId.value = null;
                villageId.value = null;
                wardId.value = null;
                handleCountryChange(countryId.value!);
                widget.countryChange(map);
              },
              validator:
                  (value) => value == null ? 'Country is required' : null,
              onValueClear: () {
                countryId.value = null;
                stateId.value = null;
                districtId.value = null;
                cityId.value = null;
                villageId.value = null;
                wardId.value = null;
              },
            );
          },
        ),
        // State
        ValueListenableBuilder<int>(
          valueListenable: _stateReset,
          builder: (_, resetVal, __) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: stateList,
              builder: (_, list, __) {
                return ValueListenableBuilder<int?>(
                  valueListenable: stateId,
                  builder: (_, val, __) {
                    return CustomDropDownWidget(
                      isDisabled: (countryId.value == null),
                      key: ValueKey('state_${val}_${list.length}_$resetVal'),
                      initialValue:
                          val == null
                              ? null
                              : list.firstWhereOrNull(
                                (e) => e['zAttributesId'] == val,
                              ),
                      title: 'State',
                      hintText: 'Select State',
                      isRequired: true,
                      dataList: list,
                      onSelected: (map) {
                        stateId.value = map['zAttributesId'];
                        districtId.value = null;
                        cityId.value = null;
                        villageId.value = null;
                        wardId.value = null;
                        handleStateChange(stateId.value!);
                        widget.stateChange(map);
                      },
                      validator:
                          (value) => value == null ? 'State is required' : null,
                      onValueClear: () {
                        stateId.value = null;
                        districtId.value = null;
                        cityId.value = null;
                        villageId.value = null;
                        wardId.value = null;
                      },
                    );
                  },
                );
              },
            );
          },
        ),

        // District
        ValueListenableBuilder<int>(
          valueListenable: _districtReset,
          builder: (_, resetVal, __) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: districtList,
              builder: (_, list, __) {
                return ValueListenableBuilder<int?>(
                  valueListenable: districtId,
                  builder: (_, val, __) {
                    return CustomDropDownWidget(
                      isDisabled: (stateId.value == null),
                      key: ValueKey('district_${val}_${list.length}_$resetVal'),
                      initialValue:
                          val == null
                              ? null
                              : list.firstWhereOrNull(
                                (e) => e['zAttributesId'] == val,
                              ),
                      title: 'District',
                      hintText: 'Select District',
                      isRequired: true,
                      dataList: list,
                      onSelected: (map) {
                        districtId.value = map['zAttributesId'];
                        cityId.value = null;
                        villageId.value = null;
                        wardId.value = null;
                        handleDistrictChange(districtId.value!);
                        widget.districtChange(map);
                      },
                      validator:
                          (value) =>
                              value == null ? 'District is required' : null,
                      onValueClear: () {
                        districtId.value = null;
                        cityId.value = null;
                        villageId.value = null;
                        wardId.value = null;
                      },
                    );
                  },
                );
              },
            );
          },
        ),

        // City
        ValueListenableBuilder<int>(
          valueListenable: _cityReset,
          builder: (_, resetVal, __) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: cityList,
              builder: (_, list, __) {
                return ValueListenableBuilder<int?>(
                  valueListenable: cityId,
                  builder: (_, val, __) {
                    return CustomDropDownWidget(
                      isDisabled: (districtId.value == null),
                      key: ValueKey('city_${val}_${list.length}_$resetVal'),
                      initialValue:
                          val == null
                              ? null
                              : list.firstWhereOrNull(
                                (e) => e['zAttributesId'] == val,
                              ),
                      title: 'City',
                      hintText: 'Select City',
                      isRequired: true,
                      dataList: list,
                      onSelected: (map) {
                        cityId.value = map['zAttributesId'];
                        villageId.value = null;
                        wardId.value = null;
                        handleCityChange(cityId.value!);
                        widget.cityChange(map);
                      },
                      validator:
                          (value) => value == null ? 'City is required' : null,
                      onValueClear: () {
                        cityId.value = null;
                        villageId.value = null;
                        wardId.value = null;
                      },
                    );
                  },
                );
              },
            );
          },
        ),

        // Village
        if (widget.villageChange != null)
          ValueListenableBuilder<int>(
            valueListenable: _villageReset,
            builder: (_, resetVal, __) {
              return ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: villageList,
                builder: (_, list, __) {
                  return ValueListenableBuilder<int?>(
                    valueListenable: villageId,
                    builder: (_, val, __) {
                      return CustomDropDownWidget(
                        isDisabled: (cityId.value == null),
                        key: ValueKey(
                          'village_${val}_${list.length}_$resetVal',
                        ),
                        initialValue:
                            val == null
                                ? null
                                : list.firstWhereOrNull(
                                  (e) => e['zAttributesId'] == val,
                                ),
                        title: 'Village',
                        hintText: 'Select Village',
                        isRequired: true,
                        dataList: list,
                        onSelected: (map) {
                          villageId.value = map['zAttributesId'];
                          wardId.value = null;
                          handleVillageChange(villageId.value!);
                          widget.villageChange!(map);
                        },
                        validator:
                            (value) =>
                                value == null ? 'Village is required' : null,
                        onValueClear: () {
                          villageId.value = null;
                          wardId.value = null;
                        },
                      );
                    },
                  );
                },
              );
            },
          ),

        // Ward (optional)
        if (widget.wardChange != null)
          ValueListenableBuilder<int>(
            valueListenable: _wardReset,
            builder: (_, resetVal, __) {
              return ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: wardList,
                builder: (_, list, __) {
                  return ValueListenableBuilder<int?>(
                    valueListenable: wardId,
                    builder: (_, val, __) {
                      return CustomDropDownWidget(
                        isDisabled: (villageId.value == null),
                        key: ValueKey('ward_${val}_${list.length}_$resetVal'),
                        initialValue:
                            val == null
                                ? null
                                : list.firstWhereOrNull(
                                  (e) => e['zAttributesId'] == val,
                                ),
                        title: 'Ward',
                        isRequired: true,
                        hintText: 'Select Ward',
                        validator:
                            (value) =>
                                value == null ? 'Ward is required' : null,
                        dataList: list,
                        onSelected: (map) {
                          wardId.value = map['zAttributesId'];
                          widget.wardChange!(map);
                        },
                        onValueClear: () {
                          wardId.value = null;
                        },
                      );
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
