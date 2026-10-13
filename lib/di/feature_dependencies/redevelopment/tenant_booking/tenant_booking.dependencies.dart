import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/business_development/tenant_booking/presentation/cubit/tenant_booking_cubit.dart';

void registerTenantBookingDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TenantBookingCubit>(TenantBookingCubit());
}
