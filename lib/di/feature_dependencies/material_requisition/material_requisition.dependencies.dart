import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/datasource/material_requisition.datasource.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/data/repository/material_requisition.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/material_requisition/presentation/cubit/material_requisition_cubit.dart';

void registerMaterialRequisitionDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<MaterialRequisitionDatasource>(
    MaterialRequisitionDataSourceImpl(),
  );
  serviceLocator.registerSingleton<MaterialRequisitionRepository>(
    MaterialRequisitionRepositoryImpl(
      materialRequisitionDatasource:
          serviceLocator<MaterialRequisitionDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<MaterialRequisitionCubit>(
    MaterialRequisitionCubit(),
  );
}
