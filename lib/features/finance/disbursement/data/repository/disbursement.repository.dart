import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/disbursement/data/datasource/disbursement.datasource.dart';

abstract interface class DisbursementRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDisbursedAmountDetails({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteDisbursedAmountDetails({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDisbursedAmountDetailsId,
  });
}

class DisbursementRepositoryImpl extends DisbursementRepository {
  final DisbursementDatasource disbursementDatasource;
  DisbursementRepositoryImpl({required this.disbursementDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDisbursedAmountDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await disbursementDatasource
          .apicallAddUpdateTermSheetDisbursedAmountDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteDisbursedAmountDetails({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDisbursedAmountDetailsId,
  }) async {
    try {
      final result = await disbursementDatasource
          .apiCallDeleteTermSheetDisbursedAmountDetails(
            projectId: projectId,
            termSheetId: termSheetId,
            termSheetDetailsId: termSheetDetailsId,
            termSheetDisbursedAmountDetailsId:
                termSheetDisbursedAmountDetailsId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
