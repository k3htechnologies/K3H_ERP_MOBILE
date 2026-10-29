part of 'company_master_cubit.dart';

class CompanyMasterState extends BaseState {
  final List<CompanyModel> companyList;
  final List<CompanyPartnerModel> companyPartner;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final bool isDisplayBankDetails;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByFirmType;
  final String filterByContactPerson;
  final String filterByMobileNumber;
  final String filterByCityName;
  final String filterByGstNumber;
  final String filterByCinNumber;
  final String filterByPanNumber;
  final String filterByTanNumber;
  final CompanyModel? companyOverview;
  final List<CompanyBankModel>? bankDetailList;
  final String searchDocumentText;
  final String filterByFinancialYear;
  final List<CompanyDocumentModel>? companyDocumentList;
  final int currentPageDocument;
  final int totalNumberOfRecordDocument;
  final String currentSortColumnDocument;
  final String currentSortDirectionDocument;
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
    required this.companyOverview,
    required this.bankDetailList,
    required this.filterByGstNumber,
    required this.filterByCinNumber,
    required this.filterByPanNumber,
    required this.filterByTanNumber,
    required this.isDisplayBankDetails,
    required this.companyDocumentList,
    required this.searchDocumentText,
    required this.filterByFinancialYear,
    required this.currentPageDocument,
    required this.totalNumberOfRecordDocument,
    required this.currentSortColumnDocument,
    required this.currentSortDirectionDocument,
  });
  factory CompanyMasterState.initial() => CompanyMasterState(
    companyList: [],
    companyPartner: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "",
    currentSortDirection: "",
    filterByFirmType: "",
    filterByContactPerson: "",
    filterByMobileNumber: "",
    filterByCityName: "",
    isLoading: true,
    companyOverview: null,
    bankDetailList: null,
    companyDocumentList: null,
    filterByGstNumber: '',
    filterByCinNumber: '',
    filterByPanNumber: '',
    filterByTanNumber: '',
    isDisplayBankDetails: false,
    searchDocumentText: '',
    filterByFinancialYear: '',
    currentPageDocument: 1,
    totalNumberOfRecordDocument: 0,
    currentSortColumnDocument: '',
    currentSortDirectionDocument: '',
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
    String? filterByGstNumber,
    String? filterByCinNumber,
    String? filterByPanNumber,
    String? filterByTanNumber,
    bool? clearOverview,
    CompanyModel? companyOverview,
    bool? clearBankDetails,
    List<CompanyBankModel>? bankDetailList,
    bool? clearCompanyDocuments,
    List<CompanyDocumentModel>? companyDocumentList,
    int? currentPageDocument,
    int? totalNumberOfRecordDocument,
    String? currentSortColumnDocument,
    String? currentSortDirectionDocument,
    String? searchDocumentText,
    String? filterByFinancialYear,
    bool? isDisplayBankDetails,
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
      filterByContactPerson:
          filterByContactPerson ?? this.filterByContactPerson,
      filterByMobileNumber: filterByMobileNumber ?? this.filterByMobileNumber,
      filterByCityName: filterByCityName ?? this.filterByCityName,
      companyOverview:
          clearOverview == true
              ? null
              : companyOverview ?? this.companyOverview,
      bankDetailList:
          clearBankDetails == true
              ? null
              : bankDetailList ?? this.bankDetailList,
      companyDocumentList:
          clearCompanyDocuments == true
              ? null
              : companyDocumentList ?? this.companyDocumentList,
      searchDocumentText: searchDocumentText ?? this.searchDocumentText,
      filterByFinancialYear:
          filterByFinancialYear ?? this.filterByFinancialYear,
      currentPageDocument: currentPageDocument ?? this.currentPageDocument,
      totalNumberOfRecordDocument:
          totalNumberOfRecordDocument ?? this.totalNumberOfRecordDocument,
      currentSortColumnDocument:
          currentSortColumnDocument ?? this.currentSortColumnDocument,
      currentSortDirectionDocument:
          currentSortDirectionDocument ?? this.currentSortDirectionDocument,
      filterByGstNumber: filterByGstNumber ?? this.filterByGstNumber,
      filterByCinNumber: filterByCinNumber ?? this.filterByCinNumber,
      filterByPanNumber: filterByPanNumber ?? this.filterByPanNumber,
      filterByTanNumber: filterByTanNumber ?? this.filterByTanNumber,
      isDisplayBankDetails: isDisplayBankDetails ?? this.isDisplayBankDetails,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
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
    filterByGstNumber,
    filterByCinNumber,
    filterByPanNumber,
    filterByTanNumber,
    companyOverview,
    bankDetailList,
    searchDocumentText,
    filterByFinancialYear,
    companyDocumentList,
    isDisplayBankDetails,
    currentPageDocument,
    totalNumberOfRecordDocument,
    currentSortColumnDocument,
    currentSortDirectionDocument,
  ];
}
