import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/datasource/collection_report.datasource.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/repository/collection_report.repository.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/presentation/cubit/collection_report_cubit.dart';

void registerCrmReportsCollectionReportDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CollectionReportDatasource>(
    CollectionReportDatasourceImpl(),
  );
  serviceLocator.registerSingleton<CollectionReportRepository>(
    CollectionReportRepositoryImpl(
      collectionReportDatasource: serviceLocator<CollectionReportDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<CollectionReportCubit>(
    CollectionReportCubit(),
  );
}
