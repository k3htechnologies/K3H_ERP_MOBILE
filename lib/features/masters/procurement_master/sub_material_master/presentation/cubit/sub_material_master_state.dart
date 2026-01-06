part of 'sub_material_master_cubit.dart';

class SubMaterialMasterState extends BaseState {
  final List<SubMaterialMasterModel> subMaterialList;
  final int totalNumberOfRecord;
  final int currentPage;
  final String searchText;

  const SubMaterialMasterState({
    super.isLoading,
    required this.subMaterialList,
    required this.totalNumberOfRecord,
    required this.currentPage,
    required this.searchText,
  });

  factory SubMaterialMasterState.initial() => SubMaterialMasterState(
        subMaterialList: [],
        totalNumberOfRecord: 0,
        currentPage: 1,
        searchText: "",
        isLoading: true,
      );

  SubMaterialMasterState copyWith({
    String? errorMessage,
    bool? isLoading,
    bool? success,
    List<SubMaterialMasterModel>? subMaterialList,
    int? totalNumberOfRecord,
    int? currentPage,
    String? searchText,
  }) {
    return SubMaterialMasterState(
      isLoading: isLoading ?? this.isLoading,
      subMaterialList: subMaterialList ?? this.subMaterialList,
      totalNumberOfRecord: totalNumberOfRecord ?? this.totalNumberOfRecord,
      currentPage: currentPage ?? this.currentPage,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        subMaterialList,
        totalNumberOfRecord,
        currentPage,
        searchText,
      ];
}


