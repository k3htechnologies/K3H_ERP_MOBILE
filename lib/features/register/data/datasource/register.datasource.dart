import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class RegisterDatasource {
  Future<UserModel> apicallIsValidOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  });

  Future<Map<String, dynamic>> apicallIsValidOTPRawResponse({
    required String mobileNumber,
    required String otp,
  });
}

class RegisterDatasourceImpl implements RegisterDatasource {
  final baseClient = BaseClient();

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
}
