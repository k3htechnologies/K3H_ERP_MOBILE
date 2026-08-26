part of 'term_sheet_cubit.dart';

class TermSheetState extends BaseState {
  final List<TermSheetModel> termSheetList;
  final List<LocalTermSheetModel> localTermSheetList;
  final TermSheetModel? termSheetOverview;
  final List<TermSheetViewModel> termSheetViewList;
  final TermSheetDetailsView? termSheetDetailsViewModel;
  final int totalNumberOfRecord;
  final List<CompanyModel> companyByProject;
  final bool isFetchingCompany;
  final int currentPage;
  final String searchText;
  final String filterByProjectName;
  final String filterByCompanyName;
  final String filterByStatus;
  final String filterByInstitutionName;
  // TO TRACK UNSAVED CHANGES
  final bool hasUnsavedTermSheetChanges;
  const TermSheetState({
    super.isLoading,
    required this.termSheetList,
    required this.totalNumberOfRecord,
    required this.companyByProject,
    required this.isFetchingCompany,
    required this.currentPage,
    this.termSheetOverview,
    required this.termSheetViewList,
    required this.hasUnsavedTermSheetChanges,
    required this.localTermSheetList,
    this.termSheetDetailsViewModel,
    required this.searchText,
    required this.filterByCompanyName,
    required this.filterByProjectName,
    required this.filterByStatus,
    required this.filterByInstitutionName,
  });

  factory TermSheetState.inital() => TermSheetState(
    termSheetList: [],
    localTermSheetList: [],
    totalNumberOfRecord: 0,
    companyByProject: [],
    isFetchingCompany: false,
    currentPage: 1,
    termSheetOverview: null,
    termSheetViewList: [],
    hasUnsavedTermSheetChanges: false,
    termSheetDetailsViewModel: null,
    searchText: '',
    filterByCompanyName: '',
    filterByProjectName: '',
    filterByStatus: '',
    filterByInstitutionName: '',
  );
  TermSheetState copyWith({
    bool? isLoading,
    List<TermSheetModel>? termSheetList,
    List<LocalTermSheetModel>? localTermSheetList,
    TermSheetModel? termSheetOverview,
    int? totalNumberOfRecord,
    List<CompanyModel>? companyByProject,
    bool? isFetchingCompany,
    int? currentPage,
    List<TermSheetViewModel>? termSheetViewList,
    bool? hasUnsavedTermSheetChanges,
    TermSheetDetailsView? termSheetDetailsViewModel,
    String? searchText,
    String? filterByCompanyName,
    String? filterByProjectName,
    String? filterByStatus,
    String? filterByInstitutionName,
  }) {
    return TermSheetState(
      isLoading: isLoading ?? this.isLoading,
      termSheetList: termSheetList ?? this.termSheetList,
      localTermSheetList: localTermSheetList ?? this.localTermSheetList,
      termSheetOverview: termSheetOverview ?? this.termSheetOverview,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      companyByProject: companyByProject ?? this.companyByProject,
      isFetchingCompany: isFetchingCompany ?? this.isFetchingCompany,
      currentPage: currentPage ?? this.currentPage,
      termSheetViewList: termSheetViewList ?? this.termSheetViewList,
      hasUnsavedTermSheetChanges:
          hasUnsavedTermSheetChanges ?? this.hasUnsavedTermSheetChanges,
      termSheetDetailsViewModel:
          termSheetDetailsViewModel ?? this.termSheetDetailsViewModel,
      searchText: searchText ?? this.searchText,
      filterByCompanyName: filterByCompanyName ?? this.filterByCompanyName,
      filterByProjectName: filterByProjectName ?? this.filterByProjectName,

      filterByStatus: filterByStatus ?? this.filterByStatus,

      filterByInstitutionName:
          filterByInstitutionName ?? this.filterByInstitutionName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetList,
    localTermSheetList,
    termSheetOverview,
    totalNumberOfRecord,
    companyByProject,
    isFetchingCompany,
    currentPage,
    termSheetViewList,
    hasUnsavedTermSheetChanges,
    termSheetDetailsViewModel,
    searchText,
    filterByProjectName,
    filterByCompanyName,
    filterByStatus,
    filterByInstitutionName,
  ];
}
