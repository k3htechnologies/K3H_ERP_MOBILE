import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/core/repository/utils.repository.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/login/data/repository/login.repository.dart';
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

  final LocalStorageManager localStorage = LocalStorageManager();

  // RESET
  void resetState() {
    emit(LoginState.initial());
  }

  // ----------------------------- SEND OTP -----------------------------------

  Future<void> sendOTP(BuildContext context, String mobileNumber) async {
    try {
      DialogHelper.showProcessingOverlay(context);
      emit(state.copyWith(isLoading: true, stateType: StateType.sendOTP));

      final result = await loginRepository.loginUser(mobileNumber: mobileNumber);

      goRouter.pop();

      result.fold(
            (failure) {
          showErrorMessage(context, "Login Failed", failure.message);
          emit(state.copyWith(isLoading: false, isSendOtp: false));
        },
            (message) async {
          emit(state.copyWith(isLoading: false, isSendOtp: true));
          await showSuccessMessage(context, subTitle: message);

          goRouter.pushNamed(
            AppRoutes.otp,
            queryParameters: {
              "mobileNumber": Uri.encodeComponent(
                EncryptionManager.encryptData(mobileNumber),
              ),
            },
          );
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
      ) async {
    DialogHelper.showProcessingOverlay(context);

    final result = await loginRepository.validateOTP(
      mobileNumber: mobileNumber,
      otp: otp,
    );

    result.fold(
          (failure) {
        goRouter.pop();
        showErrorMessage(context, "Login Failed", failure.message);
      },
          (user) async {
        goRouter.pop();
        emit(state.copyWith(user: user));

        // SAVE USER + TOKEN
        localStorage.setString(StorageKey.currentUser, jsonEncode(user));
        localStorage.setString(StorageKey.authorizationToken, user.token);
        localStorage.setString(StorageKey.userUniqueKey, user.uniqueKey);


        // ROUTING DECISION
        if (user.projectData.isNotEmpty) {
          goRouter.go(
            "${AppRoutes.projectList}?projects=${Uri.encodeComponent(
              EncryptionManager.encryptData(jsonEncode(user.projectData)),
            )}",
          );
        } else {
          // SAVE MENU
          localStorage.setString(StorageKey.menu, jsonEncode(user.moduleData));

          // UPDATE ROUTE AUTH
          await updateRouteAuthorization(user.moduleData);

          goRouter.go(AppRoutes.dashboardScreen);
        }
      },
    );
  }

  // ------------------------------ EMPLOYEE MENU ------------------------------

  Future<UserModel?> getEmployeeWithMenuList() async {
    final result = await utilsRepository.pullEmployeeWithMenuList();

    return result.fold(
          (failure) => null,
          (res) => res,
    );
  }
}
