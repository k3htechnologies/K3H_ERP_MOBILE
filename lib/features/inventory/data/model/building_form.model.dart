import 'package:flutter/material.dart';

class BuildingFormModel {
  final int id;
  final String buildingName;
  final TextEditingController numberOfBasementC;
  final TextEditingController numberOfPodiumC;
  final TextEditingController numberOfWingsC;
  List<WingFormModel> wingFormList;

  BuildingFormModel({
    this.id = 0,
    required this.buildingName,
    this.wingFormList = const [],
  }) : numberOfBasementC = TextEditingController(),
       numberOfPodiumC = TextEditingController(),
       numberOfWingsC = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingName': buildingName,
      'numberOfBasement': numberOfBasementC.text,
      'numberOfPodium': numberOfPodiumC.text,
      'numberOfWings': numberOfWingsC.text,
      'wingFormList': wingFormList.map((wing) => wing.toJson()).toList(),
    };
  }

  factory BuildingFormModel.fromJson(Map<String, dynamic> json) {
    return BuildingFormModel(
      id: json["id"],
      buildingName: json['buildingName'],
      wingFormList:
          (json['wingFormList'] as List<dynamic>)
              .map((wingJson) => WingFormModel.fromJson(wingJson))
              .toList(),
    );
  }
}

class WingFormModel {
  final String wingName;
  final TextEditingController numberOfFloorC;
  final TextEditingController numberOfFlatsC;

  WingFormModel({required this.wingName})
    : numberOfFloorC = TextEditingController(),
      numberOfFlatsC = TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'wingName': wingName,
      'numberOfFloor': numberOfFloorC.text,
      'numberOfFlats': numberOfFlatsC.text,
    };
  }

  factory WingFormModel.fromJson(Map<String, dynamic> json) {
    return WingFormModel(wingName: json['wingName']);
  }

  dispose() {
    numberOfFloorC.dispose();
    numberOfFlatsC.dispose();
  }
}
