import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/core/cubit/utils_cubit.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/core/utils.datasource.dart';

void registerUtilsDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<UtilsDatasource>(UtilsDatasourceImpl());
  serviceLocator.registerSingleton<UtilsRepository>(
    UtilsRepositoryImpl(serviceLocator<UtilsDatasource>()),
  );
  serviceLocator.registerSingleton<UtilsCubit>(UtilsCubit());
}
