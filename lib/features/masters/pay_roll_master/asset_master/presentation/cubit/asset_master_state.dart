part of 'asset_master_cubit.dart';

class AssetMasterState extends BaseState {
  final List<AssetMappingModel> assetMappingList;
  final List<AssetMasterModel> assetList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByEmployeName;
  final String filterByAssetStatus;
  final String filterByAssetType;
  final String filterByAssetBrand;
  final String filterByAssetModel;
  final String filterBySerialNumber;
  final int currentTabIndex;

  const AssetMasterState({
    required this.assetMappingList,
    required this.assetList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = '',
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByAssetStatus,
    required this.filterByAssetType,
    required this.filterByAssetBrand,
    required this.filterByAssetModel,
    required this.filterBySerialNumber,
    required this.filterByEmployeName,
    required this.currentTabIndex,
  });

  factory AssetMasterState.initial() => AssetMasterState(
    isLoading: true,
    assetMappingList: [],
    assetList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
    searchText: "",
    totalNumberOfRecord: 0,
    filterByAssetStatus: "",
    filterByAssetType: "",
    filterByAssetBrand: "",
    filterByAssetModel: "",
    filterBySerialNumber: "",
    currentTabIndex: 0,
    filterByEmployeName: '',
  );

  AssetMasterState copyWith({
    List<AssetMappingModel>? assetMappingList,
    List<AssetMasterModel>? assetList,
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByAssetStatus,
    String? filterByAssetType,
    String? filterByAssetBrand,
    String? filterByAssetModel,
    String? filterBySerialNumber,
    int? currentTabIndex,
    String? filterByEmployeName,
  }) {
    return AssetMasterState(
      assetMappingList: assetMappingList ?? this.assetMappingList,
      assetList: assetList ?? this.assetList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByAssetStatus: filterByAssetStatus ?? this.filterByAssetStatus,
      filterByAssetType: filterByAssetType ?? this.filterByAssetType,
      filterByAssetBrand: filterByAssetBrand ?? this.filterByAssetBrand,
      filterByAssetModel: filterByAssetModel ?? this.filterByAssetModel,
      filterBySerialNumber: filterBySerialNumber ?? this.filterBySerialNumber,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      filterByEmployeName: filterByEmployeName ?? this.filterByEmployeName,
    );
  }

  @override
  List<Object?> get props => [
    assetMappingList,
    assetList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    filterByAssetStatus,
    filterByAssetType,
    filterByAssetBrand,
    filterByAssetModel,
    filterBySerialNumber,
    filterByEmployeName,
    currentTabIndex,
  ];
}
