import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/datasource/inward_outward.datasource.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/repository/inward_outward.repository.dart';
import 'package:k3h_erp_app/features/more/inward_outward/presentation/cubit/inward_outward_cubit.dart';

void registerInwardOutwardependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<InwardOutwardDatasource>(
    InwardOutwardDatasourceImp(),
  );
  serviceLocator.registerSingleton<InwardOutwardRepository>(
    InwardOutwardRepositoryImpl(
      inwardOutwardDatasource: serviceLocator<InwardOutwardDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<InwardOutwardCubit>(InwardOutwardCubit());
}
