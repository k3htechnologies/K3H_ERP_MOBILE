import 'package:k3h_erp_app/features/sales/classification_parameters/data/model/classification_paramerter.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ClassificationParametersDatasource {
  Future<Map<String, dynamic>> apiCallPullClassificationParameter({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> apicallAddUpdateClassificationParameter({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteClassificationParameter({
    required int classificationParameterId,
    required String uniqueKey,
    required int projectId,
  });
  Future<Map<String, dynamic>> apicallPullClassificationParameterForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ClassificationParametersDatasourceImpl
    extends ClassificationParametersDatasource {
  final BaseClient baseClient = BaseClient();

  /// FETCH CLASSIFICATION PARAMETER LIST
  @override
  Future<Map<String, dynamic>> apiCallPullClassificationParameter({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullClassificationParameterUrl({
      required int pageSize,
      required int pageNumber,
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ClassificationParameter/PullClassificationParameter?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullClassificationParameterUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          projectId: projectId,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<ClassificationParameterModel>.from(
          networkResponse["data"].map(
            (e) => ClassificationParameterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apiCallPullClassificationParameter(
          pageNumber: pageNumber,
          pageSize: pageSize,
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateClassificationParameter({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateDepartmentUrl =
          "ClassificationParameter/AddUpdateClassificationParameter";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateDepartmentUrl,
        body,
      );
      return {
        'data': List<ClassificationParameterModel>.from(
          networkResponse["data"].map(
            (e) => ClassificationParameterModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateClassificationParameter(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteClassificationParameter({
    required int classificationParameterId,
    required String uniqueKey,
    required int projectId,
  }) async {
    String deleteClassificationParameterUrl({
      required int classificationParameterId,
      required String uniqueKey,
    }) {
      return "ClassificationParameter/DeleteClassificationParameter?ClassificationParameterId=$classificationParameterId&Uniquekey=$uniqueKey&ProjectId=$projectId";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteClassificationParameterUrl(
          classificationParameterId: classificationParameterId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteClassificationParameter(
          classificationParameterId: classificationParameterId,
          uniqueKey: uniqueKey,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullClassificationParameterForExport({
    required int pageNumber,
    required int pageSize,
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullClassificationParameterExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ClassificationParameter/PullClassificationParameter?PageSize=$pageSize&PageNumber=$pageNumber&ProjectId=$projectId";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullClassificationParameterExportUrl(
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
        apicallPullClassificationParameterForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
          projectId: projectId,
        );
      }
      rethrow;
    }
  }
}
