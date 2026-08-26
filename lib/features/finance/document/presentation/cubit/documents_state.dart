part of 'documents_cubit.dart';

class DocumentsState extends BaseState {
  final List<TermSheetDocumentModel> termSheetDocumentList;
  final TermSheetDocumentModel? termSheetDocumentOverview;
  final int totalNumberOfRecord;
  final int currentPage;
  const DocumentsState({
    super.isLoading,
    required this.totalNumberOfRecord,
    required this.termSheetDocumentList,
    this.termSheetDocumentOverview,
    required this.currentPage,
  });
  factory DocumentsState.inital() => DocumentsState(
    totalNumberOfRecord: 0,
    termSheetDocumentList: [],
    termSheetDocumentOverview: null,
    currentPage: 1,
  );
  DocumentsState copywith({
    bool? isLoading,
    int? totalNumberOfRecord,
    List<TermSheetDocumentModel>? termSheetDocumentList,
    TermSheetDocumentModel? termSheetDocumentOverview,
    int? currentPage,
  }) {
    return DocumentsState(
      isLoading: isLoading ?? this.isLoading,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      termSheetDocumentList:
          termSheetDocumentList ?? this.termSheetDocumentList,
      termSheetDocumentOverview:
          termSheetDocumentOverview ?? this.termSheetDocumentOverview,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    totalNumberOfRecord,
    termSheetDocumentList,
    termSheetDocumentOverview,
    currentPage,
  ];
}
