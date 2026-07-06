import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:k3h_erp_app/core/base_state.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
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
        emit(state.copyWith(user: user));

        // SAVE USER
        await localStorage.setString(StorageKey.authorizationToken, user.token);
        await localStorage.setString(StorageKey.userUniqueKey, user.uniqueKey);

        //  RUN BOTH IN PARALLEL
        await _fetchAndStoreCompleteEmployeeData(user);

        if (context.mounted) {
          await fetchAndStoreMenu(context, user);
        }

        // ` REGISTER DEVICE TOKEN
        final currentToken = localStorage.getString(StorageKey.fcmToken) ?? "";

        final oldToken = localStorage.getString(StorageKey.oldFcmToken) ?? "";

        if (currentToken.isNotEmpty && currentToken != oldToken) {
          if (context.mounted) {
            registerDeviceToken(
              context: context,
              oldToken: oldToken,
              newToken: currentToken,
            );
          }

          localStorage.setString(StorageKey.oldFcmToken, currentToken);
        }

        unawaited(_loadAddressInBackground());

        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (context.mounted) await _handleLocationPermissionFlow(context);
        }

        // NAVIGATE
        if (context.mounted) {
          goRouter.pop();
          goRouter.go(AppRoutes.dashboardScreen);
          showSuccessMessage(context, subTitle: "Login Successfully");
        }
      },
    );
  }

  Future<void> _handleLocationPermissionFlow(BuildContext context) async {
    if (context.mounted) {
      await showLocationDisclosure(context);
    }

    // Show actual iOS permission popup
    await Geolocator.requestPermission();
  }

  Future<void> showLocationDisclosure(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text("Location Access"),
          content: const Text(
            "Your location is used for attendance marking "
            "and work-related field activity while using the app.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAddressInBackground() async {
    try {
      final utilsRepository = serviceLocator<UtilsRepository>();

      final result = await utilsRepository.getAddressMaster();

      result.fold(
        (failure) {
          debugPrint("Address preload failed");
        },
        (data) {
          debugPrint("Address cached successfully");
        },
      );
    } catch (e) {
      debugPrint("Address preload error: $e");
    }
  }

  Future<void> fetchAndStoreMenu(BuildContext context, UserModel user) async {
    final result = await utilsRepository.getMenu(employeeId: user.employeeId);
    await result.fold(
      (failure) async {
        showErrorMessage(context, "Menu Error", failure.message);
      },
      (data) async {
        final menuList = data["menuData"] as List<ModuleModel>;

        localStorage.setString(
          StorageKey.menu,
          jsonEncode(menuList.map((e) => e.toJson()).toList()),
        );

        await updateRouteAuthorization(menuList);
      },
    );
  }

  // ------------------------------ SET MPIN ------------------------------
  //? Unused Function
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
      debugPrint(e.toString());
    }
  }

  // REGISTER DEVICE TOKEN
  Future<void> registerDeviceToken({
    required BuildContext context,
    required String oldToken,
    required String newToken,
  }) async {
    try {
      Map<String, dynamic> body = {
        "OldDeviceToken": oldToken,
        "LatestDeviceToken": newToken,
      };

      final result = await loginRepository.registerDeviceToken(body: body);

      result.fold(
        (failure) {
          debugPrint(failure.message);
        },
        (message) async {
          debugPrint(message);
        },
      );
    } catch (e) {
      debugPrint(e.toString());
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
            jsonEncode(loginUser.toJson()),
          );
        },
        (response) async {
          final employeeList = response['data'] as List<UserModel>;
          if (employeeList.isNotEmpty) {
            final completeEmployee = employeeList.first;

            final mergedUser = completeEmployee.copyWith(
              token: loginUser.token,
              moduleData: loginUser.moduleData,
              projectData: loginUser.projectData,
            );

            await localStorage.setString(
              StorageKey.currentUser,
              jsonEncode(mergedUser.toJson()),
            );
          } else {
            await localStorage.setString(
              StorageKey.currentUser,
              jsonEncode(loginUser.toJson()),
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
}
