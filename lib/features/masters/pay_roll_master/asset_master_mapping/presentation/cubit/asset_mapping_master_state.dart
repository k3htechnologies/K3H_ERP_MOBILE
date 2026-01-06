part of 'asset_mapping_master_cubit.dart';

class AssetMappingMasterState extends BaseState {
  final List<AssetMappingModel> assetMappingList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;

  const AssetMappingMasterState({
    required this.assetMappingList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory AssetMappingMasterState.initial() => AssetMappingMasterState(
    assetMappingList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
  );

  AssetMappingMasterState copyWith({
    List<AssetMappingModel>? assetMappingList,
    bool? isLoading = false,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return AssetMappingMasterState(
      assetMappingList: assetMappingList ?? this.assetMappingList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    assetMappingList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
  ];
}


