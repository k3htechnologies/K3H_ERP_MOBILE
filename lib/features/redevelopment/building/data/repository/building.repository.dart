import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/building/data/datasource/building.datasource.dart';

abstract interface class BuildingRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullBuilding({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullBuildingDetails({
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullBuildingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuilding({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingDetails({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullBuildingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteBuilding({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
  });
}

class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingDatasource buildingDatasource;

  BuildingRepositoryImpl({required this.buildingDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBuilding({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await buildingDatasource.apicallPullBuilding(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBuildingDetails({
    required int buildingId,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await buildingDatasource.apicallPullBuildingDetails(
        buildingId: buildingId,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBuildingDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int buildingId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await buildingDatasource.apicallPullBuildingDocument(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        buildingId: buildingId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await buildingDatasource
          .apicallAddUpdateBuildingDocument(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuilding({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await buildingDatasource.apicallAddUpdateBuilding(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingDetails({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await buildingDatasource.apicallAddUpdateBuildingDetails(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullBuildingForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await buildingDatasource.apicallPullBuildingForExport(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteBuilding({
    required int buildingId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await buildingDatasource.apicallDeleteBuilding(
        buildingId: buildingId,
        uniqueKey: uniqueKey,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
