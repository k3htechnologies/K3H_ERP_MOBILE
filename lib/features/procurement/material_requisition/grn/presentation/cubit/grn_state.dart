part of 'grn_cubit.dart';

final class GrnState extends BaseState {
  final List<GRNModel> allGRNList;
  final List<MaterialRequisitionDetailGrnDatum> materialList;

  const GrnState({
    super.isLoading,
    required this.allGRNList,
    required this.materialList,
  });

  factory GrnState.initial() => GrnState(allGRNList: [], materialList: []);
  GrnState copyWith({
    List<GRNModel>? allGRNList,
    List<MaterialRequisitionDetailGrnDatum>? materialList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GrnState(
      allGRNList: allGRNList ?? this.allGRNList,
      materialList: materialList ?? this.materialList,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLoading, allGRNList, materialList];
}
