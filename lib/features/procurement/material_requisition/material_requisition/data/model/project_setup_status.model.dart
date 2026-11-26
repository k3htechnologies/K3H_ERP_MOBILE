import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectSetupStatusModel {
  final int projectId;
  final bool isCompanyId;
  final bool isGstNumber;
  final bool isBank;
  final bool isApproval;
  const ProjectSetupStatusModel({
    required this.projectId,
    required this.isCompanyId,
    required this.isGstNumber,
    required this.isBank,
    required this.isApproval,
  });

  factory ProjectSetupStatusModel.fromJson(Map<String, dynamic> json) {
    return ProjectSetupStatusModel(
      projectId: parseValue<int>(json, "ProjectId"),
      isCompanyId: parseValue<bool>(json, "IsCompanyId"),
      isGstNumber: parseValue<bool>(json, "IsGSTNumber"),
      isBank: parseValue<bool>(json, "IsBank"),
      isApproval: parseValue<bool>(json, "IsApproval"),
    );
  }

  Map<String, dynamic> tojson() => {
    'ProjectId': projectId,
    'IsCompanyId': isCompanyId,
    "IsGstNumber": isGstNumber,
    "IsBank": isBank,
    "IsApproval": isApproval,
  };
  bool get isAllComplete => isCompanyId && isGstNumber && isBank && isApproval;
}
