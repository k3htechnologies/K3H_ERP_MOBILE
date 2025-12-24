import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/profile/presentation/cubit/profile_cubit.dart';

void registerProfileDependencies(GetIt serviceLocator) {
  // <----- CUBITS ----->
  serviceLocator.registerSingleton<ProfileCubit>(ProfileCubit());
}