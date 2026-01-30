import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/attendance/data/datasource/attendence.datasource.dart';

abstract interface class AttendanceRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateAttendanceRegularization({
    required Map<String, dynamic> queryParams,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceDataSource attendanceDataSource;

  AttendanceRepositoryImpl({required this.attendanceDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAttendanceList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await attendanceDataSource.apicallPullAttendance(
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
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateAttendanceRegularization({
    required Map<String, dynamic> queryParams,
  }) async {
    try {
      final result = await attendanceDataSource
          .apicallAddUpdateAttendanceRegularize(queryParams: queryParams);

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
