part of 'material_requisition_cubit.dart';

final class MaterialRequisitionState extends BaseState {
  final List<MaterialRequisitionModel> materialRequisitionList;
  final List<MaterialRequisitionDetailModel> materialList;
  final int totalNumberOfRecord;
  final String searchText;
  final int currentPage;
  final MaterialRequisitionModel? materialRequisitionOverview;
  final FinalizeVendorForComparisonModel? finalizedVendor;

  const MaterialRequisitionState({
    super.isLoading,
    required this.materialRequisitionList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.materialList,
    required this.materialRequisitionOverview,
    required this.finalizedVendor,
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
    );
  }
  MaterialRequisitionState copyWith({
    bool? isLoading,
    List<MaterialRequisitionModel>? materialRequisitionList,
    List<MaterialRequisitionDetailModel>? materialList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
    MaterialRequisitionModel? materialRequisitionOverview,
    FinalizeVendorForComparisonModel? finalizedVendor,
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
      finalizedVendor: finalizedVendor ?? this.finalizedVendor,
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
  ];
}
