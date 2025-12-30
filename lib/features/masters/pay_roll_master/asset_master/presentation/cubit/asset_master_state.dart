part of 'asset_master_cubit.dart';

class AssetMasterState extends BaseState {
  final List<AssetMasterModel> assetList;
  final int currentPage;
  final String searchText;
  final int totalNumberOfRecord;
  final String currentSortColumn;
  final String currentSortDirection;

  const AssetMasterState({
    required this.assetList,
    super.isLoading,
    this.currentPage = 1,
    this.searchText = "",
    this.totalNumberOfRecord = 0,
    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory AssetMasterState.initial() => AssetMasterState(
    assetList: [],
    currentPage: 1,
    currentSortColumn: 'Created Date',
    currentSortDirection: 'DESC',
  );

  AssetMasterState copyWith({
    List<AssetMasterModel>? assetList,
    bool? isLoading = false,
    StateType? stateType,
    String? errorMessage,
    String? searchText,
    int? totalNumberOfRecord,
    int? currentPage,
    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return AssetMasterState(
      assetList: assetList ?? this.assetList,
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
    assetList,
    isLoading,
    currentPage,
    searchText,
    totalNumberOfRecord,
  ];
}
