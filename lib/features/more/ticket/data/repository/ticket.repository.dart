import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/more/ticket/data/datasource/ticket.datasource.dart';

abstract interface class TicketRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTicketList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullEmployeeActiveTickets({
    required int pageNumber,
    required int pageSize,
  });
  Future<Either<Failure, Map<String, dynamic>>> assignTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class TicketRepositoryImpl implements TicketRepository {
  final TicketDatasource ticketDatasource;

  TicketRepositoryImpl({required this.ticketDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTicketList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await ticketDatasource.apicallPullTicket(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullEmployeeActiveTickets({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final result = await ticketDatasource.pullEmployeeActiveTickets(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> assignTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await ticketDatasource.apicallAssignTicket(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await ticketDatasource.apicallAddUpdateTicket(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
