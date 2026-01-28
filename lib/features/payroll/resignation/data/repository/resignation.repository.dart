import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/datasource/resignation.datasource.dart';

abstract interface class ResignationRepository {
  Future<Either<Failure, Map<String, dynamic>>> getResignationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateResignation({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportResignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteResignation({
    required int resignationId,
    required String uniqueKey,
  });
}

class ResignationRepositoryImpl implements ResignationRepository {
  final ResignationDatasource resignationDatasource;

  ResignationRepositoryImpl({required this.resignationDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getResignationList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await resignationDatasource.apicallPullResignation(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateResignation({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await resignationDatasource.apicallAddUpdateResignation(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportResignation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await resignationDatasource.apicallPullResignationForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteResignation({
    required int resignationId,
    required String uniqueKey,
  }) async {
    try {
      var result = await resignationDatasource.apicallDeleteResignation(
        resignationId: resignationId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
