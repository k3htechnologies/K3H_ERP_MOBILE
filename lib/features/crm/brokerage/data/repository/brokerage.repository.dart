import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/brokerage/data/datasource/brokerage.datasource.dart';

abstract interface class BrokerageRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBrokerageBookingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

}

class BrokerageRepositoryImp extends BrokerageRepository {
  final BrokerageDatasource brokerageDatasource;

  BrokerageRepositoryImp({required this.brokerageDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBrokerageBookingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await brokerageDatasource.apicallPullBrokerageBooking(
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
  Future<Either<Failure, Map<String, dynamic>>> exportBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await brokerageDatasource.apicallPullBrokerageBookingForExport(
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
}
