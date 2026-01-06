import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/datasource/leave_encashment_master.datasource.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/data/repository/leave_encashment_master.repository.dart';
import 'package:k3h_erp_app/features/masters/pay_roll_master/leave_encashment_master/presentation/cubit/leave_encashment_master_cubit.dart';

void registerLeaveEncashmentDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<LeaveEncashmentMasterDataSource>(
    LeaveEncashmentMasterDataSourceImp(),
  );
  serviceLocator.registerSingleton<LeaveEncashmentMasterRepository>(
    LeaveEncashmentMasterRepositoryImp(
      leaveEncashmentMasterDataSource:
          serviceLocator<LeaveEncashmentMasterDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<LeaveEncashmentMasterCubit>(
    LeaveEncashmentMasterCubit(),
  );
}
