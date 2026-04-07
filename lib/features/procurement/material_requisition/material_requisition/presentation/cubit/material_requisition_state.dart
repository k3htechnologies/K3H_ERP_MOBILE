part of 'material_requisition_cubit.dart';

final class MaterialRequisitionState extends BaseState {
  final List<MaterialRequisitionModel> materialRequisitionList;
  const MaterialRequisitionState({
    super.isLoading,
    required this.materialRequisitionList,
  });

  factory MaterialRequisitionState.initial() {
    return const MaterialRequisitionState(
      isLoading: false,
      materialRequisitionList: [],
    );
  }
  MaterialRequisitionState copyWith({
    bool? isLoading,
    List<MaterialRequisitionModel>? materialRequisitionList,
  }) {
    return MaterialRequisitionState(
      isLoading: isLoading ?? this.isLoading,
      materialRequisitionList:
          materialRequisitionList ?? this.materialRequisitionList,
    );
  }

  @override
  List<Object?> get props => [isLoading];
}
