part of 'grn_cubit.dart';

final class GrnState extends BaseState {
  final List<GRNModel> allGRNList;
  final List<GRNModel> filteredGRNList;
  final List<MaterialRequisitionDetailGrnDatum> materialList;

  const GrnState({
    super.isLoading,
    required this.allGRNList,
    required this.materialList,
    required this.filteredGRNList,
  });

  factory GrnState.initial() =>
      GrnState(allGRNList: [], materialList: [], filteredGRNList: []);
  GrnState copyWith({
    List<GRNModel>? allGRNList,
    List<GRNModel>? filteredGRNList,
    List<MaterialRequisitionDetailGrnDatum>? materialList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GrnState(
      allGRNList: allGRNList ?? this.allGRNList,
      materialList: materialList ?? this.materialList,
      isLoading: isLoading ?? this.isLoading,
      filteredGRNList: filteredGRNList ?? this.filteredGRNList,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    allGRNList,
    materialList,
    filteredGRNList,
  ];
}
