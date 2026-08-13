import 'package:k3h_erp_app/utils/functions/common_function.dart';

class AopAchievementReportModel {
  final int channelPartnerId;
  final String name;
  final int walkinsByCp;
  final int totalFreshVisits;
  final int revisits;
  final int bookingByCp;
  final double totalRevenue;
  final int totalIbm;
  final int ipcIbm;
  final int icpIbm;
  final int rcpIbm;
  final int totalObm;
  final int ipcObm;
  final int icpObm;
  final int rcpObm;
  final String type;

  const AopAchievementReportModel({
    required this.channelPartnerId,
    required this.name,
    required this.walkinsByCp,
    required this.totalFreshVisits,
    required this.revisits,
    required this.bookingByCp,
    required this.totalRevenue,
    required this.totalIbm,
    required this.ipcIbm,
    required this.icpIbm,
    required this.rcpIbm,
    required this.totalObm,
    required this.ipcObm,
    required this.icpObm,
    required this.rcpObm,
    required this.type,
  });

  factory AopAchievementReportModel.fromJson(Map<String, dynamic> json) {
    return AopAchievementReportModel(
      channelPartnerId: parseValue<int>(json, "ChannelPartnerId"),
      name: parseValue<String>(json, "Name"),
      walkinsByCp: parseValue<int>(json, "WalkinsByCP"),
      totalFreshVisits: parseValue<int>(json, "TotalFreshVisits"),
      revisits: parseValue<int>(json, "Revisits"),
      bookingByCp: parseValue<int>(json, "BookingByCP"),
      totalRevenue: parseValue<double>(json, "TotalRevenue"),
      totalIbm: parseValue<int>(json, "TotalIBM"),

      // API keys
      ipcIbm: parseValue<int>(json, "IPC_IBM"),
      icpIbm: parseValue<int>(json, "ICP_IBM"),
      rcpIbm: parseValue<int>(json, "RCP_IBM"),

      totalObm: parseValue<int>(json, "TotalOBM"),
      ipcObm: parseValue<int>(json, "IPC_OBM"),
      icpObm: parseValue<int>(json, "ICP_OBM"),
      rcpObm: parseValue<int>(json, "RCP_OBM"),
      type: parseValue<String>(json, "Type"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ChannelPartnerId": channelPartnerId,
      "Name": name,
      "WalkinsByCP": walkinsByCp,
      "TotalFreshVisits": totalFreshVisits,
      "Revisits": revisits,
      "BookingByCP": bookingByCp,
      "TotalRevenue": totalRevenue,
      "TotalIBM": totalIbm,

      // API keys
      "IPC_IBM": ipcIbm,
      "ICP_IBM": icpIbm,
      "RCP_IBM": rcpIbm,

      "TotalOBM": totalObm,
      "IPC_OBM": ipcObm,
      "ICP_OBM": icpObm,
      "RCP_OBM": rcpObm,
      "Type": type,
    };
  }

  /// ================= HELPERS =================

  /// Total Walkins
  int get totalWalkins => walkinsByCp + totalFreshVisits + revisits;

  /// Total IBM + OBM
  int get totalIbmObm => totalIbm + totalObm;
}
