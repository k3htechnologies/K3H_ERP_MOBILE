import 'package:get_it/get_it.dart';
import 'package:k3h_erp_app/features/more/ticket/data/datasource/ticket.datasource.dart';
import 'package:k3h_erp_app/features/more/ticket/data/repository/ticket.repository.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';

void registerTicketDependencies(GetIt serviceLocator) {
  serviceLocator.registerSingleton<TicketDatasource>(TicketDatasourceImpl());
  serviceLocator.registerSingleton<TicketRepository>(
    TicketRepositoryImpl(ticketDatasource: serviceLocator<TicketDatasource>()),
  );

  //- CUBITS -
  serviceLocator.registerSingleton<TicketCubit>(TicketCubit());
}
