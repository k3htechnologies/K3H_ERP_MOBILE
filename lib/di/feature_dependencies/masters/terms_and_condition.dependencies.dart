import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/datasource/terms_and_conditions.datasource.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/presentation/cubit/terms_and_conditions_cubit.dart';

void registerTermsAndConditionsMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TermsAndConditionsDatasource>(
    TermsAndConditionsDatasourceImpl(),
  );

  serviceLocator.registerSingleton<TermsAndConditionsMasterRepository>(
    TermsAndConditionsMasterRepositoryImpl(
      termsAndConditionsDatasource:
          serviceLocator<TermsAndConditionsDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<TermsAndConditionsCubit>(
    TermsAndConditionsCubit(),
  );
}
