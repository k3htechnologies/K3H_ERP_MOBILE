import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/datasource/construction_area.datasource.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/data/repository/construction_area.repository.dart';
import 'package:k3h_erp_app/features/estimation_and_budget/construction_area/presentation/cubit/construction_area_cubit.dart';

void registerConstructionAreaDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ConstructionAreaDatasource>(
    ConstructionAreaDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ConstructionAreaRepository>(
    ConstructionAreaRepositoryImpl(
      constructionAreaDatasource: serviceLocator<ConstructionAreaDatasource>(),
    ),
  );
  //- CUBITS -
  serviceLocator.registerSingleton<ConstructionAreaCubit>(
    ConstructionAreaCubit(),
  );
}
