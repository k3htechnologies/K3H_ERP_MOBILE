part of 'material_requisition_cubit.dart';

final class MaterialRequisitionState extends BaseState {
  final List<MaterialRequisitionModel> materialRequisitionList;
  final List<MaterialRequisitionDetailModel> materialList;

  final int totalNumberOfRecord;
  final String searchText;
  final int currentPage;
  const MaterialRequisitionState({
    super.isLoading,
    required this.materialRequisitionList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
    required this.materialList,
  });

  factory MaterialRequisitionState.initial() {
    return const MaterialRequisitionState(
      isLoading: false,
      materialRequisitionList: [],
      materialList: [],
      totalNumberOfRecord: 0,
      currentPage: 1,
      searchText: "",
    );
  }
  MaterialRequisitionState copyWith({
    bool? isLoading,
    List<MaterialRequisitionModel>? materialRequisitionList,
    List<MaterialRequisitionDetailModel>? materialList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return MaterialRequisitionState(
      isLoading: isLoading ?? this.isLoading,
      materialRequisitionList:
          materialRequisitionList ?? this.materialRequisitionList,
      currentPage: currentPage ?? this.currentPage,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      searchText: searchText ?? this.searchText,
      materialList: materialList ?? this.materialList,
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
  ];
}
