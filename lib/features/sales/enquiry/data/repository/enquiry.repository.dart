import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/enquiry/data/datasource/enquiry.datasource.dart';

abstract interface class EnquiryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEnquiryList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateEnquiry({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> getVillageList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportEnquiry({
    required int pageNumber,
    required int projectId,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> getEnquiryFollowUpList({
    required int pageNumber,
    required int pageSize,
    required int enquiryId,
    required int projectId,

    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateEnquiryFollowUp({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteEnquiryFollowUp({
    required int followUpId,
    required String uniqueKey,
    required int enquiryId,
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteEnquiry({
    required String uniqueKey,
    required int enquiryId,
    required int projectId,
  });
}

class EnquiryRepositoryImpl extends EnquiryRepository {
  EnquiryDatasource enquiryDatasource;
  EnquiryRepositoryImpl({required this.enquiryDatasource});

  /// FETCH ENQUIRY LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>> getEnquiryList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await enquiryDatasource.apiCallPullEnquiry(
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

  /// ADD OR UPDATE ENQUIRY
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEnquiry({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await enquiryDatasource.apicallAddUpdateEnquiry(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// FETCH VILLAGE LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>> getVillageList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await enquiryDatasource.apiCallPullVillage(
        pageNumber: pageNumber,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// EXPORT ENQUIRY DATA
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportEnquiry({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await enquiryDatasource.apiCallPullEnquiryForExport(
        pageNumber: pageNumber,
        projectId: projectId,
        pageSize: pageSize,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// FETCH ENQUIRY FOLLOW-UP LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>> getEnquiryFollowUpList({
    required int pageNumber,
    required int pageSize,
    required int enquiryId,
    required int projectId,

    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await enquiryDatasource.apiCallPullEnquiryFollowUp(
        pageNumber: pageNumber,
        pageSize: pageSize,
        enquiryId: enquiryId,
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// ADD OR UPDATE ENQUIRY FOLLOW-UP
  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEnquiryFollowUp({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await enquiryDatasource.apicallAddUpdateEnquiryFollowUp(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// DELETE ENQUIRY FOLLOW-UP
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteEnquiryFollowUp({
    required int followUpId,
    required String uniqueKey,
    required int enquiryId,
    required int projectId,
  }) async {
    try {
      var result = await enquiryDatasource.apicallDeleteEnquiryFollowUp(
        followUpId: followUpId,
        uniqueKey: uniqueKey,
        enquiryId: enquiryId,
        projectId: projectId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// DELETE ENQUIRY
  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteEnquiry({
    required String uniqueKey,
    required int enquiryId,
    required int projectId,
  }) async {
    try {
      var result = await enquiryDatasource.apicallDeleteEnquiry(
        uniqueKey: uniqueKey,
        enquiryId: enquiryId,
        projectId: projectId,
      );

      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
