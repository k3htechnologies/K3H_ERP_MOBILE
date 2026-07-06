import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/datasource/outdoor.datasource.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/repository/outdoor.repository.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';

void registerOutdoorDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<OutdoorDatasource>(
    OutdoorDatasourceDataSourceImpl(),
  );
  serviceLocator.registerSingleton<OutdoorRepository>(
    OutdoorRepositoryImpl(
      outdoorDatasource: serviceLocator<OutdoorDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<OutdoorCubit>(OutdoorCubit());
}
