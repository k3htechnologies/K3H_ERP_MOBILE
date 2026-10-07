import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/datasource/budget.datasource.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/data/repository/budget.repository.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/budget/presentation/cubit/budget_cubit.dart';

void registerBudgetDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BudgetDatasource>(BudgetDatasourceImpl());
  serviceLocator.registerSingleton<BudgetRepository>(
    BudgetRepositoryImpl(budgetDatasource: serviceLocator<BudgetDatasource>()),
  );
  //- CUBITS -
  serviceLocator.registerSingleton<BudgetCubit>(BudgetCubit());
}
