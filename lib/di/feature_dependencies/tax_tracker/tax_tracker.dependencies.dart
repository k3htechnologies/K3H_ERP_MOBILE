import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/datasource/tax_tracker.datasource.dart';
import 'package:k3h_erp_app/features/tax_tracker/data/repository/tax_tracker.repository.dart';
import 'package:k3h_erp_app/features/tax_tracker/presentation/cubit/tax_tracker_cubit.dart';

void registerTaxTrackerDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TaxTrackerDatasource>(
    TaxTrackerDatasourceImpl(),
  );
  serviceLocator.registerSingleton<TaxTrackerRepository>(
    TaxTrackerRepositoryImpl(
      taxTrackerDatasource: serviceLocator<TaxTrackerDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<TaxTrackerCubit>(TaxTrackerCubit());
}
