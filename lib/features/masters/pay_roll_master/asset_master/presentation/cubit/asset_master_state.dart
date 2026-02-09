part of 'asset_master_cubit.dart';

class AssetMasterState extends BaseState {
  final List<AssetMasterModel> assetList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterAssetStatus;
  final String filterAssetType;
  final String filterAssetBrand;
  final String filterAssetModel;
  final String filterSerialNumber;

  const AssetMasterState({
    required this.assetList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
    this.filterAssetStatus = "",
    this.filterAssetType = "",
    this.filterAssetBrand = "",
    this.filterAssetModel = "",
    this.filterSerialNumber = "",
  });

  factory AssetMasterState.initial() => AssetMasterState(
    isLoading: true,
    assetList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
    searchText: "",
    totalNumberOfRecord: 0,
    filterAssetStatus: "",
    filterAssetType: "",
    filterAssetBrand: "",
    filterAssetModel: "",
    filterSerialNumber: "",
  );

  AssetMasterState copyWith({
    List<AssetMasterModel>? assetList,
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterAssetStatus,
    String? filterAssetType,
    String? filterAssetBrand,
    String? filterAssetModel,
    String? filterSerialNumber,
  }) {
    return AssetMasterState(
      assetList: assetList ?? this.assetList,
      isLoading: isLoading ?? this.isLoading,
      searchText: searchText ?? this.searchText,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterAssetStatus: filterAssetStatus ?? this.filterAssetStatus,
      filterAssetType: filterAssetType ?? this.filterAssetType,
      filterAssetBrand: filterAssetBrand ?? this.filterAssetBrand,
      filterAssetModel: filterAssetModel ?? this.filterAssetModel,
      filterSerialNumber: filterSerialNumber ?? this.filterSerialNumber,
    );
  }

  @override
  List<Object?> get props => [
    assetList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
    currentSortColumn,
    currentSortDirection,
    filterAssetStatus,
    filterAssetType,
    filterAssetBrand,
    filterAssetModel,
    filterSerialNumber,
  ];
}
