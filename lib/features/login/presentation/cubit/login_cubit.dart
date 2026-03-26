import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/approval_log_history.model.dart';
import 'package:k3h_erp_app/core/models/module.model.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/data/repository/login.repository.dart';
import 'package:k3h_erp_app/features/masters/employee_master/data/repository/employee_master.repository.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());

  final loginRepository = serviceLocator<LoginRepository>();
  final utilsRepository = serviceLocator<UtilsRepository>();
  final employeeMasterRepository = serviceLocator<EmployeeMasterRepository>();

  final LocalStorageManager localStorage = LocalStorageManager();

  Timer? _resendTimer;

  // RESET
  void resetState() {
    emit(LoginState.initial());
  }

  // START TIMER
  void startResendTimer() {
    _resendTimer?.cancel();

    int seconds = 60;

    emit(state.copyWith(resendSeconds: seconds, canResend: false));

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 1) {
        seconds--;
        emit(state.copyWith(resendSeconds: seconds));
      } else {
        timer.cancel();
        emit(state.copyWith(resendSeconds: 0, canResend: true));
      }
    });
  }

  // ----------------------------- SEND OTP -----------------------------------

  Future<void> sendOTP(BuildContext context, String mobileNumber) async {
    try {
      DialogHelper.showProcessingOverlay(context);
      emit(state.copyWith(isLoading: true, stateType: StateType.sendOTP));

      final result = await loginRepository.loginUser(
        mobileNumber: mobileNumber,
      );

      goRouter.pop();

      result.fold(
        (failure) {
          showErrorMessage(context, "Login Failed", failure.message);
          emit(state.copyWith(isLoading: false, isSendOtp: false));
        },
        (message) async {
          final isOtp = message.trim().toLowerCase().contains('otp');

          emit(
            state.copyWith(
              isLoading: false,
              isSendOtp: true,
              message: message,
              isOtpFlow: isOtp,
              stateType: StateType.sendOTP,
            ),
          );
          startResendTimer();
          await showSuccessMessage(context, subTitle: message);
        },
      );
    } catch (e) {
      goRouter.pop();
      if (context.mounted) {
        showErrorMessage(context, "Login Failed", e.toString());
      }
      emit(state.copyWith(isLoading: false, isSendOtp: false));
    }
  }

  // ------------------------------ VALIDATE OTP ------------------------------

  Future<void> validateOtp(
    BuildContext context,
    String mobileNumber,
    String otp,
    String type,
  ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await loginRepository.validateOTP(
      mobileNumber: mobileNumber,
      otp: otp,
      type: type,
    );

    result.fold(
      (failure) {
        goRouter.pop();
        showErrorMessage(context, "Login Failed", failure.message);
      },
      (user) async {
        goRouter.pop();
        emit(state.copyWith(user: user));

        // SAVE USER
        await localStorage.setString(StorageKey.authorizationToken, user.token);
        await localStorage.setString(StorageKey.userUniqueKey, user.uniqueKey);

        // 🚀 RUN BOTH IN PARALLEL
        await Future.wait([
          _fetchAndStoreCompleteEmployeeData(user),
          if (context.mounted) fetchAndStoreMenu(context, user),
        ]);

        // NAVIGATE
        if (context.mounted) {
          goRouter.go(AppRoutes.dashboardScreen);
          showSuccessMessage(context, subTitle: "Login Successfully");
        }
      },
    );
  }

  Future<void> fetchAndStoreMenu(BuildContext context, UserModel user) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await utilsRepository.getMenu(employeeId: user.employeeId);
    await result.fold(
      (failure) async {
        goRouter.pop();
        showErrorMessage(context, "Menu Error", failure.message);
      },
      (data) async {
        final menuList = data["menuData"] as List<ModuleModel>;

        localStorage.setString(
          StorageKey.menu,
          jsonEncode(menuList.map((e) => e.toJson()).toList()),
        );

        await updateRouteAuthorization(menuList);
        goRouter.pop();
      },
    );
  }

  // ------------------------------ SET MPIN ------------------------------

  Future<void> sepMpin({
    required BuildContext context,
    required String pin,
    required int employeeId,
    required String uniqueKey,
  }) async {
    try {
      Map<String, dynamic> body = {
        "EmployeeId": employeeId,
        "UniqueKey": uniqueKey,
        "MPIN": pin,
      };

      final result = await loginRepository.setMpin(body: body);

      result.fold(
        (failure) {
          goRouter.pop();
          showErrorMessage(context, "Error", failure.message);
        },
        (message) async {
          showSuccessMessage(context, subTitle: message);

          await localStorage.removeAll();
          goRouter.replace(AppRoutes.splashScreen);
        },
      );
    } catch (e) {
      debugPrint("Jay Shree Ram!!!");
    }
  }

  // ------------------------------ FETCH COMPLETE EMPLOYEE DATA ------------------------------

  Future<void> _fetchAndStoreCompleteEmployeeData(UserModel loginUser) async {
    try {
      // Fetch complete employee data using employee master API
      final result = await employeeMasterRepository.getEmployeeMasterList(
        pageNumber: 1,
        pageSize: 1,
        queryParams: {"EmployeeId": loginUser.employeeId.toString()},
      );

      result.fold(
        (failure) async {
          // Fallback to login user data if fetch fails
          await localStorage.setString(
            StorageKey.currentUser,
            jsonEncode(loginUser),
          );
        },
        (response) async {
          final employeeList = response['data'] as List<UserModel>;
          if (employeeList.isNotEmpty) {
            final completeEmployee = employeeList.first;

            final mergedUserData = {
              ...completeEmployee.toJson(),
              "Token": loginUser.token, // Preserve token from login
              "ModuleData":
                  loginUser.moduleData
                      .map((e) => e.toJson())
                      .toList(), // Preserve module data
              "ProjectData":
                  loginUser.projectData
                      .map((e) => e.toJson())
                      .toList(), // Preserve project data
            };

            await localStorage.setString(
              StorageKey.currentUser,
              jsonEncode(mergedUserData),
            );
          } else {
            await localStorage.setString(
              StorageKey.currentUser,
              jsonEncode(loginUser),
            );
          }
        },
      );
    } catch (e) {
      await localStorage.setString(
        StorageKey.currentUser,
        jsonEncode(loginUser),
      );
    }
  }

  // ------------------------------ EMPLOYEE MENU ------------------------------

  Future<UserModel?> getEmployeeWithMenuList() async {
    final result = await utilsRepository.pullEmployeeWithMenuList();

    return result.fold((failure) => null, (res) => res);
  }

  // <---- SEND MODULE BASED OTP FOR VERIFICATION ---->
  Future<void> sendOTPModuleBased({
    required BuildContext context,
    String? mobileNumber,
    required String module,
  }) async {
    final result = await loginRepository.sendOTPModuleBased(
      mobileNumber: mobileNumber,
      module: module,
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

  // <----MODULES WORKFLOW APPROVAL  ---->
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
}
