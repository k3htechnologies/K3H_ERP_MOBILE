part of 'company_master_cubit.dart';

class CompanyMasterState extends BaseState {
  final List<CompanyModel> companyList;
  final List<CompanyPartnerModel> companyPartner;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByFirmType;
  final String filterByContactPerson;
  final String filterByMobileNumber;
  final String filterByCityName;

  const CompanyMasterState({
    super.isLoading,
    super.stateType,
    required this.companyList,
    required this.companyPartner,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByFirmType,
    required this.filterByContactPerson,
    required this.filterByMobileNumber,
    required this.filterByCityName,
  });

  factory CompanyMasterState.initial() => CompanyMasterState(
    companyList: [],
    companyPartner: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterByFirmType: "",
    filterByContactPerson: "",
    filterByMobileNumber: "",
    filterByCityName: "",
    isLoading: true,
  );

  CompanyMasterState copyWith({
    bool? isLoading,
    StateType? stateType,
    String? errorMessage,
    List<CompanyModel>? companyList,
    List<CompanyPartnerModel>? companyPartner,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByFirmType,
    String? filterByContactPerson,
    String? filterByMobileNumber,
    String? filterByCityName,
  }) {
    return CompanyMasterState(
      isLoading: isLoading ?? this.isLoading,
      stateType: stateType ?? this.stateType,
      companyList: companyList ?? this.companyList,
      companyPartner: companyPartner ?? this.companyPartner,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByFirmType: filterByFirmType ?? this.filterByFirmType,
      filterByContactPerson: filterByContactPerson ?? this.filterByContactPerson,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByCityName: filterByCityName ?? this.filterByCityName,
    );
  }



  @override
  List<Object?> get props => [
    companyList,
    companyPartner,
    totalNumberOfRecord,
    currentPage,
    searchText,
    currentSortColumn,
    currentSortDirection,
    filterByFirmType,
    filterByContactPerson,
    filterByMobileNumber,
    filterByCityName,
  ];
}
