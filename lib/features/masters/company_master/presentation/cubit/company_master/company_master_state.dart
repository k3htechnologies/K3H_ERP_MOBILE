part of 'company_master_cubit.dart';

class CompanyMasterState extends BaseState {
  final List<CompanyModel> companyList;
  final List<CompanyPartnerModel> companyPartner;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByCompanyType;

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
    required this.filterByCompanyType,
  });

  factory CompanyMasterState.initial() => CompanyMasterState(
    companyList: [],
    companyPartner: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "Created Date",
    currentSortDirection: "DESC",
    filterByCompanyType: "",
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
    String? filterByCompanyType,
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
      filterByCompanyType: filterByCompanyType ?? this.filterByCompanyType,
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
    filterByCompanyType,
  ];
}
