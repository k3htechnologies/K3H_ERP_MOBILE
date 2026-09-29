part of 'asset_mapping_master_cubit.dart';

class AssetMappingMasterState extends BaseState {
  final List<AssetMappingModel> assetMappingList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterEmployeeName;
  final String filterAssetCode;

  const AssetMappingMasterState({
    required this.assetMappingList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterAssetCode,
    required this.filterEmployeeName,
  });

  factory AssetMappingMasterState.initial() => AssetMappingMasterState(
    assetMappingList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
    searchText: "",
    totalNumberOfRecord: 0,
    filterAssetCode: '',
    filterEmployeeName: "",
  );

  AssetMappingMasterState copyWith({
    List<AssetMappingModel>? assetMappingList,
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterEmployeeName,
    String? filterAssetCode,
  }) {
    return AssetMappingMasterState(
      assetMappingList: assetMappingList ?? this.assetMappingList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterEmployeeName: filterEmployeeName ?? this.filterEmployeeName,
      filterAssetCode: filterAssetCode ?? this.filterAssetCode,
    );
  }

  @override
  List<Object?> get props => [
    assetMappingList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    filterEmployeeName,
  ];
}
