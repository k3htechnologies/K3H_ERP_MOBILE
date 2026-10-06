import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/datasource/designation_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/designation_master/data/repository/designation_master.repository.dart';
import 'package:k3h_erp_app/features/masters/designation_master/presentation/cubit/designation_master_cubit.dart';

void registerDesignationMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DesignationMasterDatasource>(
    DesignationDataSoucreImp(),
  );
  serviceLocator.registerSingleton<DesignationMasterRepository>(
    DesignationRepositoryImpl(serviceLocator<DesignationMasterDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DesignationMasterCubit>(
    DesignationMasterCubit(),
  );
}
