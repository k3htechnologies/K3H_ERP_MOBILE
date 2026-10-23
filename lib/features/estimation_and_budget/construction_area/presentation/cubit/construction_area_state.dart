part of 'construction_area_cubit.dart';

class ConstructionAreaState extends BaseState {
  final List<ConstructionAreaModel> constructionAreaList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<ConstructionAreaComparativeModel> constructionAreaComparativeList;
  final bool isComparativeLoading;
  final int constructionAreaId;
  const ConstructionAreaState({
    super.isLoading,
    required this.constructionAreaList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.constructionAreaComparativeList,
    required this.isComparativeLoading,
    required this.constructionAreaId,
  });

  factory ConstructionAreaState.inital() => ConstructionAreaState(
    constructionAreaList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    constructionAreaComparativeList: [],
    isComparativeLoading: false,
    constructionAreaId: 0,
  );

  ConstructionAreaState copyWith({
    bool? isLoading,
    List<ConstructionAreaModel>? constructionAreaList,
    int? totalNumberOfRecord,
    int? currentPage,
    List<ConstructionAreaComparativeModel>? constructionAreaComparativeList,
    bool? isComparativeLoading,
    int? constructionAreaId,
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
  ];
}
