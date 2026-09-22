import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/rebuild/project_lead/data/datasource/project_lead.datasource.dart';

abstract interface class ProjectLeadRepository {
  Future<Either<Failure, Map<String, dynamic>>> getRedevelopmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateProjectLeadRedevelopment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteRedevelopment({
    required int projectRedevelopmentId,
    required String uniquekey,
  });
  Future<Either<Failure, Map<String, dynamic>>> getLandList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectLand({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteLand({
    required int projectLandId,
    required String uniquekey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportRedevlopment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportLand({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class ProjectLeadRepositoryImpl extends ProjectLeadRepository {
  final ProjectLeadDatasource projectLeadDatasource;
  ProjectLeadRepositoryImpl({required this.projectLeadDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRedevelopmentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectLeadDatasource.apicallPullProjectRedevelopment(
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
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateProjectLeadRedevelopment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await projectLeadDatasource
          .apicallAddUpdateProjectRedevelopment(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLandList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectLeadDatasource.apicallPullProjectLand(
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
  Future<Either<Failure, Map<String, dynamic>>> exportRedevlopment({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectLeadDatasource
          .apiCallPullProjectRedevelopmentForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> exportLand({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await projectLeadDatasource
          .apiCallPullProjectRedevelopmentForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProjectLand({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await projectLeadDatasource.apicallAddUpdateProjectLand(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRedevelopment({
    required int projectRedevelopmentId,
    required String uniquekey,
  }) async {
    try {
      final result = await projectLeadDatasource.apiCallDeleteRedevlopment(
        projectRedevelopmentId: projectRedevelopmentId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLand({
    required int projectLandId,
    required String uniquekey,
  }) async {
    try {
      final result = await projectLeadDatasource.apiCallDeleteLand(
        projectLandId: projectLandId,
        uniquekey: uniquekey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
