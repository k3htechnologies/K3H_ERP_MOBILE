part of 'construction_area_cubit.dart';

class ConstructionAreaState extends BaseState {
  final List<ConstructionAreaModel> constructionAreaList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<ConstructionAreaComparativeModel> constructionAreaComparativeList;
  final bool isComparativeLoading;
  final int constructionAreaId;
  final String searchConstructionAreaText;
  final String searchConstructionAreaByBuildingNumber;
  final String searchConstructionAreaByWing;
  final String searchConstructionAreaByUnit;
  final String searchConstructionAreaByUnitType;
  final String searchConstructionAreaByUnitConfiguration;
  final String searchConstructionAreaComparativeText;
  const ConstructionAreaState({
    super.isLoading,
    required this.constructionAreaList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.constructionAreaComparativeList,
    required this.isComparativeLoading,
    required this.constructionAreaId,
    required this.searchConstructionAreaText,
    required this.searchConstructionAreaByBuildingNumber,
    required this.searchConstructionAreaByWing,
    required this.searchConstructionAreaByUnit,
    required this.searchConstructionAreaByUnitType,
    required this.searchConstructionAreaByUnitConfiguration,
    required this.searchConstructionAreaComparativeText,
  });

  factory ConstructionAreaState.inital() => ConstructionAreaState(
    constructionAreaList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    constructionAreaComparativeList: [],
    isComparativeLoading: false,
    constructionAreaId: 0,
    searchConstructionAreaText: "",
    searchConstructionAreaByBuildingNumber: "",
    searchConstructionAreaByWing: "",
    searchConstructionAreaByUnit: "",
    searchConstructionAreaByUnitType: "",
    searchConstructionAreaByUnitConfiguration: "",
    searchConstructionAreaComparativeText: "",
  );

  ConstructionAreaState copyWith({
    bool? isLoading,
    List<ConstructionAreaModel>? constructionAreaList,
    int? totalNumberOfRecord,
    int? currentPage,
    List<ConstructionAreaComparativeModel>? constructionAreaComparativeList,
    bool? isComparativeLoading,
    int? constructionAreaId,
    String? searchConstructionAreaText,
    String? searchConstructionAreaByBuildingNumber,
    String? searchConstructionAreaByWing,
    String? searchConstructionAreaByUnit,
    String? searchConstructionAreaByUnitType,
    String? searchConstructionAreaByUnitConfiguration,
    String? searchConstructionAreaComparativeText,
  }) {
    return ConstructionAreaState(
      isLoading: isLoading ?? this.isLoading,
      constructionAreaList: constructionAreaList ?? this.constructionAreaList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      constructionAreaComparativeList:
          constructionAreaComparativeList ??
          this.constructionAreaComparativeList,
      isComparativeLoading: isComparativeLoading ?? this.isComparativeLoading,
      constructionAreaId: constructionAreaId ?? this.constructionAreaId,
      searchConstructionAreaText:
          searchConstructionAreaText ?? this.searchConstructionAreaText,
      searchConstructionAreaByBuildingNumber:
          searchConstructionAreaByBuildingNumber ??
          this.searchConstructionAreaByBuildingNumber,
      searchConstructionAreaByWing:
          searchConstructionAreaByWing ?? this.searchConstructionAreaByWing,
      searchConstructionAreaByUnit:
          searchConstructionAreaByUnit ?? this.searchConstructionAreaByUnit,
      searchConstructionAreaByUnitType:
          searchConstructionAreaByUnitType ??
          this.searchConstructionAreaByUnitType,
      searchConstructionAreaByUnitConfiguration:
          searchConstructionAreaByUnitConfiguration ??
          this.searchConstructionAreaByUnitConfiguration,
      searchConstructionAreaComparativeText:
          searchConstructionAreaComparativeText ??
          this.searchConstructionAreaComparativeText,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    constructionAreaList,
    totalNumberOfRecord,
    currentPage,
    constructionAreaComparativeList,
    isComparativeLoading,
    constructionAreaId,
    searchConstructionAreaText,
    searchConstructionAreaByBuildingNumber,
    searchConstructionAreaByWing,
    searchConstructionAreaByUnit,
    searchConstructionAreaByUnitType,
    searchConstructionAreaByUnitConfiguration,
    searchConstructionAreaComparativeText,
  ];
}
