import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/datasource/temporary_alternate_accommodation.datasource.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/repository/temporary_alternate_accommodation.repository.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';

void registerRentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TemporaryAlternateAccommodationDatasource>(
    TemporaryAlternateAccommodationDatasourceImpl(),
  );

  serviceLocator.registerSingleton<TemporaryAlternateAccommodationRepository>(
    RentRepositoryImpl(
      rentDatasource:
          serviceLocator<TemporaryAlternateAccommodationDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TemporaryAlternateAccommodationCubit>(
    TemporaryAlternateAccommodationCubit(),
  );
}
