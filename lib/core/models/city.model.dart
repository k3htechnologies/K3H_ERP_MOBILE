import 'package:k3h_erp_app/utils/functions/common_function.dart';
class CityModel {
  final int countryMasterId;
  final String countryName;
  final int stateMasterId;
  final String stateName;
  final int districtMasterId;
  final String districtName;
  final int cityMasterId;
  final String cityName;
  final int villageMasterId;
  final String villageName;
  final int wardMasterId;
  final String wardName;
  CityModel({
    required this.countryMasterId,
    required this.countryName,
    required this.stateMasterId,
    required this.stateName,
    required this.districtMasterId,
    required this.districtName,
    required this.cityMasterId,
    required this.cityName,
    required this.villageMasterId,
    required this.villageName,
    required this.wardMasterId,
    required this.wardName,
  });
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      countryMasterId: parseValue<int>(json, "CountryMasterId"),
      countryName: parseValue<String>(json, "CountryName"),
      stateMasterId: parseValue<int>(json, "StateMasterId"),
      stateName: parseValue<String>(json, "StateName"),
      districtMasterId: parseValue<int>(json, "DistrictMasterId"),
      districtName: parseValue<String>(json, "DistrictName"),
      cityMasterId: parseValue<int>(json, "CityMasterId"),
      cityName: parseValue<String>(json, "CityName"),
      villageMasterId: parseValue<int>(json, "VillageMasterId"),
      villageName: parseValue<String>(json, "VillageName"),
      wardMasterId: parseValue<int>(json, "WardMasterId"),
      wardName: parseValue<String>(json, "WardName"),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'CountryMasterId': countryMasterId,
      'CountryName': countryName,
      'StateMasterId': stateMasterId,
      'StateName': stateName,
      'DistrictMasterId': districtMasterId,
      'DistrictName': districtName,
      'CityMasterId': cityMasterId,
      'CityName': cityName,
      'VillageMasterId': villageMasterId,
      'VillageName': villageName,
      'WardMasterId': wardMasterId,
      'WardName': wardName,
    };
  }
}
