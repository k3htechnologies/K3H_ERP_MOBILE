import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/legal/litigation/data/datasource/litigation.datasource.dart';

abstract interface class LitigationRepository {
  Future<Either<Failure, Map<String, dynamic>>> pullLitigation({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigation({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteLitigation({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullLitigationHearing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationHearing({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteLitigationHearing({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationHearingId,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullLitigationClosure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationClosure({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> updateLitigationReopen({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getLitigationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> pullLitigationDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteLitigationDocument({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationDocumentId,
  });
}

class LitigationRepositoryImpl extends LitigationRepository {
  final LitigationDatasource litigationDatasource;

  LitigationRepositoryImpl({required this.litigationDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullLitigation({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await litigationDatasource.apicallPullLitigation(
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

  // ADD / UPDATE LITIGATION
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigation({
    required Map<String, dynamic> body,
  }) async {
    try {
      final result = await litigationDatasource.apiCallAddUpdateLitigation(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLitigation({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await litigationDatasource.apicallDeleteLitigation(
        litigationId: litigationId,
        uniqueKey: uniqueKey,
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ✅ PULL LITIGATION HEARING
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullLitigationHearing({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await litigationDatasource.apicallPullLitigationHearing(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        litigationId: litigationId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ADD / UPDATE LITIGATION HEARING
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationHearing({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await litigationDatasource
          .apiCallAddUpdateLitigationHearing(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLitigationHearing({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationHearingId,
  }) async {
    try {
      var result = await litigationDatasource.apicallDeleteLitigationHearing(
        litigationId: litigationId,
        uniqueKey: uniqueKey,
        projectId: projectId,
        litigationHearingId: litigationHearingId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ✅ PULL LITIGATION CLOSURE
  @override
  Future<Either<Failure, Map<String, dynamic>>> pullLitigationClosure({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await litigationDatasource.apicallPullLitigationClosure(
        pageNumber: pageNumber,
        pageSize: pageSize,
        litigationId: litigationId,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  // ADD / UPDATE LITIGATION HEARING
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationClosure({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await litigationDatasource
          .apiCallAddUpdateLitigationClosure(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> pullLitigationDocument({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    required int litigationId,

    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await litigationDatasource.apicallPullDocument(
        pageNumber: pageNumber,
        pageSize: pageSize,
        projectId: projectId,
        litigationId: litigationId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLitigationForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await litigationDatasource.apiCallPullLitigationForExport(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateLitigationDocument({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      final result = await litigationDatasource
          .apiCallAddUpdateLitigationDocument(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteLitigationDocument({
    required int litigationId,
    required String uniqueKey,
    required int projectId,
    required int litigationDocumentId,
  }) async {
    try {
      var result = await litigationDatasource.apicallDeleteLitigationHearing(
        litigationId: litigationId,
        uniqueKey: uniqueKey,
        projectId: projectId,
        litigationHearingId: litigationDocumentId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateLitigationReopen({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await litigationDatasource.apicallUpdateLitigationReopen(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
