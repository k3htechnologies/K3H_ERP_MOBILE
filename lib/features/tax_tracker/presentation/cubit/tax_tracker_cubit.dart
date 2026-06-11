import 'package:bloc/bloc.dart';
import 'package:k3h_erp_app/core/base_state.dart';

part 'tax_tracker_state.dart';

class TaxTrackerCubit extends Cubit<TaxTrackerState> {
  TaxTrackerCubit() : super(TaxTrackerState.initial());
}
