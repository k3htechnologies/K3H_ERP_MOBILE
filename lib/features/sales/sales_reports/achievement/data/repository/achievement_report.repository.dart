import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/sales_reports/achievement/data/model/achivement_drill_down_report.model.dart';

import '../datasource/achievement_report.datasource.dart';

abstract interface class AchievementReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProjectAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getClosingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getSourcingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  getClosingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  getSourcingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>>
  getAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required int projectId,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  });
}

class AchievementReportRepositoryImpl extends AchievementReportRepository {
  final AchievementReportDatasource achievementReportDatasource;
  AchievementReportRepositoryImpl({required this.achievementReportDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullProjectAchievementReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getClosingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullClosingAchievementReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSourcingAchievementReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullSourcingAchievementReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getProjectAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullProjectAchievementReportForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getClosingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullClosingAchievementReportForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getSourcingAchievementReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullSourcingAchievementReportForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAchievementDrillDownReport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required String tabName,
    required String columnName,
    required AchievementDrillDownType achivementDrillDownType,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullAchievementDrillDownReport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            tabName: tabName,
            columnName: columnName,
            achivementDrillDownType: achivementDrillDownType,
            queryParams: queryParams,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getAchievementDrillDownReportForExport({
    required int pageNumber,
    required int pageSize,
    required String filterType,
    required int projectId,
    required String tabName,
    required String columnName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await achievementReportDatasource
          .apiCallPullAchievementDrillDownReportForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            filterType: filterType,
            projectId: projectId,
            tabName: tabName,
            columnName: columnName,
            queryParams: queryParams,
          );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
