import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/models/city.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

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
    apiCallPullCountryStateCityDistrictVillage();
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

  Future apiCallPullCountryStateCityDistrictVillage() async {
    String pullCountryStateCityDistrictVillage =
        'Static/PullCountryStateCityDistrictVillage';

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCountryStateCityDistrictVillage,
      );

      var dataList = List<CityModel>.from(
        networkResponse['data']["CountryStateCityDistrictVillageData"].map(
          (e) => CityModel.fromJson(e),
        ),
      );

      groupedStateData = groupBy(dataList, (e) => e.stateMasterId);

      groupedStateData.forEach((key, value) {
        stateList.add({
          "zAttributesId": key,
          "DisplayName": value[0].stateName,
        });
      });
      if (widget.incomingStateId != null) {
        stateId.value = widget.incomingStateId!;
        handleStateChange(stateId.value!);
        districtId.value = widget.incomingDistrictId!;
        handleDistrictChange(districtId.value!);
        cityId.value = widget.incomingCityId!;
        if (cityId.value != null) {
          handleCityChange(cityId.value!);
          villageId.value = widget.incomingVillageId;
        }
      }
    } catch (error) {
      ErrorHandler.getErrorMessage(error);
    }
  }

  void handleStateChange(int stateIdF) {
    // Guard against missing state data
    if (!groupedStateData.containsKey(stateIdF)) {
      districtList.value = [];
      cityList.value = [];
      villageList.value = [];
      return;
    }

    final newDistrictList = <Map<String, dynamic>>[];
    cityList.value = [];
    villageList.value = [];

    districtMap = groupBy(
      groupedStateData[stateIdF]!,
      (e) => e.districtMasterId,
    );

    districtMap.forEach((key, value) {
      newDistrictList.add({
        "zAttributesId": value[0].districtMasterId,
        "DisplayName": value[0].districtName,
      });
    });

    districtList.value = newDistrictList;
  }

  void handleDistrictChange(int districtId) {
    // Guard against missing district data
    if (!districtMap.containsKey(districtId)) {
      cityList.value = [];
      villageList.value = [];
      return;
    }

    final newCityList = <Map<String, dynamic>>[];
    villageList.value = [];

    cityMap = groupBy(districtMap[districtId]!, (e) => e.cityMasterId);

    cityMap.forEach((key, value) {
      newCityList.add({
        "zAttributesId": value[0].cityMasterId,
        "DisplayName": value[0].cityName,
      });
    });

    cityList.value = newCityList;
  }

  void handleCityChange(int cityIdF) {
    final newVillageList = <Map<String, dynamic>>[];

    // Only populate village list if villageChange callback is provided
    if (widget.villageChange != null && cityMap.containsKey(cityIdF)) {
      final villageData = cityMap[cityIdF]!;
      final villageMap = groupBy(villageData, (e) => e.villageMasterId);

      villageMap.forEach((key, value) {
        if (value.isNotEmpty) {
          newVillageList.add({
            "zAttributesId": value[0].villageMasterId,
            "DisplayName": value[0].villageName,
          });
        }
      });
    }

    villageList.value = newVillageList;
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
                    initialValue:
                        currentStateId == null
                            ? null
                            : stateList.firstWhere(
                              (state) =>
                                  state['zAttributesId'] == currentStateId,
                            ),
                    title: "State",
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
                        initialValue:
                            currentDistrictId == null ||
                                    currentDistrictList.isEmpty
                                ? null
                                : currentDistrictList.any(
                                  (district) =>
                                      district['zAttributesId'] ==
                                      currentDistrictId,
                                )
                                    ? currentDistrictList.firstWhere(
                                      (district) =>
                                          district['zAttributesId'] ==
                                          currentDistrictId,
                                    )
                                    : null,
                        title: "District",
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
                  initialValue:
                      currentCityId == null || currentCityList.isEmpty
                          ? null
                          : currentCityList.any(
                            (city) => city['zAttributesId'] == currentCityId,
                          )
                              ? currentCityList.firstWhere(
                                (city) => city['zAttributesId'] == currentCityId,
                              )
                              : null,
                  title: "City",
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
