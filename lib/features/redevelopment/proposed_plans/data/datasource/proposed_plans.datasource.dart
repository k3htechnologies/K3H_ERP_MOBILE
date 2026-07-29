import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';

abstract interface class ProposedPlansDatasource {
  Future<Map<String, dynamic>> apicallPullProposedPlan({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProposedPlan({
    required Map<String, dynamic> body,
  });
  Future<Map<String, dynamic>> apicallAddUpdateBuildingProposedPlan({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallCopyProposedPlan({
    required Map<String, dynamic> body,
  });
}

class ProposedPlansDatasourceImpl implements ProposedPlansDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProposedPlan({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullProposedPlansUrl({required int projectId}) {
      String url = "ProposedOffer/PullProposedPlan?ProjectId=$projectId";
      url += queryParamsFormatter(queryParams: queryParams);
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProposedPlansUrl(projectId: projectId),
      );
      return {
        'data': List<ProposedPlanBuilding>.from(
          networkResponse["data"].map((e) => ProposedPlanBuilding.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullProposedPlan(projectId: projectId);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateProposedPlan({
    required Map<String, dynamic> body,
  }) async {
    try {
      String addUpdateProposedPlanUrl = "ProposedOffer/AddUpdateProposedPlan";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        addUpdateProposedPlanUrl,
        body,
      );

      return {
        'data': List<ProposedPlanBuilding>.from(
          networkResponse["data"].map((e) => ProposedPlanBuilding.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateProposedPlan(body: body);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateBuildingProposedPlan({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateDepartmentUrl =
          "ProposedOffer/AddUpdateBuildingProposedPlan";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateDepartmentUrl,
            fileList,
            body,
          );
      return {
        'data': List<ProposedPlanBuilding>.from(
          networkResponse["data"].map((e) => ProposedPlanBuilding.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateBuildingProposedPlan(
          body: body,
          fileList: fileList,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallCopyProposedPlan({
    required Map<String, dynamic> body,
  }) async {
    try {
      String copyProposedPlanUrl = "ProposedOffer/CopyProposedPlan";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        copyProposedPlanUrl,
        body,
      );

      return {
        'data': List<ProposedPlanBuilding>.from(
          networkResponse["data"].map((e) => ProposedPlanBuilding.fromJson(e)),
        ),
        'message': networkResponse['message'],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateProposedPlan(body: body);
      }
      rethrow;
    }
  }
}
