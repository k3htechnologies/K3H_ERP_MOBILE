part of 'vendor_cubit.dart';

class VendorState extends BaseState {
  final List<VendorModel> vendorList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByCompanyName;
  final String filterByCompanyType;

  const VendorState({
    super.isLoading,
    super.stateType,
    required this.vendorList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByCompanyName,
    required this.filterByCompanyType,
  });

  factory VendorState.initial() => VendorState(
    isLoading: true,
    vendorList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterByCompanyName: "",
    filterByCompanyType: "",
  );

  VendorState copyWith({
    bool? isLoading,
    StateType? stateType,
    List<VendorModel>? vendorList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByCompanyName,
    String? filterByCompanyType,
  }) {
    return VendorState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      vendorList: vendorList ?? this.vendorList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByCompanyType: filterByCompanyType ?? this.filterByCompanyType,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    stateType,
    vendorList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterByCompanyName,
    filterByCompanyType,
  ];

}
