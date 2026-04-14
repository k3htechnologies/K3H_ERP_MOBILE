import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/datasource/brokerage.datasource.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/repository/brokerage.repository.dart';
import 'package:k3h_erp_app/features/crm/brokerage/presentation/cubit/brokerage_cubit.dart';

void registerBrokerageDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<BrokerageDatasource>(
    BrokerageDatasourceImpl(),
  );
  serviceLocator.registerSingleton<BrokerageRepository>(
    BrokerageRepositoryImp(
      brokerageDatasource: serviceLocator<BrokerageDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<BrokerageCubit>(
    BrokerageCubit(),
  );
}