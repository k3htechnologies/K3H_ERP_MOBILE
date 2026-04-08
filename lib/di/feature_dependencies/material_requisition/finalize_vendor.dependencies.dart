import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/datasource/finalize_vendor.datasource.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/repository/finalize_vendor.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/presentation/cubit/finalize_vendor_cubit.dart';

void registerMaterialRequisitionFinalizeVendorDependencies(
  GetIt serviceLocator,
) {
  serviceLocator.registerSingleton<FinalizeVendorDatasource>(
    FinalizeVendorDatasourceImpl(),
  );
  serviceLocator.registerSingleton<FinalizeVendorRepository>(
    FinalizeVendorRepositoryImpl(
      finalizeVendorDatasource: serviceLocator<FinalizeVendorDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<FinalizeVendorCubit>(FinalizeVendorCubit());
}
