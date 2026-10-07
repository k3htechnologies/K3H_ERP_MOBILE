import 'package:k3h_erp_app/utils/functions/common_function.dart';

class BudgetModel {
  int budgetId;
  String uniqueKey;
  int projectId;
  String categoryName;
  String levelType;
  int levelId1;
  String level1Name;
  int levelId2;
  String level2Name;
  int levelId3;
  String level3Name;
  int levelId4;
  String level4Name;
  String level4MaterialName;
  String level4SubMaterialUomCode;
  String level4SubMaterialUom;
  String level4IsTolerant;
  int level4LeadTimeInDays;
  String uom;
  String inventoryFlatId;
  String flat;
  int orderBy;
  String wBSCode;
  double quantity;
  double receivedQuantity;
  double labourCost;
  double materialCost;
  double pMCost;
  double totalRate;
  double budgetAmount;
  String remark;
  bool isAccessToDelete;
  int createdById;
  String createdBy;
  DateTime createdDate;
  int modifiedById;
  String modifiedBy;
  DateTime? modifiedDate;
  bool isApproval;
  String approvalStatus;
  double l3Quantity;
  double orderQuantity;

  BudgetModel({
    required this.budgetId,
    required this.uniqueKey,
    required this.projectId,
    required this.categoryName,
    required this.levelType,
    required this.levelId1,
    required this.level1Name,
    required this.levelId2,
    required this.level2Name,
    required this.levelId3,
    required this.level3Name,
    required this.levelId4,
    required this.level4Name,
    required this.level4MaterialName,
    required this.level4SubMaterialUomCode,
    required this.level4SubMaterialUom,
    required this.level4LeadTimeInDays,
    required this.level4IsTolerant,
    required this.uom,
    required this.inventoryFlatId,
    required this.flat,
    required this.orderBy,
    required this.wBSCode,
    required this.quantity,
    required this.receivedQuantity,
    required this.labourCost,
    required this.materialCost,
    required this.pMCost,
    required this.totalRate,
    required this.budgetAmount,
    required this.remark,
    required this.isAccessToDelete,
    required this.createdById,
    required this.createdBy,
    required this.createdDate,
    required this.modifiedById,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.isApproval,
    required this.approvalStatus,
    required this.l3Quantity,
    required this.orderQuantity,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    budgetId: parseValue<int>(json, "BudgetId"),
    uniqueKey: parseValue<String>(json, "UniqueKey"),
    projectId: parseValue<int>(json, "ProjectId"),
    categoryName: parseValue<String>(json, "CategoryName"),
    levelType: parseValue<String>(json, "LevelType"),
    levelId1: parseValue<int>(json, "LevelId1"),
    level1Name: parseValue<String>(json, "Level1Name"),
    levelId2: parseValue<int>(json, "LevelId2"),
    level2Name: parseValue<String>(json, "Level2Name"),
    levelId3: parseValue<int>(json, "LevelId3"),
    level3Name: parseValue<String>(json, "Level3Name"),
    levelId4: parseValue<int>(json, "LevelId4"),
    level4Name: parseValue<String>(json, "Level4Name"),
    level4MaterialName: parseValue<String>(json, "Level4MaterialName"),
    level4SubMaterialUomCode: parseValue<String>(
      json,
      "Level4SubMaterialUomCode",
    ),
    level4SubMaterialUom: parseValue<String>(json, "Level4SubMaterialUom"),
    level4LeadTimeInDays: parseValue<int>(json, "Level4LeadTimeInDays"),
    level4IsTolerant: parseValue<String>(json, "Level4IsTolerant"),
    uom: parseValue<String>(json, "Uom"),
    inventoryFlatId: parseValue<String>(json, "InventoryFlatId"),
    flat: parseValue<String>(json, "Flat"),
    orderBy: parseValue<int>(json, "OrderBy"),
    wBSCode: parseValue<String>(json, "WBSCode"),
    quantity: parseValue<double>(json, "Quantity"),
    receivedQuantity: parseValue<double>(json, "ReceivedQuantity"),
    labourCost: parseValue<double>(json, "LabourCost"),
    materialCost: parseValue<double>(json, "MaterialCost"),
    pMCost: parseValue<double>(json, "PMCost"),
    totalRate: parseValue<double>(json, "TotalRate"),
    budgetAmount: parseValue<double>(json, "BudgetAmount"),
    remark: parseValue<String>(json, "Remark"),
    isAccessToDelete: parseValue<bool>(json, "IsAccessToDelete"),
    createdById: parseValue<int>(json, "CreatedById"),
    createdBy: parseValue<String>(json, "CreatedBy"),
    createdDate: parseValue<DateTime>(json, "CreatedDate"),
    modifiedById: parseValue<int>(json, "ModifiedById"),
    modifiedBy: parseValue<String>(json, "ModifiedBy"),
    modifiedDate:
        json['ModifiedDate'] == null
            ? null
            : parseValue<DateTime>(json, "ModifiedDate"),
    isApproval: parseValue<bool>(json, "IsApproval"),
    approvalStatus: parseValue<String>(json, "ApprovalStatus"),
    l3Quantity: parseValue<double>(json, "L3Quantity"),
    orderQuantity: parseValue<double>(json, "OrderQuantity"),
  );

  Map<String, dynamic> toJson() => {
    "BudgetId": budgetId,
    "UniqueKey": uniqueKey,
    "ProjectId": projectId,
    "CategoryName": categoryName,
    "LevelType": levelType,
    "LevelId1": levelId1,
    "Level1Name": level1Name,
    "LevelId2": levelId2,
    "Level2Name": level2Name,
    "LevelId3": levelId3,
    "Level3Name": level3Name,
    "LevelId4": levelId4,
    "Level4Name": level4Name,
    "Level4MaterialName": level4MaterialName,
    "Level4SubMaterialUomCode": level4SubMaterialUomCode,
    "Level4SubMaterialUom": level4SubMaterialUom,
    "Level4LeadTimeInDays": level4LeadTimeInDays,
    "Level4IsTolerant": level4IsTolerant,
    "Uom": uom,
    "InventoryFlatId": inventoryFlatId,
    "Flat": flat,
    "OrderBy": orderBy,
    "WBSCode": wBSCode,
    "Quantity": quantity,
    "ReceivedQuantity": receivedQuantity,
    "LabourCost": labourCost,
    "MaterialCost": materialCost,
    "PMCost": pMCost,
    "TotalRate": totalRate,
    "BudgetAmount": budgetAmount,
    "Remark": remark,
    "IsAccessToDelete": isAccessToDelete,
    "CreatedById": createdById,
    "CreatedBy": createdBy,
    "CreatedDate": createdDate.toIso8601String(),
    "ModifiedById": modifiedById,
    "ModifiedBy": modifiedBy,
    "ModifiedDate": modifiedDate?.toIso8601String(),
    "IsApproval": isApproval,
    "ApprovalStatus": approvalStatus,
    "L3Quantity": l3Quantity,
    "OrderQuantity": orderQuantity,
  };
}
