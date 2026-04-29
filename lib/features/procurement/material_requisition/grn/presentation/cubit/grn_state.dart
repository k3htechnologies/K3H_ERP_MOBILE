part of 'grn_cubit.dart';

final class GrnState extends BaseState {
  final List<GRNModel> allGRNList;
  const GrnState({super.isLoading, required this.allGRNList});

  factory GrnState.initial() => GrnState(allGRNList: []);
  GrnState copyWith({
    List<GRNModel>? allGRNList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GrnState(
      allGRNList: allGRNList ?? this.allGRNList,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [isLoading, allGRNList];
}
