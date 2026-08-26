import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/sweep_ratio/data/datasource/sweep_ratio.datasource.dart';

abstract interface class SweepRatioRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetSweepRatioDetails({required Map<String, dynamic> body});
  Future<Either<Failure, Map<String, dynamic>>> deleteSweepRatioDetails({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetSweepRatioDetailsId,
  });
}

class SweepRatioRepositoryImpl extends SweepRatioRepository {
  final SweepRatioDatasource sweepRatioDatasource;
  SweepRatioRepositoryImpl({required this.sweepRatioDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetSweepRatioDetails({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await sweepRatioDatasource
          .apicallAddUpdateTermSheetSweepRatioDetails(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteSweepRatioDetails({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetSweepRatioDetailsId,
  }) async {
    try {
      final result = await sweepRatioDatasource
          .apiCallDeleteTermSheetSweepRatioDetails(
            projectId: projectId,
            termSheetId: termSheetId,
            termSheetDetailsId: termSheetDetailsId,
            termSheetSweepRatioDetailsId: termSheetSweepRatioDetailsId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
