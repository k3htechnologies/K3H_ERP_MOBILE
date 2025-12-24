import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';

abstract interface class LoginDatasource {
  Future<String> apicallIsValidMobileNumber({required String mobileNumber});

  Future<UserModel> apicallIsValidOTP({
    required String mobileNumber,
    required String otp,
  });

  Future<Map<String, dynamic>> apicallIsValidOTPRawResponse({
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

  @override
  Future<Map<String, dynamic>> apicallIsValidOTPRawResponse({
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

      final rawData = networkResponse["data"][0] as Map<String, dynamic>;
      
      // Debug logging
      print('=== RAW API RESPONSE ===');
      print('BankName: ${rawData["BankName"]}');
      print('BankBranchName: ${rawData["BankBranchName"]}');
      print('IFSCCode: ${rawData["IFSCCode"]}');
      print('AccountNo: ${rawData["AccountNo"]}');
      print('EmployeeReportingCycleData: ${rawData["EmployeeReportingCycleData"]}');
      print('Has EmployeeReportingCycleData: ${rawData.containsKey("EmployeeReportingCycleData")}');
      print('EmployeeReportingCycleData type: ${rawData["EmployeeReportingCycleData"]?.runtimeType}');
      print('EmployeeReportingCycleData is null: ${rawData["EmployeeReportingCycleData"] == null}');
      print('EmployeeReportingCycleData isEmpty: ${(rawData["EmployeeReportingCycleData"] as List?)?.isEmpty ?? "N/A"}');
      print('=======================');
      
      return rawData;
    } catch (error) {
      rethrow;
    }
  }
}