import 'package:k3h_erp_app/core/models/company.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/model/company_bank.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class CompanyMasterDatasource {
  Future<Map<String, dynamic>> apicallPullCompanyMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apicallAddUpdateCompany({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteCompany({
    required int companyId,
    required String uniqueKey,
  });

  Future<Map<String, dynamic>> apicallPullCompanyMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallPullCompanyWithBankDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  });

  Future<Map<String, dynamic>> apicallAddUpdateCompanyWithBankDetails({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });

  Future<Map<String, dynamic>> apicallDeleteCompanyWithBankDetails({
    required int companyId,
    required int companyWithBankDetailsId,
    required String uniqueKey,
  });
}

class CompanyMasterDataSourceImp implements CompanyMasterDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullCompanyMaster({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    try {
      String pullCompanyUrl({
        required int pageSize,
        required int pageNumber,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "Company/PullCompany?PageSize=$pageSize&PageNumber=$pageNumber";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompanyUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<CompanyModel>.from(
          networkResponse["data"].map((e) => CompanyModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCompanyMaster(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCompany({
    required int companyId,
    required String uniqueKey,
  }) async {
    try {
      String deleteCompanyUrl({
        required int companyId,
        required String uniqueKey,
      }) {
        return "Company/DeleteCompany?CompanyId=$companyId&Uniquekey=$uniqueKey";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteCompanyUrl(companyId: companyId, uniqueKey: uniqueKey),
      );
      return {
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteCompany(companyId: companyId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateCompany({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateCompanyUrl = "Company/AddUpdateCompany";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateCompanyUrl,
            fileList,
            body,
          );
      return {
        'data': List<CompanyModel>.from(
          networkResponse["data"].map((e) => CompanyModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateCompany(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullCompanyMasterForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String pullCompanyExportUrl({
        required int pageSize,
        required int pageNumber,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "Company/PullCompany?PageSize=$pageSize&PageNumber=$pageNumber";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompanyExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCompanyMasterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullCompanyWithBankDetails({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? query,
  }) async {
    try {
      String pullCompanyWithBankDetailsUrl({
        required int pageSize,
        required int pageNumber,
        Map<String, dynamic>? queryParams,
      }) {
        String url =
            "Company/PullCompanyWithBankDetails?PageSize=$pageSize&PageNumber=$pageNumber";
        url += queryParamsFormatter(queryParams: queryParams);
        return url;
      }

      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullCompanyWithBankDetailsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: query,
        ),
      );
      return {
        'data': List<CompanyBankModel>.from(
          networkResponse["data"].map((e) => CompanyBankModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullCompanyWithBankDetails(
          pageNumber: pageNumber,
          pageSize: pageSize,
          query: query,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteCompanyWithBankDetails({
    required int companyId,
    required String uniqueKey,
    required int companyWithBankDetailsId,
  }) async {
    try {
      String deleteCompanyWithBankDetailsUrl({
        required int companyId,
        required String uniqueKey,
        required int companyWithBankDetailsId,
      }) {
        return "Company/DeleteCompanyWithBankDetails?CompanyId=$companyId&CompanyWithBankDetailsId=$companyWithBankDetailsId&Uniquekey=$uniqueKey";
      }

      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteCompanyWithBankDetailsUrl(
          companyId: companyId,
          uniqueKey: uniqueKey,
          companyWithBankDetailsId: companyWithBankDetailsId,
        ),
      );
      return {
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallDeleteCompanyWithBankDetails(
          companyId: companyId,
          uniqueKey: uniqueKey,
          companyWithBankDetailsId: companyWithBankDetailsId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateCompanyWithBankDetails({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateCompanyWithBankDetailsUrl =
          "Company/AddUpdateCompanyWithBankDetails";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateCompanyWithBankDetailsUrl,
            fileList,
            body,
          );
      return {
        'data': List<CompanyBankModel>.from(
          networkResponse["data"].map((e) => CompanyBankModel.fromJson(e)),
        ),
        'message': networkResponse["message"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateCompanyWithBankDetails(body: body, fileList: fileList);
      }
      rethrow;
    }
  }
}
