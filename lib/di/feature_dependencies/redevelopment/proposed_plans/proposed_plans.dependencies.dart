import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/datasource/proposed_plans.datasource.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/data/repository/proposed_plans.repository.dart';
import 'package:k3h_erp_app/features/business_development/proposed_plans/presentation/cubit/proposed_plans_cubit.dart';

void registerProposedPlansDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ProposedPlansDatasource>(
    ProposedPlansDatasourceImpl(),
  );

  serviceLocator.registerSingleton<ProposedPlansRepository>(
    ProposedPlansRepositoryImpl(
      proposedPlansDatasource: serviceLocator<ProposedPlansDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ProposedPlansCubit>(ProposedPlansCubit());
}
