import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/more/inward_outward/data/datasource/inward_outward.datasource.dart';

abstract interface class InwardOutwardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getInwardOutwardList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateInwardOutward({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateInwardOutwardRevert({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteInwardOutwardRevert({
    required int inwardOutwardId,
    required String uniqueKey,
    required int inwardOutwardRevertId,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteInwardOutward({
    required int inwardOutwardId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> getSenderReceiverByMobileNo({
    required String mobileNumber,
  });
  Future<Either<Failure, Map<String, dynamic>>> getInwardOutwardListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class InwardOutwardRepositoryImpl implements InwardOutwardRepository {
  final InwardOutwardDatasource inwardOutwardDatasource;
  InwardOutwardRepositoryImpl({required this.inwardOutwardDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getInwardOutwardList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inwardOutwardDatasource.apicallPullInwardOutwardMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateInwardOutward({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await inwardOutwardDatasource
          .apicallAddUpdateInwardOutwardMaster(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateInwardOutwardRevert({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await inwardOutwardDatasource
          .apicallAddUpdateInwardOutwardRevert(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInwardOutwardRevert({
    required int inwardOutwardId,
    required String uniqueKey,
    required int inwardOutwardRevertId,
  }) async {
    try {
      var result = await inwardOutwardDatasource
          .apicallDeleteRevertInwardOutward(
            inwardOutwardId: inwardOutwardId,
            uniqueKey: uniqueKey,
            inwardOutwardRevertId: inwardOutwardRevertId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteInwardOutward({
    required int inwardOutwardId,
    required String uniqueKey,
  }) async {
    try {
      var result = await inwardOutwardDatasource.apicallDeleteInwardOutward(
        inwardOutwardId: inwardOutwardId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSenderReceiverByMobileNo({
    required String mobileNumber,
  }) async {
    try {
      var result = await inwardOutwardDatasource
          .apicallPullSenderReceiverByMobileNo(mobileNumber: mobileNumber);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getInwardOutwardListForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await inwardOutwardDatasource
          .apicallPullInwardOutwardMasterForExport(
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
