import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/calendar/data/datasource/calendar.datasource.dart';

abstract interface class CalendarRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEventList({
    required String fromDate,
    required String toDate,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateEvent({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteEvent({
    required int eventId,
    required String uniqueKey,
  });
}

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarDatasource calendarDatasource;

  CalendarRepositoryImpl({required this.calendarDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEventList({
    required String fromDate,
    required String toDate,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await calendarDatasource.apicallPullEvent(
        fromDate: fromDate,
        toDate: toDate,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEvent({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await calendarDatasource.apicallAddUpdateEvent(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteEvent({
    required int eventId,
    required String uniqueKey,
  }) async {
    try {
      var result = await calendarDatasource.apicallDeleteEvent(
        eventId: eventId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
