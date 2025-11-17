import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/terms_and_condition_master/data/datasource/terms_and_condition.datasource.dart';
import 'package:k3h_erp_app/features/masters/terms_and_condition_master/data/repository/terms_and_condition.repository.dart';
import 'package:k3h_erp_app/features/masters/terms_and_condition_master/presentation/cubit/terms_and_condition_cubit.dart';

void registerTermsAndConditionsMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TermsAndConditionDatasource>(
    TermsAndConditionDatasourceImpl(),
  );

  serviceLocator.registerSingleton<TermsAndConditionMasterRepository>(
    TermsAndConditionMasterRepositoryImpl(
      termsAndConditionDatasource:
          serviceLocator<TermsAndConditionDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<TermsAndConditionCubit>(
    TermsAndConditionCubit(),
  );
}
