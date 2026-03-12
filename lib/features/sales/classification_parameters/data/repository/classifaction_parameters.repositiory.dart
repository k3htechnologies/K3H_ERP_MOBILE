import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/sales/classification_parameters/data/datasource/classification_parameters.datasource.dart';

abstract interface class ClassificationParametersRepository {
  Future<Either<Failure, Map<String, dynamic>>>
  getClassificationParametersList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateClassificationParameter({required Map<String, dynamic> body});
  Future<Either<Failure, Map<String, dynamic>>> deleteClassificationParameters({
    required int classificationParameterId,
    required String uniqueKey,
    required int projectId,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportClassificationParameters({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ClassificationParametersRepositoryImpl
    extends ClassificationParametersRepository {
  ClassificationParametersDatasource classificationParametersDatasource;
  ClassificationParametersRepositoryImpl({
    required this.classificationParametersDatasource,
  });

  /// FETCH CLASSIFICATION PARAMETERS LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>>
  getClassificationParametersList({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await classificationParametersDatasource
          .apiCallPullClassificationParameter(
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
  Future<Either<Failure, Map<String, dynamic>>>
  addUpdateClassificationParameter({required Map<String, dynamic> body}) async {
    try {
      var result = await classificationParametersDatasource
          .apicallAddUpdateClassificationParameter(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteClassificationParameters({
    required int classificationParameterId,
    required String uniqueKey,
    required int projectId,
  }) async {
    try {
      var result = await classificationParametersDatasource
          .apicallDeleteClassificationParameter(
            classificationParameterId: classificationParameterId,
            uniqueKey: uniqueKey,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  /// EXPORT CLASSIFICATION PARAMETERS LIST
  @override
  Future<Either<Failure, Map<String, dynamic>>> exportClassificationParameters({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await classificationParametersDatasource
          .apicallPullClassificationParameterForExport(
            pageNumber: pageNumber,
            pageSize: pageSize,
            queryParams: queryParams,
            projectId: projectId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
