import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/model/proposed_plans.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class ProposedPlansDatasource {
  Future<Map<String, dynamic>> apicallPullProposedPlan({
    required int projectId,
  });

  Future<Map<String, dynamic>> apicallAddUpdateProposedPlans({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class ProposedPlansDatasourceImpl implements ProposedPlansDatasource {
  final baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullProposedPlan({
    required int projectId,
  }) async {
    String pullProposedPlansUrl({required int projectId}) {
      String url = "ProposedOffer/PullProposedPlan?ProjectId=$projectId";
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullProposedPlansUrl(projectId: projectId),
      );
      return {
        'data': List<ProposedPlansModel>.from(
          networkResponse["data"].map((e) => ProposedPlansModel.fromJson(e)),
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
  Future<Map<String, dynamic>> apicallAddUpdateProposedPlans({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      String addUpdateDepartmentUrl = "ProposedOffer/AddUpdateProposedPlan";

      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(
            addUpdateDepartmentUrl,
            fileList,
            body,
          );
      return {
        'data': List<ProposedPlansModel>.from(
          networkResponse["data"].map((e) => ProposedPlansModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallAddUpdateProposedPlans(body: body, fileList: fileList);
      }
      rethrow;
    }
  }
}
