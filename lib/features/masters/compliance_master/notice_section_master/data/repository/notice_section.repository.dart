import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/compliance_master/notice_section_master/data/datasource/notice_section.datasource.dart';

abstract interface class NoticeSectionMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullNoticeSection({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateNoticeSection({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteNoticeSection({
    required int noticeSectionMasterId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> pullNoticeSectionForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class NoticeSectionMasterRepositoryImpl
    implements NoticeSectionMasterRepository {
  final NoticeSectionMasterDatasource noticeSectionDatasource;

  NoticeSectionMasterRepositoryImpl({required this.noticeSectionDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullNoticeSection({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await noticeSectionDatasource.apiCallPullNoticeSection(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateNoticeSection({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await noticeSectionDatasource.apiCallAddUpdateNoticeSection(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteNoticeSection({
    required int noticeSectionMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await noticeSectionDatasource.apicallDeleteNoticeSection(
        noticeSectionMasterId: noticeSectionMasterId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullNoticeSectionForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await noticeSectionDatasource
          .apiCallPullNoticeSectionForExport(
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
