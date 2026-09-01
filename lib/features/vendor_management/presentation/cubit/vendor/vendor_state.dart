part of 'vendor_cubit.dart';

class VendorState extends BaseState {
  final List<VendorModel> vendorList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByVendorCode;
  final String filterByCompanyName;
  final String filterByCompanyType;
  final String filterByMobileNumber;
  final String filterByCity;
  final String filterByGstNumber;
  final String filterByAadhaarCardNumber;
  final String filterByPanCardNumber;
  const VendorState({
    super.isLoading,
    super.stateType,
    required this.vendorList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByVendorCode,
    required this.filterByCompanyName,
    required this.filterByCompanyType,
    required this.filterByMobileNumber,
    required this.filterByCity,
    required this.filterByGstNumber,
    required this.filterByAadhaarCardNumber,
    required this.filterByPanCardNumber,
  });
  factory VendorState.initial() => VendorState(
    isLoading: true,
    vendorList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterByVendorCode: "",
    filterByCompanyName: "",
    filterByCompanyType: "",
    filterByMobileNumber: "",
    filterByCity: "",
    filterByGstNumber: "",
    filterByAadhaarCardNumber: "",
    filterByPanCardNumber: "",
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
    String? filterByVendorCode,
    String? filterByCompanyName,
    String? filterByCompanyType,
    String? filterByMobileNumber,
    String? filterByCity,
    String? filterByGstNumber,
    String? filterByAadhaarCardNumber,
    String? filterByPanCardNumber,
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
      filterByVendorCode: filterByVendorCode ?? this.filterByVendorCode,
      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByCompanyType: filterByCompanyType ?? this.filterByCompanyType,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByCity: filterByCity ?? this.filterByCity,
      filterByGstNumber: filterByGstNumber ?? this.filterByGstNumber,
      filterByAadhaarCardNumber:
          filterByAadhaarCardNumber ?? this.filterByAadhaarCardNumber,
      filterByPanCardNumber:
          filterByPanCardNumber ?? this.filterByPanCardNumber,
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
    filterByVendorCode,
    filterByCompanyName,
    filterByCompanyType,
    filterByMobileNumber,
    filterByCity,
    filterByGstNumber,
    filterByAadhaarCardNumber,
    filterByPanCardNumber,
  ];
}
