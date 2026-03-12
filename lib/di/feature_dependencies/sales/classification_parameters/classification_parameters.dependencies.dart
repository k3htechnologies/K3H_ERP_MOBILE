import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/datasource/classification_parameters.datasource.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/repository/classifaction_parameters.repositiory.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/presentation/cubit/classification_parameters_cubit.dart';

void registerClassificationParameterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ClassificationParametersDatasource>(
    ClassificationParametersDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ClassificationParametersRepository>(
    ClassificationParametersRepositoryImpl(
      classificationParametersDatasource:
          serviceLocator<ClassificationParametersDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<ClassificationParametersCubit>(
    ClassificationParametersCubit(),
  );
}
