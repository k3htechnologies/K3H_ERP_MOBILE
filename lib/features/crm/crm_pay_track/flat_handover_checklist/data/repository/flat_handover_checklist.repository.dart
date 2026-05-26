import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/flat_handover_checklist/data/datasource/flat_handover_checklist.datasource.dart';

abstract interface class FlatHandoverChecklistRepository {
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  });
}

class FlatHandoverChecklistRepositoryImpl
    extends FlatHandoverChecklistRepository {
  final FlatHandoverChecklistDatasource flatHandoverChecklistDatasource;

  FlatHandoverChecklistRepositoryImpl({
    required this.flatHandoverChecklistDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBookingLoanDetailsList({
    required int projectId,
    required int bookingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await flatHandoverChecklistDatasource
          .apicallPullFlatHandOverCheckList(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBookingLoanDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await flatHandoverChecklistDatasource
          .apicallAddUpdateFlatHandOverCheckList(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
