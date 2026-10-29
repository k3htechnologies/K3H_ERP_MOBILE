import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/model/construction_area.model.dart';

class WingGroup {
  final String wing;
  final List<ConstructionAreaModel> flats;
  WingGroup({required this.wing, required this.flats});

  double get ftfHeight => flats.first.floorToFloorHeightMt;
  double get cumulativeHeight => flats.first.cumulativeHeightMt;
}

class FloorGroup {
  final String floor;
  final List<WingGroup> wings;
  FloorGroup({required this.floor, required this.wings});
}

class BuildingSummary {
  final String buildingNumber;
  final List<FloorGroup> floors;

  BuildingSummary({required this.buildingNumber, required this.floors});

  int get wingCount =>
      floors.expand((f) => f.wings).map((w) => w.wing).toSet().length;

  int get unitCount => floors
      .expand((f) => f.wings)
      .fold<int>(0, (sum, w) => sum + w.flats.length);
}

class BuildingFloorGroup {
  final String buildingNumber;
  final String floor;
  final List<ConstructionAreaModel> flats;

  BuildingFloorGroup({
    required this.buildingNumber,
    required this.floor,
    required this.flats,
  });

  int get unitCount => flats.length;
  int get wingCount => flats.map((e) => e.wing).toSet().length;
}
