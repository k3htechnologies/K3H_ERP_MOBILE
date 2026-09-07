import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/datasource/gate_pass.datasource.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/repository/gate_pass.repository.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/presentation/cubit/gate_pass_cubit.dart';

void registerGatePassDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<GatePassDatasource>(
    GatePassDatasourceImpl(),
  );
  serviceLocator.registerSingleton<GatePassRepository>(
    GatePassRepositoryImpl(
      gatePassDatasource: serviceLocator<GatePassDatasource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<GatePassCubit>(GatePassCubit());
}
