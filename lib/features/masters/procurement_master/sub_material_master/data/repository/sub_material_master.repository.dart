import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/masters/procurement_master/sub_material_master/data/datasorce/sub_material_maste.datasource.dart';

abstract interface class SubMaterialMasterRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSubMaterialList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateSubMaterial({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> deleteSubMaterial({
    required int subMaterialMasterId,
    required String uniqueKey,
  });
  Future<Either<Failure, Map<String, dynamic>>> exportSubmaterial({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class SubMaterialMasterRepositoryImpl implements SubMaterialMasterRepository {
  final SubMaterialMasterDatasource subMaterialMasterDatasource;
  SubMaterialMasterRepositoryImpl({required this.subMaterialMasterDatasource});
  @override
  Future<Either<Failure, Map<String, dynamic>>> getSubMaterialList({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await subMaterialMasterDatasource
          .apicallPullSubMaterialMaster(
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
  Future<Either<Failure, Map<String, dynamic>>> addUpdateSubMaterial({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await subMaterialMasterDatasource
          .apicallAddUpdateSubMaterialMaster(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteSubMaterial({
    required int subMaterialMasterId,
    required String uniqueKey,
  }) async {
    try {
      var result = await subMaterialMasterDatasource
          .apicallDeleteSubMaterialMaster(
            subMaterialMasterId: subMaterialMasterId,
            uniqueKey: uniqueKey,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportSubmaterial({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await subMaterialMasterDatasource
          .apicallPullSubMaterialMasterForExport(
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
