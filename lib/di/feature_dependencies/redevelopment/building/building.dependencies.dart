import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/datasource/building.datasource.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/repository/building.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/building/presentation/cubit/building_cubit.dart';

void registerRedevelopmentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BuildingDatasource>(
    BuildingDatasourceImpl(),
  );
  serviceLocator.registerSingleton<BuildingRepository>(
    BuildingRepositoryImpl(
      buildingDatasource: serviceLocator<BuildingDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<BuildingCubit>(BuildingCubit());
}
