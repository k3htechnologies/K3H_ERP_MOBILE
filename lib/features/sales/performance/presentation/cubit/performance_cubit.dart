import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  PerformanceCubit() : super(PerformanceInitial());
}
