part of 'tax_tracker_cubit.dart';

class TaxTrackerState extends BaseState {
  const TaxTrackerState({super.isLoading});

  factory TaxTrackerState.initial() => TaxTrackerState(isLoading: true);

  TaxTrackerState copywith({bool? isLoading}) {
    return TaxTrackerState(isLoading: isLoading ?? this.isLoading);
  }

  @override
  List<Object?> get props => [isLoading];
}
