import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/aop_achievement/data/model/aop_achievement_report.model.dart';

class AopAchievementReportState extends BaseState {
  final List<AopAchievementReportModel> aopAchievementReportList;
  final String searchText;
  final int currentAopAchievementReportPageNumber;
  final int aopAchievementReportTotalNumberOfRecord;
  final AchievementDrillDownType drillDownType;
  final String currentSortColumn;
  final String currentSortDirection;
  final List<AchievementDrillDownReportModel> achievementDrillDownReportList;
  final int currentAchievementDrillDownReportPageNumber;
  final int achievementDrillDownTotalNumberOfRecord;

  const AopAchievementReportState({
    super.isLoading,
    required this.aopAchievementReportList,
    required this.currentAopAchievementReportPageNumber,
    required this.aopAchievementReportTotalNumberOfRecord,
    this.drillDownType = AchievementDrillDownType.enquiry,
    this.searchText = '',
    this.currentSortColumn = '',
    this.currentSortDirection = '',
    required this.achievementDrillDownReportList,
    this.currentAchievementDrillDownReportPageNumber = 1,
    this.achievementDrillDownTotalNumberOfRecord = 0,
  });

  factory AopAchievementReportState.initial() => AopAchievementReportState(
    isLoading: true,
    aopAchievementReportList: [],
    searchText: '',
    aopAchievementReportTotalNumberOfRecord: 0,
    currentAopAchievementReportPageNumber: 1,
    drillDownType: AchievementDrillDownType.enquiry,
    currentSortColumn: '',
    currentSortDirection: '',
    achievementDrillDownReportList: [],
    currentAchievementDrillDownReportPageNumber: 1,
    achievementDrillDownTotalNumberOfRecord: 0,
  );

  AopAchievementReportState copyWith({
    bool? isLoading,
    List<AopAchievementReportModel>? aopAchievementReportList,
    String? searchText,
    int? currentAopAchievementReportPageNumber,
    int? aopAchievementReportTotalNumberOfRecord,
    AchievementDrillDownType? drillDownType,
    String? currentSortColumn,
    String? currentSortDirection,
    List<AchievementDrillDownReportModel>? achievementDrillDownReportList,
    int? currentAchievementDrillDownReportPageNumber,
    int? achievementDrillDownTotalNumberOfRecord,
  }) {
    return AopAchievementReportState(
      isLoading: isLoading ?? this.isLoading,
      aopAchievementReportList:
          aopAchievementReportList ?? this.aopAchievementReportList,
      searchText: searchText ?? this.searchText,
      currentAopAchievementReportPageNumber:
          currentAopAchievementReportPageNumber ??
          this.currentAopAchievementReportPageNumber,
      aopAchievementReportTotalNumberOfRecord:
          aopAchievementReportTotalNumberOfRecord ??
          this.aopAchievementReportTotalNumberOfRecord,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,

      achievementDrillDownReportList:
          achievementDrillDownReportList ?? this.achievementDrillDownReportList,

      currentAchievementDrillDownReportPageNumber:
          currentAchievementDrillDownReportPageNumber ??
          this.currentAchievementDrillDownReportPageNumber,

      achievementDrillDownTotalNumberOfRecord:
          achievementDrillDownTotalNumberOfRecord ??
          this.achievementDrillDownTotalNumberOfRecord,
      drillDownType: drillDownType ?? this.drillDownType,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    aopAchievementReportList,
    searchText,
    currentAopAchievementReportPageNumber,
    aopAchievementReportTotalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    achievementDrillDownReportList,
    currentAchievementDrillDownReportPageNumber,
    achievementDrillDownTotalNumberOfRecord,
    drillDownType,
  ];
}
