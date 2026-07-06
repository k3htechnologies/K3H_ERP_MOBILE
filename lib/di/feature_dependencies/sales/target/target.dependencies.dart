import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/target/data/datasource/target.datasource.dart';
import 'package:k3h_erp_app/features/sales/target/data/repository/target.repository.dart';
import 'package:k3h_erp_app/features/sales/target/presentation/cubit/target_cubit.dart';

void registerTargetDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TargetDatasource>(TargetDatasourceImpl());
  serviceLocator.registerSingleton<TargetRepository>(
    TargetRepositoryImpl(
      salesTargetDatasource: serviceLocator<TargetDatasource>(),
    ),
  );

  //<---- CUBIT
  serviceLocator.registerSingleton<TargetCubit>(TargetCubit());
}
