import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/datasource/umo_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/data/repository/umo_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/umo_master/presentation/cubit/umo_master_cubit.dart';

void registerUOMMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<UOMMasterDatasource>(
    UOMMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<UOMMasterRepository>(
    UOMMasterRepositoryImpl(
      uomMasterDatasource: serviceLocator<UOMMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<UOMMasterCubit>(
    UOMMasterCubit(),
  );
}

