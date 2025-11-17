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
  final Function(Map<String, dynamic>) stateChange;
  final Function(Map<String, dynamic>) districtChange;
  final Function(Map<String, dynamic>) cityChange;
  final GlobalKey<FormState> formKey;
  const AddressWidget({
    super.key,
    this.incomingStateId,
    this.incomingDistrictId,
    this.incomingCityId,
    required this.stateChange,
    required this.districtChange,
    required this.cityChange,
    required this.formKey,
  });

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {

  late BaseClient baseClient;


  List<Map<String, dynamic>> stateList = [];
  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> cityList = [];

  Map<int, List<CityModel>> groupedStateData = {};
  Map<int, List<CityModel>> districtMap = {};

  int? stateId;
  int? districtId;
  int? cityId;


  @override
  void initState() {
    baseClient = BaseClient();
    apiCallPullCountryStateCityDistrictVillage();
    super.initState();
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
        stateId = widget.incomingStateId!;
        handleStateChange(stateId!);
        districtId = widget.incomingDistrictId!;
        handleDistrictChange(districtId!);
        setState(() {
          cityId = widget.incomingCityId!;
        });
      }
      setState(() {});
    } catch (error) {
      ErrorHandler.getErrorMessage(error);
    }
  }

  void handleStateChange(int stateIdF) {
    districtList.clear();
    cityList.clear();

    districtMap = groupBy(
      groupedStateData[stateIdF]!,
          (e) => e.districtMasterId,
    );

    districtMap.forEach((key, value) {
      districtList.add({
        "zAttributesId": value[0].districtMasterId,
        "DisplayName": value[0].districtName,
      });
    });

    setState(() {});
  }

  void handleDistrictChange(int districtId) {
    cityList.clear();

    Map<int, List<CityModel>> groupedCityMap = groupBy(
      districtMap[districtId]!,
          (e) => e.districtMasterId,
    );

    groupedCityMap.forEach((key, value) {
      cityList.add({
        "zAttributesId": value[0].cityMasterId,
        "DisplayName": value[0].cityName,
      });
    });

    setState(() {});
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
              child: CustomDropDownWidget(
                initialValue:
                stateId == null
                    ? null
                    : stateList.firstWhere(
                      (state) => state['zAttributesId'] == stateId,
                ),
                title: "State*",
                dataList: stateList,
                onSelected: (stateMap) {
                  districtId = null;
                  cityId = null;
                  stateId = stateMap['zAttributesId'];
                  handleStateChange(stateId!);
                  widget.stateChange(stateMap);
                },
                validator: (s) {
                  if (s == null) {
                    return "State is required";
                  }
                  return null;
                },
              ),
            ),

            Expanded(
              child: CustomDropDownWidget(
                initialValue:
                districtId == null
                    ? null
                    : districtList.firstWhere(
                      (district) =>
                  district['zAttributesId'] == districtId,
                ),
                title: "District*",
                dataList: districtList,
                onSelected: (districtMap) {
                  districtId = districtMap['zAttributesId'];
                  cityId = null;
                  handleDistrictChange(districtId!);
                  widget.districtChange(districtMap);
                },
                validator: (s) {
                  if (s == null) {
                    return "District is required";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        CustomDropDownWidget(
          initialValue:
          cityId == null
              ? null
              : cityList.firstWhere(
                (city) => city['zAttributesId'] == cityId,
          ),
          title: "City*",
          dataList: cityList,
          onSelected: (cityselectedmap) {
            cityId = cityselectedmap['zAttributesId'];
            setState(() {});
            widget.cityChange(cityselectedmap);
          },
          validator: (s) {
            if (s == null) {
              return "City is required";
            }
            return null;
          },
        ),
      ],
    );
  }
}