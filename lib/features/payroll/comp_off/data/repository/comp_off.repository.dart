import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/datasource/comp_off.datasource.dart';

abstract interface class CompOffRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCompOffList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CompOffRepositoryImpl implements CompOffRepository {
  final CompOffDatasource compOffDatasource;

  CompOffRepositoryImpl({required this.compOffDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCompOffList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await compOffDatasource.apicallPullCompOff(
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
