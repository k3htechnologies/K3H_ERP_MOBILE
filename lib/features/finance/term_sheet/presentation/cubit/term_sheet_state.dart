part of 'term_sheet_cubit.dart';

class TermSheetState extends BaseState {
  final List<TermSheetModel> termSheetList;
  final int totalNumberOfRecord;
  final List<CompanyModel> companyByProject;
  final bool isFetchingCompany;
  const TermSheetState({
    super.isLoading,
    required this.termSheetList,
    required this.totalNumberOfRecord,
    required this.companyByProject,
    required this.isFetchingCompany,
  });

  factory TermSheetState.inital() => TermSheetState(
    termSheetList: [],
    totalNumberOfRecord: 0,
    companyByProject: [],
    isFetchingCompany: false,
  );
  TermSheetState copyWith({
    bool? isLoading,
    List<TermSheetModel>? termSheetList,
    int? totalNumberOfRecord,
    List<CompanyModel>? companyByProject,
    bool? isFetchingCompany,
  }) {
    return TermSheetState(
      isLoading: isLoading ?? this.isLoading,
      termSheetList: termSheetList ?? this.termSheetList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      companyByProject: companyByProject ?? this.companyByProject,
      isFetchingCompany: isFetchingCompany ?? this.isFetchingCompany,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetList,
    totalNumberOfRecord,
    companyByProject,
    isFetchingCompany,
  ];
}
