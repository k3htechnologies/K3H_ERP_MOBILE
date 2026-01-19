import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/parking/data/datasource/parking.datasource.dart';

abstract interface class ParkingRepository {
  Future<Either<Failure, Map<String, dynamic>>> getParking({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getParkingWithPagination({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateParking({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportParking({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  });
}

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingDatasource parkingDataSource;

  ParkingRepositoryImpl({required this.parkingDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getParking({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await parkingDataSource.apicallPullParking(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getParkingWithPagination({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await parkingDataSource.apicallPullParkingWithPagination(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateParking({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await parkingDataSource.apicallUpdateParking(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportParking({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await parkingDataSource.apicallPullParkingForExport(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
