import 'package:k3h_erp_app/utils/functions/common_function.dart';

class ProjectAchievementReportModel {
  int projectId;
  String projectName;
  int totalWalkins;
  int walkinsByCp;
  int walkinsDirect;
  int totalFreshVisits;
  int revisits;
  int bookingByCp;
  int bookingDirect;
  int totalBooking;
  double totalRevenue;
  int totalIbm;
  int totalObm;
  String projectPhotoURL;

  ProjectAchievementReportModel({
    required this.projectId,
    required this.projectName,
    required this.totalWalkins,
    required this.walkinsByCp,
    required this.walkinsDirect,
    required this.totalFreshVisits,
    required this.revisits,
    required this.bookingByCp,
    required this.bookingDirect,
    required this.totalBooking,
    required this.totalRevenue,
    required this.totalIbm,
    required this.totalObm,
    required this.projectPhotoURL,
  });

  factory ProjectAchievementReportModel.fromJson(Map<String, dynamic> json) =>
      ProjectAchievementReportModel(
        projectId: parseValue<int>(json, "ProjectId"),
        projectName: parseValue<String>(json, "ProjectName"),
        projectPhotoURL: parseValue<String>(json, "ProjectPhotoURL"),
        totalWalkins: parseValue<int>(json, "TotalWalkins"),
        walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
        walkinsDirect: parseValue<int>(json, "WalkinsDirect"),
        totalFreshVisits: parseValue<int>(json, "TotalFreshVisits"),
        revisits: parseValue<int>(json, "Revisits"),
        bookingByCp: parseValue<int>(json, "BookingByCP"),
        bookingDirect: parseValue<int>(json, "BookingDirect"),
        totalBooking: parseValue<int>(json, "TotalBooking"),
        totalRevenue: parseValue<double>(json, "TotalRevenue"),
        totalIbm: parseValue<int>(json, "TotalIBM"),
        totalObm: parseValue<int>(json, "TotalOBM"),
      );

  Map<String, dynamic> toJson() => {
    "ProjectId": projectId,
    "ProjectName": projectName,
    "ProjectPhotoURL": projectPhotoURL,
    "TotalWalkins": totalWalkins,
    "WalkinsByCP": walkinsByCp,
    "WalkinsDirect": walkinsDirect,
    "TotalFreshVisits": totalFreshVisits,
    "Revisits": revisits,
    "BookingByCP": bookingByCp,
    "BookingDirect": bookingDirect,
    "TotalBooking": totalBooking,
    "TotalRevenue": totalRevenue,
    "TotalIBM": totalIbm,
    "TotalOBM": totalObm,
  };
}
