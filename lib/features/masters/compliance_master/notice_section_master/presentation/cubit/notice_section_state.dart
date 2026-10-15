import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/model/notice_section.model.dart';

class NoticeSectionMasterState extends BaseState {
  final List<NoticeSectionModel> noticeSectionList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;
  final String currentSortColumn;
  final String currentSortDirection;
  final String filterByGovernmentCompliance;

  const NoticeSectionMasterState({
    required this.noticeSectionList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.currentSortColumn,
    required this.currentSortDirection,
    required this.filterByGovernmentCompliance,
    super.isLoading,
  });

  factory NoticeSectionMasterState.initial() => NoticeSectionMasterState(
    noticeSectionList: [],
    isLoading: false,
    totalNumberOfRecord: 0,
    currentPage: 1,
    searchText: "",
    currentSortColumn: "",
    currentSortDirection: "",
    filterByGovernmentCompliance: "",
  );

  NoticeSectionMasterState copyWith({
    bool? isLoading,
    List<NoticeSectionModel>? noticeSectionList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    String? currentSortColumn,
    String? currentSortDirection,
    String? filterByGovernmentCompliance,
  }) {
    return NoticeSectionMasterState(
      isLoading: isLoading ?? this.isLoading,
      noticeSectionList: noticeSectionList ?? this.noticeSectionList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
      filterByGovernmentCompliance:
          filterByGovernmentCompliance ?? this.filterByGovernmentCompliance,
    );
  }

  @override
  List<Object?> get props => [
    noticeSectionList,
    isLoading,
    totalNumberOfRecord,
    searchText,
    currentPage,
    currentSortColumn,
    currentSortDirection,
    filterByGovernmentCompliance,
  ];
}
