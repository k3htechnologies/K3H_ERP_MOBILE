import 'package:k3h_erp_app/utils/common_function.dart';

class SalesDashboardModel {
  final List<Table0> table0;
  final List<Table1> table1;
  final List<Table2> table2;
  final List<Table3> table3;
  final List<Table4> table4;
  final List<Table5> table5;
  final List<Table6> table6;
  final List<dynamic> table7;
  final List<dynamic> table8;
  final List<Table9> table9;
  final List<Table10> table10;
  final List<Table11> table11;
  final List<Table12> table12;
  final List<Table13> table13;
  final List<Table14> table14;
  final List<Table15> table15;
  final List<dynamic> table16;
  final List<Table17> table17;
  final List<Table18> table18;

  SalesDashboardModel({
    required this.table0,
    required this.table1,
    required this.table2,
    required this.table3,
    required this.table4,
    required this.table5,
    required this.table6,
    required this.table7,
    required this.table8,
    required this.table9,
    required this.table10,
    required this.table11,
    required this.table12,
    required this.table13,
    required this.table14,
    required this.table15,
    required this.table16,
    required this.table17,
    required this.table18,
  });

  factory SalesDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) => SalesDashboardModel(
    table0: List<Table0>.from(json["Table0"].map((x) => Table0.fromJson(x))),
    table1: List<Table1>.from(json["Table1"].map((x) => Table1.fromJson(x))),
    table2: List<Table2>.from(json["Table2"].map((x) => Table2.fromJson(x))),
    table3: List<Table3>.from(json["Table3"].map((x) => Table3.fromJson(x))),
    table4: List<Table4>.from(json["Table4"].map((x) => Table4.fromJson(x))),
    table5: List<Table5>.from(json["Table5"].map((x) => Table5.fromJson(x))),
    table6: List<Table6>.from(json["Table6"].map((x) => Table6.fromJson(x))),
    table7: List<dynamic>.from(json["Table7"].map((x) => x)),
    table8: List<dynamic>.from(json["Table8"].map((x) => x)),
    table9: List<Table9>.from(json["Table9"].map((x) => Table9.fromJson(x))),
    table10: List<Table10>.from(
      json["Table10"].map((x) => Table10.fromJson(x)),
    ),
    table11: List<Table11>.from(
      json["Table11"].map((x) => Table11.fromJson(x)),
    ),
    table12: List<Table12>.from(
      json["Table12"].map((x) => Table12.fromJson(x)),
    ),
    table13: List<Table13>.from(
      json["Table13"].map((x) => Table13.fromJson(x)),
    ),
    table14: List<Table14>.from(
      json["Table14"].map((x) => Table14.fromJson(x)),
    ),
    table15: List<Table15>.from(
      json["Table15"].map((x) => Table15.fromJson(x)),
    ),
    table16: List<dynamic>.from(json["Table16"].map((x) => x)),
    table17: List<Table17>.from(
      json["Table17"].map((x) => Table17.fromJson(x)),
    ),
    table18: List<Table18>.from(
      json["Table18"].map((x) => Table18.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "Table0": List<dynamic>.from(table0.map((x) => x.toJson())),
    "Table1": List<dynamic>.from(table1.map((x) => x.toJson())),
    "Table2": List<dynamic>.from(table2.map((x) => x.toJson())),
    "Table3": List<dynamic>.from(table3.map((x) => x.toJson())),
    "Table4": List<dynamic>.from(table4.map((x) => x.toJson())),
    "Table5": List<dynamic>.from(table5.map((x) => x.toJson())),
    "Table6": List<dynamic>.from(table6.map((x) => x.toJson())),
    "Table7": List<dynamic>.from(table7.map((x) => x)),
    "Table8": List<dynamic>.from(table8.map((x) => x)),
    "Table9": List<dynamic>.from(table9.map((x) => x.toJson())),
    "Table10": List<dynamic>.from(table10.map((x) => x.toJson())),
    "Table11": List<dynamic>.from(table11.map((x) => x.toJson())),
    "Table12": List<dynamic>.from(table12.map((x) => x.toJson())),
    "Table13": List<dynamic>.from(table13.map((x) => x.toJson())),
    "Table14": List<dynamic>.from(table14.map((x) => x.toJson())),
    "Table15": List<dynamic>.from(table15.map((x) => x.toJson())),
    "Table16": List<dynamic>.from(table16.map((x) => x)),
    "Table17": List<dynamic>.from(table17.map((x) => x.toJson())),
    "Table18": List<dynamic>.from(table18.map((x) => x.toJson())),
  };
}

class Table0 {
  final int totalEnquiries;
  final double increaseEnquiryPercentage;
  final int newLeadsThisMonth;
  final int activeFollowUps;
  final int lostLeadsToday;
  final int todaysFollowUpDues;
  final int totalBookingConversion;
  final double averageBookingValue;
  final int todayBookings;
  final int todayBookingValue;
  final int todayTotalCalls;
  final int todayConnected;
  final int todayNotConnected;
  final int todayRescheduled;
  final int todayClosed;
  final int achieved;
  final int cpPercentage;
  final int activeCp;

  Table0({
    required this.totalEnquiries,
    required this.increaseEnquiryPercentage,
    required this.newLeadsThisMonth,
    required this.activeFollowUps,
    required this.lostLeadsToday,
    required this.todaysFollowUpDues,
    required this.totalBookingConversion,
    required this.averageBookingValue,
    required this.todayBookings,
    required this.todayBookingValue,
    required this.todayTotalCalls,
    required this.todayConnected,
    required this.todayNotConnected,
    required this.todayRescheduled,
    required this.todayClosed,
    required this.achieved,
    required this.cpPercentage,
    required this.activeCp,
  });

  factory Table0.fromJson(Map<String, dynamic> json) => Table0(
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    increaseEnquiryPercentage:
        parseValue<double>(json, "IncreaseEnquiryPercentage").toDouble(),
    newLeadsThisMonth: parseValue<int>(json, "NewLeadsThisMonth"),
    activeFollowUps: parseValue<int>(json, "ActiveFollowUps"),
    lostLeadsToday: parseValue<int>(json, "LostLeadsToday"),
    todaysFollowUpDues: parseValue<int>(json, "TodaysFollowUpDues"),
    totalBookingConversion: parseValue<int>(json, "TotalBookingConversion"),
    averageBookingValue: parseValue<double>(json, "AverageBookingValue"),
    todayBookings: parseValue<int>(json, "TodayBookings"),
    todayBookingValue: parseValue<int>(json, "TodayBookingValue"),
    todayTotalCalls: parseValue<int>(json, "TodayTotalCalls"),
    todayConnected: parseValue<int>(json, "TodayConnected"),
    todayNotConnected: parseValue<int>(json, "TodayNotConnected"),
    todayRescheduled: parseValue<int>(json, "TodayRescheduled"),
    todayClosed: parseValue<int>(json, "TodayClosed"),
    achieved: parseValue<int>(json, "Achieved"),
    cpPercentage: parseValue<int>(json, "CPPercentage"),
    activeCp: parseValue<int>(json, "ActiveCp"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEnquiries": totalEnquiries,
    "IncreaseEnquiryPercentage": increaseEnquiryPercentage,
    "NewLeadsThisMonth": newLeadsThisMonth,
    "ActiveFollowUps": activeFollowUps,
    "LostLeadsToday": lostLeadsToday,
    "TodaysFollowUpDues": todaysFollowUpDues,
    "TotalBookingConversion": totalBookingConversion,
    "AverageBookingValue": averageBookingValue,
    "TodayBookings": todayBookings,
    "TodayBookingValue": todayBookingValue,
    "TodayTotalCalls": todayTotalCalls,
    "TodayConnected": todayConnected,
    "TodayNotConnected": todayNotConnected,
    "TodayRescheduled": todayRescheduled,
    "TodayClosed": todayClosed,
    "Achieved": achieved,
    "CPPercentage": cpPercentage,
    "ActiveCp": activeCp,
  };
}

class Table1 {
  final int totalEnquiry;
  final int siteVisit;
  final int negotiation;
  final int bookingStage;
  final int closedStage;
  final int siteVisitConversion;
  final int negotiationConversion;
  final int bookingConversion;
  final int closingConversion;
  final double enquiryConversionRate;

  Table1({
    required this.totalEnquiry,
    required this.siteVisit,
    required this.negotiation,
    required this.bookingStage,
    required this.closedStage,
    required this.siteVisitConversion,
    required this.negotiationConversion,
    required this.bookingConversion,
    required this.closingConversion,
    required this.enquiryConversionRate,
  });

  factory Table1.fromJson(Map<String, dynamic> json) => Table1(
    totalEnquiry: parseValue<int>(json, "TotalEnquiry"),
    siteVisit: parseValue<int>(json, "SiteVisit"),
    negotiation: parseValue<int>(json, "Negotiation"),
    bookingStage: parseValue<int>(json, "BookingStage"),
    closedStage: parseValue<int>(json, "ClosedStage"),
    siteVisitConversion: parseValue<int>(json, "SiteVisitConversion"),
    negotiationConversion: parseValue<int>(json, "NegotiationConversion"),
    bookingConversion: parseValue<int>(json, "BookingConversion"),
    closingConversion: parseValue<int>(json, "ClosingConversion"),
    enquiryConversionRate:
        parseValue<double>(json, "EnquiryConversionRate").toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "TotalEnquiry": totalEnquiry,
    "SiteVisit": siteVisit,
    "Negotiation": negotiation,
    "BookingStage": bookingStage,
    "ClosedStage": closedStage,
    "SiteVisitConversion": siteVisitConversion,
    "NegotiationConversion": negotiationConversion,
    "BookingConversion": bookingConversion,
    "ClosingConversion": closingConversion,
    "EnquiryConversionRate": enquiryConversionRate,
  };
}

class Table11 {
  final String sourceName;
  final String subTitle;
  final int totalEnquiries;
  final int sourcePct;

  Table11({
    required this.sourceName,
    required this.subTitle,
    required this.totalEnquiries,
    required this.sourcePct,
  });

  factory Table11.fromJson(Map<String, dynamic> json) => Table11(
    sourceName: parseValue<String>(json, "SourceName"),
    subTitle: parseValue<String>(json, "SubTitle"),
    totalEnquiries: parseValue(json, "TotalEnquiries"),
    sourcePct: parseValue<int>(json, "SourcePct"),
  );

  Map<String, dynamic> toJson() => {
    "SourceName": sourceName,
    "SubTitle": subTitle,
    "TotalEnquiries": totalEnquiries,
    "SourcePct": sourcePct,
  };
}

class Table12 {
  final String sourceName;
  final String subSourceName;
  final String subSubSourceName;
  final int totalEnquiries;
  final int sourcePct;

  Table12({
    required this.sourceName,
    required this.subSourceName,
    required this.subSubSourceName,
    required this.totalEnquiries,
    required this.sourcePct,
  });

  factory Table12.fromJson(Map<String, dynamic> json) => Table12(
    sourceName: parseValue<String>(json, "SourceName"),
    subSourceName: parseValue<String>(json, "SubSourceName"),
    subSubSourceName: parseValue<String>(json, "SubSubSourceName"),
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    sourcePct: parseValue<int>(json, "SourcePct"),
  );

  Map<String, dynamic> toJson() => {
    "SourceName": sourceName,
    "SubSourceName": subSourceName,
    "SubSubSourceName": subSubSourceName,
    "TotalEnquiries": totalEnquiries,
    "SourcePct": sourcePct,
  };
}

class Table13 {
  final String unitType;
  final int totalEnquiries;
  final int percentage;

  Table13({
    required this.unitType,
    required this.totalEnquiries,
    required this.percentage,
  });

  factory Table13.fromJson(Map<String, dynamic> json) => Table13(
    unitType: parseValue<String>(json, "UnitType"),
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    percentage: parseValue<int>(json, "Percentage"),
  );

  Map<String, dynamic> toJson() => {
    "UnitType": unitType,
    "TotalEnquiries": totalEnquiries,
    "Percentage": percentage,
  };
}

class Table14 {
  final String unitType;
  final int totalEnquiries;
  final int percentage;

  Table14({
    required this.unitType,
    required this.totalEnquiries,
    required this.percentage,
  });

  factory Table14.fromJson(Map<String, dynamic> json) => Table14(
    unitType: parseValue<String>(json, "UnitType"),
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    percentage: parseValue<int>(json, "Percentage"),
  );

  Map<String, dynamic> toJson() => {
    "UnitType": unitType,
    "TotalEnquiries": totalEnquiries,
    "Percentage": percentage,
  };
}

class Table15 {
  final int totalEnquiries;
  final int totalBookings;
  final int conversionRatePct;

  Table15({
    required this.totalEnquiries,
    required this.totalBookings,
    required this.conversionRatePct,
  });

  factory Table15.fromJson(Map<String, dynamic> json) => Table15(
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    totalBookings: parseValue<int>(json, "TotalBookings"),
    conversionRatePct: parseValue<int>(json, "ConversionRatePct"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEnquiries": totalEnquiries,
    "TotalBookings": totalBookings,
    "ConversionRatePct": conversionRatePct,
  };
}

class Table2 {
  final int totalEnquiries;
  final int coldLeads;
  final int warmLeads;
  final int hotLeads;
  final int coldRate;
  final int warmRate;
  final int hotRate;

  Table2({
    required this.totalEnquiries,
    required this.coldLeads,
    required this.warmLeads,
    required this.hotLeads,
    required this.coldRate,
    required this.warmRate,
    required this.hotRate,
  });

  factory Table2.fromJson(Map<String, dynamic> json) => Table2(
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    coldLeads: parseValue<int>(json, "ColdLeads"),
    warmLeads: parseValue<int>(json, "WarmLeads"),
    hotLeads: parseValue<int>(json, "HotLeads"),
    coldRate: parseValue<int>(json, "ColdRate"),
    warmRate: parseValue<int>(json, "WarmRate"),
    hotRate: parseValue<int>(json, "HotRate"),
  );

  Map<String, dynamic> toJson() => {
    "TotalEnquiries": totalEnquiries,
    "ColdLeads": coldLeads,
    "WarmLeads": warmLeads,
    "HotLeads": hotLeads,
    "ColdRate": coldRate,
    "WarmRate": warmRate,
    "HotRate": hotRate,
  };
}

class Table3 {
  final String fullName;
  final int targetAmount;
  final int achievedAmount;
  final int totalBookings;
  final int bookingFromEnquiry;
  final String designation;
  final double achievementPercent;
  final String performanceStatus;

  Table3({
    required this.fullName,
    required this.targetAmount,
    required this.achievedAmount,
    required this.totalBookings,
    required this.bookingFromEnquiry,
    required this.designation,
    required this.achievementPercent,
    required this.performanceStatus,
  });

  factory Table3.fromJson(Map<String, dynamic> json) => Table3(
    fullName: parseValue<String>(json, "FullName"),
    targetAmount: parseValue<int>(json, "TargetAmount"),
    achievedAmount: parseValue<int>(json, "AchievedAmount"),
    totalBookings: parseValue<int>(json, "TotalBookings"),
    bookingFromEnquiry: parseValue<int>(json, "BookingFromEnquiry"),
    designation: parseValue<String>(json, "Designation"),
    achievementPercent:
        parseValue<double>(json, "AchievementPercent").toDouble(),
    performanceStatus: parseValue<String>(json, "PerformanceStatus"),
  );

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "TargetAmount": targetAmount,
    "AchievedAmount": achievedAmount,
    "TotalBookings": totalBookings,
    "BookingFromEnquiry": bookingFromEnquiry,
    "Designation": designation,
    "AchievementPercent": achievementPercent,
    "PerformanceStatus": performanceStatus,
  };
}

class Table4 {
  final String fullName;
  final String designation;
  final int totalBookings;
  final int bookingValueInCr;
  final int conversionRate;

  Table4({
    required this.fullName,
    required this.designation,
    required this.totalBookings,
    required this.bookingValueInCr,
    required this.conversionRate,
  });

  factory Table4.fromJson(Map<String, dynamic> json) => Table4(
    fullName: parseValue<String>(json, "FullName"),
    designation: parseValue<String>(json, "Designation"),
    totalBookings: parseValue<int>(json, "TotalBookings"),
    bookingValueInCr: parseValue<int>(json, "BookingValueInCr"),
    conversionRate: parseValue(json, "ConversionRate"),
  );

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "Designation": designation,
    "TotalBookings": totalBookings,
    "BookingValueInCr": bookingValueInCr,
    "ConversionRate": conversionRate,
  };
}

class Table5 {
  final String fullName;
  final int totalBookings;
  final int bookingValue;
  final int conversionPercent;

  Table5({
    required this.fullName,
    required this.totalBookings,
    required this.bookingValue,
    required this.conversionPercent,
  });

  factory Table5.fromJson(Map<String, dynamic> json) => Table5(
    fullName: parseValue<String>(json, "FullName"),
    totalBookings: parseValue<int>(json, "TotalBookings"),
    bookingValue: parseValue<int>(json, "BookingValue"),
    conversionPercent: parseValue<int>(json, "ConversionPercent"),
  );

  Map<String, dynamic> toJson() => {
    "FullName": fullName,
    "TotalBookings": totalBookings,
    "BookingValue": bookingValue,
    "ConversionPercent": conversionPercent,
  };
}

class Table6 {
  final int totalCalls;
  final int pending;
  final int overdue;
  final int avgDurationMinutes;

  Table6({
    required this.totalCalls,
    required this.pending,
    required this.overdue,
    required this.avgDurationMinutes,
  });

  factory Table6.fromJson(Map<String, dynamic> json) => Table6(
    totalCalls: parseValue<int>(json, "TotalCalls"),
    pending: parseValue<int>(json, "Pending"),
    overdue: parseValue<int>(json, "Overdue"),
    avgDurationMinutes: parseValue<int>(json, "AvgDurationMinutes"),
  );

  Map<String, dynamic> toJson() => {
    "TotalCalls": totalCalls,
    "Pending": pending,
    "Overdue": overdue,
    "AvgDurationMinutes": avgDurationMinutes,
  };
}

class Table9 {
  final int directBookingCount;
  final int directBookingPct;
  final int channelPartnerBookingCount;
  final int channelPartnerBookingPct;
  final int upcomingRegistrationCount;

  Table9({
    required this.directBookingCount,
    required this.directBookingPct,
    required this.channelPartnerBookingCount,
    required this.channelPartnerBookingPct,
    required this.upcomingRegistrationCount,
  });

  factory Table9.fromJson(Map<String, dynamic> json) => Table9(
    directBookingCount: parseValue<int>(json, "DirectBookingCount"),
    directBookingPct: parseValue<int>(json, "DirectBookingPct"),
    channelPartnerBookingCount: parseValue<int>(
      json,
      "ChannelPartnerBookingCount",
    ),
    channelPartnerBookingPct: parseValue<int>(json, "ChannelPartnerBookingPct"),
    upcomingRegistrationCount: parseValue<int>(
      json,
      "UpcomingRegistrationCount",
    ),
  );

  Map<String, dynamic> toJson() => {
    "DirectBookingCount": directBookingCount,
    "DirectBookingPct": directBookingPct,
    "ChannelPartnerBookingCount": channelPartnerBookingCount,
    "ChannelPartnerBookingPct": channelPartnerBookingPct,
    "UpcomingRegistrationCount": upcomingRegistrationCount,
  };
}

class Table10 {
  final String monthName;
  final int monthNumber;
  final int yearNumber;
  final String totalBookingValue;
  final String budgetSlab;

  Table10({
    required this.monthName,
    required this.monthNumber,
    required this.yearNumber,
    required this.totalBookingValue,
    required this.budgetSlab,
  });

  factory Table10.fromJson(Map<String, dynamic> json) => Table10(
    monthName: parseValue<String>(json, "MonthName"),
    monthNumber: parseValue<int>(json, "MonthNumber"),
    yearNumber: parseValue<int>(json, "YearNumber"),
    totalBookingValue: parseValue<String>(json, "TotalBookingValue"),
    budgetSlab: parseValue<String>(json, "BudgetSlab"),
  );

  Map<String, dynamic> toJson() => {
    "MonthName": monthName,
    "MonthNumber": monthNumber,
    "YearNumber": yearNumber,
    "TotalBookingValue": totalBookingValue,
    "BudgetSlab": budgetSlab,
  };
}

class Table17 {
  final String channelPartnerName;
  final int totalBookings;
  final int totalEnquiries;
  final int totalBookingValue;
  final int bookingValueInCr;
  final int conversionPercent;
  final int inActiveChannelPartnerDays;
  final String status;

  Table17({
    required this.channelPartnerName,
    required this.totalBookings,
    required this.totalEnquiries,
    required this.totalBookingValue,
    required this.bookingValueInCr,
    required this.conversionPercent,
    required this.inActiveChannelPartnerDays,
    required this.status,
  });

  factory Table17.fromJson(Map<String, dynamic> json) => Table17(
    channelPartnerName: parseValue<String>(json, "ChannelPartnerName"),
    totalBookings: parseValue<int>(json, "TotalBookings"),
    totalEnquiries: parseValue<int>(json, "TotalEnquiries"),
    totalBookingValue: parseValue<int>(json, "TotalBookingValue"),
    bookingValueInCr: parseValue<int>(json, "BookingValueInCr"),
    conversionPercent: parseValue<int>(json, "ConversionPercent"),
    inActiveChannelPartnerDays: parseValue<int>(
      json,
      "InActiveChannelPartnerDays",
    ),
    status: parseValue<String>(json, "Status"),
  );

  Map<String, dynamic> toJson() => {
    "ChannelPartnerName": channelPartnerName,
    "TotalBookings": totalBookings,
    "TotalEnquiries": totalEnquiries,
    "TotalBookingValue": totalBookingValue,
    "BookingValueInCr": bookingValueInCr,
    "ConversionPercent": conversionPercent,
    "InActiveChannelPartnerDays": inActiveChannelPartnerDays,
    "Status": status,
  };
}

class Table18 {
  final int totalIbm;
  final int totalObm;
  final int totalInboundMeeting;
  final int totalOutboundMeeting;
  final String inboundConversionRate;
  final String outboundConversionRate;

  Table18({
    required this.totalIbm,
    required this.totalObm,
    required this.totalInboundMeeting,
    required this.totalOutboundMeeting,
    required this.inboundConversionRate,
    required this.outboundConversionRate,
  });

  factory Table18.fromJson(Map<String, dynamic> json) => Table18(
    totalIbm: parseValue<int>(json, "totalIbm"),
    totalObm: parseValue<int>(json, "totalObm"),
    totalInboundMeeting: parseValue<int>(json, "totalInboundMeeting"),
    totalOutboundMeeting: parseValue<int>(json, "totalOutboundMeeting"),
    inboundConversionRate: parseValue<String>(json, "inboundConversionRate"),
    outboundConversionRate: parseValue<String>(json, "outboundConversionRate"),
  );

  Map<String, dynamic> toJson() => {
    "totalIbm": totalIbm,
    "totalObm": totalObm,
    "totalInboundMeeting": totalInboundMeeting,
    "totalOutboundMeeting": totalOutboundMeeting,
    "inboundConversionRate": inboundConversionRate,
    "outboundConversionRate": outboundConversionRate,
  };
}
