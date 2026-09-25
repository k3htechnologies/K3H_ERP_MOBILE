import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/data/model/term_sheet_documents.model.dart';

class TermSheetDocumentsState extends BaseState {
  final List<TermSheetDocumentModel> termSheetDocumentList;
  final TermSheetDocumentModel? termSheetDocumentOverview;
  final String filterDocumentName;
  final int totalNumberOfRecord;
  final int currentPage;
  const TermSheetDocumentsState({
    super.isLoading,
    required this.termSheetDocumentList,
    this.termSheetDocumentOverview,
    required this.filterDocumentName,
    required this.totalNumberOfRecord,
    required this.currentPage,
  });
  factory TermSheetDocumentsState.inital() => TermSheetDocumentsState(
    termSheetDocumentList: [],
    termSheetDocumentOverview: null,
    filterDocumentName: '',
    totalNumberOfRecord: 0,
    currentPage: 1,
  );
  TermSheetDocumentsState copywith({
    bool? isLoading,
    List<TermSheetDocumentModel>? termSheetDocumentList,
    TermSheetDocumentModel? termSheetDocumentOverview,
    int? totalNumberOfRecord,
    int? currentPage,
    String? filterDocumentName,
  }) {
    return TermSheetDocumentsState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDocumentList:
          termSheetDocumentList ?? this.termSheetDocumentList,
      termSheetDocumentOverview:
          termSheetDocumentOverview ?? this.termSheetDocumentOverview,
      filterDocumentName: filterDocumentName ?? this.filterDocumentName,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDocumentList,
    termSheetDocumentOverview,
    filterDocumentName,
    totalNumberOfRecord,
    currentPage,
  ];
}
