import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/datasource/uom_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/data/repository/uom_master.repository.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/uom_master/presentation/cubit/uom_master_cubit.dart';

void registerUOMMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<UOMMasterDatasource>(
    UOMMasterDatasourceImpl(),
  );

  serviceLocator.registerSingleton<UOMMasterRepository>(
    UOMMasterRepositoryImpl(
      uomMasterDatasource: serviceLocator<UOMMasterDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<UOMMasterCubit>(UOMMasterCubit());
}
