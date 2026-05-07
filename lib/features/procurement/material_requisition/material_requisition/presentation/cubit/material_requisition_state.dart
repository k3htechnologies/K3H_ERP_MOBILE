part of 'material_requisition_cubit.dart';

final class MaterialRequisitionState extends BaseState {
  final List<MaterialRequisitionModel> materialRequisitionList;
  final List<MaterialRequisitionDetailModel> materialList;
  final int totalNumberOfRecord;
  final String searchText;
  final int currentPage;
  final MaterialRequisitionModel? materialRequisitionOverview;
  final FinalizeVendorForComparisonModel? finalizedVendor;
  final String filterByMaterialRequisitionStage;
  final String filterByMaterialRequisitionStatus;
  final DateTime? filterByFromDate;
  final DateTime? filterByToDate;

  const MaterialRequisitionState({
    super.isLoading,
    required this.materialRequisitionList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.materialList,
    required this.materialRequisitionOverview,
    required this.finalizedVendor,
    required this.filterByMaterialRequisitionStage,
    required this.filterByMaterialRequisitionStatus,
    required this.filterByFromDate,
    required this.filterByToDate,
  });

  factory MaterialRequisitionState.initial() {
    return const MaterialRequisitionState(
      isLoading: false,
      materialRequisitionList: [],
      materialList: [],
      totalNumberOfRecord: 0,
      currentPage: 1,
      searchText: "",
      materialRequisitionOverview: null,
      finalizedVendor: null,
      filterByMaterialRequisitionStage: "",
      filterByMaterialRequisitionStatus: "",
      filterByFromDate: null,
      filterByToDate: null,
    );
  }

  static const _noChange = Object();

  MaterialRequisitionState copyWith({
    bool? isLoading,
    List<MaterialRequisitionModel>? materialRequisitionList,
    List<MaterialRequisitionDetailModel>? materialList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    MaterialRequisitionModel? materialRequisitionOverview,

    Object? filterByMaterialRequisitionStage = _noChange,
    Object? filterByMaterialRequisitionStatus = _noChange,

    Object? filterByFromDate = _noChange,
    Object? filterByToDate = _noChange,

    Object? finalizedVendor = _noChange,
  }) {
    return MaterialRequisitionState(
      isLoading: isLoading ?? this.isLoading,
      materialRequisitionList:
          materialRequisitionList ?? this.materialRequisitionList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      materialList: materialList ?? this.materialList,

      materialRequisitionOverview:
          materialRequisitionOverview ?? this.materialRequisitionOverview,

      finalizedVendor:
          finalizedVendor == _noChange
              ? this.finalizedVendor
              : finalizedVendor as FinalizeVendorForComparisonModel?,

      filterByMaterialRequisitionStage:
          filterByMaterialRequisitionStage == _noChange
              ? this.filterByMaterialRequisitionStage
              : filterByMaterialRequisitionStage as String? ?? "",

      filterByMaterialRequisitionStatus:
          filterByMaterialRequisitionStatus == _noChange
              ? this.filterByMaterialRequisitionStatus
              : filterByMaterialRequisitionStatus as String? ?? "",

      filterByFromDate:
          filterByFromDate == _noChange
              ? this.filterByFromDate
              : filterByFromDate as DateTime?,

      filterByToDate:
          filterByToDate == _noChange
              ? this.filterByToDate
              : filterByToDate as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    materialRequisitionList,
    materialList,
    totalNumberOfRecord,
    currentPage,
    searchText,
    materialRequisitionOverview,
    finalizedVendor,
    filterByMaterialRequisitionStage,
    filterByMaterialRequisitionStatus,
    filterByFromDate,
    filterByToDate,
  ];
}
