import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/features/redevelopment/proposed_plans/data/datasource/proposed_plans.datasource.dart';

abstract interface class ProposedPlansRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProposedPlanList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> addUpdateProposedPlan({
    required Map<String, dynamic> body,
  });
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingProposedPlan({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Either<Failure, Map<String, dynamic>>> copyProposedPlan({
    required Map<String, dynamic> body,
  });
}

class ProposedPlansRepositoryImpl extends ProposedPlansRepository {
  final ProposedPlansDatasource proposedPlansDatasource;

  ProposedPlansRepositoryImpl({required this.proposedPlansDatasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProposedPlanList({
    required int projectId,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await proposedPlansDatasource.apicallPullProposedPlan(
        projectId: projectId,
        queryParams: queryParams,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateProposedPlan({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedPlansDatasource.apicallAddUpdateProposedPlan(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addUpdateBuildingProposedPlan({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    try {
      var result = await proposedPlansDatasource
          .apicallAddUpdateBuildingProposedPlan(body: body, fileList: fileList);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> copyProposedPlan({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await proposedPlansDatasource.apicallCopyProposedPlan(
        body: body,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
