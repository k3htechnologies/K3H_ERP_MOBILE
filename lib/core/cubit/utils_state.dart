import 'package:k3h_erp_app/core/base_state.dart';

class UtilsState extends BaseState {
  const UtilsState({super.isLoading});
  factory UtilsState.initial() => const UtilsState(isLoading: false);
  UtilsState copyWith({bool? isLoading}) {
    return UtilsState(isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [isLoading];
}
