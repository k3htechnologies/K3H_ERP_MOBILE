import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/datasource/employee_master.datasource.dart';

abstract interface class EmployeeMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeMasterList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getEmployeeDocumentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getEmployeeAssetList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getEmployeeShiftManagementList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getEmployeeWeekOffMappingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateEmployeeMaster({
    required Map<String, dynamic> requestBody,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateEmployeeDocument({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> getBankList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> getBranchList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> exportEmployee({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class EmployeeMasterRepositoryImp implements EmployeeMasterRepository {
  final EmployeeMasterDataSource employeeMasterDataSource;
  EmployeeMasterRepositoryImp(this.employeeMasterDataSource);
  @override
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeMasterList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource.apiCallToPullEmployeeMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeDocumentList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource.apiCallToPullEmployeeDocument(
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
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeAssetList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource.apiCallToPullEmployeeAsset(
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
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeShiftManagementList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource
          .apiCallToPullEmployeeShiftManagementMapping(
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
  Future<Either<Failure, Map<String, dynamic>>> getEmployeeWeekOffMappingList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource
          .apiCallToPullEmployeeWeekOffMapping(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEmployeeMaster({
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      var result = await employeeMasterDataSource
          .apiCallToAddUpdateEmployeeMaster(requestBody: requestBody);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateEmployeeDocument({
    required Map<String, String> requestBody,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await employeeMasterDataSource
          .apiCallToAddUpdateEmployeeDocument(
            requestBody: requestBody,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBankList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    try {
      var result = await employeeMasterDataSource.apicallPullBankListMaster(
        pageNumber: pageNumber,
        pageSize: pageSize,
        query: query,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBranchList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    try {
      var result = await employeeMasterDataSource.apicallPullBranchMaster(
        pageNumber: pageNumber,
        pageSize: pageSize,
        query: query,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportEmployee({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await employeeMasterDataSource
          .apicallPullEmployeeMasterForExport(
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
