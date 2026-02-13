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
}

class EnquiryRepositoryImpl extends EnquiryRepository {
  EnquiryDatasource enquiryDatasource;
  EnquiryRepositoryImpl({required this.enquiryDatasource});

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
}
