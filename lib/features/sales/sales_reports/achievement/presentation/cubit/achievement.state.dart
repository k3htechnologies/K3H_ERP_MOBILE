import 'package:k3h_erp_app/core/base_state.dart';

import '../../data/model/closing_achievement_report.model.dart';
import '../../data/model/project_achievement_report.model.dart';
import '../../data/model/sourcing_achievement_report.model.dart';

class AchievementState extends BaseState {
  final List<ProjectAchievementReportModel> projectAchievementReportList;

  final List<ClosingAchievementReportModel> closingAchievementReportList;

  final List<SourcingAchievementReportModel> sourcingAchievementReportList;

  final List<ClosingAchievementReportModel> managerClosingAchievementReportList;

  final List<SourcingAchievementReportModel>
  managerSourcingAchievementReportList;

  final int currentProjectAchievementReportPageNumber;
  final int currentClosingAchievementReportPageNumber;
  final int currentSourcingAchievementReportPageNumber;

  final int managerClosingAchievementReportPageNumber;
  final int managerSourcingAchievementReportPageNumber;

  final int projectAchievementTotalNumberOfRecord;
  final int closingAchievementTotalNumberOfRecord;
  final int sourcingAchievementTotalNumberOfRecord;

  final int managerClosingAchievementTotalNumberOfRecord;
  final int managerSourcingAchievementTotalNumberOfRecord;

  final String searchText;
  final String managerSearchText;

  const AchievementState({
    super.isLoading,

    required this.projectAchievementReportList,
    required this.closingAchievementReportList,
    required this.sourcingAchievementReportList,

    required this.managerClosingAchievementReportList,
    required this.managerSourcingAchievementReportList,

    this.currentProjectAchievementReportPageNumber = 1,
    this.currentClosingAchievementReportPageNumber = 1,
    this.currentSourcingAchievementReportPageNumber = 1,

    this.managerClosingAchievementReportPageNumber = 1,
    this.managerSourcingAchievementReportPageNumber = 1,

    this.projectAchievementTotalNumberOfRecord = 0,
    this.closingAchievementTotalNumberOfRecord = 0,
    this.sourcingAchievementTotalNumberOfRecord = 0,

    this.managerClosingAchievementTotalNumberOfRecord = 0,
    this.managerSourcingAchievementTotalNumberOfRecord = 0,

    this.searchText = '',
    this.managerSearchText = '',
  });

  factory AchievementState.initial() => AchievementState(
    isLoading: true,

    projectAchievementReportList: [],
    closingAchievementReportList: [],
    sourcingAchievementReportList: [],

    managerClosingAchievementReportList: [],
    managerSourcingAchievementReportList: [],

    currentProjectAchievementReportPageNumber: 1,
    currentClosingAchievementReportPageNumber: 1,
    currentSourcingAchievementReportPageNumber: 1,

    managerClosingAchievementReportPageNumber: 1,
    managerSourcingAchievementReportPageNumber: 1,

    projectAchievementTotalNumberOfRecord: 0,
    closingAchievementTotalNumberOfRecord: 0,
    sourcingAchievementTotalNumberOfRecord: 0,

    managerClosingAchievementTotalNumberOfRecord: 0,
    managerSourcingAchievementTotalNumberOfRecord: 0,

    searchText: '',
    managerSearchText: '',
  );

  AchievementState copyWith({
    bool? isLoading,

    List<ProjectAchievementReportModel>? projectAchievementReportList,

    List<ClosingAchievementReportModel>? closingAchievementReportList,

    List<SourcingAchievementReportModel>? sourcingAchievementReportList,

    List<ClosingAchievementReportModel>? managerClosingAchievementReportList,

    List<SourcingAchievementReportModel>? managerSourcingAchievementReportList,

    int? currentProjectAchievementReportPageNumber,
    int? currentClosingAchievementReportPageNumber,
    int? currentSourcingAchievementReportPageNumber,

    int? managerClosingAchievementReportPageNumber,
    int? managerSourcingAchievementReportPageNumber,

    int? projectAchievementTotalNumberOfRecord,
    int? closingAchievementTotalNumberOfRecord,
    int? sourcingAchievementTotalNumberOfRecord,

    int? managerClosingAchievementTotalNumberOfRecord,
    int? managerSourcingAchievementTotalNumberOfRecord,

    String? searchText,
    String? managerSearchText,
  }) {
    return AchievementState(
      isLoading: isLoading ?? this.isLoading,

      projectAchievementReportList:
          projectAchievementReportList ?? this.projectAchievementReportList,

      closingAchievementReportList:
          closingAchievementReportList ?? this.closingAchievementReportList,

      sourcingAchievementReportList:
          sourcingAchievementReportList ?? this.sourcingAchievementReportList,

      managerClosingAchievementReportList:
          managerClosingAchievementReportList ??
          this.managerClosingAchievementReportList,

      managerSourcingAchievementReportList:
          managerSourcingAchievementReportList ??
          this.managerSourcingAchievementReportList,

      currentProjectAchievementReportPageNumber:
          currentProjectAchievementReportPageNumber ??
          this.currentProjectAchievementReportPageNumber,

      currentClosingAchievementReportPageNumber:
          currentClosingAchievementReportPageNumber ??
          this.currentClosingAchievementReportPageNumber,

      currentSourcingAchievementReportPageNumber:
          currentSourcingAchievementReportPageNumber ??
          this.currentSourcingAchievementReportPageNumber,

      managerClosingAchievementReportPageNumber:
          managerClosingAchievementReportPageNumber ??
          this.managerClosingAchievementReportPageNumber,

      managerSourcingAchievementReportPageNumber:
          managerSourcingAchievementReportPageNumber ??
          this.managerSourcingAchievementReportPageNumber,

      projectAchievementTotalNumberOfRecord:
          projectAchievementTotalNumberOfRecord ??
          this.projectAchievementTotalNumberOfRecord,

      closingAchievementTotalNumberOfRecord:
          closingAchievementTotalNumberOfRecord ??
          this.closingAchievementTotalNumberOfRecord,

      sourcingAchievementTotalNumberOfRecord:
          sourcingAchievementTotalNumberOfRecord ??
          this.sourcingAchievementTotalNumberOfRecord,

      managerClosingAchievementTotalNumberOfRecord:
          managerClosingAchievementTotalNumberOfRecord ??
          this.managerClosingAchievementTotalNumberOfRecord,

      managerSourcingAchievementTotalNumberOfRecord:
          managerSourcingAchievementTotalNumberOfRecord ??
          this.managerSourcingAchievementTotalNumberOfRecord,

      searchText: searchText ?? this.searchText,

      managerSearchText: managerSearchText ?? this.managerSearchText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,

    projectAchievementReportList,
    closingAchievementReportList,
    sourcingAchievementReportList,

    managerClosingAchievementReportList,
    managerSourcingAchievementReportList,

    currentProjectAchievementReportPageNumber,
    currentClosingAchievementReportPageNumber,
    currentSourcingAchievementReportPageNumber,

    managerClosingAchievementReportPageNumber,
    managerSourcingAchievementReportPageNumber,

    projectAchievementTotalNumberOfRecord,
    closingAchievementTotalNumberOfRecord,
    sourcingAchievementTotalNumberOfRecord,

    managerClosingAchievementTotalNumberOfRecord,
    managerSourcingAchievementTotalNumberOfRecord,

    searchText,
    managerSearchText,
  ];
}
