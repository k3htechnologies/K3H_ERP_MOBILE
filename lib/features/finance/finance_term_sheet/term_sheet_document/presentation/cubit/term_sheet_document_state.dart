import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/term_sheet_document/data/model/term_sheet_documents.model.dart';

class TermSheetDocumentsState extends BaseState {
  final List<TermSheetDocumentModel> termSheetDocumentList;
  final TermSheetDocumentModel? termSheetDocumentOverview;
  const TermSheetDocumentsState({
    super.isLoading,
    required this.termSheetDocumentList,
    this.termSheetDocumentOverview,
  });
  factory TermSheetDocumentsState.inital() => TermSheetDocumentsState(
    termSheetDocumentList: [],
    termSheetDocumentOverview: null,
  );
  TermSheetDocumentsState copywith({
    bool? isLoading,
    List<TermSheetDocumentModel>? termSheetDocumentList,
    TermSheetDocumentModel? termSheetDocumentOverview,
  }) {
    return TermSheetDocumentsState(
      isLoading: isLoading ?? this.isLoading,
      termSheetDocumentList:
          termSheetDocumentList ?? this.termSheetDocumentList,
      termSheetDocumentOverview:
          termSheetDocumentOverview ?? this.termSheetDocumentOverview,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    termSheetDocumentList,
    termSheetDocumentOverview,
  ];
}
