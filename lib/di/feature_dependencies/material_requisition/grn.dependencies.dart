import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/datasource/grn.datasource.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/data/repository/grn.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/grn/presentation/cubit/grn_cubit.dart';

void registerMaterialRequisitionGRNDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<GrnDatasource>(GrnDatasourceImpl());
  serviceLocator.registerSingleton<GrnRepository>(
    GrnRepositoryImpl(grnDatasource: serviceLocator<GrnDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<GrnCubit>(GrnCubit());
}
