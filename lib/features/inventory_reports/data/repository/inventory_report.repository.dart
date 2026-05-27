import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/inventory_reports/data/datasource/inventory_report.datasource.dart';

abstract interface class InventoryReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> getInventoryReport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getInventoryReportForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getInventoryOverallReport({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class InventoryReportRepositoryImpl implements InventoryReportRepository {
  final InventoryReportDatasource inventoryReportDatasource;

  InventoryReportRepositoryImpl({required this.inventoryReportDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getInventoryReport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryReportDatasource
          .apicallPullProjectInventoryParkingDetails(
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
  Future<Either<Failure, Map<String, dynamic>>> getInventoryReportForExport({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryReportDatasource
          .apicallPullProjectInventoryParkingDetailsForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> getInventoryOverallReport({
    required int pageSize,
    required int pageNumber,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inventoryReportDatasource
          .apicallPullInventoryParkingOverallReport(
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
}
