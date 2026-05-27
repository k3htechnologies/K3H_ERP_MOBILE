import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';

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
}
