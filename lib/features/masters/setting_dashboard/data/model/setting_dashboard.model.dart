import 'package:k3h_erp_app/utils/common_function.dart';

class SettingDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;
  final List<Table6> table6;

  SettingDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
  });

  factory SettingDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => SettingDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<Table5>.from(json["Table5"].map((x) => Table5.fromJson(x))),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x.toJson())),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
  };
}

class Table0 {
  final int totalCompanies;
  final int totalEmployees;
  final int activeProjects;
  final int registeredVendors;
  final double payrollConfiguredPercent;

  Table0({
    required this.totalCompanies,
    required this.totalEmployees,
    required this.activeProjects,
    required this.registeredVendors,
    required this.payrollConfiguredPercent,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalCompanies: parseValue<int>(json, "TotalCompanies"),
    totalEmployees: parseValue<int>(json, "TotalEmployees"),
    activeProjects: parseValue<int>(json, "ActiveProjects"),
    registeredVendors: parseValue<int>(json, "RegisteredVendors"),
    payrollConfiguredPercent:
        parseValue<double>(json, "PayrollConfiguredPercent").toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "TotalCompanies": totalCompanies,
    "TotalEmployees": totalEmployees,
    "ActiveProjects": activeProjects,
    "RegisteredVendors": registeredVendors,
    "PayrollConfiguredPercent": payrollConfiguredPercent,
  };
}

class Table1 {
  final int departments;
  final int designations;
  final int employees;
  final int branches;
  final int banksListed;
  final int tnc;

  Table1({
    required this.departments,
    required this.designations,
    required this.employees,
    required this.branches,
    required this.banksListed,
    required this.tnc,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    departments: parseValue<int>(json, "Departments"),
    designations: parseValue<int>(json, "Designations"),
    employees: parseValue<int>(json, "Employees"),
    branches: parseValue<int>(json, "Branches"),
    banksListed: parseValue<int>(json, "BanksListed"),
    tnc: parseValue<int>(json, "TNC"),
  );

  Map<String, dynamic> toJson() => {
    "Departments": departments,
    "Designations": designations,
    "Employees": employees,
    "Branches": branches,
    "BanksListed": banksListed,
    "TNC": tnc,
  };
}

class Table2 {
  final int totalMaterial;
  final int totalSubMaterial;
  final int materialWithoutSubMaterial;
  final int uom;

  Table2({
    required this.totalMaterial,
    required this.totalSubMaterial,
    required this.materialWithoutSubMaterial,
    required this.uom,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    totalMaterial: parseValue<int>(json, "TotalMaterial"),
    totalSubMaterial: parseValue<int>(json, "TotalSubMaterial"),
    materialWithoutSubMaterial: parseValue<int>(
      json,
      "MaterialWithoutSubMaterial",
    ),
    uom: parseValue<int>(json, "UOM"),
  );

  Map<String, dynamic> toJson() => {
    "TotalMaterial": totalMaterial,
    "TotalSubMaterial": totalSubMaterial,
    "MaterialWithoutSubMaterial": materialWithoutSubMaterial,
    "UOM": uom,
  };
}

class Table3 {
  final int totalVendors;
  final int missingDetails;
  final int recentlyAddedVendors;
  final int totalMaterial;
  final int contractCount;

  Table3({
    required this.totalVendors,
    required this.missingDetails,
    required this.recentlyAddedVendors,
    required this.totalMaterial,
    required this.contractCount,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    totalVendors: parseValue<int>(json, "TotalVendors"),
    missingDetails: parseValue<int>(json, "MissingDetails"),
    recentlyAddedVendors: parseValue<int>(json, "RecentlyAddedVendors"),
    totalMaterial: parseValue<int>(json, "TotalMaterial"),
    contractCount: parseValue<int>(json, "ContractCount"),
  );

  Map<String, dynamic> toJson() => {
    "TotalVendors": totalVendors,
    "MissingDetails": missingDetails,
    "RecentlyAddedVendors": recentlyAddedVendors,
    "TotalMaterial": totalMaterial,
    "ContractCount": contractCount,
  };
}

class Table4 {
  final int totalProjects;
  final int redevelopment;
  final int reraRegistered;

  Table4({
    required this.totalProjects,
    required this.redevelopment,
    required this.reraRegistered,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    totalProjects: parseValue<int>(json, "TotalProjects"),
    redevelopment: parseValue<int>(json, "Redevelopment"),
    reraRegistered: parseValue<int>(json, "RERARegistered"),
  );

  Map<String, dynamic> toJson() => {
    "TotalProjects": totalProjects,
    "Redevelopment": redevelopment,
    "RERARegistered": reraRegistered,
  };
}

class Table5 {
  final String companyType;
  final int vendorCount;

  Table5({required this.companyType, required this.vendorCount});

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    companyType: parseValue<String>(json, "CompanyType"),
    vendorCount: parseValue<int>(json, "VendorCount"),
  );

  Map<String, dynamic> toJson() => {
    "CompanyType": companyType,
    "VendorCount": vendorCount,
  };
}

class Table6 {
  final int activeProjects;
  final int onHoldProjects;

  Table6({required this.activeProjects, required this.onHoldProjects});

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    activeProjects: parseValue<int>(json, "ActiveProjects"),
    onHoldProjects: parseValue<int>(json, "OnHoldProjects"),
  );

  Map<String, dynamic> toJson() => {
    "ActiveProjects": activeProjects,
    "OnHoldProjects": onHoldProjects,
  };
}
