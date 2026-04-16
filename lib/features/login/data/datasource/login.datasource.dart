import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class LoginDatasource {
  Future<String> apicallIsValidMobileNumber({required String mobileNumber});

  Future<UserModel> apicallIsValidOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  });

  Future<Map<String, dynamic>> apicallIsValidOTPRawResponse({
    required String mobileNumber,
    required String otp,
  });

  Future<String> apicallToSetMPIN({required Map<String, dynamic> body});

  Future<String> apicallRegisterDeviceToken({
    required Map<String, dynamic> body,
  });
}

class LoginDatasourceImpl implements LoginDatasource {
  final baseClient = BaseClient();

  @override
  Future<String> apicallIsValidMobileNumber({
    required String mobileNumber,
  }) async {
    try {
      String isValidMobileNumber({required String mobileNumber}) {
        return "Authentication/IsValidMobileNumber?MobileNumber=$mobileNumber";
      }

      var networkResponse = await baseClient.getRequestWithoutAuthentication(
        isValidMobileNumber(mobileNumber: mobileNumber),
      );
      return networkResponse["message"];
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UserModel> apicallIsValidOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  }) async {
    try {
      String isValidOTP({required String mobileNumber, required String otp}) {
        return "Authentication/IsValidOTP?MobileNumber=$mobileNumber&OTP=$otp&Type=$type";
      }

      var networkResponse = await baseClient.getRequestWithoutAuthentication(
        isValidOTP(mobileNumber: mobileNumber, otp: otp),
      );

      return UserModel.fromJson(networkResponse["data"][0]);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallIsValidOTPRawResponse({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      String isValidOTP({required String mobileNumber, required String otp}) {
        return "Authentication/IsValidOTP?MobileNumber=$mobileNumber&OTP=$otp";
      }

      var networkResponse = await baseClient.getRequestWithoutAuthentication(
        isValidOTP(mobileNumber: mobileNumber, otp: otp),
      );

      final rawData = networkResponse["data"][0] as Map<String, dynamic>;

      return rawData;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<String> apicallToSetMPIN({required Map<String, dynamic> body}) async {
    try {
      String setMpinUrl = "Employee/SetEmployeeMPIN";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        setMpinUrl,
        body,
      );

      return networkResponse["message"];
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<String> apicallRegisterDeviceToken({
    required Map<String, dynamic> body,
  }) async {
    try {
      String registerDeviceToken = "DeviceToken/RegisterDeviceToken";

      var networkResponse = await baseClient.postRequestWithAuthentication(
        registerDeviceToken,
        body,
      );

      return networkResponse["message"];
    } catch (error) {
      rethrow;
    }
  }
}
