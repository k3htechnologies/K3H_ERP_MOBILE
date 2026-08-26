import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/dsra/data/datasource/dsra.datasource.dart';

abstract interface class DsraRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDebtServiceReserveAccount({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTermSheetDebtServiceReserveAccount({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDebtServiceReserveAccountId,
  });
}

class DsraRepositoryImpl extends DsraRepository {
  final DsraDatasource dsraDatasource;

  DsraRepositoryImpl({required this.dsraDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDebtServiceReserveAccount({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await dsraDatasource
          .apicallAddUpdateTermSheetDebtServiceReserveAccount(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTermSheetDebtServiceReserveAccount({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDebtServiceReserveAccountId,
  }) async {
    try {
      final result = await dsraDatasource
          .apiCallDeleteTermSheetDebtServiceReserveAccount(
            projectId: projectId,
            termSheetId: termSheetId,
            termSheetDetailsId: termSheetDetailsId,
            termSheetDebtServiceReserveAccountId:
                termSheetDebtServiceReserveAccountId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
