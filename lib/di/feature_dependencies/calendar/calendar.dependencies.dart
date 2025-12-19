import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/datasource/calendar.datasource.dart';
import 'package:k3h_erp_app/features/more/events/calendar/data/repository/calendar.repository.dart';
import 'package:k3h_erp_app/features/more/events/calendar/presentation/cubit/calendar_cubit.dart';

void registerCalendarDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<CalendarDatasource>(
    CalendarDatasourceImpl(),
  );
  serviceLocator.registerSingleton<CalendarRepository>(
    CalendarRepositoryImpl(
      calendarDatasource: serviceLocator<CalendarDatasource>(),
    ),
  );

  // <----- CUBITS ----->
  serviceLocator.registerSingleton<CalendarCubit>(CalendarCubit());
}
