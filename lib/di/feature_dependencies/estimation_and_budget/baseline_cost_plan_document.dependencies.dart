import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/datasource/baseline_cost_plan.datasource.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/data/repository/baseline_cost_plan.repository.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/baseline_cost_plan/presentation/cubit/baseline_cost_plan_cubit.dart';

void registerBaselineCostPlanDocumentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BaselineCostPlanDatasource>(
    BaselineCostPlanDatasourceImpl(),
  );
  serviceLocator.registerSingleton<BaselineCostPlanRepository>(
    BaselineCostPlanRepositoryImpl(
      baselineCostPlanDatasource: serviceLocator<BaselineCostPlanDatasource>(),
    ),
  );
  //- CUBITS -
  serviceLocator.registerSingleton<BaselineCostPlanCubit>(
    BaselineCostPlanCubit(),
  );
}
