import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class LoginDatasource {
  Future<String> apicallIsValidMobileNumber({required String mobileNumber});

  Future<UserModel> apicallIsValidOTP({
    required String mobileNumber,
    required String otp,
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
  }) async {
    try {

      String isValidOTP({
        required String mobileNumber,
        required String otp,
      }) {
        return "Authentication/IsValidOTP?MobileNumber=$mobileNumber&OTP=$otp";
      }

      var networkResponse = await baseClient.getRequestWithoutAuthentication(
        isValidOTP(mobileNumber: mobileNumber, otp: otp),
      );

      return UserModel.fromJson(networkResponse["data"][0]);
    } catch (error) {
      rethrow;
    }
  }
}