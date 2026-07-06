import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ModuleModel {
  int modulesMasterId;
  String moduleName;
  String icon;
  List<SubModuleModel> subModuleData;
  bool isSelected;

  ModuleModel({
    required this.modulesMasterId,
    required this.moduleName,
    required this.icon,
    required this.subModuleData,
    this.isSelected = false,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) => ModuleModel(
    modulesMasterId: parseValue<int>(json, "ModulesMasterId"),
    moduleName: parseValue<String>(json, "ModuleName"),
    icon: parseValue<String>(json, "Icon"),
    subModuleData: List<SubModuleModel>.from(
      json["SubModuleData"].map((x) => SubModuleModel.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "ModulesMasterId": modulesMasterId,
    "ModuleName": moduleName,
    "Icon": icon,
    "SubModuleData": List<dynamic>.from(subModuleData.map((x) => x.toJson())),
  };
}

class SubModuleModel {
  int subModulesMasterId;
  String subModuleName;
  String icon;
  String path;
  bool isAction;
  bool isView;
  bool isExport;
  bool isSelected;
  List<SubSubModuleModel> subSubModuleData;

  SubModuleModel({
    required this.subModulesMasterId,
    required this.subModuleName,
    required this.icon,
    required this.path,
    this.isAction = false,
    this.isView = false,
    this.isExport = false,
    this.isSelected = false,
    required this.subSubModuleData,
  });

  factory SubModuleModel.fromJson(Map<String, dynamic> json) => SubModuleModel(
    subModulesMasterId: parseValue<int>(json, "SubModulesMasterId"),
    subModuleName: parseValue<String>(json, "SubModuleName"),
    icon: parseValue<String>(json, "Icon"),
    path: parseValue<String>(json, "Path"),
    isAction: parseValue<bool>(json, "IsAction"),
    isView: parseValue<bool>(json, "IsView"),
    isExport: parseValue<bool>(json, "IsExport"),
    subSubModuleData:
    json["SubSubModuleData"] == null
        ? []
        : List<SubSubModuleModel>.from(
      json["SubSubModuleData"]!.map(
            (x) => SubSubModuleModel.fromJson(x),
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "SubModulesMasterId": subModulesMasterId,
    "SubModuleName": subModuleName,
    "Icon": icon,
    "Path": path,
    "IsAction": isAction,
    "IsExport": isExport,
    "IsView": isView,
    "SubSubModuleData": List<dynamic>.from(
      subSubModuleData.map((x) => x.toJson()),
    ),
  };
}

class SubSubModuleModel {
  int subSubModulesMasterId;
  String subSubModuleName;
  String icon;
  String path;
  bool isDisplay;
  bool isAction;
  bool isView;
  bool isExport;

  SubSubModuleModel({
    required this.subSubModulesMasterId,
    required this.subSubModuleName,
    required this.icon,
    required this.path,
    this.isDisplay = false,
    this.isAction = false,
    this.isView = false,
    this.isExport = false,
  });

  factory SubSubModuleModel.fromJson(Map<String, dynamic> json) =>
      SubSubModuleModel(
        subSubModulesMasterId: parseValue(json, "SubSubModulesMasterId"),
        subSubModuleName: parseValue(json, "SubSubModuleName"),
        icon: parseValue<String>(json, "Icon"),
        path: parseValue<String>(json, "Path"),
        isDisplay: parseValue<bool>(json, "IsDisplay"),
        isAction: parseValue<bool>(json, "IsAction"),
        isView: parseValue<bool>(json, "IsView"),
        isExport: parseValue<bool>(json, "IsExport"),
      );

  Map<String, dynamic> toJson() => {
    "SubSubModulesMasterId": subSubModulesMasterId,
    "SubSubModuleName": subSubModuleName,
    "Icon": icon,
    "Path": path,
    "IsDisplay": isDisplay,
    "IsAction": isAction,
    "IsView": isView,
    "IsExport": isExport,
  };
}