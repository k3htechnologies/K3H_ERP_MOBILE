import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/brokerage/data/datasource/brokerage.datasource.dart';
abstract interface class BrokerageRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBrokerageBookingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBrokerageInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteBrokerageInvoice({
    required int projectId,
    required int brokerageInvoiceId,
    required int bookingId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaidBrokerageBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deletePaidBrokerageBooking({
    required int projectId,
    required int paidBrokerageBookingId,
    required int bookingId,
    required int brokerageInvoiceId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
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
  Future<Either<Failure, Map<String, dynamic>>> pullBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await brokerageDatasource.apicallPullBrokerageInvoice(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        bookingId: bookingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBrokerageInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await brokerageDatasource.addUpdateBrokerageInvoice(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBrokerageInvoice({
    required int projectId,
    required int brokerageInvoiceId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    try {
      final result = await brokerageDatasource.deleteBrokerageInvoice(
        projectId: projectId,
        brokerageInvoiceId: brokerageInvoiceId,
        bookingId: bookingId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await brokerageDatasource.pullPaidBrokerageBooking(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        bookingId: bookingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdatePaidBrokerageBooking({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await brokerageDatasource.addUpdatePaidBrokerageBooking(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> deletePaidBrokerageBooking({
    required int projectId,
    required int paidBrokerageBookingId,
    required int bookingId,
    required int brokerageInvoiceId,
    required String uniqueKey,
  }) async {
    try {
      final result = await brokerageDatasource.deletePaidBrokerageBooking(
        projectId: projectId,
        paidBrokerageBookingId: paidBrokerageBookingId,
        uniqueKey: uniqueKey,
        bookingId: bookingId,
        brokerageInvoiceId: brokerageInvoiceId,
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
      final result = await brokerageDatasource
          .apicallPullBrokerageBookingForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportBrokerageInvoice({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await brokerageDatasource
          .apicallPullBrokerageInvoiceForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            bookingId: bookingId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportPaidBrokerageBooking({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await brokerageDatasource
          .pullPaidBrokerageBookingForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            projectId: projectId,
            bookingId: bookingId,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
