import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/datasource/company_master_datasource.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/repository/company_master_repository.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master_add/company_master_add_cubit.dart';

void registerCompanyMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CompanyMasterDatasource>(
    CompanyMasterDataSourceImp(),
  );

  serviceLocator.registerSingleton<CompanyMasterRepository>(
    CompanyMasterRepositoryImp(
      companyMasterDatasource: serviceLocator<CompanyMasterDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<CompanyMasterCubit>(CompanyMasterCubit());
  serviceLocator.registerSingleton<CompanyMasterAddCubit>(
    CompanyMasterAddCubit(),
  );
}