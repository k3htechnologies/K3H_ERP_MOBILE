import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/datasource/other_charges.datasource.dart';
import 'package:k3h_erp_app/features/sales/other_charges/data/repository/other_charges.repository.dart';
import 'package:k3h_erp_app/features/sales/other_charges/presentation/cubit/other_charges_cubit.dart';

void registerOtherChargesDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<OtherChargesDatasource>(
    OtherChargesDatasourceImpl(),
  );
  serviceLocator.registerSingleton<OtherChargesRepository>(
    OtherChargesRepositoryImpl(
      otherChargesDatasource: serviceLocator<OtherChargesDatasource>(),
    ),
  );

  //<---- CUBIT ---->
  serviceLocator.registerSingleton<OtherChargesCubit>(OtherChargesCubit());
}
