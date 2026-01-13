import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/datasource/proposed_plans.datasource.dart';

abstract interface class ProposedPlansRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProposedPlanList({
    required int projectId,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateProposedPlans({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
}

class ProposedPlansRepositoryImpl extends ProposedPlansRepository {
  final ProposedPlansDatasource proposedPlansDatasource;

  ProposedPlansRepositoryImpl({required this.proposedPlansDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProposedPlanList({
    required int projectId,
  }) async {
    try {
      var result = await proposedPlansDatasource.apicallPullProposedPlan(
        projectId: projectId,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProposedPlans({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await proposedPlansDatasource.apicallAddUpdateProposedPlans(
        body: body,
        fileList: fileList,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
