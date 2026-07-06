import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/datasource/resignation.datasource.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/repository/resignation.repository.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_cubit.dart';

void registerResignationDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<ResignationDatasource>(
    ResignationDatasourceImpl(),
  );
  serviceLocator.registerSingleton<ResignationRepository>(
    ResignationRepositoryImpl(
      resignationDatasource: serviceLocator<ResignationDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<ResignationCubit>(ResignationCubit());
}
