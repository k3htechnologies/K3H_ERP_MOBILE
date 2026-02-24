import 'package:fpdart/fpdart.dart';
import 'package:k3h_erp_app/core/error_handler.dart';
import 'package:k3h_erp_app/core/failure.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/features/login/data/datasource/login.datasource.dart';

abstract interface class LoginRepository {
  Future<Either<Failure, String>> loginUser({required String mobileNumber});

  // ✅ NEW: Send OTP method
  Future<Either<Failure, Map<String, dynamic>>> sendOTP({
    String? mobileNumber,
    String? module,
  });

  Future<Either<Failure, UserModel>> validateOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  });

  Future<Either<Failure, Map<String, dynamic>>> validateOTPRawResponse({
    required String mobileNumber,
    required String otp,
  });

  Future<Either<Failure, String>> setMpin({required Map<String, dynamic> body});
}

class LoginRepositoryImpl implements LoginRepository {
  final LoginDatasource loginDatasource;

  LoginRepositoryImpl({required this.loginDatasource});

  @override
  Future<Either<Failure, String>> loginUser({
    required String mobileNumber,
  }) async {
    try {
      var result = await loginDatasource.apicallIsValidMobileNumber(
        mobileNumber: mobileNumber,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOTP({
    String? mobileNumber,
    String? module,
  }) async {
    try {
      var result = await loginDatasource.apiCallSendOTP(
        mobileNumber: mobileNumber,
        module: module,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, UserModel>> validateOTP({
    required String mobileNumber,
    required String otp,
    required String type,
  }) async {
    try {
      var result = await loginDatasource.apicallIsValidOTP(
        mobileNumber: mobileNumber,
        otp: otp,
        type:type
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateOTPRawResponse({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      var result = await loginDatasource.apicallIsValidOTPRawResponse(
        mobileNumber: mobileNumber,
        otp: otp,
      );
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }

  @override
  Future<Either<Failure, String>> setMpin({
    required Map<String, dynamic> body,
  }) async {
    try {
      var result = await loginDatasource.apicallToSetMPIN(body: body);
      return right(result);
    } catch (error) {
      return left(Failure(message: ErrorHandler.getErrorMessage(error)));
    }
  }
}
