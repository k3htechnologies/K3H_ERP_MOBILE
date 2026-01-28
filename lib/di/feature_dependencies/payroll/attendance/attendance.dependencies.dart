import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/datasource/attendence.datasource.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/repository/attendance.repository.dart';
import 'package:k3h_erp_app/features/payroll/attendance/presentation/cubit/attendance_cubit.dart';

void registerAttendanceDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<AttendanceDataSource>(
    AttendanceDataSourceImpl(),
  );
  serviceLocator.registerSingleton<AttendanceRepository>(
    AttendanceRepositoryImpl(
      attendanceDataSource: serviceLocator<AttendanceDataSource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<AttendanceCubit>(AttendanceCubit());
}
