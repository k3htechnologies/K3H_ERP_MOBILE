import 'package:k3h_erp_app/features/masters/pay_roll_master/branch_association_master/data/model/branch_association_master.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class BranchAssociationMasterDatasource {
  Future<Map<String, dynamic>> apicallPullBranchAssociation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateBranchAssociation({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallDeleteBranchAssociation({
    required int branchAssociationId,
    required String uniqueKey,
  });
}

class BranchAssociationMasterDatasourceImpl
    extends BranchAssociationMasterDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullBranchAssociation({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullBranchAssociationsUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "BranchAssociations/PullBranchAssociations?PageSize=$pageSize&PageNumber=$pageNumber";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullBranchAssociationsUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data':
            networkResponse['data'].runtimeType == String
                ? networkResponse['data']
                : List<BranchAssociationModel>.from(
                  networkResponse['data'].map(
                    (e) => BranchAssociationModel.fromJson(e),
                  ),
                ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBranchAssociation({
    required Map<String, dynamic> body,
  }) async {
    String addUpdateBranchAssociationUrl =
        "BranchAssociations/AddUpdateBranchAssociations";

    try {
      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateBranchAssociationUrl,
        body,
      );
      return {
        'data': List<BranchAssociationModel>.from(
          networkResponse['data'].map(
            (e) => BranchAssociationModel.fromJson(e),
          ),
        ),
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteBranchAssociation({
    required int branchAssociationId,
    required String uniqueKey,
  }) async {
    String deleteBranchAssociation({
      required int branchAssociationId,
      required String uniqueKey,
    }) {
      return "BranchAssociations/DeleteBranchAssociations?BranchAssociationsId=$branchAssociationId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteBranchAssociation(
          branchAssociationId: branchAssociationId,
          uniqueKey: uniqueKey,
        ),
      );
      return {
        'data': networkResponse['data'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      rethrow;
    }
  }
}
