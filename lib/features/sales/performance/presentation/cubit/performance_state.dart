part of 'performance_cubit.dart';

sealed class PerformanceState extends Equatable {
  const PerformanceState();

  @override
  List<Object> get props => [];
}

final class PerformanceInitial extends PerformanceState {}
