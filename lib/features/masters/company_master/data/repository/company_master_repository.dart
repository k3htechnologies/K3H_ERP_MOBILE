import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/datasource/company_master_datasource.dart';

abstract interface class CompanyMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCompanyList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateCompanyList({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
    required int pageNumber,
    required int pageSize,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteCompany({
    required int companyId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportCompany({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class CompanyMasterRepositoryImp implements CompanyMasterRepository {
  final CompanyMasterDatasource companyMasterDatasource;
  CompanyMasterRepositoryImp({required this.companyMasterDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getCompanyList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await companyMasterDatasource.apicallPullCompanyMaster(
        pageNumber: pageNumber,
        pageSize: pageSize,
        query: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateCompanyList({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      var result = await companyMasterDatasource.apicallAddUpdateCompany(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteCompany({
    required int companyId,
    required String uniqueKey,
  }) async {
    try {
      var result = await companyMasterDatasource.apicallDeleteCompany(
        companyId: companyId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportCompany({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await companyMasterDatasource
          .apicallPullCompanyMasterForExport(
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
