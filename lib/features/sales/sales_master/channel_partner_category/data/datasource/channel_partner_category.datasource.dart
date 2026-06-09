import 'package:k3h_erp_app/features/sales/sales_master/channel_partner_category/data/model/channel_partner_category.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ChannelPartnerCategoryDatasource {
  Future<Map<String, dynamic>> apicallPullChannelPartnerCategory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateChannelPartnerCategory({
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> apicallPullChannelPartnerCategoryForExport({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });
}

class ChannelPartnerCategoryDatasourceImpl
    extends ChannelPartnerCategoryDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullChannelPartnerCategory({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullChannelPartnerCategoryUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ChannelPartnerCategory/PullChannelPartnerCategory?ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullChannelPartnerCategoryUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': List<ChannelPartnerCategoryModel>.from(
          networkResponse["data"].map(
            (e) => ChannelPartnerCategoryModel.fromJson(e),
          ),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallPullChannelPartnerCategory(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateChannelPartnerCategory({
    required Map<String, dynamic> body,
  }) async {
    String url = "ChannelPartnerCategory/AddUpdateChannelPartnerCategory";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        url,
        body,
      );

      return {
        'data': List<ChannelPartnerCategoryModel>.from(
          networkResponse["data"].map(
            (e) => ChannelPartnerCategoryModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallAddUpdateChannelPartnerCategory(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullChannelPartnerCategoryForExport({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullChannelPartnerCategoryExportUrl({
      required int projectId,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ChannelPartnerCategory/PullChannelPartnerCategory?ProjectId=$projectId";

      queryParams?.forEach((key, value) {
        url += "&$key=$value";
      });

      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullChannelPartnerCategoryExportUrl(
          projectId: projectId,
          queryParams: queryParams,
        ),
      );

      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return await apicallPullChannelPartnerCategoryForExport(
          projectId: projectId,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
