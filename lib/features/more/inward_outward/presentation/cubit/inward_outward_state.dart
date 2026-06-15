import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/model/inward_outward.model.dart';

class InwardOutwardState extends BaseState {
  // All
  final List<InwardOutwardModel> inwardOutwardList;
  final int inwardOutwardTotalRecords;
  final int inwardOutwardCurrentPage;

  final List<InwardOutwardModel> inwardList;
  final int inwardTotalRecords;
  final int inwardCurrentPage;

  final List<InwardOutwardModel> outwardList;
  final int outwardTotalRecords;
  final int outwardCurrentPage;

  final String searchText;
  final int currentTabIndex;

  // Filters
  final String filterBySenderName;
  final String filterByReceiverName;
  final String filterByDocumentType;

  // Sorting
  final String currentSortColumn;
  final String currentSortDirection;

  const InwardOutwardState({
    super.isLoading,

    required this.inwardOutwardList,
    required this.inwardOutwardTotalRecords,
    required this.inwardOutwardCurrentPage,

    required this.inwardList,
    required this.inwardTotalRecords,
    required this.inwardCurrentPage,

    required this.outwardList,
    required this.outwardTotalRecords,
    required this.outwardCurrentPage,

    required this.searchText,
    required this.currentTabIndex,

    required this.filterBySenderName,
    required this.filterByReceiverName,
    required this.filterByDocumentType,

    required this.currentSortColumn,
    required this.currentSortDirection,
  });

  factory InwardOutwardState.initial() => const InwardOutwardState(
    isLoading: true,

    inwardOutwardList: [],
    inwardOutwardTotalRecords: 0,
    inwardOutwardCurrentPage: 1,

    inwardList: [],
    inwardTotalRecords: 0,
    inwardCurrentPage: 1,

    outwardList: [],
    outwardTotalRecords: 0,
    outwardCurrentPage: 1,

    searchText: "",
    currentTabIndex: 0,

    filterBySenderName: "",
    filterByReceiverName: "",
    filterByDocumentType: "",

    currentSortColumn: "",
    currentSortDirection: "",
  );

  InwardOutwardState copyWith({
    bool? isLoading,

    List<InwardOutwardModel>? inwardOutwardList,
    int? inwardOutwardTotalRecords,
    int? inwardOutwardCurrentPage,

    List<InwardOutwardModel>? inwardList,
    int? inwardTotalRecords,
    int? inwardCurrentPage,

    List<InwardOutwardModel>? outwardList,
    int? outwardTotalRecords,
    int? outwardCurrentPage,

    String? searchText,
    int? currentTabIndex,

    String? filterBySenderName,
    String? filterByReceiverName,
    String? filterByDocumentType,

    String? currentSortColumn,
    String? currentSortDirection,
  }) {
    return InwardOutwardState(
      isLoading: isLoading ?? this.isLoading,

      inwardOutwardList: inwardOutwardList ?? this.inwardOutwardList,
      inwardOutwardTotalRecords:
          inwardOutwardTotalRecords ?? this.inwardOutwardTotalRecords,
      inwardOutwardCurrentPage:
          inwardOutwardCurrentPage ?? this.inwardOutwardCurrentPage,

      inwardList: inwardList ?? this.inwardList,
      inwardTotalRecords: inwardTotalRecords ?? this.inwardTotalRecords,
      inwardCurrentPage: inwardCurrentPage ?? this.inwardCurrentPage,

      outwardList: outwardList ?? this.outwardList,
      outwardTotalRecords: outwardTotalRecords ?? this.outwardTotalRecords,
      outwardCurrentPage: outwardCurrentPage ?? this.outwardCurrentPage,

      searchText: searchText ?? this.searchText,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,

      filterBySenderName: filterBySenderName ?? this.filterBySenderName,
      filterByReceiverName: filterByReceiverName ?? this.filterByReceiverName,
      filterByDocumentType: filterByDocumentType ?? this.filterByDocumentType,

      currentSortColumn: currentSortColumn ?? this.currentSortColumn,
      currentSortDirection: currentSortDirection ?? this.currentSortDirection,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,

    inwardOutwardList,
    inwardOutwardTotalRecords,
    inwardOutwardCurrentPage,

    inwardList,
    inwardTotalRecords,
    inwardCurrentPage,

    outwardList,
    outwardTotalRecords,
    outwardCurrentPage,

    searchText,
    currentTabIndex,

    filterBySenderName,
    filterByReceiverName,
    filterByDocumentType,

    currentSortColumn,
    currentSortDirection,
  ];
}
