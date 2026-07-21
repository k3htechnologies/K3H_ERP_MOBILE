import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/request_management/data/datasource/request_management.datasource.dart';

abstract interface class RequestManagementRepository {
  Future<Either<Failure, Map<String, dynamic>>> getFlatAlterationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getParkingModificationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getBookingApplicantModificationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  deleteBookingApplicantModificationRequest({
    required int projectId,
    required int bookingApplicantModificationRequestId,
    required int bookingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addFlatAlterationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteFlatAlterationRequest({
    required int flatAlterationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateParkingModificationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  deleteParkingModificationRequest({
    required int parkingModificationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  updateBookingApplicantModificationRequest({
    required int bookingId,
    required int projectId,
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addAmountRefundedAgainstBookingAddUpdateRefundedAmount({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getRefundedAmountLedgerList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteRefundedAmountLedger({
    required int projectId,
    required int refundedAmountLedgerId,
    required int bookingId,
    required String uniqueKey,
  });
}

class RequestManagementRepositoryImpl extends RequestManagementRepository {
  final RequestManagementDatasource flatAlterationRequestDatasource;

  RequestManagementRepositoryImpl({
    required this.flatAlterationRequestDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFlatAlterationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallPullFlatAlterationRequest(
            pageSize: pageSize,
            pageNumber: pageNumber,
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
  Future<Either<Failure, Map<String, dynamic>>>
  getParkingModificationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallPullParkingModificationRequest(
            pageSize: pageSize,
            pageNumber: pageNumber,
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
  Future<Either<Failure, Map<String, dynamic>>>
  getBookingApplicantModificationRequestList({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallPullBookingApplicantModificationRequest(
            pageSize: pageSize,
            pageNumber: pageNumber,
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
  Future<Either<Failure, Map<String, dynamic>>> addFlatAlterationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallAddFlatAlterationRequest(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateParkingModificationRequest({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallAddParkingModificationRequest(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  updateBookingApplicantModificationRequest({
    required int bookingId,
    required int projectId,
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallUpdateBookingApplicantModificationRequest(
            bookingId: bookingId,
            projectId: projectId,
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addAmountRefundedAgainstBookingAddUpdateRefundedAmount({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallAmountRefundedAgainstBookingAddUpdateRefundedAmount(
            body: body,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRefundedAmountLedgerList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallPullRefundedAmountLedger(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateRefundedAmountLedger({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallAddUpdateRefundedAmountLedger(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRefundedAmountLedger({
    required int projectId,
    required int refundedAmountLedgerId,
    required int bookingId,
    required String uniqueKey,
  }) async {
    try {
      final result = await flatAlterationRequestDatasource
          .deleteRefundedAmountLedger(
            projectId: projectId,
            refundedAmountLedgerId: refundedAmountLedgerId,
            bookingId: bookingId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deleteBookingApplicantModificationRequest({
    required int projectId,
    required int bookingApplicantModificationRequestId,
    required int bookingId,
  }) async {
    try {
      final result = await flatAlterationRequestDatasource
          .deleteBookingApplicantModificationRequest(
            projectId: projectId,
            bookingApplicantModificationRequestId:
                bookingApplicantModificationRequestId,
            bookingId: bookingId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteFlatAlterationRequest({
    required int flatAlterationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallDeleteFlatAlterationRequest(
            flatAlterationRequestId: flatAlterationRequestId,
            uniqueKey: uniqueKey,
            bookingId: bookingId,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deleteParkingModificationRequest({
    required int parkingModificationRequestId,
    required String uniqueKey,
    required int bookingId,
    required int projectId,
  }) async {
    try {
      var result = await flatAlterationRequestDatasource
          .apicallDeletParkingModificationRequest(
            parkingModificationRequestId: parkingModificationRequestId,
            uniqueKey: uniqueKey,
            bookingId: bookingId,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
