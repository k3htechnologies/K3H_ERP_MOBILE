import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/litigation/data/datasource/litigation.datasource.dart';
import 'package:k3h_erp_app/features/litigation/data/repository/litigation.repository.dart';
import 'package:k3h_erp_app/features/litigation/presentation/cubit/litigation_cubit.dart';

void registerLitigationDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LitigationDatasource>(
    LitigationDatasourceImpl(),
  );
  serviceLocator.registerSingleton<LitigationRepository>(
    LitigationRepositoryImpl(
      litigationDatasource: serviceLocator<LitigationDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<LitigationCubit>(LitigationCubit());
}
