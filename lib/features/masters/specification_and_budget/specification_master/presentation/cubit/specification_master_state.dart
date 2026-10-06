import 'package:k3h_erp_app/core/base_state.dart';

import '../../data/model/specification_master.model.dart';

class SpecificationMasterState extends BaseState {
  final List<SpecificationMasterModel> specificationList;
  final int totalNumberOfRecord;
  final int currentPage;
  final List<SpecificationMasterModel> specificationViewList;
  final int totalNumberOfViewRecord;
  final int currentPageView;
  final String searchText;
  final String currentTabName;
  // Map to hold the children of each specification by their parent ID
  final Map<String, List<SpecificationMasterModel>> childrenMap;
  final Set<String> loadingIds;

  const SpecificationMasterState({
    super.isLoading,
    required this.specificationList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.specificationViewList,
    required this.totalNumberOfViewRecord,
    required this.currentPageView,
    required this.searchText,
    this.childrenMap = const {},
    this.loadingIds = const {},
    required this.currentTabName,
  });

  factory SpecificationMasterState.initial() => SpecificationMasterState(
    specificationList: [],
    totalNumberOfRecord: 0,
    currentPage: 1,
    specificationViewList: [],
    totalNumberOfViewRecord: 0,
    currentPageView: 1,
    searchText: "",
    isLoading: true,
    currentTabName: "L1",
  );

  SpecificationMasterState copyWith({
    bool? isLoading,
    List<SpecificationMasterModel>? specificationList,
    int? totalNumberOfRecord,
    int? currentPage,
    List<SpecificationMasterModel>? specificationViewList,
    int? totalNumberOfViewRecord,
    int? currentPageView,
    String? searchText,
    Map<String, List<SpecificationMasterModel>>? childrenMap,
    Map<String, int>? childPageMap,
    Map<String, int>? childTotalMap,
    Set<String>? expandedIds,
    Set<String>? loadingIds,
    String? currentTabName,
  }) {
    return SpecificationMasterState(
      isLoading: isLoading ?? this.isLoading,
      specificationList: specificationList ?? this.specificationList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      specificationViewList:
          specificationViewList ?? this.specificationViewList,
      totalNumberOfViewRecord:
          totalNumberOfViewRecord ?? this.totalNumberOfViewRecord,
      currentPageView: currentPageView ?? this.currentPageView,
      searchText: searchText ?? this.searchText,
      childrenMap: childrenMap ?? this.childrenMap,
      loadingIds: loadingIds ?? this.loadingIds,
      currentTabName: currentTabName ?? this.currentTabName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    specificationList,
    totalNumberOfRecord,
    currentPage,
    specificationViewList,
    totalNumberOfViewRecord,
    currentPageView,
    searchText,
    childrenMap,
    loadingIds,
    currentTabName,
  ];
}
