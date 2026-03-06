import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'classification_parameters_state.dart';

class ClassificationParametersCubit extends Cubit<ClassificationParametersState> {
  ClassificationParametersCubit() : super(ClassificationParametersInitial());
}
