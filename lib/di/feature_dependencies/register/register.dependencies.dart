import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';
import 'package:k3h_erp_app/features/register/data/datasource/register.datasource.dart';
import 'package:k3h_erp_app/features/register/data/repository/register.repository.dart';
import 'package:k3h_erp_app/features/register/presentation/cubit/register_cubit.dart';

void registerDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<RegisterDatasource>(
    RegisterDatasourceImpl(),
  );
  serviceLocator.registerSingleton<RegisterRepository>(
    RegisterRepositoryImpl(
      registerDatasource: serviceLocator<RegisterDatasource>(),
      utilsDatasource: serviceLocator<UtilsDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<RegisterCubit>(RegisterCubit());
}
