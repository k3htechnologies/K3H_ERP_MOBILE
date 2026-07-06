import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';
import 'package:k3h_erp_app/features/login/data/datasource/login.datasource.dart';
import 'package:k3h_erp_app/features/login/data/repository/login.repository.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';

void registerLoginDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LoginDatasource>(LoginDatasourceImpl());
  serviceLocator.registerSingleton<LoginRepository>(
    LoginRepositoryImpl(
      loginDatasource: serviceLocator<LoginDatasource>(),
      utilsDatasource: serviceLocator<UtilsDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<LoginCubit>(LoginCubit());
}
