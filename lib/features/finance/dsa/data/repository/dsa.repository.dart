import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/finance/dsa/data/datasource/dsa.datasource.dart';

abstract interface class DSARepository {
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDirectSellingAgent({required Map<String, dynamic> body});
  Future<Either<Failure, Map<String, dynamic>>>
  deleteTermSheetDirectSellingAgent({
    required int projectId,
    required int termSheetId,
    required int termSheetDetailsId,
    required int termSheetDirectSellingAgentId,
  });
}

class DSARepositoryImpl extends DSARepository {
  final DSADatasource dsaDatasource;
  DSARepositoryImpl({required this.dsaDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateTermSheetDirectSellingAgent({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await dsaDatasource
          .apicallAddUpdateTermSheetDirectSellingAgent(body: body);
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
    required int termSheetDirectSellingAgentId,
  }) async {
    try {
      final result = await dsaDatasource
          .apiCallDeleteTermSheetDirectSellingAgent(
            projectId: projectId,
            termSheetId: termSheetId,
            termSheetDetailsId: termSheetDetailsId,
            termSheetDirectSellingAgentId: termSheetDirectSellingAgentId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
