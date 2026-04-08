import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/datasource/invoice.datasource.dart';

abstract interface class InvoiceRepository {
  Future<Either<Failure, Map<String, dynamic>>> getRequisitionInvoice({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateRequisitionInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> deleteRequisitionInvoice({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required String uniqueKey,
    required int materialRequisitionId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateRequisitionPayment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Either<Failure, Map<String, dynamic>>> getRequisitionPayment({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getFinalisedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });
}

class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceDatasource invoiceDatasource;

  InvoiceRepositoryImpl({required this.invoiceDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRequisitionInvoice({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      var result = await invoiceDatasource.apicallGetMaterialRequisitionInvoice(
        projectId: projectId,
        materialRequisitionId: materialRequisitionId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateRequisitionInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await invoiceDatasource
          .apicallAddUpdateMaterialRequisitionInvoice(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> deleteRequisitionInvoice({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    try {
      var result = await invoiceDatasource
          .apicallDeleteMaterialRequisitionInvoice(
            projectId: projectId,
            materialRequisitionInvoiceId: materialRequisitionInvoiceId,
            uniqueKey: uniqueKey,
            materialRequisitionId: materialRequisitionId,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateRequisitionPayment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await invoiceDatasource
          .apicallAddUpdateMaterialRequisitionPayment(
            body: body,
            fileList: fileList,
          );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRequisitionPayment({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
  }) async {
    try {
      var result = await invoiceDatasource.apicallGetMaterialRequisitionPayment(
        projectId: projectId,
        materialRequisitionInvoiceId: materialRequisitionInvoiceId,
        materialRequisitionId: materialRequisitionId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinalisedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      var result = await invoiceDatasource.apicallPullFinalizedVendor(
        projectId: projectId,
        materialRequisitionId: materialRequisitionId,
        uniqueKey: uniqueKey,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
