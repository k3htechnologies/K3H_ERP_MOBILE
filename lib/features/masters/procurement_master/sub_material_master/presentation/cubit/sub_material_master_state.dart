part of 'sub_material_master_cubit.dart';

class SubMaterialMasterState extends BaseState {
  final List<SubMaterialMasterModel> subMaterialList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String filterByMaterialName;
  final String currentSortColumn;
  final String currentSortDirection;

  const SubMaterialMasterState({
    super.isLoading,
    required this.subMaterialList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.filterByMaterialName,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });
  factory SubMaterialMasterState.initial() => SubMaterialMasterState(
    subMaterialList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    filterByMaterialName: "",
    isLoading: true,
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
  );
  SubMaterialMasterState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? success,
    List<SubMaterialMasterModel>? subMaterialList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? filterByMaterialName,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return SubMaterialMasterState(
      isLoading: isLoading ?? this.isLoading,
      subMaterialList: subMaterialList ?? this.subMaterialList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      filterByMaterialName: filterByMaterialName ?? this.filterByMaterialName,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    subMaterialList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    filterByMaterialName,
    currentSortColumn,
    currentSortDirection,
  ];
}
