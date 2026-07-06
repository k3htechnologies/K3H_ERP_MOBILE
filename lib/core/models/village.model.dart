import 'package:k3h_erp_app/utils/functions/common_function.dart';

class VillageModel {
  final int villageMasterId;
  final String villageName;

  VillageModel({required this.villageMasterId, required this.villageName});

  factory VillageModel.fromJson(Map<String, dynamic> json) {
    return VillageModel(
      villageMasterId: parseValue<int>(json, "VillageMasterId"),
      villageName: parseValue<String>(json, "VillageName"),
    );
  }

  Map<String, dynamic> toJson() {
    return {"VillageMasterId": villageMasterId, "VillageName": villageName};
  }
}
