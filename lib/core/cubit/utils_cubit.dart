import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'utils_state.dart';

class UtilsCubit extends Cubit<UtilsState> {
  UtilsCubit() : super(UtilsState.initial());
  final utilsRepository = serviceLocator<UtilsRepository>();
  // SEND MODULE BASED OTP FOR VERIFICATION
  Future<void> sendOTPModuleBased({
    required BuildContext context,
    required String mobileNumber,
    required String module,
    required String name,
    String? companyName,
    String? projectName,
    String? source,
  }) async {
    final result = await utilsRepository.sendOTPModuleBased(
      mobileNumber: mobileNumber,
      module: module,
      name: name,
      companyName: companyName,
      projectName: projectName,
      source: source,
    );
    result.fold(
      (failure) {
        showErrorMessage(context, 'OTP Error', failure.message);
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? 'OTP sent successfully',
        );
      },
    );
  }

  //MODULES WORKFLOW APPROVAL
  Future<bool> updateModulesWorkflowApproval({
    required BuildContext context,
    required String moduleName,
    required int id,
    required int projectId,
    required bool isApproved,
    required String remark,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    final result = await utilsRepository.updateModulesWorkflowApproval(
      moduleName: moduleName,
      id: id,
      projectId: projectId,
      isApproved: isApproved,
      remark: remark,
      subId: subId,
      subSubId: subSubId,
      subSubSubId: subSubSubId,
    );
    goRouter.pop();
    final isSuccess = result.fold(
      (failure) {
        showErrorMessage(context, "Approval Failed", failure.message);
        return false;
      },
      (response) {
        showSuccessMessage(
          context,
          subTitle: response['message'] ?? "Updated Successfully",
        );
        return true;
      },
    );
    return isSuccess;
  }

  //  GET APPROVAL LOG HISTORY LIST
  Future<List<ApprovalLogHistory>> getApprovalLogHistory({
    required BuildContext context,
    required int projectId,
    required int id,
    required String moduleName,
    int? subId,
    int? subSubId,
    int? subSubSubId,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));
    var result = await utilsRepository.pullModuleApprovalStatus(
      projectId: projectId,
      moduleName: moduleName,
      id: id,
      subId: subId,
      subSubId: subSubId,
      subSubSubId: subSubSubId,
    );
    goRouter.pop();
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return [];
      },
      (response) {
        final List<ApprovalLogHistory> newData = List<ApprovalLogHistory>.from(
          response['data'] ?? [],
        );
        emit(state.copyWith(isLoading: false));
        return newData;
      },
    );
  }

  Future<String> getMagicLinkWithValidate({
    required BuildContext context,
    required String magicLinkType,
    required int clientRegistrationId,
    Map<String, dynamic>? queryParams,
  }) async {
    DialogHelper.showProcessingOverlay(context);
    emit(state.copyWith(isLoading: true));
    var result = await utilsRepository.getMagicLinkWithValidate(
      clientRegistrationId: clientRegistrationId,
      magicLinkType: magicLinkType,
      queryParams: queryParams,
    );
    goRouter.pop();
    return result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        showErrorMessage(context, 'Error', failure.message);
        return '';
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        return response['data'] ?? '';
      },
    );
  }
}
