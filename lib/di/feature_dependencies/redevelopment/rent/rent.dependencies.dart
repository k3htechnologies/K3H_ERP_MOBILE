import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/datasource/rent.datasource.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/data/repository/rent.repository.dart';
import 'package:k3h_erp_app/features/redevelopment/rent/presentation/cubit/rent_cubit.dart';

void registerRentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<RentDatasource>(RentDatasourceImpl());

  serviceLocator.registerSingleton<RentRepository>(
    RentRepositoryImpl(rentDatasource: serviceLocator<RentDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<RentCubit>(RentCubit());
}
