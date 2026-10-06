import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/datasource/leave_type_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/data/repository/leave_type_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_type_master/presentation/cubit/leave_type_master_cubit.dart';

void registerLeaveTypeMasterDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LeaveTypeMasterDataSource>(
    LeaveTypeMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<LeaveTypeMasterRepository>(
    LeaveTypeMasterRepositoryImp(
      leaveTypeMasterDataSource: serviceLocator<LeaveTypeMasterDataSource>(),
    ),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<LeaveTypeMasterCubit>(
    LeaveTypeMasterCubit(),
  );
}
