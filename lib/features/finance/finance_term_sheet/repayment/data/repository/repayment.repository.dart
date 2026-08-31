import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/finance_term_sheet/repayment/data/datasource/repayment.datasource.dart';

abstract interface class RepaymentRepository {
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheetRepayLedger({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTermSheetDirectSellingAgent({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetRepayLedgerId,
  });
}

class RepaymentRepositoryImpl extends RepaymentRepository {
  final RepaymentDatasource repaymentDatasource;
  RepaymentRepositoryImpl({required this.repaymentDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermSheetRepayLedger({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await repaymentDatasource
          .apicallAddUpdateTermSheetRepayLedger(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTermSheetDirectSellingAgent({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetRepayLedgerId,
  }) async {
    try {
      final result = await repaymentDatasource
          .apiCallDeleteTermSheetDirectSellingAgent(
            projectId: projectId,
            termSheetId: termSheetId,
            termSheetDetailsId: termSheetDetailsId,
            termSheetRepayLedgerId: termSheetRepayLedgerId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
