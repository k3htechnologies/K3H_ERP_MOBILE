import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/datasource/tenant.datasource.dart';
import 'package:k3h_erp_app/features/business_development/tenant/data/repository/tenant.repository.dart';
import 'package:k3h_erp_app/features/business_development/tenant/presentation/cubit/tenant_cubit.dart';

void registerTenantMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TenantDatasource>(TenantDataSourceImpl());

  serviceLocator.registerSingleton<TenantRepository>(
    TenantRepositoryImpl(tenantDatasource: serviceLocator<TenantDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TenantCubit>(TenantCubit());
}
