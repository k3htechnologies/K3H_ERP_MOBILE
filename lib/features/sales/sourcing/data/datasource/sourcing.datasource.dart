import 'package:k3h_erp_app/features/sales/sourcing/data/model/sourcing.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class SourcingDatasource {
  Future<Map<String, dynamic>> apicallPullSourcing({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  });
}

class SourcingDatasourceImpl extends SourcingDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullSourcing({
    required int pageSize,
    required int pageNumber,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullSourcingUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "ChannelPartnerSourcing/PullChannelPartnerSourcing?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullSourcingUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<SourcingModel>.from(
          networkResponse["data"].map((e) => SourcingModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullSourcing(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
