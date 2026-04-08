import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/invoice/data/model/invoice_payment.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class InvoiceDatasource {
  Future<Map<String, dynamic>> apicallGetMaterialRequisitionInvoice({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisitionInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteMaterialRequisitionInvoice({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required String uniqueKey,
    required int materialRequisitionId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisitionPayment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallGetMaterialRequisitionPayment({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
  });

  Future<Map<String, dynamic>> apicallPullFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  });
}

class InvoiceDatasourceImpl implements InvoiceDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallGetMaterialRequisitionInvoice({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      String pullGetMaterialRequisitionInvoiceUrl({
        required int projectId,
        required int materialRequisitionId,
        required String uniqueKey,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionInvoice/PullMaterialRequisitionInvoice?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueKey&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullGetMaterialRequisitionInvoiceUrl(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': List<InvoiceModel>.from(
          networkResponse["data"].map((e) => InvoiceModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisitionInvoice({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateMaterialRequisitionInvoiceUrl =
          "MaterialRequisitionInvoice/AddUpdateMaterialRequisitionInvoice";
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateMaterialRequisitionInvoiceUrl,
            fileList,
            body,
          );
      return networkResponse;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteMaterialRequisitionInvoice({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required String uniqueKey,
    required int materialRequisitionId,
  }) async {
    try {
      String deleteMaterialRequisitionInvoiceUrl({
        required int projectId,
        required int materialRequisitionInvoiceId,
        required String uniqueKey,
        required int materialRequisitionId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionInvoice/DeleteMaterialRequisitionInvoice?MaterialRequisitionInvoiceId=$materialRequisitionId&Uniquekey=$uniqueKey&MaterialRequisitionId=$materialRequisitionId&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteMaterialRequisitionInvoiceUrl(
          projectId: projectId,
          materialRequisitionInvoiceId: materialRequisitionInvoiceId,
          uniqueKey: uniqueKey,
          materialRequisitionId: materialRequisitionId,
        ),
      );
      return networkResponse;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateMaterialRequisitionPayment({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateMaterialRequisitionPayment =
          "MaterialRequisitionPayment/AddUpdateMaterialRequisitionPayment";
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateMaterialRequisitionPayment,
            fileList,
            body,
          );
      return networkResponse;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallGetMaterialRequisitionPayment({
    required int projectId,
    required int materialRequisitionInvoiceId,
    required int materialRequisitionId,
  }) async {
    try {
      String pullGetMaterialRequisitionPaymentUrl({
        required int projectId,
        required int materialRequisitionInvoiceId,
        required int materialRequisitionId,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionPayment/PullMaterialRequisitionPayment?MaterialRequisitionInvoiceId=$materialRequisitionInvoiceId&MaterialRequisitionId=$materialRequisitionId&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullGetMaterialRequisitionPaymentUrl(
          projectId: projectId,
          materialRequisitionInvoiceId: materialRequisitionInvoiceId,
          materialRequisitionId: materialRequisitionId,
        ),
      );
      return {
        'data': List<MaterialRequisitionPaymentModel>.from(
          networkResponse["data"].map(
            (e) => MaterialRequisitionPaymentModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniqueKey,
  }) async {
    try {
      String pullFinalizedVendorUrl({
        required int projectId,
        required int materialRequisitionId,
        required String uniqueKey,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "MaterialRequisitionForEnquiry/PullFinalizedVendor?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniqueKey&ProjectId=$projectId";
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullFinalizedVendorUrl(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniqueKey: uniqueKey,
        ),
      );
      return networkResponse;
    } catch (error) {
      rethrow;
    }
  }
}
