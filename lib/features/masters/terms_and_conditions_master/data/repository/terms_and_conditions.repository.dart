import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/datasource/terms_and_conditions.datasource.dart';

abstract interface class TermsAndConditionsMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getTermsAndConditionsList({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermsAndConditions({
    required Map<String, dynamic> body,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteTermsAndConditions({
    required int termsAndConditionsMasterId,
    required String uniquekey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportTermsAndConditions({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  });
}

class TermsAndConditionsMasterRepositoryImpl
    extends TermsAndConditionsMasterRepository {
  final TermsAndConditionsDatasource termsAndConditionsDatasource;

  TermsAndConditionsMasterRepositoryImpl({
    required this.termsAndConditionsDatasource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTermsAndConditionsList({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termsAndConditionsDatasource
          .apicallPullTermsAndConditionsMaster(
            pageNumber: pageNumber,
            pageSize: pageSize,
            moduleName: moduleName,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateTermsAndConditions({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await termsAndConditionsDatasource
          .apicallAddUpdateTermsAndConditionMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteTermsAndConditions({
    required int termsAndConditionsMasterId,
    required String uniquekey,
  }) async {
    try {
      var result = await termsAndConditionsDatasource
          .apicallDeleteTermsAndConditionsMaster(
            termsAndConditionsMasterId: termsAndConditionsMasterId,
            uniquekey: uniquekey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportTermsAndConditions({
    required int pageNumber,
    required int pageSize,
    required String moduleName,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await termsAndConditionsDatasource
          .apicallPullTermsAndConditionsMasterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            moduleName: moduleName,
            queryParams: queryParams,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
