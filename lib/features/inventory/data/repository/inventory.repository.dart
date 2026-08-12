import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/inventory/data/datasource/inventory.datasource.dart';

abstract interface class InventoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getInventory({
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addInventory({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportInventory({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addBuilding({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> addInventoryWing({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> addInventoryFloor({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryFlat({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required int inventoryFlatId,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryFloor({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryWing({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryBuilding({
    required int projectId,
    required int inventoryBuildingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addInventoryFlat({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> updateInventoryFlat({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  updateInventoryFloorParkingCount({required Map<String, dynamic> requestBody});

  // PAGINATED FLATS
  Future<Either<Failure, Map<String, dynamic>>> getPaginatedFlats({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getInventoryDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addFloor({
    required Map<String, dynamic> requestBody,
  });
}

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDatasource inventoryDatasource;

  InventoryRepositoryImpl({required this.inventoryDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInventory({
    required int projectId,
  }) async {
    try {
      var result = await inventoryDatasource.apicallPullInventory(
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addInventory({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallAddInventory(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportInventory({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryDatasource.apicallPullInventoryForExport(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addBuilding({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallAddInventoryBuilding(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addInventoryWing({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToAddInventoryWing(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addInventoryFloor({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToAddInventoryFloor(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryBuilding({
    required int projectId,
    required int inventoryBuildingId,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToDeleteInventoryBuilding(
        projectId: projectId,
        inventoryBuildingId: inventoryBuildingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryWing({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToDeleteInventoryWing(
        projectId: projectId,
        inventoryBuildingId: inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            inventoryFlatFloorBasementPodiumWingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryFloor({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToDeleteInventoryFloor(
        projectId: projectId,
        inventoryBuildingId: inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            inventoryFlatFloorBasementPodiumWingId,
        inventoryFloorId: inventoryFloorId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInventoryFlat({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required int inventoryFlatId,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToDeleteInventoryFlat(
        projectId: projectId,
        inventoryBuildingId: inventoryBuildingId,
        inventoryFlatFloorBasementPodiumWingId:
            inventoryFlatFloorBasementPodiumWingId,
        inventoryFloorId: inventoryFloorId,
        inventoryFlatId: inventoryFlatId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addInventoryFlat({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToAddInventoryFlat(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateInventoryFlat({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToUpdateInventoryFlat(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  updateInventoryFloorParkingCount({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource
          .apicallToUpdateInventoryFloorParkingCount(body: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPaginatedFlats({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await inventoryDatasource.apicallPullPaginatedFlats(
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

  // GET PROJECT INVENTORY
  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectInventoryStructure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryDatasource
          .apicallPullProjectInventoryStructure(
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
  Future<Either<Failure, Map<String, dynamic>>> getInventoryDashboard({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryDatasource.apicallPullInventoryDashboard(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addFloor({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await inventoryDatasource.apicallToAddFloor(
        body: requestBody,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
