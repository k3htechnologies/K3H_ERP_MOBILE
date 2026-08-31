import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/vendor_management/data/datasource/vendor.datasource.dart';
import 'package:k3h_erp_app/features/vendor_management/data/repository/vendor.repository.dart';
import 'package:k3h_erp_app/features/vendor_management/presentation/cubit/vendor/vendor_cubit.dart';

void registerVendorManagementDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<VendorDatasource>(VendorDataSourceImpl());
  serviceLocator.registerSingleton<VendorRepository>(
    VendorRepositoryImpl(vendorDatasource: serviceLocator<VendorDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<VendorCubit>(VendorCubit());
}
