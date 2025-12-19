import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'vendor_add_state.dart';

class VendorAddCubit extends Cubit<VendorAddState> {
  VendorAddCubit() : super(VendorAddInitial());
}
