import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_hearing.model.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/model/litigation_document.model.dart';

class LitigationState extends BaseState {
  // ---- Litigation ----
  final List<LitigationModel> litigationList;
  final int litigationCurrentPage;
  final int litigationTotalRecords;

  // ---- Hearing ----
  final List<LitigationHearingModel> litigationHearingList;
  final int hearingCurrentPage;
  final int hearingTotalRecords;

  // ---- Document ----
  final List<LitigationDocumentModel> litigationDocumentList;
  final int documentCurrentPage;
  final int documentTotalRecords;

  // ---- UI ----
  final int currentTabIndex;
  final String searchText;

  // ----- FILTER ---------
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterCaseNumber;
  final String filterByCourtName;
  final String filterByProjectName;

  const LitigationState({
    super.isLoading,
    required this.litigationList,
    required this.litigationCurrentPage,
    required this.litigationTotalRecords,
    required this.litigationHearingList,
    required this.hearingCurrentPage,
    required this.hearingTotalRecords,
    required this.litigationDocumentList,
    required this.documentCurrentPage,
    required this.documentTotalRecords,
    required this.currentTabIndex,
    this.searchText = "",
    this.currentSortColumn = "",
    this.currentSortDirection = "",
    this.filterCaseNumber = "",
    this.filterByCourtName = "",
    this.filterByProjectName = "",
  });

  // ---------------- INITIAL ----------------
  factory LitigationState.initial() {
    return const LitigationState(
      isLoading: false,

      litigationList: [],
      litigationCurrentPage: 1,
      litigationTotalRecords: 0,

      litigationHearingList: [],
      hearingCurrentPage: 1,
      hearingTotalRecords: 0,

      litigationDocumentList: [],
      documentCurrentPage: 1,
      documentTotalRecords: 0,

      currentTabIndex: 0,
      searchText: "",

      currentSortColumn: "",
      currentSortDirection: "",
      filterCaseNumber: "",
      filterByCourtName: "",
      filterByProjectName: "",
    );
  }

  // ---------------- COPY WITH ----------------
  LitigationState copyWith({
    bool? isLoading,

    List<LitigationModel>? litigationList,
    int? litigationCurrentPage,
    int? litigationTotalRecords,

    List<LitigationHearingModel>? litigationHearingList,
    int? hearingCurrentPage,
    int? hearingTotalRecords,

    List<LitigationDocumentModel>? litigationDocumentList,
    int? documentCurrentPage,
    int? documentTotalRecords,

    int? currentTabIndex,
    String? searchText,

    String? currentSortColumn,
    String? currentSortDirection,
    String? filterCaseNumber,
    String? filterByCourtName,
    String? filterByProjectName,
  }) {
    return LitigationState(
      isLoading: isLoading ?? this.isLoading,

      litigationList: litigationList ?? this.litigationList,
      litigationCurrentPage:
          litigationCurrentPage ?? this.litigationCurrentPage,
      litigationTotalRecords:
          litigationTotalRecords ?? this.litigationTotalRecords,

      litigationHearingList:
          litigationHearingList ?? this.litigationHearingList,
      hearingCurrentPage: hearingCurrentPage ?? this.hearingCurrentPage,
      hearingTotalRecords: hearingTotalRecords ?? this.hearingTotalRecords,

      litigationDocumentList:
          litigationDocumentList ?? this.litigationDocumentList,
      documentCurrentPage: documentCurrentPage ?? this.documentCurrentPage,
      documentTotalRecords: documentTotalRecords ?? this.documentTotalRecords,

      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      searchText: searchText ?? this.searchText,

      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterCaseNumber: filterCaseNumber ?? this.filterCaseNumber,
      filterByCourtName: filterByCourtName ?? this.filterByCourtName,
      filterByProjectName: filterByProjectName ?? this.filterByProjectName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,

    litigationList,
    litigationCurrentPage,
    litigationTotalRecords,

    litigationHearingList,
    hearingCurrentPage,
    hearingTotalRecords,

    litigationDocumentList,
    documentCurrentPage,
    documentTotalRecords,

    currentTabIndex,
    searchText,

    currentSortColumn,
    currentSortDirection,
    filterCaseNumber,
    filterByCourtName,
    filterByProjectName,
  ];
}
