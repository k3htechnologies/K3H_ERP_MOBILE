import 'package:bloc/bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';

class PayTrackCubit extends Cubit<PayTrackState> {
  PayTrackCubit() : super(PayTrackState.initial());
}
