import 'package:k3h_erp_app/utils/common_function.dart';

class SalesDashboardModel {
  final List<Table0> table0;

  SalesDashboardModel({required this.table0});

  factory SalesDashboardModel.fromJson(Map<String, dynamic> json) =>
      SalesDashboardModel(
        table0: List<Table0>.from(
          json["Table0"].map((x) => Table0.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
  };
}

class Table0 {
  final int totalEnquiries;
  final int newLeadsThisMonth;
  final int activeFollowUps;
  final int lostLeadsToday;
  final int todayBookings;
  final int todayBookingValue;
  final int todayTotalCalls;
  final int todayConnected;
  final int todayNotConnected;
  final int todayRescheduled;
  final int todayClosed;

  Table0({
    required this.totalEnquiries,
    required this.newLeadsThisMonth,
    required this.activeFollowUps,
    required this.lostLeadsToday,
    required this.todayBookings,
    required this.todayBookingValue,
    required this.todayTotalCalls,
    required this.todayConnected,
    required this.todayNotConnected,
    required this.todayRescheduled,
    required this.todayClosed,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    newLeadsThisMonth: parseValue<int>(json, "NewLeadsThisMonth"),
    activeFollowUps: parseValue<int>(json, "ActiveFollowUps"),
    lostLeadsToday: parseValue<int>(json, "LostLeadsToday"),
    todayBookings: parseValue<int>(json, "TodayBookings"),
    todayBookingValue: parseValue<int>(json, "TodayBookingValue"),
    todayTotalCalls: parseValue<int>(json, "TodayTotalCalls"),
    todayConnected: parseValue<int>(json, "TodayConnected"),
    todayNotConnected: parseValue<int>(json, "TodayNotConnected"),
    todayRescheduled: parseValue<int>(json, "TodayRescheduled"),
    todayClosed: parseValue<int>(json, "TodayClosed"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEnquiries": totalEnquiries,
    "NewLeadsThisMonth": newLeadsThisMonth,
    "ActiveFollowUps": activeFollowUps,
    "LostLeadsToday": lostLeadsToday,
    "TodayBookings": todayBookings,
    "TodayBookingValue": todayBookingValue,
    "TodayTotalCalls": todayTotalCalls,
    "TodayConnected": todayConnected,
    "TodayNotConnected": todayNotConnected,
    "TodayRescheduled": todayRescheduled,
    "TodayClosed": todayClosed,
  };
}
