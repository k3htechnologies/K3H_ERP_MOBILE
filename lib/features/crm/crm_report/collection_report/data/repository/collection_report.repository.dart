import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/crm/crm_report/collection_report/data/datasource/collection_report.datasource.dart';

abstract interface class CollectionReportRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectWiseCollectionReportList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  exportProjectWiseCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getProjectCollectionReportList({
    required int projectId,
    required String projectName,
    Map<String, dynamic>? queryParams,
  });
}

class CollectionReportRepositoryImpl extends CollectionReportRepository {
  final CollectionReportDatasource collectionReportDatasource;

  CollectionReportRepositoryImpl({required this.collectionReportDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectWiseCollectionReportList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await collectionReportDatasource
          .apiCallPullProjectWiseCollectionReport(
            queryParams: queryParams,
            pageNumber: pageNumber,
            pageSize: pageSize,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  exportProjectWiseCollectionReportList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await collectionReportDatasource
          .apiCallPullProjectWiseCollectionReportForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> getProjectCollectionReportList({
    required int projectId,
    required String projectName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await collectionReportDatasource.apiCallPullCollectionReport(
        queryParams: queryParams,
        projectId: projectId,
        projectName: projectName,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
