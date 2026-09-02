import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/visitor_management/gate_pass/data/datasource/gate_pass.datasource.dart';

abstract interface class GatePassRepository {
  Future<Either<Failure, Map<String, dynamic>>> getGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateGatePass({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateGatePassOut({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteGatePass({
    required int externalId,
    required String uniquekey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class GatePassRepositoryImpl extends GatePassRepository {
  final GatePassDatasource gatePassDatasource;
  GatePassRepositoryImpl({required this.gatePassDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await gatePassDatasource.apiCallPullGatePass(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateGatePass({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await gatePassDatasource.apiCallAddUpdateGatePass(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateGatePassOut({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await gatePassDatasource.apicallUpdateGatePassOut(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteGatePass({
    required int externalId,
    required String uniquekey,
  }) async {
    try {
      final result = await gatePassDatasource.apiCallDeleteGatePass(
        externalId: externalId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportGatePass({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await gatePassDatasource.apiCallPullGatePassForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
