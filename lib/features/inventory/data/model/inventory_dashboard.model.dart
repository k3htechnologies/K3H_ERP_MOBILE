import 'package:k3h_erp_app/utils/common_function.dart';

class InventoryDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;

  InventoryDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
  });

  factory InventoryDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => InventoryDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
  };
}

class Table0 {
  final String projectName;
  final int totalBuilding;
  final int totalBasement;
  final int totalPodium;
  final int totalWings;
  final int totalFloors;
  final int totalFlats;
  final int allotedFlats;
  final int availableFlats;
  final int bookedFlats;
  final int holdFlats;
  final int blockedFlats;
  final int totalFlats1;

  Table0({
    required this.projectName,
    required this.totalBuilding,
    required this.totalBasement,
    required this.totalPodium,
    required this.totalWings,
    required this.totalFloors,
    required this.totalFlats,
    required this.allotedFlats,
    required this.availableFlats,
    required this.bookedFlats,
    required this.holdFlats,
    required this.blockedFlats,
    required this.totalFlats1,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    projectName: parseValue<String>(json, "ProjectName"),
    totalBuilding: parseValue<int>(json, "TotalBuilding"),
    totalBasement: parseValue<int>(json, "TotalBasement"),
    totalPodium: parseValue<int>(json, "TotalPodium"),
    totalWings: parseValue<int>(json, "TotalWings"),
    totalFloors: parseValue<int>(json, "TotalFloors"),
    totalFlats: parseValue<int>(json, "TotalFlats"),
    allotedFlats: parseValue<int>(json, "AllotedFlats"),
    availableFlats: parseValue<int>(json, "AvailableFlats"),
    bookedFlats: parseValue<int>(json, "BookedFlats"),
    holdFlats: parseValue<int>(json, "HoldFlats"),
    blockedFlats: parseValue<int>(json, "BlockedFlats"),
    totalFlats1: parseValue<int>(json, "TotalFlats1"),
  );

  Map<String, dynamic> toJson() => {
    "ProjectName": projectName,
    "TotalBuilding": totalBuilding,
    "TotalBasement": totalBasement,
    "TotalPodium": totalPodium,
    "TotalWings": totalWings,
    "TotalFloors": totalFloors,
    "TotalFlats": totalFlats,
    "AllotedFlats": allotedFlats,
    "AvailableFlats": availableFlats,
    "BookedFlats": bookedFlats,
    "HoldFlats": holdFlats,
    "BlockedFlats": blockedFlats,
    "TotalFlats1": totalFlats1,
  };
}

class Table1 {
  final String floorName;
  final int totalParking;
  final int availableParking;
  final int bookedParking;
  Table1({
    required this.floorName,
    required this.totalParking,
    required this.availableParking,
    required this.bookedParking,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    floorName: parseValue<String>(json, "FloorName"),
    totalParking: parseValue<int>(json, "TotalParking"),
    availableParking: parseValue<int>(json, "AvailableParking"),
    bookedParking: parseValue<int>(json, "BookedParking"),
  );

  Map<String, dynamic> toJson() => {
    "FloorName": floorName,
    "TotalParking": totalParking,
    "AvailableParking": availableParking,
    "BookedParking": bookedParking,
  };
}

class Table2 {
  Table2();

  factory Table2.fromJson(Map<String, dynamic> json) => Table2();

  Map<String, dynamic> toJson() => {};
}

class Table3 {
  Table3();

  factory Table3.fromJson(Map<String, dynamic> json) => Table3();

  Map<String, dynamic> toJson() => {};
}
