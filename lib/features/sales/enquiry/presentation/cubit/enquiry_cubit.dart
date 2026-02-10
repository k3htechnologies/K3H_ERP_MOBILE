import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'enquiry_state.dart';

class EnquiryCubit extends Cubit<EnquiryState> {
  EnquiryCubit() : super(EnquiryInitial());
}
