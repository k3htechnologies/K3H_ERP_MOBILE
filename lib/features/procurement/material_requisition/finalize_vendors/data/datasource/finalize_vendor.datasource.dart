import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor.model.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/finalize_vendors/data/model/finalize_vendor_for_compare.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class FinalizeVendorDatasource {
  Future<Map<String, dynamic>> apicallPullVendorForEnquiry({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });
  Future<Map<String, dynamic>> apiCallPullSelectedVendorForEnquiry({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });
  Future<Map<String, dynamic>> apiCallPullFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  });
  Future<Map<String, dynamic>> apiCallAddVendorForEnquiry({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallAddFinalizedVendor({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallToUpdateMaterialRequisitionQuotation({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apiCallPullSelectedVendorForEnquiryForCompare({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
    Map<String, dynamic>? queryParams,
  });
}

class FinalizeVendorDatasourceImpl implements FinalizeVendorDatasource {
  final baseClient = BaseClient();
  @override
  Future<Map<String, dynamic>> apicallPullVendorForEnquiry({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      String pullVendorForEnquiryUrl =
          "MaterialRequisitionForEnquiry/PullVendorForEnquiry?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniquekey&ProjectId=$projectId";

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullVendorForEnquiryUrl,
      );
      return {
        'data': List<RequisitionVendorModel>.from(
          networkResponse["data"].map(
            (e) => RequisitionVendorModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullSelectedVendorForEnquiry({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      String selectedVendorForEnquiryUrl =
          'MaterialRequisitionForEnquiry/PullSelectedVendorForEnquiry?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniquekey&ProjectId=$projectId';
      var networkResponse = await baseClient.getRequestWithAuthentication(
        selectedVendorForEnquiryUrl,
      );
      return {
        'data': List<RequisitionVendorModel>.from(
          networkResponse["data"].map(
            (e) => RequisitionVendorModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullFinalizedVendor({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
  }) async {
    try {
      String selectedVendorForEnquiryUrl =
          'MaterialRequisitionForEnquiry/PullFinalizedVendor?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniquekey&ProjectId=$projectId';
      var networkResponse = await baseClient.getRequestWithAuthentication(
        selectedVendorForEnquiryUrl,
      );
      return {
        'data': List<RequisitionVendorModel>.from(
          networkResponse["data"].map(
            (e) => RequisitionVendorModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddVendorForEnquiry({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addVendorForEnquiryUrl =
          "MaterialRequisitionForEnquiry/AddVendorForEnquiry";
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addVendorForEnquiryUrl,
        body,
      );

      return {
        'data': List<RequisitionVendorModel>.from(
          networkResponse["data"].map(
            (e) => RequisitionVendorModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallAddFinalizedVendor({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addFinalizedVendorUrl =
          "MaterialRequisitionForEnquiry/AddFinalizedVendor";
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addFinalizedVendorUrl,
        body,
      );
      return {
        'data': List<RequisitionVendorModel>.from(
          networkResponse["data"].map(
            (e) => RequisitionVendorModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallToUpdateMaterialRequisitionQuotation({
    required Map<String, dynamic> body,
  }) async {
    try {
      String updateMaterialRequisitionQuotationUrl =
          "MaterialRequisitionQuotation/AddUpdateMaterialRequisitionQuotation";
      var networkResponse = await baseClient.postRequestWithAuthentication(
        updateMaterialRequisitionQuotationUrl,
        body,
      );
      return {
        'data': List<MaterialRequisitionQuotationTerms>.from(
          networkResponse["data"]
              .map((e) => MaterialRequisitionQuotationTerms.fromJson(e))
              .toList(),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apiCallPullSelectedVendorForEnquiryForCompare({
    required int projectId,
    required int materialRequisitionId,
    required String uniquekey,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullSelectedVendorForEnquiryForCompareUrl({
        required int projectId,
        required int materialRequisitionId,
        required String uniquekey,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            'MaterialRequisitionForEnquiry/PullSelectedVendorForEnquiry?MaterialRequisitionId=$materialRequisitionId&Uniquekey=$uniquekey&ProjectId=$projectId';
        queryParams?.forEach((key, value) => url += "&$key=$value");
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSelectedVendorForEnquiryForCompareUrl(
          projectId: projectId,
          materialRequisitionId: materialRequisitionId,
          uniquekey: uniquekey,
        ),
      );
      return {
        'data': List<FinalizeVendorForComparisonModel>.from(
          networkResponse["data"]
              .map((e) => FinalizeVendorForComparisonModel.fromJson(e))
              .toList(),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }
}
