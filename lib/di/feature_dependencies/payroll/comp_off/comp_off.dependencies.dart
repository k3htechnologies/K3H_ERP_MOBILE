import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/datasource/comp_off.datasource.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/repository/comp_off.repository.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';

void registerCompOffDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CompOffDatasource>(CompOffDatasourceImpl());
  serviceLocator.registerSingleton<CompOffRepository>(
    CompOffRepositoryImpl(
      compOffDatasource: serviceLocator<CompOffDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<CompOffCubit>(CompOffCubit());
}
