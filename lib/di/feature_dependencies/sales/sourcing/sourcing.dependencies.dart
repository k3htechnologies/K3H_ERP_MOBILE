import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/datasource/sourcing.datasource.dart';
import 'package:k3h_erp_app/features/sales/sourcing/data/repository/sourcing.repository.dart';
import 'package:k3h_erp_app/features/sales/sourcing/presentation/cubit/sourcing_cubit.dart';

void registerSourcingDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<SourcingDatasource>(
    SourcingDatasourceImpl(),
  );
  serviceLocator.registerSingleton<SourcingRepository>(
    SourcingRepositoryImpl(
      sourcingDatasource: serviceLocator<SourcingDatasource>(),
    ),
  );

  //<---- CUBIT
  serviceLocator.registerSingleton<SourcingCubit>(SourcingCubit());
}
