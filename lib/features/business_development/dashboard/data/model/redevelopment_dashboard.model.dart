import 'package:k3h_erp_app/utils/functions/common_function.dart';

class RedevelopmentDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;

  RedevelopmentDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
  });

  factory RedevelopmentDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => RedevelopmentDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
  };
}

class Table0 {
  final String buildingName;
  final String ctsNumber;
  final double totalPlotAreaSqFt;
  final int totalRecords;
  final int buildingId;
  final String cityName;
  final String villageName;
  final String wardName;

  Table0({
    required this.buildingName,
    required this.ctsNumber,
    required this.totalPlotAreaSqFt,
    required this.totalRecords,
    required this.buildingId,
    required this.cityName,
    required this.villageName,
    required this.wardName,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    buildingName: parseValue<String>(json, "BuildingName"),
    ctsNumber: parseValue<String>(json, "CTSNumber"),
    totalPlotAreaSqFt: parseValue<double>(json, "TotalPlotAreaSqFt"),
    totalRecords: parseValue<int>(json, "TotalRecords"),
    buildingId: parseValue<int>(json, "BuildingId"),
    cityName: parseValue<String>(json, "CityName"),
    villageName: parseValue<String>(json, "VillageName"),
    wardName: parseValue<String>(json, "WardName"),
  );

  Map<String, dynamic> toJson() => {
    "BuildingName": buildingName,
    "CTSNumber": ctsNumber,
    "TotalPlotAreaSqFt": totalPlotAreaSqFt,
    "TotalRecords": totalRecords,
    "BuildingId": buildingId,
    "CityName": cityName,
    "VillageName": villageName,
    "WardName": wardName,
  };
}

class Table1 {
  final String chargeType;
  final double amount;
  final int paid;

  Table1({required this.chargeType, required this.amount, required this.paid});

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    chargeType: parseValue<String>(json, "ChargeType"),
    amount: parseValue<double>(json, "Amount").toDouble(),
    paid: parseValue<int>(json, "Paid"),
  );

  Map<String, dynamic> toJson() => {
    "ChargeType": chargeType,
    "Amount": amount,
    "Paid": paid,
  };
}

class Table2 {
  int salesParking;
  int memberParking;
  int visitorsParking;

  Table2({
    required this.salesParking,
    required this.memberParking,
    required this.visitorsParking,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    salesParking: parseValue<int>(json, "SalesParking"),
    memberParking: parseValue<int>(json, "MemberParking"),
    visitorsParking: parseValue<int>(json, "VisitorsParking"),
  );

  Map<String, dynamic> toJson() => {
    "SalesParking": salesParking,
    "MemberParking": memberParking,
    "VisitorsParking": visitorsParking,
  };
}

class Table3 {
  final double flatCarpetAreaSqFt;
  final double freeAreaOfferedPercent;
  final double extraAreaPurchasedSqFt;
  final int totalRecords;
  final int buildingId;
  final String unitConfiguration;
  final String unitType;

  Table3({
    required this.flatCarpetAreaSqFt,
    required this.freeAreaOfferedPercent,
    required this.extraAreaPurchasedSqFt,
    required this.totalRecords,
    required this.buildingId,
    required this.unitConfiguration,
    required this.unitType,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    flatCarpetAreaSqFt: parseValue<double>(json, "FlatCarpetAreaSqFt"),
    freeAreaOfferedPercent: parseValue<double>(json, "FreeAreaOfferedPercent"),
    extraAreaPurchasedSqFt: parseValue<double>(json, "ExtraAreaPurchasedSqFt"),
    totalRecords: parseValue<int>(json, "TotalRecords"),
    buildingId: parseValue<int>(json, "BuildingId"),
    unitConfiguration: parseValue<String>(json, "UnitConfiguration"),
    unitType: parseValue<String>(json, "UnitType"),
  );

  Map<String, dynamic> toJson() => {
    "FlatCarpetAreaSqFt": flatCarpetAreaSqFt,
    "FreeAreaOfferedPercent": freeAreaOfferedPercent,
    "ExtraAreaPurchasedSqFt": extraAreaPurchasedSqFt,
    "TotalRecords": totalRecords,
    "BuildingId": buildingId,
    "UnitConfiguration": unitConfiguration,
    "UnitType": unitType,
  };
}

class Table4 {
  final String buildingName;
  final String column1;
  final String issue;

  Table4({
    required this.buildingName,
    required this.column1,
    required this.issue,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    buildingName: parseValue<String>(json, "BuildingName"),
    column1: parseValue<String>(json, "Column1"),
    issue: parseValue<String>(json, "Issue"),
  );

  Map<String, dynamic> toJson() => {
    "BuildingName": buildingName,
    "Column1": column1,
    "Issue": issue,
  };
}
