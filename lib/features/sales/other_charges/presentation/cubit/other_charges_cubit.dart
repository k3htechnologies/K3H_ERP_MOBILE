import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'other_charges_state.dart';

class OtherChargesCubit extends Cubit<OtherChargesState> {
  OtherChargesCubit() : super(OtherChargesInitial());
}
