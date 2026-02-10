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
}
