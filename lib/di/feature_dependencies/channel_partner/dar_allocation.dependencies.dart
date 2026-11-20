import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/datasource/dar_allocation.datasource.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/data/repository/dar_allocation_repository.dart';
import 'package:k3h_erp_app/features/channel_partner_module/dar_allocation/presentation/cubit/dar_allocation_cubit.dart';

void registerDarAllocationDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<DarAllocationDatasource>(
    DarAllocationDatasourceImpl(),
  );
  serviceLocator.registerSingleton<DarAllocationRepository>(
    DarAllocationRepositoryImpl(
      darAllocationDatasource: serviceLocator<DarAllocationDatasource>(),
    ),
  );
  //- CUBITS -
  serviceLocator.registerSingleton<DarAllocationCubit>(DarAllocationCubit());
}
