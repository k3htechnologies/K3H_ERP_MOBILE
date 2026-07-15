import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/datasource/dcr.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/data/repository/dcr.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_report/dcr/presentation/cubit/dcr_cubit.dart';

void registerCrmReportsDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DCRDatasource>(
    DCRDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DCRRepository>(
    DCRRepositoryImp(
      dcrDatasource: serviceLocator<DCRDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<DcrCubit>(DcrCubit());
}
