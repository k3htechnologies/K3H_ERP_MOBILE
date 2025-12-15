import 'package:k3h_erp_app/features/inventory/data/model/building.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class InventoryDatasource {
  Future<Map<String, dynamic>> apicallPullInventory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddInventory({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullInventoryForExport({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddInventoryBuilding({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallToAddInventoryWing({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallToAddInventoryFloor({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallToDeleteInventoryFlat({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required int inventoryFlatId,
  });

  Future<Map<String, dynamic>> apicallToDeleteInventoryFloor({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
  });

  Future<Map<String, dynamic>> apicallToDeleteInventoryWing({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
  });

  Future<Map<String, dynamic>> apicallToDeleteInventoryBuilding({
    required int projectId,
    required int inventoryBuildingId,
  });

  Future<Map<String, dynamic>> apicallToAddInventoryFlat({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallToUpdateInventoryFlat({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallToUpdateInventoryFloorParkingCount({
    required Map<String, dynamic> body,
  });

  // PAGINATED FLATS
  Future<Map<String, dynamic>> apicallPullPaginatedFlats({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class InventoryDatasourceImpl implements InventoryDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullInventory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullInventoryUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Inventory/PullInventory?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInventoryUrl(projectId: projectId, queryParams: queryParams),
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullInventory(projectId: projectId, queryParams: queryParams);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddInventory({
    required Map<String, dynamic> body,
  }) async {
    String addInventoryUrl = "Inventory/AddInventory";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addInventoryUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddInventory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullInventoryForExport({
    required int projectId,
    required Map<String, dynamic>? queryParams,
  }) async {
    String pullInventoryForExportUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url = "Inventory/PullInventory?ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullInventoryForExportUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullInventoryForExport(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddInventoryBuilding({
    required Map<String, dynamic> body,
  }) async {
    String addInventoryBuildingUrl = "Inventory/AddInventoryBuilding";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addInventoryBuildingUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddInventoryBuilding(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToAddInventoryWing({
    required Map<String, dynamic> body,
  }) async {
    String addInventoryWingUrl = "Inventory/AddInventoryWing";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addInventoryWingUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToAddInventoryWing(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToAddInventoryFloor({
    required Map<String, dynamic> body,
  }) async {
    String addInventoryFloorUrl = "Inventory/AddInventoryFloor";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addInventoryFloorUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToAddInventoryFloor(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToDeleteInventoryBuilding({
    required int projectId,
    required int inventoryBuildingId,
  }) async {
    String deleteInventoryBuildingUrl({
      required int projectId,
      required int inventoryBuildingId,
    }) {
      return "Inventory/DeleteInventoryBuilding?ProjectId=$projectId&InventoryBuildingId=$inventoryBuildingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteInventoryBuildingUrl(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
        ),
      );
      return {'totalNumberOfRecord': networkResponse['totalNumberOfRecord']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToDeleteInventoryBuilding(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToDeleteInventoryFlat({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
    required int inventoryFlatId,
  }) async {
    String deleteInventoryFlatUrl({
      required int projectId,
      required int inventoryBuildingId,
      required int inventoryFlatFloorBasementPodiumWingId,
      required int inventoryFloorId,
      required int inventoryFlatId,
    }) {
      return "Inventory/DeleteInventoryFlat?ProjectId=$projectId&InventoryBuildingId=$inventoryBuildingId&InventoryFlatFloorBasementPodiumWingId=$inventoryFlatFloorBasementPodiumWingId&InventoryFloorId=$inventoryFloorId&InventoryFlatId=$inventoryFlatId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteInventoryFlatUrl(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
          inventoryFloorId: inventoryFloorId,
          inventoryFlatId: inventoryFlatId,
        ),
      );
      return {'totalNumberOfRecord': networkResponse['totalNumberOfRecord']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToDeleteInventoryFlat(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
          inventoryFloorId: inventoryFloorId,
          inventoryFlatId: inventoryFlatId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToDeleteInventoryFloor({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
    required int inventoryFloorId,
  }) async {
    String deleteInventoryFloorUrl({
      required int projectId,
      required int inventoryBuildingId,
      required int inventoryFlatFloorBasementPodiumWingId,
      required int inventoryFloorId,
    }) {
      return "Inventory/DeleteInventoryFloor?ProjectId=$projectId&InventoryBuildingId=$inventoryBuildingId&InventoryFlatFloorBasementPodiumWingId=$inventoryFlatFloorBasementPodiumWingId&InventoryFloorId=$inventoryFloorId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteInventoryFloorUrl(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
          inventoryFloorId: inventoryFloorId,
        ),
      );
      return {'totalNumberOfRecord': networkResponse['totalNumberOfRecord']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToDeleteInventoryFloor(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
          inventoryFloorId: inventoryFloorId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToDeleteInventoryWing({
    required int projectId,
    required int inventoryBuildingId,
    required int inventoryFlatFloorBasementPodiumWingId,
  }) async {
    String deleteInventoryWingUrl({
      required int projectId,
      required int inventoryBuildingId,
      required int inventoryFlatFloorBasementPodiumWingId,
    }) {
      return "Inventory/DeleteInventoryWing?ProjectId=$projectId&InventoryBuildingId=$inventoryBuildingId&InventoryFlatFloorBasementPodiumWingId=$inventoryFlatFloorBasementPodiumWingId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteInventoryWingUrl(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
        ),
      );
      return {'totalNumberOfRecord': networkResponse['totalNumberOfRecord']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToDeleteInventoryWing(
          projectId: projectId,
          inventoryBuildingId: inventoryBuildingId,
          inventoryFlatFloorBasementPodiumWingId:
              inventoryFlatFloorBasementPodiumWingId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToAddInventoryFlat({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateInventoryFlatUrl = "Inventory/AddInventoryFlat";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateInventoryFlatUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToAddInventoryFlat(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToUpdateInventoryFlat({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateInventoryFlatUrl = "Inventory/AddInventoryFlat";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateInventoryFlatUrl,
        body,
      );
      return {
        'data': List<BuildingModel>.from(
          networkResponse["data"].map((e) => BuildingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToUpdateInventoryFlat(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallToUpdateInventoryFloorParkingCount({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateInventoryFloorParkingCountUrl =
        "Inventory/AddUpdateInventoryFloorParkingCount";
    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateInventoryFloorParkingCountUrl,
        body,
      );
      return {'totalNumberOfRecord': networkResponse['totalNumberOfRecord']};
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallToUpdateInventoryFloorParkingCount(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullPaginatedFlats({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullPaginatedFlatsUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      String? buildingNumber,
      String? wing,
      String? floor,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Inventory/PullPaginatedFlats?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";

      if (buildingNumber != null && buildingNumber.isNotEmpty) {
        url += "&BuildingNumber=$buildingNumber";
      }
      if (wing != null && wing.isNotEmpty) {
        url += "&Wing=$wing";
      }
      if (floor != null && floor.isNotEmpty) {
        url += "&Floor=$floor";
      }

      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      final networkResponse = await baseClient.getRequestWithAuthentication(
        pullPaginatedFlatsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullPaginatedFlats(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
